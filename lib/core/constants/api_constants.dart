class ApiConstants {
  static const String baseUrl = 
  // 'http://127.0.0.1:8000/api/v1';
  'http://192.168.1.87:8000/api/v1';
  // 'https://gestiparr.onrender.com/api/v1';
  // 'http://127.0.0.1:8100/api/v1';
  // 'https://gestion-paroissiale.onrender.com/api/v1';
  // 'http://10.0.0.89:8000/api/v1';

  // Sync (offline → serveur central, push + pull en un appel)
  static const String sync = '/sync/';

  // Auth
  static const String login = '/auth/login/';
  static const String logout = '/auth/logout/';
  static const String register = '/auth/register/';
  static const String me = '/auth/me/';
  static const String tokenRefresh = '/auth/token/refresh/';
  static const String tokenValidate = '/auth/token/validate/';
  static const String passwordReset = '/auth/password-reset/';
  static const String passwordResetConfirm = '/auth/password-reset-confirm/';
  static const String sendVerification = '/auth/send-verification/';
  static const String emailVerify = '/auth/email-verify/';
  static const String verificationStatus = '/auth/verification-status/';

  // Membres
  static const String membres = '/membres/';
  static const String membreMe = '/membres/me/';
  static String membreById(String id) => '/membres/$id/';
  static String membreSacrements(String id) => '/membres/$id/sacrements/';
  static String membreAjouterSacrement(String id) =>
      '/membres/$id/ajouter_sacrement/';

  // Groupes
  static const String groupes = '/groupes/';
  static const String users = '/users/';
  static String groupeById(String id) => '/groupes/$id/';
  static String groupeMembres(String id) => '/groupes/$id/membres/';

  // Evenements
  static const String evenements = '/evenements/';
  static String evenementById(String id) => '/evenements/$id/';
  static String evenementInscrire(String id) => '/evenements/$id/inscrire/';
  static String evenementParticipants(String id) =>
      '/evenements/$id/participants/';

  // Finances
  static const String transactions = '/finances/transactions/';
  static String transactionById(String id) => '/finances/transactions/$id/';
  static const String transactionsRapport = '/finances/transactions/rapport/';
  static const String financesRapport = '/finances/rapport/';
  static String membreDons(String id) => '/finances/membre/$id/dons/';

  // Librairie
  static const String articles = '/librairie/articles/';
  static String articleById(String id) => '/librairie/articles/$id/';
  static const String articlesAlertes = '/librairie/articles/alertes/';
  static const String librairieAlertes = '/librairie/alertes/';
  static const String ventes = '/librairie/ventes/';
  static String venteById(String id) => '/librairie/ventes/$id/';

  // Activities
  static const String activities = '/activities/';

  // User
  static const String userProfile = '/user/profile/';
  static const String changePassword = '/user/change-password/';
  static String userById(String id) => '/users/$id/';
  static const String checkPermission = '/check-permission/';
}
