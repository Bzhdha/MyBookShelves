import 'package:drift/drift.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

import '../../../db/app_db.dart';
import '../domain/active_user_store.dart';

class CopyMyReviewPage extends StatefulWidget {
  final String copyId;
  const CopyMyReviewPage({super.key, required this.copyId});

  @override
  State<CopyMyReviewPage> createState() => _CopyMyReviewPageState();
}

class _CopyMyReviewPageState extends State<CopyMyReviewPage> {
  int rating = 0;
  int condition = 3; // optionnel perso, si tu veux le personnaliser, sinon ignore
  late final TextEditingController _reviewCtrl;
  String status = 'owned';
  String? loanedToUserId;

  UserCopyMeta? meta;
  List<User> _users = [];
  bool _reviewHydrated = false;

  @override
  void initState() {
    super.initState();
    _reviewCtrl = TextEditingController();
  }

  @override
  void dispose() {
    _reviewCtrl.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(CopyMyReviewPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.copyId != widget.copyId) {
      _reviewHydrated = false;
    }
  }

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

    final users = await db.getAllUsers();

    if (!mounted) return;
    setState(() {
      meta = existing;
      rating = existing?.rating ?? 0;
      status = existing?.status ?? 'owned';
      loanedToUserId = existing?.loanedToUserId;
      _users = users;
    });
    if (!_reviewHydrated) {
      _reviewCtrl.text = existing?.review ?? '';
      _reviewHydrated = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    final userId = context.select<ActiveUserStore, String?>((s) => s.activeUserId);

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
                    value: status,
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
                  DropdownButtonFormField<String?>(
                    value: loanedToUserId,
                    decoration: const InputDecoration(
                      labelText: 'Prêté à',
                      hintText: '—',
                    ),
                    items: [
                      const DropdownMenuItem<String?>(
                        value: null,
                        child: Text('—'),
                      ),
                      ..._users
                          .where((u) => u.id != userId)
                          .map((u) => DropdownMenuItem<String?>(
                                value: u.id,
                                child: Text(u.displayName),
                              )),
                    ],
                    onChanged: (v) => setState(() => loanedToUserId = v),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    decoration: const InputDecoration(labelText: 'Mon avis'),
                    minLines: 3,
                    maxLines: 6,
                    controller: _reviewCtrl,
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
                            review: Value(_reviewCtrl.text),
                            status: Value(status),
                            loanedToUserId: Value(loanedToUserId),
                            loanedAt: Value(loanedToUserId != null ? DateTime.now() : null),
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
