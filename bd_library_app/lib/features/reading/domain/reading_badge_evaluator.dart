import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../../../db/app_db.dart';
import 'reading_badge_catalog.dart';

/// Résumé d’un badge nouvellement débloqué (affichage snackbar / liste).
class ReadingBadgeUnlock {
  ReadingBadgeUnlock(this.badgeId, this.title);

  final String badgeId;
  final String title;
}

/// Évalue et enregistre les badges après une fin de lecture, et permet un rattrapage post-import.
class ReadingBadgeEvaluator {
  ReadingBadgeEvaluator(this._db);

  final AppDb _db;
  final Uuid _uuid = const Uuid();

  /// Appelé après qu’un tome soit passé à « terminé » (ex. fin de séance).
  Future<List<ReadingBadgeUnlock>> onBookFinished(
    String bookId,
    DateTime finishedAt,
  ) async {
    final local = finishedAt.toLocal();
    final unlocked = <ReadingBadgeUnlock>[];

    final monday = _mondayOfWeekContaining(local);
    final weekStart = DateTime(monday.year, monday.month, monday.day);
    final sunday = weekStart.add(const Duration(days: 6));
    final weekEnd =
        DateTime(sunday.year, sunday.month, sunday.day, 23, 59, 59, 999);
    final firstWeek = await _firstFinishedBookInWindow(weekStart, weekEnd);
    if (firstWeek == bookId) {
      await _tryGrant(
        unlocked,
        ReadingBadgeIds.pioneerWeek,
        _weekPeriodKey(local),
        context: {'bookId': bookId},
      );
    }

    final monthStart = DateTime(local.year, local.month, 1);
    final monthEnd =
        DateTime(local.year, local.month + 1, 0, 23, 59, 59, 999);
    final firstMonth = await _firstFinishedBookInWindow(monthStart, monthEnd);
    if (firstMonth == bookId) {
      await _tryGrant(
        unlocked,
        ReadingBadgeIds.pioneerMonth,
        _monthPeriodKey(local),
        context: {'bookId': bookId},
      );
    }

    final yearStart = DateTime(local.year, 1, 1);
    final yearEnd = DateTime(local.year, 12, 31, 23, 59, 59, 999);
    final firstYear = await _firstFinishedBookInWindow(yearStart, yearEnd);
    if (firstYear == bookId) {
      await _tryGrant(
        unlocked,
        ReadingBadgeIds.pioneerYear,
        _yearPeriodKey(local),
        context: {'bookId': bookId},
      );
    }

    await _grantVolumeMilestones(unlocked);
    await _grantSeriesMilestones(unlocked);
    return unlocked;
  }

  /// Rattrapage : paliers de tomes / séries (ex. après import JSON ou ZIP).
  Future<void> syncMilestoneBadgesFromProgress() async {
    final unlocked = <ReadingBadgeUnlock>[];
    await _grantVolumeMilestones(unlocked);
    await _grantSeriesMilestones(unlocked);
  }

  Future<void> _tryGrant(
    List<ReadingBadgeUnlock> unlocked,
    String badgeId,
    String periodKey, {
    Map<String, dynamic>? context,
  }) async {
    final inserted = await _db.insertEarnedBadgeIfAbsent(
      EarnedBadgesCompanion.insert(
        id: _uuid.v4(),
        badgeId: badgeId,
        unlockedAt: DateTime.now(),
        periodKey:
            periodKey.isEmpty ? const Value.absent() : Value(periodKey),
        contextJson: Value(context == null ? null : jsonEncode(context)),
      ),
    );
    if (!inserted) return;
    final m = readingBadgeMeta(badgeId);
    if (m != null) {
      unlocked.add(ReadingBadgeUnlock(badgeId, m.title));
    }
  }

  Future<String?> _firstFinishedBookInWindow(
    DateTime start,
    DateTime end,
  ) async {
    final rows = await (_db.select(_db.readingProgress)
          ..where(
            (t) =>
                t.status.equals(ReadingStatusValues.finished) &
                t.readingFinishedAt.isNotNull() &
                t.readingFinishedAt.isBiggerOrEqualValue(start) &
                t.readingFinishedAt.isSmallerOrEqualValue(end),
          ))
        .get();
    if (rows.isEmpty) return null;
    rows.sort((a, b) {
      final da = a.readingFinishedAt!;
      final db_ = b.readingFinishedAt!;
      final c = da.compareTo(db_);
      if (c != 0) return c;
      return a.bookId.compareTo(b.bookId);
    });
    return rows.first.bookId;
  }

  DateTime _mondayOfWeekContaining(DateTime local) {
    final day = DateTime(local.year, local.month, local.day);
    return day.subtract(Duration(days: day.weekday - 1));
  }

  String _weekPeriodKey(DateTime local) {
    final m = _mondayOfWeekContaining(local);
    return '${m.year.toString().padLeft(4, '0')}-'
        '${m.month.toString().padLeft(2, '0')}-'
        '${m.day.toString().padLeft(2, '0')}';
  }

  String _monthPeriodKey(DateTime local) =>
      '${local.year}-${local.month.toString().padLeft(2, '0')}';

  String _yearPeriodKey(DateTime local) => '${local.year}';

  Future<int> _countFinishedBooks() async {
    final rows = await (_db.select(_db.readingProgress)
          ..where((t) => t.status.equals(ReadingStatusValues.finished)))
        .get();
    return rows.length;
  }

  Future<void> _grantVolumeMilestones(List<ReadingBadgeUnlock> unlocked) async {
    final n = await _countFinishedBooks();
    if (n >= 1) {
      await _tryGrant(unlocked, ReadingBadgeIds.firstBookEver, '');
    }
    if (n >= 10) {
      await _tryGrant(unlocked, ReadingBadgeIds.books10, '');
    }
    if (n >= 25) {
      await _tryGrant(unlocked, ReadingBadgeIds.books25, '');
    }
    if (n >= 50) {
      await _tryGrant(unlocked, ReadingBadgeIds.books50, '');
    }
    if (n >= 100) {
      await _tryGrant(unlocked, ReadingBadgeIds.books100, '');
    }
  }

  /// Séries avec [expectedVolumes] : tomes 1…N tous en bibliothèque et tous terminés.
  Future<int> _countCompleteSeriesModeA() async {
    final allSeries = await _db.getAllSeries();
    var n = 0;
    for (final s in allSeries) {
      final exp = s.expectedVolumes;
      if (exp == null || exp <= 0) continue;
      final books = await _db.getBooksBySeries(s.id);
      final byVol = <int, Book>{};
      for (final b in books) {
        final v = b.volumeNumber;
        if (v != null && v >= 1 && v <= exp) {
          byVol[v] = b;
        }
      }
      if (byVol.length < exp) continue;
      var ok = true;
      for (var v = 1; v <= exp; v++) {
        final b = byVol[v];
        if (b == null) {
          ok = false;
          break;
        }
        final p = await _db.readingProgressForBook(b.id);
        if (p == null || p.status != ReadingStatusValues.finished) {
          ok = false;
          break;
        }
      }
      if (ok) n++;
    }
    return n;
  }

  Future<void> _grantSeriesMilestones(List<ReadingBadgeUnlock> unlocked) async {
    final c = await _countCompleteSeriesModeA();
    if (c >= 1) {
      await _tryGrant(unlocked, ReadingBadgeIds.firstSeriesComplete, '');
    }
    if (c >= 5) {
      await _tryGrant(unlocked, ReadingBadgeIds.seriesCollector5, '');
    }
    if (c >= 10) {
      await _tryGrant(unlocked, ReadingBadgeIds.seriesCollector10, '');
    }
  }
}
