import 'dart:convert';
import 'dart:io';

import 'package:archive/archive.dart';
import 'package:archive/archive_io.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../db/app_db.dart';
import '../models/export_model.dart';

/// Extension export/import "famille" (v3) :
/// - Ajoute users + userCopyMeta au même ZIP
/// - Conserve library.json v2 pour compatibilité, et ajoute family.json v3
class FamilyTransferService {
  final AppDb db;
  FamilyTransferService(this.db);

  Future<File> exportFamilyZip() async {
    // Réutilise l'export v2 (library.json + covers/) via le service Bloc 1 si tu veux.
    // Ici, on crée un zip complet à partir de db directement.

    final allSeries = await db.getAllSeries();
    final allBooks = await db.getAllBooks();

    final allCopies = <Copy>[];
    for (final b in allBooks) {
      final cs = await db.getCopiesByBook(b.id);
      allCopies.addAll(cs);
    }

    // Export v2 (works + copies) dans library.json (compat)
    final lib2 = ExportLibrary(
      version: 2,
      exportedAt: DateTime.now(),
      series: allSeries
          .map((s) => ExportSeries(
                id: s.id,
                name: s.name,
                expectedVolumes: s.expectedVolumes,
                tags: s.tags,
                updatedAt: s.updatedAt,
              ))
          .toList(),
      books: allBooks
          .map((b) => ExportBook(
                id: b.id,
                isbn: b.isbn,
                title: b.title,
                seriesId: b.seriesId,
                volumeNumber: b.volumeNumber,
                authors: b.authors,
                publisher: b.publisher,
                publishedDate: b.publishedDate,
                coverUrl: b.coverUrl,
                tags: b.tags,
                updatedAt: b.updatedAt,
              ))
          .toList(),
      copies: allCopies
          .map((c) => ExportCopy(
                id: c.id,
                bookId: c.bookId,
                rating: c.rating,
                review: c.review,
                condition: c.condition,
                location: c.location,
                notes: c.notes,
                updatedAt: c.updatedAt,
              ))
          .toList(),
    );

    // Family v3 (users + metas)
    final users = await db.select(db.users).get();
    final metas = await db.select(db.userCopyMetas).get();

    final family = {
      "version": 3,
      "exportedAt": DateTime.now().toIso8601String(),
      "users": users
          .map((u) => {
                "id": u.id,
                "displayName": u.displayName,
                "avatar": u.avatar,
                "updatedAt": u.updatedAt.toIso8601String(),
              })
          .toList(),
      "userCopyMetas": metas
          .map((m) => {
                "id": m.id,
                "userId": m.userId,
                "copyId": m.copyId,
                "rating": m.rating,
                "review": m.review,
                "status": m.status,
                "loanedToUserId": m.loanedToUserId,
                "loanedAt": m.loanedAt?.toIso8601String(),
                "updatedAt": m.updatedAt.toIso8601String(),
              })
          .toList(),
    };

    final tmp = await getTemporaryDirectory();
    final zipPath = p.join(tmp.path, 'bd_library_family_export.zip');

    final encoder = ZipFileEncoder();
    encoder.create(zipPath);

    // library.json (v2)
    final libBytes = utf8.encode(jsonEncode(lib2.toJson()));
    encoder.addArchiveFile(ArchiveFile('library.json', libBytes.length, libBytes));

    // family.json (v3)
    final famBytes = utf8.encode(jsonEncode(family));
    encoder.addArchiveFile(ArchiveFile('family.json', famBytes.length, famBytes));

    // covers/
    for (final b in allBooks) {
      final localPath = b.coverLocalPath;
      if (localPath == null) continue;
      final f = File(localPath);
      if (!await f.exists()) continue;

      final bytes = await f.readAsBytes();
      final filename = p.basename(localPath);
      encoder.addArchiveFile(ArchiveFile('covers/$filename', bytes.length, bytes));
    }

    encoder.close();
    return File(zipPath);
  }

  Future<void> shareFamilyZip() async {
    final file = await exportFamilyZip();
    await Share.shareXFiles([XFile(file.path)], text: 'Export bibliothèque BD - Famille (ZIP)');
  }

  Future<File?> pickZip() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['zip'],
    );
    if (result == null || result.files.single.path == null) return null;
    return File(result.files.single.path!);
  }

  /// Import family.zip :
  /// - délègue l'import v2 (library.json) à ton flow existant (ImportPlan + conflicts) si tu veux
  /// - puis importe users + userCopyMetas (family.json) en "last write wins"
  Future<Map<String, dynamic>?> readFamilyJson(File zip) async {
    final bytes = await zip.readAsBytes();
    final archive = ZipDecoder().decodeBytes(bytes);

    final entry = archive.files.firstWhere(
      (f) => f.name == 'family.json',
      orElse: () => throw StateError('family.json introuvable'),
    );

    final text = utf8.decode(entry.content as List<int>);
    return jsonDecode(text) as Map<String, dynamic>;
  }

  Future<void> importFamilyJsonLastWriteWins(Map<String, dynamic> familyJson) async {
    final users = (familyJson['users'] as List?)?.cast<Map<String, dynamic>>() ?? [];
    final metas = (familyJson['userCopyMetas'] as List?)?.cast<Map<String, dynamic>>() ?? [];

    for (final u in users) {
      final id = u['id'] as String;
      final existing = await (db.select(db.users)..where((t) => t.id.equals(id))).getSingleOrNull();
      final incomingUpdatedAt = DateTime.parse(u['updatedAt'] as String);

      if (existing == null || incomingUpdatedAt.isAfter(existing.updatedAt)) {
        await db.into(db.users).insertOnConflictUpdate(UsersCompanion.insert(
              id: id,
              displayName: u['displayName'] as String,
              avatar: (u['avatar'] as String?) ?? '',
              updatedAt: incomingUpdatedAt,
            ));
      }
    }

    for (final m in metas) {
      final id = m['id'] as String;
      final existing = await (db.select(db.userCopyMetas)..where((t) => t.id.equals(id))).getSingleOrNull();
      final incomingUpdatedAt = DateTime.parse(m['updatedAt'] as String);

      if (existing == null || incomingUpdatedAt.isAfter(existing.updatedAt)) {
        await db.into(db.userCopyMetas).insertOnConflictUpdate(UserCopyMetasCompanion.insert(
              id: id,
              userId: m['userId'] as String,
              copyId: m['copyId'] as String,
              rating: (m['rating'] as num?)?.toInt() ?? 0,
              review: (m['review'] as String?) ?? '',
              status: (m['status'] as String?) ?? 'owned',
              loanedToUserId: Value(m['loanedToUserId'] as String?),
              loanedAt: Value(m['loanedAt'] == null ? null : DateTime.parse(m['loanedAt'] as String)),
              updatedAt: incomingUpdatedAt,
            ));
      }
    }
  }
}
