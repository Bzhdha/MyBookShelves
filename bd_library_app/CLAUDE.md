# Règles projet

## Git
Après chaque commit, toujours faire un `git push` vers le repo distant.

Avant de pousser des commits sur une branche existante, vérifier si la PR associée est déjà mergée (`mcp__github__pull_request_read` method `get`). Si c'est le cas, créer une nouvelle branche et ouvrir une nouvelle PR plutôt que de pousser sur la branche mergée.

Une fois la PR créée et le CI vert, la merger automatiquement via `mcp__github__merge_pull_request` sans attendre de validation manuelle.

## Style de code
Minifier le code Dart : variables courtes, pas d'espaces superflus, tout sur le moins de lignes possible. L'utilisateur ne lit pas le code source directement.
