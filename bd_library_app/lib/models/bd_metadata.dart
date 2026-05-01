class BdMetadata {
  final String? title;
  final List<String>? authors;
  final String? publisher;
  final String? publishedDate;
  final String? description;
  final String? coverUrl;
  final String? volumeNumber;

  /// Série / collection regroupant plusieurs tomes (nom d’affichage).
  final String? seriesTitle;

  BdMetadata({
    this.title,
    this.authors,
    this.publisher,
    this.publishedDate,
    this.description,
    this.coverUrl,
    this.volumeNumber,
    this.seriesTitle,
  });
}
