import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../presentation/blocs/auth/auth_bloc.dart';

/// Contrôle d'affichage UI basé sur le rôle de l'utilisateur.
///
/// **Miroir de l'enforcement réel du backend.** Les vues DRF protègent les
/// écritures par des classes hiérarchiques de rôle (`core/permissions.py`) —
/// et non (encore) par les permissions granulaires de `core/rbac.py`. Pour que
/// l'UI ne montre jamais un bouton qui renverrait 403 (ni n'en cache un qui
/// passerait), on reproduit ici **ces mêmes ensembles de rôles** :
///
/// - `SECRETARY_ROLES` (IsSecretaryOrAbove) : secretaire, tresorier,
///   responsable, pretre, admin
/// - `TREASURER_ROLES` (IsTreasurerOrAbove) : tresorier, pretre, admin
/// - `ADMIN_ROLES` (IsAdmin) : admin
///
/// Si le backend migre vers les permissions granulaires (`HasPermission`),
/// aligner ces capacités en conséquence.
class AppPermissions {
  final String role;

  const AppPermissions(this.role);

  static const Set<String> secretaryRoles = {
    'secretaire',
    'tresorier',
    'responsable',
    'pretre',
    'admin',
  };
  static const Set<String> treasurerRoles = {'tresorier', 'pretre', 'admin'};
  static const Set<String> adminRoles = {'admin'};
  static const Set<String> responsableRoles = {'responsable'};

  bool get isSecretaryOrAbove => secretaryRoles.contains(role);
  bool get isTreasurerOrAbove => treasurerRoles.contains(role);
  bool get isAdmin => adminRoles.contains(role);
  bool get isResponsable => responsableRoles.contains(role);

  // --- Capacités par domaine (reflètent les permission_classes des vues) -----

  // Dashboard : lecture = IsSecretaryOrAbove (secretaire, tresorier, responsable, pretre, admin).
  bool get canViewDashboard => isSecretaryOrAbove && !isResponsable;

  // Membres : create/edit + ajout de sacrement = IsSecretaryOrAbove ;
  // suppression = IsAdmin ; lecture = tout utilisateur authentifié.
  bool get canManageMembres => isSecretaryOrAbove;
  bool get canDeleteMembres => isAdmin;
  bool get canRecordSacrement => isSecretaryOrAbove;

  // Groupes : create/edit/delete = IsAdmin ; lecture = authentifié.
  bool get canManageGroupes => isSecretaryOrAbove;
  bool get canDeleteGroupes => isAdmin;

  // Événements : create/edit = IsSecretaryOrAbove ; suppression = IsAdmin.
  bool get canManageEvenements => isSecretaryOrAbove;
  bool get canDeleteEvenements => isAdmin;

  // Finances : la vue liste elle-même exige IsTreasurerOrAbove (donc consulter
  // aussi) ; create/edit = IsTreasurerOrAbove ; suppression = IsAdmin.
  bool get canViewFinances => isTreasurerOrAbove;
  bool get canManageFinances => isTreasurerOrAbove;
  bool get canDeleteFinances => isAdmin;

  // Librairie : articles/ventes create/edit = IsSecretaryOrAbove ;
  // suppression d'article = IsAdmin ; lecture = authentifié.
  bool get canManageLibrairie => isSecretaryOrAbove;
  bool get canDeleteLibrairie => isAdmin;

  // --- Accès aux sections (navigation + garde de route) ----------------------
  //
  // Source de vérité unique de la visibilité des sections principales : le
  // drawer, la sidebar ET la garde du routeur s'en servent, pour qu'une section
  // masquée ne soit jamais accessible par navigation directe / au démarrage.

  /// Ordre de préférence des sections pour la page d'accueil par défaut.
  static const List<String> _sectionsOrder = [
    '/dashboard',
    '/membres',
    '/groupes',
    '/evenements',
    '/finances',
    '/librairie',
    '/profile',
  ];

  /// L'utilisateur peut-il accéder à la section correspondant à [location] ?
  /// (Gère les sous-routes via `startsWith`, ex. `/membres/<id>/edit`.)
  bool canAccessRoute(String location) {
    if (location.startsWith('/dashboard')) return canViewDashboard;
    if (location.startsWith('/membres')) return canManageMembres;
    if (location.startsWith('/groupes')) return canManageGroupes;
    if (location.startsWith('/evenements')) return true;
    if (location.startsWith('/finances')) return canViewFinances;
    if (location.startsWith('/librairie')) {
      return canManageLibrairie && !isResponsable;
    }
    if (location.startsWith('/profile')) return true;
    // Routes hors sections gardées (splash, auth…) : non concernées ici.
    return true;
  }

  /// Première section accessible : page d'accueil après connexion / au
  /// démarrage. Toujours accessible (repli `/profile`).
  String get landingRoute =>
      _sectionsOrder.firstWhere(canAccessRoute, orElse: () => '/profile');
}

/// Accès aux permissions de l'utilisateur courant depuis un `BuildContext`.
///
/// Utilise `watch` : les widgets se reconstruisent à la connexion/déconnexion.
/// À n'appeler que dans une méthode `build` (pas dans un callback).
extension PermissionsContext on BuildContext {
  AppPermissions get perms {
    final state = watch<AuthBloc>().state;
    final role = state is AuthAuthenticated ? state.user.role : 'fidele';
    return AppPermissions(role);
  }
}
