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
        ‘Starter de la semaine’,
        ‘Premier tome terminé cette semaine — belle mise en route !’,
      );
    case ReadingBadgeIds.pioneerMonth:
      return const ReadingBadgeMeta(
        ‘Lanceur du mois’,
        ‘Premier tome terminé ce mois — tu donnes le ton !’,
      );
    case ReadingBadgeIds.pioneerYear:
      return const ReadingBadgeMeta(
        ‘Démarreur de l’année’,
        ‘Premier tome terminé cette année — quelle année ça va être !’,
      );
    case ReadingBadgeIds.firstBookEver:
      return const ReadingBadgeMeta(
        ‘Première page tournée’,
        ‘Ton tout premier tome bouclé. Le voyage commence ici !’,
      );
    case ReadingBadgeIds.books10:
      return const ReadingBadgeMeta(
        ‘Lecteur assidu’,
        ‘10 BD dévorées — le rythme est là, continue !’,
      );
    case ReadingBadgeIds.books25:
      return const ReadingBadgeMeta(
        ‘Herbivore de cases’,
        ‘25 albums au compteur. Tu es bien lancé(e) !’,
      );
    case ReadingBadgeIds.books50:
      return const ReadingBadgeMeta(
        ‘Cinquante bulles’,
        ‘50 tomes lus. Tu lis à un rythme impressionnant !’,
      );
    case ReadingBadgeIds.books100:
      return const ReadingBadgeMeta(
        ‘Centurion des bulles’,
        ‘100 œuvres ! Tu es une légende de la lecture BD.’,
      );
    case ReadingBadgeIds.firstSeriesComplete:
      return const ReadingBadgeMeta(
        ‘Série bouclée !’,
        ‘Ta première série complète de A à Z. Aucune fin ne t’échappe !’,
      );
    case ReadingBadgeIds.seriesCollector5:
      return const ReadingBadgeMeta(
        ‘Chasseur de fins’,
        ‘5 séries terminées — tu ne laisses rien en suspens !’,
      );
    case ReadingBadgeIds.seriesCollector10:
      return const ReadingBadgeMeta(
        ‘Maître des arcs’,
        ‘10 séries complètes. Aucune histoire ne te résiste !’,
      );
    default:
      return null;
  }
}
