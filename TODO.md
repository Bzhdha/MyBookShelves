# Todo – MyBookShelves / bd_library_app

Liste des actions à mener (architecture & sécurisation).

## Fait (récent)

- [x] **Migration feature livres (UI + use cases)**  
  Pages livres / exemplaires / scan passent par `BookService` + `BooksRepository` (`main`, `HomePage`, `BookDetailPage`, `AddBookPage`, `IsbnScannerPage`, `CopyFormPage`).  
  *Hors scope pour l’instant :* `LibraryTransferService` / `FamilyTransferService` (import-export) et pages utilisateurs / avis perso restent sur `AppDb` pour les tables users & metas.

## À faire

- [ ] **Structuration par features**  
  Introduire une structure par feature (`books`, `users`, `family`, `import_export`) avec séparation `data` / `domain` / `ui`.

- [ ] **Validation ISBN**  
  Renforcer la validation et la normalisation des ISBN (formulaire et scanner) avant tout appel réseau (longueur, chiffres, préfixe 978/979, etc.).

- [ ] **Logging réseau**  
  Remplacer les `print` par un logger configurable (debug uniquement, pas de données sensibles dans les messages).

- [ ] **Sécurisation stockage**  
  Étudier et, si nécessaire, mettre en place un chiffrement de la base SQLite ou au moins des champs les plus sensibles.

- [ ] **Protection d’accès locale**  
  Ajouter une protection d’accès à l’app (PIN, biométrie ou écran de verrouillage) si les données utilisateur doivent être protégées sur l’appareil.

---
*Mis à jour : actions issues du refactoring et de l’analyse architecture/sécu.*
