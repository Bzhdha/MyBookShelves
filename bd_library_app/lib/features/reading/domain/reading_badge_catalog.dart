/// Identifiants stables des badges (persistés en base).
abstract class ReadingBadgeIds {
  static const pioneerWeek = 'pioneer_week';
  static const pioneerMonth = 'pioneer_month';
  static const pioneerYear = 'pioneer_year';
  static const firstBookEver = 'first_book_ever';
  static const books10 = 'books_finished_10';
  static const books25 = 'books_finished_25';
  static const books50 = 'books_finished_50';
  static const books100 = 'books_finished_100';
  static const firstSeriesComplete = 'first_series_complete';
  static const seriesCollector5 = 'series_collector_5';
  static const seriesCollector10 = 'series_collector_10';
}

class ReadingBadgeMeta {
  const ReadingBadgeMeta(this.title, this.description);

  final String title;
  final String description;
}

ReadingBadgeMeta? readingBadgeMeta(String badgeId) {
  switch (badgeId) {
    case ReadingBadgeIds.pioneerWeek:
      return const ReadingBadgeMeta(
        'Pionnier de la semaine',
        'Premier tome terminé de cette semaine (lundi–dimanche).',
      );
    case ReadingBadgeIds.pioneerMonth:
      return const ReadingBadgeMeta(
        'Pionnier du mois',
        'Premier tome terminé de ce mois civil.',
      );
    case ReadingBadgeIds.pioneerYear:
      return const ReadingBadgeMeta(
        'Pionnier de l’année',
        'Premier tome terminé de cette année civile.',
      );
    case ReadingBadgeIds.firstBookEver:
      return const ReadingBadgeMeta(
        'Première clôture',
        'Ton tout premier tome marqué comme terminé.',
      );
    case ReadingBadgeIds.books10:
      return const ReadingBadgeMeta(
        'Dix tomes',
        'Au moins dix œuvres terminées.',
      );
    case ReadingBadgeIds.books25:
      return const ReadingBadgeMeta(
        'Vingt-cinq tomes',
        'Au moins vingt-cinq œuvres terminées.',
      );
    case ReadingBadgeIds.books50:
      return const ReadingBadgeMeta(
        'Cinquante tomes',
        'Au moins cinquante œuvres terminées.',
      );
    case ReadingBadgeIds.books100:
      return const ReadingBadgeMeta(
        'Cent tomes',
        'Au moins cent œuvres terminées.',
      );
    case ReadingBadgeIds.firstSeriesComplete:
      return const ReadingBadgeMeta(
        'Série bouclée',
        'Première série complète (tous les tomes 1…N possédés et lus, N = nombre annoncé).',
      );
    case ReadingBadgeIds.seriesCollector5:
      return const ReadingBadgeMeta(
        'Collectionneur de séries',
        'Cinq séries complètes au sens « nombre de tomes attendu ».',
      );
    case ReadingBadgeIds.seriesCollector10:
      return const ReadingBadgeMeta(
        'Maître des arcs',
        'Dix séries complètes au sens « nombre de tomes attendu ».',
      );
    default:
      return null;
  }
}
