import 'package:drift/drift.dart';
import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';

import '../../../db/app_db.dart';
import '../data/reading_repository.dart';

enum StartSessionResult {
  started,
  resumedSameBook,
  conflictOtherBook,
}

class ReadingSessionStore extends ChangeNotifier {
  ReadingSessionStore(this._repo);

  final ReadingRepository _repo;
  final Uuid _uuid = const Uuid();

  ReadingSession? _session;
  Book? _book;

  ReadingSession? get activeSession => _session;
  Book? get activeBook => _book;

  bool get hasActiveSession => _session != null;

  Future<void> load() async {
    _session = await _repo.activeSession();
    if (_session != null) {
      _book = await _repo.bookById(_session!.bookId);
    } else {
      _book = null;
    }
    notifyListeners();
  }

  /// Démarre ou reprend une séance sur [bookId]. Si une autre séance est ouverte, retourne [conflictOtherBook].
  Future<StartSessionResult> startOrResumeSession(String bookId) async {
    final existing = await _repo.activeSession();
    if (existing != null) {
      if (existing.bookId == bookId) {
        _session = existing;
        _book = await _repo.bookById(bookId);
        notifyListeners();
        return StartSessionResult.resumedSameBook;
      }
      return StartSessionResult.conflictOtherBook;
    }

    final progress = await _repo.getOrCreateProgress(bookId);
    final id = _uuid.v4();
    final now = DateTime.now();
    await _repo.insertSession(
      ReadingSessionsCompanion.insert(
        id: id,
        bookId: bookId,
        startedAt: now,
        startPage: Value(progress.currentPage),
      ),
    );
    await _repo.upsertProgress(
      ReadingProgressCompanion(
        bookId: Value(bookId),
        status: const Value(ReadingStatusValues.inProgress),
        readingStartedAt: Value(progress.readingStartedAt ?? now),
      ),
    );
    await load();
    return StartSessionResult.started;
  }

  /// Termine la séance active : enregistre la page d’arrêt et la durée (temps entre début et fin).
  Future<void> endActiveSession({
    required int endPage,
    required bool markBookFinished,
  }) async {
    final s = _session;
    if (s == null) return;

    final endedAt = DateTime.now();
    final duration = endedAt.difference(s.startedAt).inSeconds;

    await _repo.updateSession(
      s.id,
      ReadingSessionsCompanion(
        endedAt: Value(endedAt),
        endPage: Value(endPage),
        durationSeconds: Value(duration),
        finishedBook: Value(markBookFinished),
      ),
    );

    final bookId = s.bookId;
    await _repo.upsertProgress(
      ReadingProgressCompanion(
        bookId: Value(bookId),
        currentPage: Value(endPage),
        status: Value(
          markBookFinished
              ? ReadingStatusValues.finished
              : ReadingStatusValues.inProgress,
        ),
        readingFinishedAt:
            markBookFinished ? Value(endedAt) : const Value.absent(),
      ),
    );

    _session = null;
    _book = null;
    notifyListeners();
  }

  /// Ferme une séance en cours (autre livre) pour en démarrer une nouvelle : enregistre fin = début, durée réelle.
  Future<void> abandonActiveSessionForSwitch() async {
    final s = _session;
    if (s == null) return;
    final endedAt = DateTime.now();
    final duration = endedAt.difference(s.startedAt).inSeconds;
    await _repo.updateSession(
      s.id,
      ReadingSessionsCompanion(
        endedAt: Value(endedAt),
        endPage: Value(s.startPage),
        durationSeconds: Value(duration),
        finishedBook: const Value(false),
      ),
    );
    _session = null;
    _book = null;
    notifyListeners();
  }
}
