import 'dart:io' show Platform;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'core/di/injection.dart';
import 'core/storage/secure_storage.dart';
import 'core/sync/periodic_sync_manager.dart';
import 'app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (!kIsWeb && (Platform.isLinux || Platform.isWindows || Platform.isMacOS)) {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }

  await setupDependencies();
  await initializeDateFormatting('fr_FR', null);

  var secureStorageLocked = false;
  if (!kIsWeb && Platform.isLinux) {
    secureStorageLocked = !(await sl<SecureStorage>().probe());
    if (secureStorageLocked) {
      debugPrint(
        '[SecureStorage] GNOME keyring locked — auth tokens cannot persist '
        'until the user unlocks it (Seahorse → Passwords → Login → Unlock).',
      );
    }
  }

  sl<PeriodicSyncManager>().startPeriodicSync();

  runApp(App(secureStorageLocked: secureStorageLocked));
}
