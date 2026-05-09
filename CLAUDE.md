# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a Flutter application called **Gestion Paroissiale** (Parish Management System), a comprehensive management platform for parishes with features for members, groups, events, finances, and a library system.

- **Language**: Dart (Flutter)
- **Min SDK**: 3.3.0
- **Target Platforms**: iOS, Android, macOS, Web

## Architecture

The project follows **Clean Architecture** with three main layers:

### `/lib/core`
Infrastructure and configuration layer:
- **`constants/`**: API endpoints and app constants
- **`di/`**: Dependency injection setup using GetIt (`injection.dart` - registers all repositories and BLoCs)
- **`network/`**: Dio HTTP client and exception handling
- **`router/`**: GoRouter configuration with nested routes and auth guards
- **`theme/`**: Material design theme definitions
- **`storage/`**: Secure token storage using flutter_secure_storage

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

## Common Development Commands

```bash
# Get dependencies
flutter pub get

# Run the app (debug mode)
flutter run

# Run the app on specific device
flutter run -d <device-id>

# List connected devices
flutter devices

# Hot reload during development
r (in running app)

# Full app restart
R (in running app)

# Format code
flutter format lib

# Analyze code
flutter analyze

# Run tests
flutter test

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

- **Base URL**: Defined in `lib/core/constants/api_constants.dart`
- **Client**: `DioClient` handles:
  - Authorization headers with JWT tokens
  - Token refresh logic
  - Request/response interceptors
  - Exception handling and parsing
- **Auth Flow**: Login stores access and refresh tokens in secure storage; they're auto-included in requests

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
**Solution**: DioClient handles token refresh automatically

**Issue**: Screen not responding to BLoC changes  
**Solution**: Ensure BlocProvider is above BlocListener/BlocBuilder in widget tree

**Issue**: State not updating  
**Solution**: Ensure events extend Equatable with proper props lists for equality

## Key Dependencies

- `flutter_bloc`: State management
- `go_router`: Navigation
- `dio`: HTTP client
- `get_it`: Service locator/DI
- `responsive_framework`: Responsive layouts
- `flutter_secure_storage`: Secure data storage
- `shared_preferences`: Local storage
- `cached_network_image`: Image caching
- `fl_chart`: Charts and statistics
- `data_table_2`: Advanced data tables
- `sidebarx`: Sidebar navigation
- `equatable`: Value equality helper
