import 'package:drift/drift.dart' hide Column;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

import '../../../db/app_db.dart';
import '../domain/active_user_store.dart';

class UsersPage extends StatefulWidget {
  const UsersPage({super.key});

  @override
  State<UsersPage> createState() => _UsersPageState();
}

class _UsersPageState extends State<UsersPage> {
  List<User> users = [];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _load();
  }

  Future<void> _load() async {
    final db = context.read<AppDb>();
    final list = await (db.select(db.users)..orderBy([(t) => OrderingTerm.asc(t.displayName)])).get();
    setState(() => users = list);
  }

  @override
  Widget build(BuildContext context) {
    final active = context.watch<ActiveUserStore>().activeUserId;

    return Scaffold(
      appBar: AppBar(title: const Text('Membres de la famille')),
      floatingActionButton: FloatingActionButton.extended(
        icon: const Icon(Icons.person_add),
        label: const Text('Ajouter'),
        onPressed: () => _addOrEdit(context),
      ),
      body: ListView(
        children: [
          const ListTile(
            title: Text('Utilisateur actif'),
            subtitle: Text('Les notes/avis "pour moi" utiliseront ce profil.'),
          ),
          const Divider(),
          ...users.map((u) => ListTile(
                title: Text(u.displayName),
                subtitle: Text(u.avatar.isEmpty ? '—' : u.avatar),
                trailing: active == u.id ? const Icon(Icons.check_circle) : null,
                onTap: () async {
                  await context.read<ActiveUserStore>().setActiveUserId(u.id);
                  if (mounted) ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Utilisateur actif: ${u.displayName}')),
                  );
                },
                onLongPress: () => _addOrEdit(context, existing: u),
              )),
          if (users.isEmpty) const Padding(
            padding: EdgeInsets.all(16),
            child: Text('Aucun membre. Ajoute un profil.'),
          ),
        ],
      ),
    );
  }

  Future<void> _addOrEdit(BuildContext context, {User? existing}) async {
    final db = context.read<AppDb>();
    final nameCtrl = TextEditingController(text: existing?.displayName ?? '');
    final avatarCtrl = TextEditingController(text: existing?.avatar ?? '');

    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(existing == null ? 'Nouveau membre' : 'Modifier membre'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Nom')),
            TextField(controller: avatarCtrl, decoration: const InputDecoration(labelText: 'Avatar (emoji/couleur)')),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Annuler')),
          FilledButton(
            onPressed: () async {
              final id = existing?.id ?? const Uuid().v4();
              await db.into(db.users).insertOnConflictUpdate(UsersCompanion.insert(
                    id: id,
                    displayName: nameCtrl.text.trim().isEmpty ? 'Membre' : nameCtrl.text.trim(),
                    avatar: Value(avatarCtrl.text.trim()),
                    updatedAt: DateTime.now(),
                  ));
              if (context.mounted) Navigator.pop(context);
              await _load();
            },
            child: const Text('Enregistrer'),
          ),
        ],
      ),
    );
  }
}
