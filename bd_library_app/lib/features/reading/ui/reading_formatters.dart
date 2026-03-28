String formatReadingDuration(int seconds) {
  if (seconds <= 0) return '—';
  final h = seconds ~/ 3600;
  final m = (seconds % 3600) ~/ 60;
  if (h > 0) return '$h h $m min';
  if (m > 0) return '$m min';
  return '$seconds s';
}

String readingStatusLabel(int status) {
  switch (status) {
    case 0:
      return 'À lire';
    case 1:
      return 'En cours';
    case 2:
      return 'Terminé';
    default:
      return '?';
  }
}
