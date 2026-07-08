import 'package:intl/intl.dart';

class AppConstants {
  static const String appName = 'Gestion Paroissiale';
  static const String appVersion = '1.0.0';

  // Currency formatter
  static final formatter =
      NumberFormat.currency(locale: 'fr_FR', symbol: 'XFA', decimalDigits: 0);
  // Storage keys
  static const String accessTokenKey = 'access_token';
  static const String refreshTokenKey = 'refresh_token';
  static const String userKey = 'user_data';
  static const String membreSelfKey = 'membre_self_data';
  static const String apiBaseUrlKey = 'api_base_url';
  // Pagination
  static const int defaultPageSize = 20;

  // Timeouts
  static const int connectTimeout = 30000;
  static const int receiveTimeout = 30000;

  // Routes
  static const String loginRoute = '/login';
  static const String forgotPasswordRoute = '/forgot-password';
  static const String dashboardRoute = '/dashboard';
  static const String membresRoute = '/membres';
  static const String membreDetailRoute = '/membres/:id';
  static const String membreNewRoute = '/membres/new';
  static const String groupesRoute = '/groupes';
  static const String evenementsRoute = '/evenements';
  static const String financesRoute = '/finances';
  static const String librairieRoute = '/librairie';
  static const String profileRoute = '/profile';

  // Sexe
  static const Map<String, String> sexeOptions = {
    'M': 'Masculin',
    'F': 'Féminin',
  };

  // Types de sacrements
  static const List<String> sacrementTypes = [
    'bapteme',
    'mariage',
    'confirmation',
    'communion',
    'funerailles',
  ];

  static const Map<String, String> sacrementLabels = {
    'bapteme': 'Baptême',
    'mariage': 'Mariage',
    'confirmation': 'Confirmation',
    'communion': 'Communion',
    'funerailles': 'Funérailles',
  };

  // Types d'événements
  static const Map<String, String> evenementTypes = {
    'messe': 'Messe',
    'fete_liturgique': 'Fête Liturgique',
    'reunion': 'Réunion',
    'kermesse': 'Kermesse',
    'reservation': 'Réservation',
  };

  // Types de transactions
  static const Map<String, String> transactionTypes = {
    'recette': 'Recette',
    'depense': 'Dépense',
  };

  // Catégories de transactions
  static const Map<String, String> transactionCategories = {
    'quete': 'Quête',
    'don': 'Don',
    'location': 'Location',
    'librairie': 'Librairie',
    'autre': 'Autre',
  };

  // Catégories d'articles
  static const Map<String, String> articleCategories = {
    'livre': 'Livre',
    'bougie': 'Bougie',
    'chapelet': 'Chapelet',
    'vetement': 'Vêtement',
    'autre': 'Autre',
  };
}
