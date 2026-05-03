import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../domain/reading_session_store.dart';

Future<void> showEndReadingSessionSheet(BuildContext context) async {
  final store = context.read<ReadingSessionStore>();
  final session = store.activeSession;
  final book = store.activeBook;
  if (session == null || book == null) return;

  await showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    useSafeArea: true,
    builder: (ctx) {
      return _EndSessionBody(
        store: store,
        sessionStartPage: session.startPage,
        bookTitle: book.title.isEmpty ? 'Sans titre' : book.title,
      );
    },
  );
}

class _EndSessionBody extends StatefulWidget {
  const _EndSessionBody({
    required this.store,
    required this.sessionStartPage,
    required this.bookTitle,
  });

  final ReadingSessionStore store;
  final int sessionStartPage;
  final String bookTitle;

  @override
  State<_EndSessionBody> createState() => _EndSessionBodyState();
}

class _EndSessionBodyState extends State<_EndSessionBody> {
  late final TextEditingController _pageCtrl;
  bool _finished = false;

  @override
  void initState() {
    super.initState();
    _pageCtrl = TextEditingController(text: '${widget.sessionStartPage}');
  }

  @override
  void dispose() {
    _pageCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 16,
        left: 16,
        right: 16,
        top: 8,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Fin de séance',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 4),
          Text(
            widget.bookTitle,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _pageCtrl,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Page d’arrêt',
              border: OutlineInputBorder(),
            ),
          ),
          CheckboxListTile(
            value: _finished,
            onChanged: (v) => setState(() => _finished = v ?? false),
            title: const Text('J’ai terminé ce livre'),
            controlAffinity: ListTileControlAffinity.leading,
            contentPadding: EdgeInsets.zero,
          ),
          const SizedBox(height: 12),
          FilledButton(
            onPressed: () async {
              final endPage =
                  int.tryParse(_pageCtrl.text.trim()) ?? widget.sessionStartPage;
              final badges = await widget.store.endActiveSession(
                endPage: endPage,
                markBookFinished: _finished,
              );
              if (!context.mounted) return;
              final messenger = ScaffoldMessenger.of(context);
              Navigator.pop(context);
              if (badges.isEmpty) {
                messenger.showSnackBar(
                  const SnackBar(content: Text('Séance enregistrée')),
                );
              } else if (badges.length == 1) {
                messenger.showSnackBar(
                  SnackBar(
                    content: Text(
                      'Nouveau badge : ${badges.first.title}',
                    ),
                  ),
                );
              } else {
                messenger.showSnackBar(
                  SnackBar(
                    content: Text(
                      '${badges.length} nouveaux badges : '
                      '${badges.map((b) => b.title).join(', ')}',
                    ),
                  ),
                );
              }
            },
            child: const Text('Enregistrer la fin de lecture'),
          ),
        ],
      ),
    );
  }
}
