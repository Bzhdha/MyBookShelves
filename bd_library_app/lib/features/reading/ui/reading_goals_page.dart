import 'package:drift/drift.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../db/app_db.dart';
import '../data/reading_repository.dart';

class ReadingGoalsPage extends StatefulWidget {
  const ReadingGoalsPage({super.key});

  @override
  State<ReadingGoalsPage> createState() => _ReadingGoalsPageState();
}

class _ReadingGoalsPageState extends State<ReadingGoalsPage> {
  final _monthCtrl = TextEditingController();
  final _yearCtrl = TextEditingController();
  bool _filledFromDb = false;
  Future<(ReadingGoalsRow, int, int)>? _future;

  @override
  void dispose() {
    _monthCtrl.dispose();
    _yearCtrl.dispose();
    super.dispose();
  }

  Future<(ReadingGoalsRow, int, int)> _fetch(ReadingRepository repo) async {
    final now = DateTime.now();
    final g = await repo.goals();
    final m = await repo.finishedBooksInMonth(now);
    final y = await repo.finishedBooksInYear(now.year);
    return (g, m, y);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _future ??= _fetch(context.read<ReadingRepository>());
  }

  @override
  Widget build(BuildContext context) {
    final repo = context.read<ReadingRepository>();
    final now = DateTime.now();
    return Scaffold(
      appBar: AppBar(title: const Text('Objectifs de lecture')),
      body: FutureBuilder<(ReadingGoalsRow, int, int)>(
        future: _future,
        builder: (context, snap) {
          if (!snap.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final goals = snap.data!.$1;
          final monthDone = snap.data!.$2;
          final yearDone = snap.data!.$3;

          if (!_filledFromDb) {
            _monthCtrl.text = goals.booksPerMonth?.toString() ?? '';
            _yearCtrl.text = goals.booksPerYear?.toString() ?? '';
            _filledFromDb = true;
          }

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text(
                'Mois en cours (${now.month}/${now.year})',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              Text(
                monthDone.toString(),
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              Text(
                goals.booksPerMonth != null
                    ? 'Objectif : ${goals.booksPerMonth} livre(s) terminé(s)'
                    : 'Aucun objectif mensuel défini',
              ),
              const Divider(height: 32),
              Text(
                'Année ${now.year}',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              Text(
                yearDone.toString(),
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              Text(
                goals.booksPerYear != null
                    ? 'Objectif : ${goals.booksPerYear} livre(s) terminé(s)'
                    : 'Aucun objectif annuel défini',
              ),
              const Divider(height: 32),
              TextField(
                controller: _monthCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Objectif livres / mois',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _yearCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Objectif livres / an',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: () async {
                  final mStr = _monthCtrl.text.trim();
                  final yStr = _yearCtrl.text.trim();
                  await repo.upsertGoals(
                    ReadingGoalsCompanion(
                      id: const Value('default'),
                      booksPerMonth: mStr.isEmpty
                          ? const Value(null)
                          : Value(int.tryParse(mStr)),
                      booksPerYear: yStr.isEmpty
                          ? const Value(null)
                          : Value(int.tryParse(yStr)),
                    ),
                  );
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Objectifs enregistrés')),
                    );
                    setState(() {
                      _filledFromDb = false;
                      _future = _fetch(repo);
                    });
                  }
                },
                child: const Text('Enregistrer les objectifs'),
              ),
            ],
          );
        },
      ),
    );
  }
}
