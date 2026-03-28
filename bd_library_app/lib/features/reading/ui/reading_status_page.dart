import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../db/app_db.dart';
import '../data/reading_repository.dart';
import '../../books/ui/book_detail_page.dart';
import 'reading_formatters.dart';

class ReadingStatusPage extends StatefulWidget {
  const ReadingStatusPage({super.key});

  @override
  State<ReadingStatusPage> createState() => _ReadingStatusPageState();
}

class _ReadingStatusPageState extends State<ReadingStatusPage>
    with SingleTickerProviderStateMixin {
  late TabController _tab;

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tab.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Statuts de lecture'),
        bottom: TabBar(
          controller: _tab,
          tabs: const [
            Tab(text: 'À lire'),
            Tab(text: 'En cours'),
            Tab(text: 'Terminé'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tab,
        children: const [
          _StatusList(status: ReadingStatusValues.toRead),
          _StatusList(status: ReadingStatusValues.inProgress),
          _StatusList(status: ReadingStatusValues.finished),
        ],
      ),
    );
  }
}

class _StatusList extends StatelessWidget {
  const _StatusList({required this.status});

  final int status;

  @override
  Widget build(BuildContext context) {
    final repo = context.read<ReadingRepository>();
    return FutureBuilder<List<(Book, ReadingProgressRow)>>(
      future: repo.booksWithProgressForStatus(status),
      builder: (context, snap) {
        if (!snap.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        final items = snap.data!;
        if (items.isEmpty) {
          return Center(
            child: Text(
              'Aucun livre (${readingStatusLabel(status)})',
              textAlign: TextAlign.center,
            ),
          );
        }
        return ListView.builder(
          itemCount: items.length,
          itemBuilder: (context, i) {
            final b = items[i].$1;
            return ListTile(
              title: Text(b.title.isEmpty ? 'Sans titre' : b.title),
              subtitle: b.authors.trim().isNotEmpty ? Text(b.authors) : null,
              onTap: () => Navigator.push<void>(
                context,
                MaterialPageRoute(
                  builder: (_) => BookDetailPage(bookId: b.id),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
