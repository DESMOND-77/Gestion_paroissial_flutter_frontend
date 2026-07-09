class ApiConstants {
  static const String baseUrl = 'https://gestiparr.onrender.com/api';
// 127.0.0.1
// gestion-paroissiale.onrender.com
// https://gestiparr.onrender.com
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
  static String membreById(int id) => '/membres/$id/';
  static String membreSacrements(int id) => '/membres/$id/sacrements/';
  static String membreAjouterSacrement(int id) => '/membres/$id/ajouter_sacrement/';

  // Groupes
  static const String groupes = '/groupes/';
  static String groupeById(int id) => '/groupes/$id/';
  static String groupeMembres(int id) => '/groupes/$id/membres/';

  // Evenements
  static const String evenements = '/evenements/';
  static String evenementById(int id) => '/evenements/$id/';
  static String evenementInscrire(int id) => '/evenements/$id/inscrire/';
  static String evenementParticipants(int id) => '/evenements/$id/participants/';

  // Finances
  static const String transactions = '/finances/transactions/';
  static String transactionById(int id) => '/finances/transactions/$id/';
  static const String transactionsRapport = '/finances/transactions/rapport/';
  static const String financesRapport = '/finances/rapport/';
  static String membreDons(int id) => '/finances/membre/$id/dons/';

  // Librairie
  static const String articles = '/librairie/articles/';
  static String articleById(int id) => '/librairie/articles/$id/';
  static const String articlesAlertes = '/librairie/articles/alertes/';
  static const String librairieAlertes = '/librairie/alertes/';
  static const String ventes = '/librairie/ventes/';
  static String venteById(int id) => '/librairie/ventes/$id/';

  // Activities
  static const String activities = '/activities/';

  // User
  static const String userProfile = '/user/profile/';
  static const String changePassword = '/user/change-password/';
  static String userById(int id) => '/users/$id/';
  static const String checkPermission = '/check-permission/';
}
