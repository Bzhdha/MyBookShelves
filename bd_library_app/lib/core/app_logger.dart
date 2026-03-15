import 'package:flutter/foundation.dart';

/// Entrée de log : horodatage, nom de la fonction, paramètres (optionnel).
class AppLogEntry {
  final DateTime at;
  final String function;
  final Map<String, dynamic>? params;

  const AppLogEntry({
    required this.at,
    required this.function,
    this.params,
  });

  String get paramsSummary {
    if (params == null || params!.isEmpty) return '';
    return params!
        .entries
        .map((e) => '${e.key}=${e.value}')
        .join(', ');
  }
}

/// Logger applicatif en mémoire : enregistre les appels de fonctions avec paramètres.
/// Utilisé pour le débogage et la page "Logs" du menu.
class AppLogger extends ChangeNotifier {
  static const int _maxEntries = 500;
  final List<AppLogEntry> _entries = [];

  List<AppLogEntry> get entries => List.unmodifiable(_entries);

  void log(String function, [Map<String, dynamic>? params]) {
    _entries.add(AppLogEntry(
      at: DateTime.now(),
      function: function,
      params: params != null && params.isNotEmpty ? Map.from(params) : null,
    ));
    while (_entries.length > _maxEntries) {
      _entries.removeAt(0);
    }
    notifyListeners();
  }

  void clear() {
    _entries.clear();
    notifyListeners();
  }
}
