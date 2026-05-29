# Fixes Log

A chronological log of bug fixes applied to this project. Each entry: date, symptom, root cause, files touched, follow-up steps.

---

## 2026-05-29 — `PlatformException(KeyringLocked)` on Linux at first auth read

### Symptom

`lib/core/storage/secure_storage.dart:16` threw at app startup the moment
`AuthBloc` ran `AuthCheckRequested`:

```text
PlatformException(KeyringLocked, KeyringLocked, null, null)
```

### Root cause

`flutter_secure_storage` v10 on Linux is backed by libsecret → GNOME keyring.
The `gnome-keyring-daemon` was running, but the **Login keyring was locked**
(common on auto-login sessions or when the keyring password differs from the
login password). Every read/write/delete on libsecret throws `KeyringLocked`
in this state, with no fallback in the package. The original
`SecureStorage` made bare calls with no error handling, so a routine startup
read crashed the auth flow.

### Fix

- Rewrote `lib/core/storage/secure_storage.dart` to:
  - Introduce a typed `SecureStorageLockedException`.
  - Wrap reads/deletes: return `null` / no-op on `KeyringLocked` (graceful
    degradation — caller sees "no token", app falls back to the login screen
    instead of crashing).
  - Wrap writes: throw `SecureStorageLockedException` with a French
    user-facing message so callers (BLoCs) can surface it cleanly.
  - Add a `probe()` method that attempts a sentinel read so callers can
    detect the locked state up front.
- `lib/main.dart`: on Linux only, call `SecureStorage.probe()` after DI
  setup; pass the result into `App(secureStorageLocked: …)`.
- `lib/app.dart`: when `secureStorageLocked` is true, schedule a one-time
  post-frame `AlertDialog` (rendered via GoRouter's navigator context) that
  explains the lock state and how to unlock via Seahorse.

### Files touched

- `lib/core/storage/secure_storage.dart` — full rewrite with error handling
  + `probe()` + typed exception.
- `lib/main.dart` — added Linux probe + flag passthrough to `App`.
- `lib/app.dart` — `App.secureStorageLocked` field, post-frame warning
  dialog.

### Follow-up (manual)

Unlock the keyring once so the app can persist tokens:

```bash
# GUI (recommended):
#   Open Seahorse → Passwords → Login → right-click → Unlock
#   (or set an empty password so GDM auto-unlocks on every login)

# CLI smoke test that triggers the unlock prompt:
secret-tool lookup test test
```

Then `flutter run -d linux` again — the warning dialog should no longer
appear and login will persist across restarts.

---

## 2026-05-29 — SqfliteFfiException on Linux: `sqlite3_initialize` not found

### Symptom

At app startup on Linux, the first access to `DatabaseService.database`
(`lib/core/database/database_service.dart:16`) threw:

```text
SqfliteFfiException: Couldn't resolve native function 'sqlite3_initialize'
  in 'package:sqlite3/src/ffi/libsqlite3.g.dart'
  No asset with id 'package:sqlite3/src/ffi/libsqlite3.g.dart' found.
  No available native assets. Attempted to fallback to process lookup.
  libflutter_linux_gtk.so: undefined symbol: sqlite3_initialize.
```

### Root cause

Two compounding issues:

1. **No native SQLite available on Linux.** `sqflite_common_ffi` on Linux
   tries to load `libsqlite3.so` via `DynamicLibrary.process()` then the
   system loader. Neither resolves because (a) Flutter's Linux GTK shell
   doesn't link sqlite3, and (b) no asset-bundled SQLite was declared.
2. **FFI init ordering in `main.dart`.** `sqfliteFfiInit()` and
   `databaseFactory = databaseFactoryFfi` ran **after**
   `setupDependencies()`, so any DI step that touched the DB would use
   the default (mobile) factory.

### Fix

- Added `sqlite3_flutter_libs: ^0.5.24` to `pubspec.yaml` to bundle a
  native SQLite library on Linux/Windows/macOS (no system install needed).
- Rewrote `lib/main.dart` to:
  - Initialize FFI **before** `setupDependencies()`.
  - Guard the FFI init with `!kIsWeb && (Platform.isLinux || Platform.isWindows || Platform.isMacOS)` so mobile (Android/iOS) still uses native `sqflite`.

### Files touched

- `pubspec.yaml` — added `sqlite3_flutter_libs`.
- `lib/main.dart` — reordered init + added platform guard.

### Follow-up (manual)

```bash
flutter pub get
flutter clean        # required: Linux build bundle is stale
flutter run -d linux
```
