import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:uuid/uuid.dart';

import '../../../models/export_model.dart';

class ImportedLibraryEntry {
  final String id;
  final String name;
  final DateTime importedAt;

  ImportedLibraryEntry({
    required this.id,
    required this.name,
    required this.importedAt,
  });
}

/// Stocke les bibliothèques importées (amis) sans les fusionner avec la BDD.
/// Chaque import est un fichier JSON dans [imported_libraries]/ avec un index.
class ImportedLibraryStore {
  static const String _dirName = 'imported_libraries';
  static const String _indexFileName = 'index.json';
  final _uuid = const Uuid();

  Future<Directory> _getDir() async {
    final doc = await getApplicationDocumentsDirectory();
    final dir = Directory(p.join(doc.path, _dirName));
    if (!await dir.exists()) await dir.create(recursive: true);
    return dir;
  }

  Future<File> _indexFile() async {
    final dir = await _getDir();
    return File(p.join(dir.path, _indexFileName));
  }

  Future<List<ImportedLibraryEntry>> _readIndex() async {
    final file = await _indexFile();
    if (!await file.exists()) return [];
    try {
      final list = jsonDecode(await file.readAsString()) as List<dynamic>;
      return list
          .map((e) => ImportedLibraryEntry(
                id: e['id'] as String,
                name: e['name'] as String,
                importedAt: DateTime.parse(e['importedAt'] as String),
              ))
          .toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> _writeIndex(List<ImportedLibraryEntry> entries) async {
    final file = await _indexFile();
    await file.writeAsString(jsonEncode(entries
        .map((e) => {
              'id': e.id,
              'name': e.name,
              'importedAt': e.importedAt.toIso8601String(),
            })
        .toList()));
  }

  /// Enregistre une bibliothèque importée (sans fusion). Retourne l'id.
  Future<String> saveImportedLibrary(String name, ExportLibrary lib) async {
    final id = _uuid.v4();
    final dir = await _getDir();
    final file = File(p.join(dir.path, '$id.json'));
    await file.writeAsString(const JsonEncoder.withIndent('  ').convert(lib.toJson()));
    final entries = await _readIndex();
    entries.add(ImportedLibraryEntry(
      id: id,
      name: name.trim().isEmpty ? 'Bibliothèque importée' : name,
      importedAt: DateTime.now(),
    ));
    await _writeIndex(entries);
    return id;
  }

  /// Liste toutes les bibliothèques importées.
  Future<List<ImportedLibraryEntry>> listImportedLibraries() async {
    final entries = await _readIndex();
    entries.sort((a, b) => b.importedAt.compareTo(a.importedAt));
    return entries;
  }

  /// Charge une bibliothèque importée par id.
  Future<ExportLibrary?> getImportedLibrary(String id) async {
    final dir = await _getDir();
    final file = File(p.join(dir.path, '$id.json'));
    if (!await file.exists()) return null;
    try {
      final map = jsonDecode(await file.readAsString()) as Map<String, dynamic>;
      return ExportLibrary.fromJson(map);
    } catch (_) {
      return null;
    }
  }

  /// Supprime une bibliothèque importée.
  Future<void> deleteImportedLibrary(String id) async {
    final dir = await _getDir();
    final file = File(p.join(dir.path, '$id.json'));
    if (await file.exists()) await file.delete();
    final entries = await _readIndex();
    entries.removeWhere((e) => e.id == id);
    await _writeIndex(entries);
  }
}
