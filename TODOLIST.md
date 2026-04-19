# TODOLIST – MyBookShelves / bd_library_app

Prioritized action list from full architecture & code review (2026-04-19).

---

## 🔴 Priority 1 — Critical (Security / Stability)

- [x] **Remplacer les `print()` par AppLogger**  
  `OpenLibraryProvider` accepte désormais `AppLogger?` en paramètre. Les `print()` remplacés par `logger?.log()`. `main.dart` passe `appLogger` à la construction.

- [x] **Validation & normalisation ISBN**  
  Nouveau `lib/core/isbn_validator.dart` : normalize (strip tirets/espaces), validate ISBN-10 (MOD11) et ISBN-13 (EAN checksum + préfixe 978/979). `AddBookPage` valide avant tout appel réseau et affiche l'erreur dans un SnackBar.

- [x] **Gestion d'erreurs explicite dans les providers metadata**  
  `MetadataService._safeFetchBdTheque`, `_safeFetchOpenLibrary` et `_safeFetchLlm` loggent désormais les erreurs catchées via `AppLogger` (visibles dans la page Logs).

- [x] **Cascade suppression UserCopyMetas lors de la suppression d'un utilisateur**  
  `AppDb.deleteUserById()` ajouté : supprime `UserCopyMetas` puis `Users`. Bouton suppression avec dialog de confirmation ajouté dans `UsersPage`.

- [ ] **Sécurisation stockage (SQLite encryption)**  
  API keys : ✅ déjà dans `flutter_secure_storage`. Base SQLite : migration vers SQLCipher en attente (nécessite changements natifs Android/iOS — hors scope de ce sprint).

- [x] **Protection d'accès locale (biométrie / credential appareil)**  
  Package `local_auth ^2.3.0` ajouté. `AppLockStore` (SharedPreferences). `AppLockScreen` (biométrie + credential device). `_AppLockGate` dans `main.dart` verrouille au lancement et à la mise en arrière-plan. Toggle dans le drawer ("Verrouillage biométrique"). Permissions Android + `FlutterFragmentActivity` configurés.

---

## 🟠 Priority 2 — High (Feature Completeness)

- [ ] **Objectifs de lecture (Reading Goals UI)**  
  `reading_goals_page.dart` lit les données en base mais n'affiche que du placeholder. Implémenter l'UI de saisie et de suivi d'objectifs mensuels/annuels.

- [ ] **Remplacer le scraping HTML ISBNdb par l'API officielle**  
  `open_library_provider.dart` parse du HTML avec des sélecteurs CSS hardcodés fragiles. Utiliser l'API ISBNdb REST ou Open Library JSON à la place.

- [ ] **Validation des formulaires (toutes les pages d'entrée)**  
  `add_book_page.dart`, `copy_form_page.dart`, `edit_book_page.dart` : ajouter des règles de validation (champs requis, formats, longueurs max) avec feedback visible.

- [ ] **Tests unitaires — couche data/domain**  
  Couverture actuelle : ~0% (1 seul fichier placeholder). Ajouter tests pour `BookService`, `BooksRepository`, `MetadataService`, les providers metadata, et la logique import/export.

- [ ] **Refactorer `main.dart` (616 lignes)**  
  Extraire `HomePage` et ses widgets dans `lib/features/books/ui/home_page.dart`. `main.dart` ne devrait contenir que le bootstrap de l'app et les providers.

---

## 🟡 Priority 3 — Medium (UX / Maintainability)

- [ ] **Pagination / scroll virtuel sur la liste des livres**  
  `HomePage` charge tous les livres en mémoire via un stream. Implémenter la pagination ou `ListView.builder` avec chargement incrémental pour les grandes bibliothèques.

- [ ] **Filtres de recherche**  
  Ajouter filtres sur : série, auteur, statut de lecture, étagère, état de l'exemplaire. La recherche ne supporte actuellement que le texte libre.

- [ ] **Options de tri de la liste**  
  Actuellement trié par titre uniquement. Ajouter tri par auteur, date d'ajout, note, statut.

- [ ] **Indicateur hors-ligne**  
  L'app tente des appels réseau sans vérifier la connectivité. Ajouter un check (package `connectivity_plus`) et désactiver les actions réseau avec message explicite.

- [ ] **Convertir les champs status `String` en enum**  
  `UserCopyMetas.status` est une chaîne libre. Définir un enum `ReadingStatus` pour la sûreté de type et éviter les fautes de frappe silencieuses.

---

## 🟢 Priority 4 — Low (Polish / Tech Debt)

- [ ] **Harmoniser la gestion d'erreurs des providers LLM**  
  ChatGPT, Claude, Mistral, Groq ont chacun leur propre pattern de gestion d'erreur. Créer un wrapper commun (`LlmProvider` interface) avec timeout uniforme et retry basique.

- [ ] **Centraliser les constantes magic values**  
  `app_db.dart` schéma version `5`, couleur par défaut `#6200EE`, sélecteurs ISBNdb, etc. Regrouper dans un fichier `lib/core/constants.dart`.

- [ ] **Tests widgets — pages principales**  
  Ajouter des tests widgets pour `HomePage`, `BookDetailPage`, `AddBookPage`, `IsbnScannerPage`.

- [ ] **Tests d'intégration — flux bout-en-bout**  
  Ajouter au moins : ajout d'un livre → consultation → modification → suppression, et import/export round-trip.

- [ ] **Logging d'utilisation interne**  
  Exploiter `AppLogger` et `LogsPage` pour tracer les événements importants (scan ISBN, import/export, erreurs réseau) et faciliter le debug en production.

---

## ✅ Fait (archive)

- [x] **Structuration par features** — `lib/features/` avec séparation `data/domain/ui`
- [x] **Migration feature livres** — `BookService` + `BooksRepository` sur toutes les pages livres/exemplaires/scan
- [x] **Intégration OCR** — `google_mlkit_text_recognition` + zone selection (`cover_ocr_zones_page.dart`)
- [x] **Scanner ISBN multi-formats** — `mobile_scanner` avec lookup et fallback LLM
- [x] **Import/export bibliothèque** — ZIP + JSON avec résolution de conflits (`import_review_page.dart`)

---

*Généré le 2026-04-19 — basé sur l'analyse de 60 fichiers Dart, schema DB v5.*
