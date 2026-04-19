/// ISBN normalization and checksum validation (ISBN-10 and ISBN-13).
class IsbnValidator {
  IsbnValidator._();

  /// Strips hyphens and spaces from [raw].
  static String normalize(String raw) =>
      raw.replaceAll(RegExp(r'[\s\-]'), '');

  /// Returns null if [raw] is a valid ISBN-10 or ISBN-13, otherwise an error message.
  static String? validate(String raw) {
    final isbn = normalize(raw);
    if (isbn.isEmpty) return 'ISBN vide';
    if (isbn.length == 10) return _validateIsbn10(isbn);
    if (isbn.length == 13) return _validateIsbn13(isbn);
    return 'Longueur invalide (${isbn.length} car.), attendu 10 ou 13';
  }

  static String? _validateIsbn10(String isbn) {
    final upper = isbn.toUpperCase();
    int sum = 0;
    for (int i = 0; i < 9; i++) {
      final c = upper[i];
      if (c.compareTo('0') < 0 || c.compareTo('9') > 0) {
        return 'Caractère invalide à la position $i : $c';
      }
      sum += int.parse(c) * (10 - i);
    }
    final last = upper[9];
    if (last == 'X') {
      sum += 10;
    } else if (last.compareTo('0') >= 0 && last.compareTo('9') <= 0) {
      sum += int.parse(last);
    } else {
      return 'Dernier caractère invalide : $last (attendu 0-9 ou X)';
    }
    if (sum % 11 != 0) return 'Checksum ISBN-10 invalide';
    return null;
  }

  static String? _validateIsbn13(String isbn) {
    if (!RegExp(r'^\d{13}$').hasMatch(isbn)) {
      return 'ISBN-13 doit contenir uniquement des chiffres';
    }
    if (!isbn.startsWith('978') && !isbn.startsWith('979')) {
      return 'ISBN-13 doit commencer par 978 ou 979';
    }
    int sum = 0;
    for (int i = 0; i < 12; i++) {
      sum += int.parse(isbn[i]) * (i.isEven ? 1 : 3);
    }
    final check = (10 - (sum % 10)) % 10;
    if (check != int.parse(isbn[12])) return 'Checksum ISBN-13 invalide';
    return null;
  }
}
