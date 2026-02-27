import 'package:drift/drift.dart';

/// -----------
/// Users (profils)
/// -----------
class Users extends Table {
  TextColumn get id => text()(); // UUID
  TextColumn get displayName => text()();

  /// Couleur/emoji optionnels pour différencier rapidement
  TextColumn get avatar => text().withDefault(const Constant(''))();

  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

/// -----------
/// Meta par utilisateur ET par exemplaire (sans casser Copies)
/// Permet à chaque membre de donner sa note/avis sur le même exemplaire.
/// -----------
class UserCopyMetas extends Table {
  TextColumn get id => text()(); // UUID
  TextColumn get userId => text().references(Users, #id)();
  TextColumn get copyId => text()(); // references(Copies,#id) - référence croisée, on le garde texte pour patch minimal

  /// Données "pour moi"
  IntColumn get rating => integer().withDefault(const Constant(0))(); // 0..5
  TextColumn get review => text().withDefault(const Constant(''))();

  /// Statut perso (lu, à lire, wishlist, etc.)
  TextColumn get status => text().withDefault(const Constant('owned'))();

  /// Prêt : si cet utilisateur prête/reçoit l'exemplaire
  TextColumn get loanedToUserId => text().nullable()();
  DateTimeColumn get loanedAt => dateTime().nullable()();

  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};

  /// Un utilisateur ne devrait avoir qu'une ligne meta par copy
  @override
  List<String> get customConstraints => [
        'UNIQUE(user_id, copy_id) ON CONFLICT REPLACE'
      ];
}
