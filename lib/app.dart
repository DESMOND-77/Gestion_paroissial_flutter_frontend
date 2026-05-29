import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:responsive_framework/responsive_framework.dart';
import 'core/di/injection.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'presentation/blocs/auth/auth_bloc.dart';
import 'presentation/blocs/membres/membres_bloc.dart';
import 'presentation/blocs/groupes/groupes_bloc.dart';
import 'presentation/blocs/evenements/evenements_bloc.dart';
import 'presentation/blocs/finances/finances_bloc.dart';
import 'presentation/blocs/librairie/librairie_bloc.dart';
import 'presentation/blocs/dashboard/dashboard_bloc.dart';

class App extends StatefulWidget {
  final bool secureStorageLocked;
  const App({super.key, this.secureStorageLocked = false});

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  late final AuthBloc _authBloc;
  late final AppRouter _appRouter;

  @override
  void initState() {
    super.initState();
    _authBloc = sl<AuthBloc>();
    _authBloc.add(const AuthCheckRequested());
    _appRouter = AppRouter(authBloc: _authBloc);

    if (widget.secureStorageLocked) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _warnKeyringLocked());
    }
  }

  void _warnKeyringLocked() {
    final ctx =
        _appRouter.router.routerDelegate.navigatorKey.currentContext;
    if (ctx == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _warnKeyringLocked());
      return;
    }
    showDialog<void>(
      context: ctx,
      builder: (dialogCtx) => AlertDialog(
        title: const Text('Trousseau verrouillé'),
        content: const Text(
          'Le trousseau GNOME est verrouillé. Tant qu\'il ne sera pas '
          'déverrouillé, la connexion ne pourra pas être sauvegardée et '
          'vous devrez vous reconnecter à chaque démarrage.\n\n'
          'Pour le déverrouiller : ouvrez Seahorse (Mots de passe et clés), '
          'développez « Mots de passe » → « Login » → clic droit → '
          'Déverrouiller.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogCtx).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _authBloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: _authBloc),
        BlocProvider(create: (_) => sl<MembresBloc>()),
        BlocProvider(create: (_) => sl<GroupesBloc>()),
        BlocProvider(create: (_) => sl<EvenementsBloc>()),
        BlocProvider(create: (_) => sl<FinancesBloc>()),
        BlocProvider(create: (_) => sl<LibrairieBloc>()),
        BlocProvider(create: (_) => sl<DashboardBloc>()),
      ],
      child: MaterialApp.router(
        title: 'Gestion Paroissiale',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.light,
        routerConfig: _appRouter.router,
        builder: (context, child) => ResponsiveBreakpoints.builder(
          child: child!,
          breakpoints: [
            const Breakpoint(start: 0, end: 450, name: MOBILE),
            const Breakpoint(start: 451, end: 800, name: TABLET),
            const Breakpoint(start: 801, end: 1920, name: DESKTOP),
            const Breakpoint(start: 1921, end: double.infinity, name: '4K'),
          ],
        ),
      ),
    );
  }
}
