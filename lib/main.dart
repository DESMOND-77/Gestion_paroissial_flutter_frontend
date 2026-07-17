import 'dart:io' show Platform;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:isar_plus/isar_plus.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'core/di/injection.dart';
import 'core/network/dio_client.dart';
import 'core/storage/secure_storage.dart';
import 'core/sync/periodic_sync_manager.dart';
import 'app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (kIsWeb) {
    // Sur le natif (Android/iOS/Linux/macOS/Windows), isar_plus_flutter_libs
    // charge le moteur automatiquement. Sur le web, il faut charger le
    // binaire WASM explicitement avant tout Isar.openAsync (DatabaseService).
    // Auto-hébergé sous web/ pour ne pas dépendre du CDN unpkg.com à
    // l'exécution (cohérent avec l'esprit "hors ligne" de l'app).
    await Isar.initialize('isar_plus.wasm');
  }

  await setupDependencies();
  // Applique une URL de serveur précédemment enregistrée par l'utilisateur
  // avant toute requête réseau (login, vérification de session, etc.).
  await sl<DioClient>().loadPersistedBaseUrl();
  await initializeDateFormatting('fr_FR', null);

  var secureStorageLocked = false;
  if (!kIsWeb && Platform.isLinux) {
    secureStorageLocked = !(await sl<SecureStorage>().probe());
    if (secureStorageLocked) {
      debugPrint(
        '[SecureStorage] GNOME keyring locked - auth tokens cannot persist '
        'until the user unlocks it (Seahorse → Passwords → Login → Unlock).',
      );
    }
  }

  sl<PeriodicSyncManager>().startPeriodicSync();

  runApp(App(secureStorageLocked: secureStorageLocked));
}
