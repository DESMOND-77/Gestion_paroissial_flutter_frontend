import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'core/di/injection.dart';
import 'core/sync/periodic_sync_manager.dart';
import 'app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await setupDependencies();
  await initializeDateFormatting('fr_FR', null);

  // Démarrer la synchronisation périodique
  sl<PeriodicSyncManager>().startPeriodicSync();

  runApp(const App());
}
