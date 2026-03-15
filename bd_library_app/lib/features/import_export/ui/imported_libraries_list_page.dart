import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/imported_library_store.dart';
import 'imported_library_view_page.dart';
import '../data/library_transfer_service.dart';
import '../../../db/app_db.dart';

/// Liste des bibliothèques importées (amis) — consultation sans fusion.
class ImportedLibrariesListPage extends StatefulWidget {
  const ImportedLibrariesListPage({super.key});

  @override
  State<ImportedLibrariesListPage> createState() =>
      _ImportedLibrariesListPageState();
}

class _ImportedLibrariesListPageState extends State<ImportedLibrariesListPage> {
  List<ImportedLibraryEntry> _entries = [];
  bool _loading = true;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _load();
  }

  Future<void> _load() async {
    final store = context.read<ImportedLibraryStore>();
    final list = await store.listImportedLibraries();
    if (!mounted) return;
    setState(() {
      _entries = list;
      _loading = false;
    });
  }

  Future<void> _importFriendLibrary() async {
    final db = context.read<AppDb>();
    final transfer = LibraryTransferService(db);
    final store = context.read<ImportedLibraryStore>();

    final file = await transfer.pickLibraryFile();
    if (file == null || !mounted) return;

    final lib = await transfer.readLibraryFromFile(file);
    if (lib == null || !mounted) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Fichier invalide ou illisible')),
        );
      }
      return;
    }

    final name = await showDialog<String>(
      context: context,
      builder: (ctx) {
        final ctrl = TextEditingController(
          text: 'Bibliothèque du ${DateTime.now().day}/${DateTime.now().month}',
        );
        return AlertDialog(
          title: const Text('Nom de la bibliothèque'),
          content: TextField(
            controller: ctrl,
            decoration: const InputDecoration(
              labelText: 'Ex. Bibliothèque de Marie',
            ),
            autofocus: true,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, null),
              child: const Text('Annuler'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(ctx, ctrl.text.trim()),
              child: const Text('Importer'),
            ),
          ],
        );
      },
    );

    if (name == null || !mounted) return;

    await store.saveImportedLibrary(name.isEmpty ? 'Bibliothèque importée' : name, lib);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Bibliothèque enregistrée (consultation seule)')),
    );
    await _load();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bibliothèques importées'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_box),
            tooltip: 'Importer la bibliothèque d\'un ami',
            onPressed: _loading ? null : _importFriendLibrary,
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _entries.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.people_outline, size: 64, color: Theme.of(context).colorScheme.outline),
                      const SizedBox(height: 16),
                      const Text('Aucune bibliothèque importée'),
                      const SizedBox(height: 8),
                      Text(
                        'Appuyez sur + pour importer un fichier\n(JSON ou ZIP) sans fusion avec la vôtre.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  itemCount: _entries.length,
                  itemBuilder: (context, index) {
                    final e = _entries[index];
                    return ListTile(
                      leading: const CircleAvatar(
                        child: Icon(Icons.menu_book),
                      ),
                      title: Text(e.name),
                      subtitle: Text(
                        'Importé le ${e.importedAt.day}/${e.importedAt.month}/${e.importedAt.year}',
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.visibility),
                            tooltip: 'Consulter',
                            onPressed: () async {
                              await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => ImportedLibraryViewPage(
                                    importId: e.id,
                                    libraryName: e.name,
                                  ),
                                ),
                              );
                              await _load();
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete_outline),
                            tooltip: 'Supprimer',
                            onPressed: () async {
                              final ok = await showDialog<bool>(
                                context: context,
                                builder: (ctx) => AlertDialog(
                                  title: const Text('Supprimer cette bibliothèque importée ?'),
                                  content: Text(
                                    '« ${e.name} » ne sera plus visible. Votre propre bibliothèque ne sera pas modifiée.',
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.pop(ctx, false),
                                      child: const Text('Annuler'),
                                    ),
                                    FilledButton(
                                      onPressed: () => Navigator.pop(ctx, true),
                                      child: const Text('Supprimer'),
                                    ),
                                  ],
                                ),
                              );
                              if (ok != true || !mounted) return;
                              await context.read<ImportedLibraryStore>().deleteImportedLibrary(e.id);
                              if (!mounted) return;
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Bibliothèque importée supprimée')),
                              );
                              await _load();
                            },
                          ),
                        ],
                      ),
                    );
                  },
                ),
    );
  }
}
