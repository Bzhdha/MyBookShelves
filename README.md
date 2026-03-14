# MyBookShelves — Bibliothèque BD

Application Flutter pour gérer une bibliothèque de bandes dessinées : cataloguer séries et ouvrages, gérer les exemplaires (notes, avis, état), partager la bibliothèque en famille et importer/exporter les données.

## Structure du projet

- **`bd_library_app/`** — Application Flutter (Bibliothèque BD)
  - Base de données locale (Drift/SQLite) : séries, livres, exemplaires, utilisateurs, avis par membre
  - Interface : liste des BD, détail livre, ajout manuel, scan ISBN, import/export, gestion des membres famille

## Fonctionnalités

- **Séries et livres** : séries avec nombre de tomes attendu, livres avec ISBN, titre, tome, auteurs, éditeur, date, couverture
- **Exemplaires** : plusieurs exemplaires par livre ; note (0–5), avis, état (1–5), emplacement, notes
- **Membres famille** : profils utilisateurs ; note/avis personnels par exemplaire, statut (lu, à lire, wishlist…), prêt entre membres
- **Scan ISBN** : ajout rapide via code-barres (mobile_scanner)
- **Métadonnées** : recherche Open Library et BdTheque pour compléter automatiquement les infos et la couverture ; cache local des couvertures
- **Import / Export**
  - **JSON** : import avec revue des conflits (garder local, importer, fusionner) ; export JSON partageable
  - **ZIP** : export complet (library.json + dossiers de couvertures) ; import depuis ZIP avec plan d’import
  - **Famille** : export/import incluant utilisateurs et `UserCopyMetas` (family.json v3)

## Prérequis

- [Flutter](https://docs.flutter.dev/get-started/install) (SDK ^3.10.7)
- Pour Android : JDK 17 pour la build release

## Démarrage

```bash
cd bd_library_app
flutter pub get
dart run build_runner build --delete-conflicting-outputs   # génération Drift (app_db.g.dart)
flutter run
```

Cibler un appareil ou un émulateur avec `flutter run -d <device_id>` (voir `flutter devices`).

## Build release (APK)

```bash
cd bd_library_app
flutter build apk --release
```

L’APK est généré dans `bd_library_app/build/app/outputs/flutter-apk/`.

### Build APK via GitHub Actions

Un workflow **Build APK** est défini dans `.github/workflows/build-apk.yml` :

- **Déclenchement** : manuel (`workflow_dispatch`) ou à chaque push sur `main`/`master` touchant `bd_library_app/**`
- **Actions** : checkout, Java 17, Flutter 3.41.4, `flutter pub get`, `flutter build apk --release`, upload de l’APK en artefact

Pour lancer manuellement : onglet **Actions** du dépôt → **Build APK** → **Run workflow**.

## Stack technique

| Domaine        | Techno |
|----------------|--------|
| UI / état      | Flutter, Provider |
| Base de données| Drift (SQLite), drift_flutter |
| Métadonnées    | Open Library, BdTheque (http, html) |
| Fichiers       | file_picker, path_provider, archive |
| Partage        | share_plus |
| Scan           | mobile_scanner |
| Persistance    | shared_preferences, uuid |

## Licence

Projet personnel — pas de licence spécifique précisée.
