import 'package:drift/drift.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

import '../db/app_db.dart';
import '../state/active_user_store.dart';

class CopyMyReviewPage extends StatefulWidget {
  final String copyId;
  const CopyMyReviewPage({super.key, required this.copyId});

  @override
  State<CopyMyReviewPage> createState() => _CopyMyReviewPageState();
}

class _CopyMyReviewPageState extends State<CopyMyReviewPage> {
  int rating = 0;
  int condition = 3; // optionnel perso, si tu veux le personnaliser, sinon ignore
  String review = '';
  String status = 'owned';

  UserCopyMeta? meta;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _load();
  }

  Future<void> _load() async {
    final db = context.read<AppDb>();
    final userId = context.read<ActiveUserStore>().activeUserId;
    if (userId == null) return;

    final existing = await (db.select(db.userCopyMetas)
          ..where((t) => t.userId.equals(userId) & t.copyId.equals(widget.copyId)))
        .getSingleOrNull();

    setState(() {
      meta = existing;
      rating = existing?.rating ?? 0;
      review = existing?.review ?? '';
      status = existing?.status ?? 'owned';
    });
  }

  @override
  Widget build(BuildContext context) {
    final userId = context.watch<ActiveUserStore>().activeUserId;

    return Scaffold(
      appBar: AppBar(title: const Text('Mon avis (famille)')),
      body: userId == null
          ? const Padding(
              padding: EdgeInsets.all(16),
              child: Text('Aucun utilisateur actif. Va dans "Membres" pour en sélectionner un.'),
            )
          : Padding(
              padding: const EdgeInsets.all(16),
              child: ListView(
                children: [
                  const Text('Ma note'),
                  Row(
                    children: [
                      for (int i = 1; i <= 5; i++)
                        IconButton(
                          icon: Icon(i <= rating ? Icons.star : Icons.star_border),
                          onPressed: () => setState(() => rating = i),
                        ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    key: ValueKey(meta?.id ?? 'loading'),
                    initialValue: status,
                    decoration: const InputDecoration(labelText: 'Statut'),
                    items: const [
                      DropdownMenuItem(value: 'owned', child: Text('Possédé')),
                      DropdownMenuItem(value: 'read', child: Text('Lu')),
                      DropdownMenuItem(value: 'to_read', child: Text('À lire')),
                      DropdownMenuItem(value: 'wishlist', child: Text('Wishlist')),
                    ],
                    onChanged: (v) => setState(() => status = v ?? 'owned'),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    decoration: const InputDecoration(labelText: 'Mon avis'),
                    minLines: 3,
                    maxLines: 6,
                    controller: TextEditingController(text: review),
                    onChanged: (v) => review = v,
                  ),
                  const SizedBox(height: 24),
                  FilledButton.icon(
                    icon: const Icon(Icons.save),
                    label: const Text('Enregistrer'),
                    onPressed: () async {
                      final db = context.read<AppDb>();
                      final id = meta?.id ?? const Uuid().v4();
                      await db.into(db.userCopyMetas).insertOnConflictUpdate(UserCopyMetasCompanion.insert(
                            id: id,
                            userId: userId,
                            copyId: widget.copyId,
                            rating: Value(rating.clamp(0, 5)),
                            review: Value(review),
                            status: Value(status),
                            loanedToUserId: Value(null),
                            loanedAt: Value(null),
                            updatedAt: DateTime.now(),
                          ));
                      if (context.mounted) Navigator.pop(context);
                    },
                  ),
                ],
              ),
            ),
    );
  }
}
