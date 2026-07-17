# Guide de développement

Ce document rassemble les commandes et conventions pour développer sur **Gestion Paroissiale**.

## Commandes courantes

```bash
flutter run                     # Lancer en mode debug
flutter run -d chrome           # Cible Web
flutter devices                 # Lister les appareils
flutter analyze                 # Analyse statique
dart format lib                 # Formatage
flutter test                    # Tests
```

Dans l'app en cours d'exécution : `r` = hot reload, `R` = redémarrage complet.

### Régénération de code (Isar)

Après toute modification de `lib/core/database/cached_entity.dart` ou `pending_change_entity.dart` :

```bash
dart run build_runner build --delete-conflicting-outputs
```

## Ajouter une nouvelle fonctionnalité

1. **BLoC** - `lib/presentation/blocs/<feature>/` (events, states, bloc).
2. **Repository** - `lib/data/repositories/` (appels API via `DioClient`).
3. **DI** - enregistrer dans `lib/core/di/injection.dart` (repository en lazy singleton, BLoC en factory).
4. **Écrans** - `lib/presentation/screens/<feature>/`.
5. **Routes** - `lib/core/router/app_router.dart`.
6. **Modèles** - `lib/data/models/` (avec `fromJson`/`toJson`).
7. **Provider** - ajouter le `BlocProvider` dans `lib/app.dart`.

## Conventions de code

- **Equatable** pour l'égalité de valeur (modèles, events, states) - tous les champs dans `props`.
- Constructeurs **`const`** pour les widgets immuables ; `copyWith()` pour les modèles.
- BLoCs : pattern `on<EventType>`, gestion des erreurs dans le repository, émission d'un état d'erreur.
- Requêtes concurrentes : `Future.wait()`.
- **Texte utilisateur** issu d'exceptions : `messageOf(e)`, jamais `e.toString()`.
- **Datetimes** : envoi en **UTC** (`dt.toUtc().toIso8601String()`), affichage en **local** (`.toLocal()`).
- **Thème** : les neutres (`AppTheme.textPrimary`, `surfaceColor`, …) sont des getters runtime → ne pas les mettre dans une expression `const`. Les couleurs de marque (`primaryColor`, `secondaryColor`, `accentColor`) restent `const`.

## Cache & synchronisation

- Requête **sans filtre** → cache utilisé si valide (< 5 min).
- Requête **filtrée** (recherche, pagination, dates) → toujours envoyée au serveur.
- Création/modification/suppression → le cache se rafraîchit au prochain cycle (max 5 min) ou via `forceSyncNow()`.

Contrôle manuel :

```dart
final syncManager = sl<PeriodicSyncManager>();
await syncManager.forceSyncNow();
await syncManager.forceEntitySync('membres');
await syncManager.clearCache();
final isOnline = await syncManager.isOnline();
```

Voir [`database.md`](database.md) pour le détail du cache et de la synchronisation.

## Tests

- La structure de `test/` reflète celle de `lib/`.
- BLoCs : utilisez `blocTest` et mockez les repositories / `DioClient`.

```bash
flutter test
flutter test --coverage
```

## Qualité & CI

Avant de pousser :

```bash
dart format lib
flutter analyze
flutter test
```

La CI (voir `.github/workflows/ci.yml`) rejoue ces étapes et construit le Web et l'APK.

## Journalisation des correctifs

Tout correctif de bug **doit** être consigné en haut de [`fix.md`](../fix.md) : date, symptôme, cause racine, fichiers touchés, suivi.
