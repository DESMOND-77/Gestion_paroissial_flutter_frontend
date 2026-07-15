import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../presentation/blocs/auth/auth_bloc.dart';
import '../../presentation/screens/splash/splash_screen.dart';
import '../../presentation/screens/auth/login_screen.dart';
import '../../presentation/screens/auth/forgot_password_screen.dart';
import '../../presentation/screens/auth/register_screen.dart';
import '../../presentation/screens/dashboard/dashboard_screen.dart';
import '../../presentation/screens/membres/membres_screen.dart';
import '../../presentation/screens/membres/membre_detail_screen.dart';
import '../../presentation/screens/membres/membre_form_screen.dart';
import '../../presentation/screens/groupes/groupes_screen.dart';
import '../../presentation/screens/groupes/groupe_detail_screen.dart';
import '../../presentation/screens/groupes/groupe_form_screen.dart';
import '../../presentation/screens/evenements/evenements_screen.dart';
import '../../presentation/screens/evenements/evenement_detail_screen.dart';
import '../../presentation/screens/evenements/evenement_form_screen.dart';
import '../../presentation/screens/finances/finances_screen.dart';
import '../../presentation/screens/finances/transaction_form_screen.dart';
import '../../presentation/screens/librairie/librairie_screen.dart';
import '../../presentation/screens/librairie/article_form_screen.dart';
import '../../presentation/screens/librairie/vente_form_screen.dart';
import '../../presentation/screens/profile/profile_screen.dart';
import '../../presentation/widgets/main_layout.dart';

class AppRouter {
  final AuthBloc authBloc;

  AppRouter({required this.authBloc});

  late final GoRouter router = GoRouter(
    initialLocation: '/splash',
    debugLogDiagnostics: false,
    redirect: (context, state) {
      final authState = authBloc.state;
      final isLoginRoute = state.matchedLocation == '/login' ||
          state.matchedLocation == '/forgot-password' ||
          state.matchedLocation == '/register';
      // Le splash gère lui-même sa navigation une fois l'animation terminée
      // et l'état d'authentification connu ; le redirect ne doit pas le
      // court-circuiter pendant que l'animation joue.
      final isSplashRoute = state.matchedLocation == '/splash';

      // Seul un état explicitement "non connecté" (déconnexion, session
      // expirée, échec de la vérification initiale) doit renvoyer vers le
      // login. Des états transitoires comme AuthError (ex: rafraîchissement
      // du profil qui échoue faute de réseau) ne signifient PAS que la
      // session est invalide — les jetons sont toujours valides en storage —
      // donc ils ne doivent pas éjecter l'utilisateur de l'écran courant.
      final isLoggedOut = authState is AuthUnauthenticated;
      final isConfirmedAuthenticated =
          authState is AuthAuthenticated || authState is AuthLoginSuccess;

      if (isLoggedOut && !isLoginRoute && !isSplashRoute) {
        return '/login';
      }
      if (isConfirmedAuthenticated && isLoginRoute) {
        return '/dashboard';
      }
      return null;
    },
    refreshListenable: GoRouterRefreshStream(authBloc.stream),
    routes: [
      GoRoute(
        path: '/splash',
        name: 'splash',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/forgot-password',
        name: 'forgot-password',
        builder: (context, state) => const ForgotPasswordScreen(),
      ),
      GoRoute(
        path: '/register',
        name: 'register',
        builder: (context, state) => const RegisterScreen(),
      ),
      ShellRoute(
        builder: (context, state, child) => MainLayout(child: child),
        routes: [
          GoRoute(
            path: '/dashboard',
            name: 'dashboard',
            builder: (context, state) => const DashboardScreen(),
          ),
          GoRoute(
            path: '/membres',
            name: 'membres',
            builder: (context, state) => const MembresScreen(),
            routes: [
              GoRoute(
                path: 'new',
                name: 'membre-new',
                builder: (context, state) => const MembreFormScreen(),
              ),
              GoRoute(
                path: ':id',
                name: 'membre-detail',
                builder: (context, state) {
                  final id = state.pathParameters['id']!;
                  return MembreDetailScreen(membreId: id);
                },
                routes: [
                  GoRoute(
                    path: 'edit',
                    name: 'membre-edit',
                    builder: (context, state) {
                      final id = state.pathParameters['id']!;
                      return MembreFormScreen(membreId: id);
                    },
                  ),
                ],
              ),
            ],
          ),
          GoRoute(
            path: '/groupes',
            name: 'groupes',
            builder: (context, state) => const GroupesScreen(),
            routes: [
              GoRoute(
                path: 'new',
                name: 'groupe-new',
                builder: (context, state) => const GroupeFormScreen(),
              ),
              GoRoute(
                path: ':id',
                name: 'groupe-detail',
                builder: (context, state) {
                  final id = state.pathParameters['id']!;
                  return GroupeDetailScreen(groupeId: id);
                },
              ),
              GoRoute(
                path: ':id/edit',
                name: 'groupe-edit',
                builder: (context, state) {
                  final id = state.pathParameters['id']!;
                  return GroupeFormScreen(groupeId: id);
                },
              ),
            ],
          ),
          GoRoute(
            path: '/evenements',
            name: 'evenements',
            builder: (context, state) => const EvenementsScreen(),
            routes: [
              GoRoute(
                path: 'new',
                name: 'evenement-new',
                builder: (context, state) => const EvenementFormScreen(),
              ),
              GoRoute(
                path: ':id',
                name: 'evenement-detail',
                builder: (context, state) {
                  final id = state.pathParameters['id']!;
                  return EvenementDetailScreen(evenementId: id);
                },
              ),
              GoRoute(
                path: ':id/edit',
                name: 'evenement-edit',
                builder: (context, state) {
                  final id = state.pathParameters['id']!;
                  return EvenementFormScreen(evenementId: id);
                },
              ),
            ],
          ),
          GoRoute(
            path: '/finances',
            name: 'finances',
            builder: (context, state) => const FinancesScreen(),
            routes: [
              GoRoute(
                path: 'new',
                name: 'transaction-new',
                builder: (context, state) => const TransactionFormScreen(),
              ),
              GoRoute(
                path: ':id/edit',
                name: 'transaction-edit',
                builder: (context, state) {
                  final id = state.pathParameters['id']!;
                  return TransactionFormScreen(transactionId: id);
                },
              ),
            ],
          ),
          GoRoute(
            path: '/librairie',
            name: 'librairie',
            builder: (context, state) => const LibrairieScreen(),
            routes: [
              GoRoute(
                path: 'articles/new',
                name: 'article-new',
                builder: (context, state) => const ArticleFormScreen(),
              ),
              GoRoute(
                path: 'articles/:id/edit',
                name: 'article-edit',
                builder: (context, state) {
                  final id = state.pathParameters['id']!;
                  return ArticleFormScreen(articleId: id);
                },
              ),
              GoRoute(
                path: 'ventes/new',
                name: 'vente-new',
                builder: (context, state) => const VenteFormScreen(),
              ),
            ],
          ),
          GoRoute(
            path: '/profile',
            name: 'profile',
            builder: (context, state) => const ProfileScreen(),
          ),
        ],
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              'Page introuvable',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 8),
            Text(state.error.toString()),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => context.go('/dashboard'),
              child: const Text('Retour au tableau de bord'),
            ),
          ],
        ),
      ),
    ),
  );
}

class GoRouterRefreshStream extends ChangeNotifier {
  late final Stream _stream;

  GoRouterRefreshStream(Stream stream) {
    _stream = stream;
    _stream.listen((_) => notifyListeners());
  }
}
