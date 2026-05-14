import '../../../models/bd_metadata.dart';

/// Résultat d'une recherche par prompt personnalisé : réponse brute du LLM et métadonnées parsées (si possible).
typedef LlmPromptResult = ({String rawResponse, BdMetadata? parsed});

/// Interface commune pour les fournisseurs de métadonnées via API LLM (OpenAI, Claude, Mistral, Groq).
abstract class LlmMetadataProvider {
  bool get isConfigured;
  Future<BdMetadata?> fetchByIsbn(String isbn);

  /// Appelle le LLM avec le message utilisateur donné et retourne la réponse brute + métadonnées parsées.
  Future<LlmPromptResult?> fetchWithUserPrompt(String userPrompt);
}

/// Prompt utilisateur pour la recherche ISBN par IA (remplacer [INSÉRER_ISBN_ICI] par l'ISBN).
const String llmIsbnSearchUserPromptTemplate = '''
Recherche les informations détaillées pour la bande dessinée ou le livre associé au code ISBN suivant : [INSÉRER_ISBN_ICI].

Fournis le résultat au format JSON strict avec les champs suivants (si disponibles) :
- "isbn" : le code ISBN,
- "titre" : le titre complet,
- "auteurs" : une liste des auteurs/scénaristes/dessinateurs,
- "éditeur" : le nom de l'éditeur,
- "collection" : le nom de la collection (si applicable),
- "série" : le nom de la série ou du cycle regroupant plusieurs tomes (si applicable),
- "type" : "BD", "Manga", "Manhua", "Roman", etc.,
- "tome" : le numéro du tome (si applicable),
- "date_parution" : la date de parution (format AAAA-MM-JJ),
- "nombre_pages" : le nombre de pages (entier),
- "prix_public" : le prix public conseillé en euros (nombre décimal, ex: 13.99),
- "résumé" : un résumé court du contenu,
- "liens" : une liste d'URLs pour plus d'infos (si disponibles).

Si aucune information n'est trouvée pour cet ISBN, retourne un JSON vide : {}.
''';

/// Parse un objet JSON avec clés françaises (réponse IA) en [BdMetadata]. Retourne null si titre manquant ou {}.
BdMetadata? parseLlmMetadataJsonFromFrench(Map<String, dynamic> meta) {
  if (meta.isEmpty) return null;

  String? title;
  final titre = meta['titre'];
  if (titre != null && titre.toString().trim().isNotEmpty) {
    title = titre.toString().trim();
  }
  if (title == null || title.isEmpty) return null;

  List<String>? authors;
  final rawAuthors = meta['auteurs'];
  if (rawAuthors is List) {
    authors = rawAuthors
        .map((e) => e?.toString().trim())
        .where((s) => s != null && s.isNotEmpty)
        .cast<String>()
        .toList();
    if (authors.isEmpty) authors = null;
  }

  String? publisher;
  final editeur = meta['éditeur'];
  if (editeur != null && editeur.toString().trim().isNotEmpty) {
    publisher = editeur.toString().trim();
  }

  String? publishedDate;
  final dateParution = meta['date_parution'];
  if (dateParution != null && dateParution.toString().trim().isNotEmpty) {
    publishedDate = dateParution.toString().trim();
  }

  String? volumeNumber;
  final tome = meta['tome'];
  if (tome != null && tome.toString().trim().isNotEmpty) {
    volumeNumber = tome.toString().trim();
  }

  String? description;
  final resume = meta['résumé'];
  if (resume != null && resume.toString().trim().isNotEmpty) {
    description = resume.toString().trim();
  }

  String? seriesTitle;
  for (final key in ['série', 'serie', 'collection']) {
    final v = meta[key];
    if (v != null && v.toString().trim().isNotEmpty) {
      seriesTitle = v.toString().trim();
      break;
    }
  }

  int? pageCount;
  final nbPages = meta['nombre_pages'];
  if (nbPages != null) pageCount = (nbPages as num?)?.toInt();

  double? retailPrice;
  final prixPublic = meta['prix_public'];
  if (prixPublic != null) retailPrice = (prixPublic as num?)?.toDouble();

  return BdMetadata(
    title: title,
    authors: authors,
    publisher: publisher,
    publishedDate: publishedDate,
    description: description,
    volumeNumber: volumeNumber,
    seriesTitle: seriesTitle,
    pageCount: pageCount,
    retailPrice: retailPrice,
  );
}

/// Parse un objet JSON renvoyé par un LLM en [BdMetadata]. Retourne null si titre manquant.
BdMetadata? parseLlmMetadataJson(Map<String, dynamic> meta) {
  final fromFrench = parseLlmMetadataJsonFromFrench(meta);
  if (fromFrench != null) return fromFrench;

  String? title;
  if (meta['title'] != null && meta['title'].toString().trim().isNotEmpty) {
    title = meta['title'].toString().trim();
  }

  List<String>? authors;
  final rawAuthors = meta['authors'];
  if (rawAuthors is List) {
    authors = rawAuthors
        .map((e) => e?.toString().trim())
        .where((s) => s != null && s.isNotEmpty)
        .cast<String>()
        .toList();
    if (authors.isEmpty) authors = null;
  }

  String? publisher;
  if (meta['publisher'] != null && meta['publisher'].toString().trim().isNotEmpty) {
    publisher = meta['publisher'].toString().trim();
  }

  String? publishedDate;
  if (meta['publishedDate'] != null && meta['publishedDate'].toString().trim().isNotEmpty) {
    publishedDate = meta['publishedDate'].toString().trim();
  }

  String? volumeNumber;
  if (meta['volumeNumber'] != null && meta['volumeNumber'].toString().trim().isNotEmpty) {
    volumeNumber = meta['volumeNumber'].toString().trim();
  }

  if (title == null || title.isEmpty) return null;

  String? description;
  final desc = meta['description'] ?? meta['summary'];
  if (desc != null && desc.toString().trim().isNotEmpty) {
    description = desc.toString().trim();
  }

  String? seriesTitle;
  for (final key in ['seriesTitle', 'series', 'collection']) {
    final v = meta[key];
    if (v != null && v.toString().trim().isNotEmpty) {
      seriesTitle = v.toString().trim();
      break;
    }
  }

  int? pageCount;
  final pc = meta['pageCount'] ?? meta['page_count'] ?? meta['nombre_pages'];
  if (pc != null) pageCount = (pc as num?)?.toInt();

  double? retailPrice;
  final rp = meta['retailPrice'] ?? meta['retail_price'] ?? meta['prix_public'];
  if (rp != null) retailPrice = (rp as num?)?.toDouble();

  return BdMetadata(
    title: title,
    authors: authors,
    publisher: publisher,
    publishedDate: publishedDate,
    description: description,
    volumeNumber: volumeNumber,
    seriesTitle: seriesTitle,
    pageCount: pageCount,
    retailPrice: retailPrice,
  );
}
