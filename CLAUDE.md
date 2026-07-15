# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a Flutter application called **Gestion Paroissiale** (Parish Management System), a comprehensive management platform for parishes with features for members, groups, events, finances, and a library system.

- **Language**: Dart (Flutter)
- **Min SDK**: 3.3.0
- **Target Platforms**: Android, iOS, Linux, macOS, Windows, and Web (all six are scaffolded; the `isar_plus` caching layer is chosen specifically because it supports all of them — see Local Caching System)

## Architecture

The project follows **Clean Architecture** with three main layers:

### `/lib/core`

Infrastructure and configuration layer:

- **`constants/`**: API endpoints and app constants
- **`di/`**: Dependency injection setup using GetIt (`injection.dart` - registers all repositories and BLoCs)
- **`network/`**: Dio HTTP client and exception handling
- **`router/`**: GoRouter configuration with nested routes and auth guards
- **`theme/`**: Material design theme definitions
- **`storage/`**: `SecureStorage` (JWT tokens via flutter_secure_storage) and `FileStorageService` (`file_storage_service.dart`) — caches downloaded files (e.g. profile pictures) to disk via `path_provider` for offline use; `AuthRepository` uses it for profile-picture caching
- **`database/`**: Isar (`isar_plus`) local cache — see Local Caching System
- **`sync/`**: Background sync (`PeriodicSyncManager`, `SyncService`) — see Local Caching System

### `/lib/data`

Data layer responsible for API communication and models:

- **`models/`**: JSON-serializable data models (AuthUser, LoginResponse, Member, Group, Event, Finance, Article, etc.)
- **`repositories/`**: Repository classes that abstract data sources (auth, membres, groupes, evenements, finances, librairie)
  - Each repository handles API calls via DioClient
  - AuthRepository also manages token persistence

### `/lib/presentation`

UI and state management layer:

- **`blocs/`**: State management using BLoC pattern
  - Each feature has: `*_bloc.dart` (events, states, BLoC class), `*_event.dart`, `*_state.dart` (separated in some cases)
  - BLoCs follow event-driven architecture with Equatable for value equality
  - 7 main BLoCs: AuthBloc, MembresBloc, GroupesBloc, EvenementsBloc, FinancesBloc, LibrairieBloc, DashboardBloc
- **`screens/`**: Feature screens (auth, dashboard, membres, groupes, evenements, finances, librairie, profile)
  - Nested navigation: detail and form screens under parent feature screens
- **`widgets/`**: Reusable UI components (MainLayout, AppDrawer, StatCard, LoadingWidget, responsive text)

## Routing Structure

Uses **GoRouter** with nested routes:

- **Auth routes** (unauthenticated only):
  - `/login`, `/register`, `/forgot-password`
- **Main routes** (require authentication via ShellRoute):
  - `/dashboard` - Dashboard with statistics
  - `/membres` - Members list, detail, create/edit forms
  - `/groupes` - Groups management
  - `/evenements` - Events management
  - `/finances` - Financial transactions
  - `/librairie` - Library (articles & sales)
  - `/profile` - User profile

Auth guard in `AppRouter.redirect()` enforces authentication state.

## State Management (BLoC Pattern)

All screens use **flutter_bloc** with the following pattern:

```dart
// Events (user actions)
abstract class FeatureEvent extends Equatable { }

// States (UI states)
abstract class FeatureState extends Equatable { }
class FeatureInitial extends FeatureState { }
class FeatureLoading extends FeatureState { }
class FeatureSuccess extends FeatureState { }
class FeatureError extends FeatureState { }

// BLoC
class FeatureBloc extends Bloc<FeatureEvent, FeatureState> {
  final FeatureRepository repository;
  FeatureBloc({required this.repository}) : super(FeatureInitial()) {
    on<FeatureEventRequested>(_onFeatureEventRequested);
  }
  Future<void> _onFeatureEventRequested(FeatureEvent event, Emitter emit) async {
    emit(FeatureLoading());
    try {
      final result = await repository.fetchFeature();
      emit(FeatureSuccess(result));
    } catch (e) {
      emit(FeatureError(e.toString()));
    }
  }
}
```

## Dependency Injection

All dependencies are set up in `lib/core/di/injection.dart`:

- Repositories are registered as **lazy singletons** (created on first use, then cached)
- BLoCs are registered as **factories** (new instance per request, except AuthBloc which is a singleton)
- DioClient and SecureStorage are lazy singletons
- Use `sl<ClassName>()` to retrieve instances

## Responsive Design

Uses **responsive_framework** package with breakpoints:

- `MOBILE` (0-450px)
- `TABLET` (451-800px)
- `DESKTOP` (801-1920px)
- `4K` (1921px+)

Check screen width with `ResponsiveValue` or `ResponsiveBreakpoints.of(context).isPhone`.

## Internationalization

- French locale configured by default (`intl` package with `fr_FR`)
- Date formatting initialized in `main.dart`

## Setup & Common Development Commands

### Initial Setup

```bash
# Get dependencies (required after cloning or adding packages)
flutter pub get
```

### Development

```bash
# Run the app (debug mode)
flutter run

# Run the app on specific device
flutter run -d <device-id>

# List connected devices
flutter devices

# Hot reload during development (press in running app)
r

# Full app restart (press in running app)
R

# Format code
flutter format lib

# Analyze code for issues
flutter analyze

# Run tests
flutter test
```

### Building

```bash
# Build release APK (Android)
flutter build apk

# Build release IPA (iOS)
flutter build ios --release
```

## Adding a New Feature

1. **Create BLoC** in `lib/presentation/blocs/<feature>/`:
   - Define Events, States, and BLoC class
   - Create events and states (or separate files if complex)

2. **Create Repository** in `lib/data/repositories/`:
   - Implement API calls using DioClient
   - Handle data conversion with models

3. **Register in DI** (`lib/core/di/injection.dart`):
   - Register repository as lazy singleton
   - Register BLoC as factory

4. **Create Screens** in `lib/presentation/screens/<feature>/`:
   - List screen (shows data via BlocBuilder)
   - Detail/Edit screens

5. **Add Routes** to `lib/core/router/app_router.dart`:
   - Add GoRoute(s) to appropriate location

6. **Create Models** in `lib/data/models/`:
   - JSON serializable classes with fromJson/toJson

7. **Add Provider** in `lib/app.dart`:
   - Add BlocProvider to MultiBlocProvider list

## Code Style & Patterns

- Use **Equatable** for value equality in models and events
- BLoCs use `on<EventType>` pattern for event handlers
- Use **const** constructors for immutable widgets and data classes
- Models use `copyWith()` for immutability
- Repositories abstract data sources from BLoCs
- Use secure_storage for sensitive data (tokens, passwords)
- Handle API errors in repositories and emit appropriate error states
- Use Future.wait() for concurrent API calls when needed

## API Communication

- **Base URL**: Defined in `lib/core/constants/api_constants.dart` (e.g., `http://127.0.0.1:8000/api`)
- **API Endpoints Reference**: `./api_endpoints.json` contains the Swagger specification for all available API endpoints (for reference/documentation)
- **Client**: `DioClient` in `lib/core/network/dio_client.dart` handles:
  - Authorization headers with JWT tokens from secure storage
  - Automatic token refresh on 401 responses
  - Request/response interceptors
  - Exception handling and parsing
- **Auth Flow**:  
  - Login via `AuthRepository.login()` stores access and refresh tokens in `SecureStorage`
  - Tokens are automatically included in all subsequent requests via DioClient interceptor
  - Token refresh is transparent—no need for manual re-authentication on expiry

## Local Caching System

Reduces server load and enables offline functionality. Auto-initialized in `main.dart` via `PeriodicSyncManager.startPeriodicSync()`.

### Database Architecture

- **Isar NoSQL Database** (`lib/core/database/database_service.dart`, via the `isar_plus` package):
  - Two collections defined in `lib/core/database/cached_entity.dart`: `CachedEntity` (one JSON blob per `(entityType, entityId)`, standing in for what used to be five separate SQLite tables — `membres`, `groupes`, `evenements`, `finances`, `librairie`) and `SyncMetadataEntity` (last sync timestamp per entity type, replaces the old `sync_metadata` table)
  - `DatabaseService`'s public API (`saveItems`/`getItems`/`getItemById`/`getLastSyncTime`/`isCacheValid`/`hasData`/`clearDatabase`/`clearTable`/`close`) is unchanged from the old SQLite implementation on purpose — `SyncService` and all 5 repositories call it exactly as before; only the storage engine changed
  - Ids are deterministic (`Isar.fastHash('$entityType|$entityId')`), not auto-incremented — `getItemById` is an O(1) primary-key read, not a filtered query
  - Schema is generated code: after editing `cached_entity.dart`, run `dart run build_runner build --delete-conflicting-outputs` to regenerate `cached_entity.g.dart`

### Cross-platform setup (Android/iOS/Linux/macOS/Windows/Web)

- `isar_plus` (not the original/unmaintained `isar` or web-less `isar_community`) is the only Isar fork with genuine support for all of Android, iOS, Linux, macOS, Windows **and** Web — required since this app targets all of them
- Native platforms: `isar_plus_flutter_libs` bundles the native engine per platform automatically, no manual init needed in `main.dart`
- Web: the engine runs as WASM and must be loaded explicitly before first use — `main.dart` calls `await Isar.initialize('isar_plus.wasm')` when `kIsWeb`. The `.wasm`/`.js` pair is **self-hosted** under `web/isar_plus.{wasm,js}` (copied from `unpkg.com/isar_plus@<version>`) rather than fetched from the CDN at runtime, in keeping with the app's offline-first design — if you bump `isar_plus`'s version, re-download both files for the new version from unpkg and keep them in sync with the pinned pubspec version
- `isar_plus` embeds its own code generator (registered via its `build.yaml`, builder name `isar_generator`) — no separate `isar_plus_generator` package exists, just `build_runner` as a dev dependency
- `isar_plus` currently requires `meta: ^1.18.0`, newer than the version pinned by the bundled Flutter SDK's `flutter_test` — hence the `dependency_overrides: meta: ^1.18.0` in `pubspec.yaml`. Remove it only once the Flutter SDK's own `meta` pin catches up.

### Sync Strategy

Each 5-minute cycle (`PeriodicSyncManager._syncCycle`) runs two steps in order: **push then pull**.

- **Push — offline writes** (`lib/core/sync/offline_sync_service.dart`, `OfflineSyncService.pushPull`): sends the local outbox to `POST /api/v1/sync/` (bidirectional endpoint), then processes `results` (applied → dequeue; conflicts → server copy overwrites cache, last-write-wins on `updated_at`; errors → logged + dequeued to avoid a poison-pill loop), merges server `changes` into the cache, and advances the sync cursor (`server_time`). Backend collection names map to cache entity types via `OfflineSyncService._cacheEntityType` (`transactions`→`finances`, `articles`→`librairie`, etc.).
- **Pull — REST refresh** (`SyncService.syncAll`): the historical pull path, still the authority for the 5 read entity types (reloads full lists into cache).
- **Offline writes**: repository `create/update/patch/delete` call the API directly when online (unchanged); on `NetworkException` they fall back to `queueOfflineWrite` (`lib/core/sync/offline_write.dart`) → enqueue in the `PendingChangeEntity` outbox + optimistic cache write. Client-generated UUIDs (`lib/core/utils/id_generator.dart`) keep offline-created ids stable through sync (backend `WritableIDModelSerializer` accepts them). A record's outbox row carries the business fields plus `updated_at` and `is_deleted` (a delete is `is_deleted: true`, not a removed row).
- The `PendingChangeEntity` field is named `syncCollection`, **not** `collection` — a field literally named `collection` collides with the isar_plus generator's internal variable and breaks the generated `.g.dart`.
- **Not yet offline-capable**: event registration (`inscrire` / `participations`) and self-profile edit (`updateMyMembre`) stay online-only.
- When fetching data from repositories:
  1. **No filters** → Check local cache first; return if valid (< 5 min old)
  2. **Cache miss/expired** → Fetch from server and update cache
  3. **With filters/pagination** → Always hit server (cache ignored for accurate results)
- **Connectivity detection** via `connectivity_plus` (syncs only when online)

### Cache Invalidation & Updates

- Cache is valid for 5 minutes; after that, fresh data is fetched on next request
- Filtered queries **always bypass cache** (e.g., `search`, pagination, date ranges)
- Creating/updating/deleting items: cache is NOT updated immediately—it refreshes on next sync cycle (max 5 min wait)
- Manual cache control:

  ```dart
  final syncManager = sl<PeriodicSyncManager>();
  await syncManager.forceSyncNow();        // Force immediate sync
  await syncManager.forceEntitySync('membres');  // Sync specific entity
  await syncManager.clearCache();          // Clear all cached data
  final isOnline = await syncManager.isOnline();  // Check connectivity
  ```

### Using the Cache System

```dart
// In repositories: unfiltered queries use cache
final membres = await _membreRepository.getMembres();  // Uses cache if available

// Filtered queries always hit server
final filtered = await _membreRepository.getMembres(search: 'Jean');

// This request goes to server even if cache exists
final sorted = await _membreRepository.getMembres(page: 2);
```

### Offline Mode

- App functions with local cache when offline
- Sync attempts skip automatically when no internet
- On reconnect, next scheduled sync (or `forceSyncNow()`) refreshes all data
- **Note**: Filtered queries won't work offline (they require server-side filtering)

### Debugging Cache Issues

- **"Cache shows old data"**: Normal behavior—cache refreshes every 5 minutes, or use `forceSyncNow()` for immediate refresh
- **"Item I just created doesn't appear"**: Expected—cache syncs periodically, not on every create/update
- **"App works fine online but shows nothing offline"**: Ensure cache has data before going offline; requets with filters bypass cache
- **"Need more details?"**: See `CACHE_USAGE_GUIDE.md` for practical examples and troubleshooting (French)

## Testing

Test file structure mirrors src:

- `test/widget_test.dart` contains basic app tests
- To test BLoCs: use `blocTest` from `flutter_bloc`
- Mock repositories and DioClient in tests

## Performance Considerations

- BLoCs are instantiated as factories per screen (except AuthBloc)
- Use `cached_network_image` for image caching
- Use `auto_size_text` for responsive text scaling
- MainLayout uses ShellRoute to prevent rebuilds
- Implement pagination in list screens for large datasets

## Common Issues & Solutions

**Issue**: Auth token expired  
**Solution**: DioClient handles token refresh automatically on 401 responses

**Issue**: Screen not responding to BLoC changes  
**Solution**: Ensure BlocProvider is above BlocListener/BlocBuilder in widget tree; check that events/states extend Equatable with all fields in props

**Issue**: State not updating after event dispatch  
**Solution**: Verify events and states extend Equatable and include all fields in the `props` list for proper equality checking

**Issue**: Data not persisting locally or showing old cached data  
**Solution**: Check that repositories are using `DatabaseService` for cache operations; manually call `forceSyncNow()` to update cache immediately

**Issue**: Queries with filters returning wrong results  
**Solution**: Filtered queries (`search`, pagination, date ranges) always hit the server—this is intentional; for cache-only filtering, fetch unfiltered data and filter locally

**Issue**: Database locked / "Isar instance not found" errors  
**Solution**: Ensure only one instance of `DatabaseService` is used (registered as lazy singleton in DI); check that async database operations aren't blocking the UI thread

**Issue**: `IsarNotReadyError` on web ("call Isar.initialize() manually before using Isar")  
**Solution**: Confirm `main.dart` calls `await Isar.initialize('isar_plus.wasm')` when `kIsWeb`, before `setupDependencies()`, and that `web/isar_plus.wasm` + `web/isar_plus.js` exist and match the `isar_plus` version pinned in `pubspec.yaml`.

**Issue**: Isar schema changes not taking effect  
**Solution**: Re-run `dart run build_runner build --delete-conflicting-outputs` after editing `lib/core/database/cached_entity.dart` to regenerate `cached_entity.g.dart`.

## Key Dependencies

- `flutter_bloc`: State management
- `go_router`: Navigation
- `dio`: HTTP client
- `get_it`: Service locator/DI
- `responsive_framework`: Responsive layouts
- `flutter_secure_storage`: Secure data storage (JWT tokens, credentials)
- `shared_preferences`: Local key-value storage
- `cached_network_image`: Image caching
- `fl_chart`: Charts and statistics (dashboard)
- `data_table_2`: Advanced data tables
- `sidebarx`: Sidebar navigation
- `equatable`: Value equality helper
- `isar_plus` / `isar_plus_flutter_libs`: NoSQL database for local caching (Android/iOS/Linux/macOS/Windows/Web)
- `connectivity_plus`: Network connectivity detection
- `intl`: Internationalization (French locale)
- `path_provider`: Resolves platform cache/documents dirs (used by `FileStorageService`)
- `image_picker`: Picking profile/article images from gallery or camera
- `lottie`: Animated illustrations (e.g. splash screen)
- `flutter_native_splash` / `flutter_launcher_icons`: Generate native splash screens and app launcher icons (config lives in `pubspec.yaml`; regenerate with `dart run flutter_native_splash:create` / `dart run flutter_launcher_icons`)

## Key Configuration Files

- **`pubspec.yaml`**: Dependencies and Flutter configuration
- **`lib/core/constants/api_constants.dart`**: API base URL and endpoints
- **`./api_endpoints.json`**: Swagger/OpenAPI spec for reference
- **`lib/core/di/injection.dart`**: Dependency injection setup
- **`lib/core/router/app_router.dart`**: Navigation and route guards
- **`lib/core/theme/app_theme.dart`**: Material theme definitions
- **`lib/core/sync/periodic_sync_manager.dart`**: Cache sync configuration (5-minute interval)
- **`lib/main.dart`**: App entry point and initialization
- **`fix.md`**: Chronological bug-fix log. Every bug fix gets a dated entry with symptom, root cause, files touched, and follow-up steps — append a new section at the top when fixing a bug.

## Code Organization Quick Reference

| Need to... | Look in... |
| ----------- | ----------- |
| Add a new API endpoint | `lib/data/repositories/<feature>_repository.dart`, then expose in BLoC |
| Cache a new entity type offline | Just add `_sync<Entity>()` in `lib/core/sync/sync_service.dart` calling `saveItems('<entityType>', ...)` — `database_service.dart`/`cached_entity.dart` need no changes, the `CachedEntity` collection is generic |
| Create new screen | `lib/presentation/screens/<feature>/` and add route to `lib/core/router/app_router.dart` |
| Create new BLoC | `lib/presentation/blocs/<feature>/` (events, states, bloc class) |
| Create new model | `lib/data/models/` (ensure JSON serializable with fromJson/toJson) |
| Configure theme colors | `lib/core/theme/app_theme.dart` |
| Manage responsive breakpoints | `lib/core/theme/app_theme.dart` or check `ResponsiveBreakpoints` in screens |
