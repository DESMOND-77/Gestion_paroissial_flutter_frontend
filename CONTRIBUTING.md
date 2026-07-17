# Guide de contribution

Merci de l'intérêt que vous portez à **Gestion Paroissiale** ! Ce document décrit comment contribuer efficacement au projet. Toute contribution — code, documentation, tests, rapports de bugs — est la bienvenue.

En participant, vous acceptez de respecter notre [Code de conduite](CODE_OF_CONDUCT.md).

## Sommaire

- [Prérequis](#prérequis)
- [Mise en place de l'environnement](#mise-en-place-de-lenvironnement)
- [Workflow Git (GitHub Flow)](#workflow-git-github-flow)
- [Stratégie de branches](#stratégie-de-branches)
- [Convention de commits](#convention-de-commits)
- [Style de code, linting et formatage](#style-de-code-linting-et-formatage)
- [Tests](#tests)
- [Documentation](#documentation)
- [Ouvrir une Issue](#ouvrir-une-issue)
- [Pull Requests](#pull-requests)
- [Revue de code](#revue-de-code)

## Prérequis

- Flutter SDK ≥ 3.3.0 (canal stable)
- Un backend Gestion Paroissiale accessible pour tester les fonctionnalités réseau

Vérifiez votre installation avec `flutter doctor`.

## Mise en place de l'environnement

```bash
git clone https://github.com/DESMOND-77/Gestion_paroissial_flutter_frontend.git
cd Gestion_paroissial_flutter_frontend
flutter pub get
flutter analyze
flutter test
```

Après toute modification de `lib/core/database/cached_entity.dart`, régénérez le code :

```bash
dart run build_runner build --delete-conflicting-outputs
```

## Workflow Git (GitHub Flow)

Nous suivons le **GitHub Flow** :

1. **Forkez** le dépôt (contributeurs externes) ou créez une branche (mainteneurs).
2. Créez une **branche descriptive** depuis `main`.
3. Effectuez des commits atomiques et bien nommés.
4. Poussez votre branche et ouvrez une **Pull Request**.
5. Répondez aux retours de la revue de code.
6. Une fois approuvée et la CI verte, la PR est fusionnée (squash recommandé).

> Ne poussez jamais directement sur `main`.

## Stratégie de branches

Utilisez des préfixes explicites :

| Préfixe | Usage |
| --- | --- |
| `feat/` | Nouvelle fonctionnalité |
| `fix/` | Correction de bug |
| `docs/` | Documentation uniquement |
| `refactor/` | Refactorisation sans changement de comportement |
| `test/` | Ajout ou correction de tests |
| `chore/` | Maintenance, dépendances, outillage |

Exemple : `feat/inscription-evenement-offline`.

## Convention de commits

Nous utilisons les [**Conventional Commits**](https://www.conventionalcommits.org/fr/) :

```
<type>(<portée optionnelle>): <description courte>

[corps optionnel]

[pied de page optionnel]
```

**Types acceptés** : `feat`, `fix`, `docs`, `style`, `refactor`, `perf`, `test`, `build`, `ci`, `chore`, `revert`.

Exemples :

```
feat(evenements): ajouter l'inscription hors ligne
fix(auth): corriger le rafraîchissement du jeton sur 401
docs(readme): compléter la section configuration
```

Les changements incompatibles (breaking changes) sont indiqués par `!` ou un pied de page `BREAKING CHANGE:`.

## Style de code, linting et formatage

Le projet respecte les règles de [`flutter_lints`](analysis_options.yaml) et les conventions décrites dans [`CLAUDE.md`](CLAUDE.md) :

- Utilisez `Equatable` pour l'égalité de valeur (modèles, events, states).
- BLoCs : pattern `on<EventType>`, states/events dans `props`.
- Constructeurs `const` pour les widgets immuables ; `copyWith()` pour les modèles.
- Pour le texte utilisateur issu d'exceptions API, utilisez `messageOf(e)`, jamais `e.toString()`.
- Datetimes : envoi en **UTC**, affichage en **local** (`.toLocal()`).

Avant chaque commit :

```bash
dart format lib
flutter analyze
```

Aucun avertissement de `flutter analyze` ne doit subsister.

## Tests

```bash
flutter test
```

- Ajoutez des tests pour toute nouvelle logique (BLoC, repository, utilitaire).
- Pour les BLoCs, utilisez `blocTest` et mockez les repositories / `DioClient`.
- La structure de `test/` reflète celle de `lib/`.

## Documentation

- Mettez à jour le `README.md` et le dossier `docs/` si votre changement affecte l'usage.
- **Tout correctif de bug** doit être consigné en haut de [`fix.md`](fix.md) : date, symptôme, cause racine, fichiers touchés, suivi.
- Mettez à jour [`CHANGELOG.md`](CHANGELOG.md) sous la section `[Non publié]`.

## Ouvrir une Issue

Avant d'ouvrir une Issue :

1. Recherchez les Issues existantes pour éviter les doublons.
2. Choisissez le bon modèle (bug, fonctionnalité, question).
3. Fournissez un maximum de contexte : version de Flutter, plateforme, étapes de reproduction, logs.

## Pull Requests

Une bonne PR :

- Est liée à une Issue (`Closes #123`) lorsque c'est pertinent.
- Reste **focalisée** sur un seul sujet.
- Passe la CI (analyse, tests, build).
- Contient une description claire et remplit le modèle de PR.
- Met à jour la documentation et le `CHANGELOG.md`.

## Revue de code

- Restez courtois et constructif (voir le Code de conduite).
- Répondez à chaque commentaire, même par « corrigé ».
- Au moins une approbation d'un mainteneur est requise avant fusion.
- Les mainteneurs privilégient le **squash & merge** pour garder un historique lisible.

Merci pour votre contribution ! 🙏
