import 'package:flutter/material.dart';

/// Thème de l'application, dérivé de la palette du logo (`assets/images/logo.svg`).
///
/// Palette de marque (constantes, identiques en clair/sombre) :
///  - crimson   `#90151F`  → couleur primaire
///  - orange    `#F3751E`  → couleur secondaire / accents
///  - bleu ciel `#2F9ADC`  → accent / information
///  - papier    `#FDFDFC`  → fond en mode clair
///
/// Les **neutres** (texte, fonds, cartes, séparateurs) sont exposés comme des
/// getters qui s'adaptent à la luminosité système (l'app est en
/// `ThemeMode.system`). Ainsi les nombreux widgets qui référencent
/// `AppTheme.textPrimary` / `AppTheme.surfaceColor` restent lisibles en clair
/// **comme** en sombre sans réécriture. Les définitions `lightTheme`/`darkTheme`
/// ci-dessous utilisent, elles, les valeurs explicites de chaque mode.
class AppTheme {
  // --- Marque (palette logo) — constantes, indépendantes du mode ------------
  static const Color primaryColor = Color(0xFF90151F); // crimson logo
  static const Color primaryDark = Color(0xFF6E0F17);
  static const Color secondaryColor = Color(0xFFF3751E); // orange logo
  static const Color accentColor = Color(0xFF2F9ADC); // bleu logo
  static const Color infoColor = Color(0xFF2F9ADC);
  static const Color errorColor = Color(0xFFC62828);
  static const Color successColor = Color(0xFF2E7D32);
  static const Color warningColor = Color(0xFFEF6C00);
  // La barre latérale reste sombre dans les deux modes (texte blanc dessus).
  static const Color sidebarBg = Color(0xFF2B1013); // crimson très sombre
  static const Color sidebarSelected = primaryColor;

  // --- Neutres par mode (valeurs privées) -----------------------------------
  static const Color _lightBg = Color(0xFFFDFDFC); // papier logo
  static const Color _lightSurface = Color(0xFFFFFFFF);
  static const Color _lightCard = Color(0xFFFFFFFF);
  static const Color _lightTextPrimary = Color(0xFF1E1A1B);
  static const Color _lightTextSecondary = Color(0xFF6B6266);
  static const Color _lightDivider = Color(0xFFEAE6E7);

  static const Color _darkBg = Color(0xFF141011);
  static const Color _darkSurface = Color(0xFF1E1A1B);
  static const Color _darkCard = Color(0xFF241F20);
  static const Color _darkTextPrimary = Color(0xFFF4F0F0);
  static const Color _darkTextSecondary = Color(0xFFB3A9AB);
  static const Color _darkDivider = Color(0xFF332D2F);

  // Primaire éclaircie pour l'usage en *avant-plan* sur fond sombre (le crimson
  // est trop foncé pour du texte/icône lisible sur du sombre).
  static const Color primaryOnDark = Color(0xFFE0727A);

  /// Vrai si le système est en mode sombre (l'app suit `ThemeMode.system`).
  static bool get _isDark =>
      WidgetsBinding.instance.platformDispatcher.platformBrightness ==
      Brightness.dark;

  // --- Neutres adaptatifs (getters lus au build) ----------------------------
  static Color get backgroundColor => _isDark ? _darkBg : _lightBg;
  static Color get surfaceColor => _isDark ? _darkBg : _lightBg;
  static Color get cardColor => _isDark ? _darkCard : _lightCard;
  static Color get textPrimary => _isDark ? _darkTextPrimary : _lightTextPrimary;
  static Color get textSecondary =>
      _isDark ? _darkTextSecondary : _lightTextSecondary;
  static Color get dividerColor => _isDark ? _darkDivider : _lightDivider;

  // ==========================================================================
  // THÈMES
  // ==========================================================================

  static final ThemeData lightTheme = _build(
    brightness: Brightness.light,
    scaffold: _lightBg,
    surface: _lightSurface,
    card: _lightCard,
    textPrimaryC: _lightTextPrimary,
    textSecondaryC: _lightTextSecondary,
    divider: _lightDivider,
    primaryForeground: primaryColor,
    inputFill: _lightSurface,
  );

  static final ThemeData darkTheme = _build(
    brightness: Brightness.dark,
    scaffold: _darkBg,
    surface: _darkSurface,
    card: _darkCard,
    textPrimaryC: _darkTextPrimary,
    textSecondaryC: _darkTextSecondary,
    divider: _darkDivider,
    primaryForeground: primaryOnDark,
    inputFill: _darkCard,
  );

  static ThemeData _build({
    required Brightness brightness,
    required Color scaffold,
    required Color surface,
    required Color card,
    required Color textPrimaryC,
    required Color textSecondaryC,
    required Color divider,
    required Color primaryForeground,
    required Color inputFill,
  }) {
    final isDark = brightness == Brightness.dark;
    final colorScheme = ColorScheme.fromSeed(
      seedColor: primaryColor,
      brightness: brightness,
      // `primary` sert d'avant-plan Material (boutons texte, focus, liens) :
      // éclairci en sombre pour rester lisible.
      primary: primaryForeground,
      onPrimary: isDark ? const Color(0xFF3A0A0F) : Colors.white,
      secondary: secondaryColor,
      onSecondary: Colors.white,
      tertiary: accentColor,
      surface: surface,
      onSurface: textPrimaryC,
      error: errorColor,
      onError: Colors.white,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: scaffold,
      // AppBar en crimson de marque + texte blanc dans les deux modes.
      appBarTheme: const AppBarTheme(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        elevation: 2,
        centerTitle: false,
        titleTextStyle: TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
        iconTheme: IconThemeData(color: Colors.white),
      ),
      cardTheme: CardThemeData(
        color: card,
        elevation: isDark ? 1 : 2,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          disabledBackgroundColor: primaryColor.withAlpha(60),
          disabledForegroundColor: Colors.white70,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primaryForeground,
          side: BorderSide(color: primaryForeground),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(foregroundColor: primaryForeground),
      ),
      iconTheme: IconThemeData(color: textSecondaryC),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: inputFill,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: divider),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: divider),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: primaryForeground, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: errorColor),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        labelStyle: TextStyle(color: textSecondaryC),
        hintStyle: TextStyle(color: textSecondaryC),
        prefixIconColor: textSecondaryC,
      ),
      textTheme: _textTheme(textPrimaryC, textSecondaryC),
      dividerTheme: DividerThemeData(color: divider, thickness: 1),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
      ),
      popupMenuTheme: PopupMenuThemeData(
        color: card,
        surfaceTintColor: Colors.transparent,
        textStyle: TextStyle(color: textPrimaryC, fontSize: 14),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: card,
        surfaceTintColor: Colors.transparent,
      ),
      listTileTheme: ListTileThemeData(
        iconColor: textSecondaryC,
        textColor: textPrimaryC,
      ),
      chipTheme: ChipThemeData(
        backgroundColor: isDark ? _darkCard : const Color(0xFFF1ECEC),
        selectedColor: primaryColor.withAlpha(40),
        labelStyle: TextStyle(fontSize: 12, color: textPrimaryC),
        secondaryLabelStyle: TextStyle(fontSize: 12, color: textPrimaryC),
        side: BorderSide(color: divider),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
      dataTableTheme: DataTableThemeData(
        headingRowColor: WidgetStateProperty.all(primaryColor.withAlpha(20)),
        dataRowColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return primaryColor.withAlpha(40);
          }
          return Colors.transparent;
        }),
        headingTextStyle: TextStyle(
          fontWeight: FontWeight.w600,
          color: textPrimaryC,
          fontSize: 13,
        ),
        dataTextStyle: TextStyle(color: textPrimaryC, fontSize: 13),
      ),
      tabBarTheme: TabBarThemeData(
        labelColor: primaryForeground,
        unselectedLabelColor: textSecondaryC,
        indicatorColor: primaryForeground,
      ),
    );
  }

  static TextTheme _textTheme(Color primary, Color secondary) {
    return TextTheme(
      displayLarge:
          TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: primary),
      displayMedium:
          TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: primary),
      headlineLarge:
          TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: primary),
      headlineMedium: TextStyle(
          fontSize: 20, fontWeight: FontWeight.w600, color: primary),
      headlineSmall: TextStyle(
          fontSize: 18, fontWeight: FontWeight.w600, color: primary),
      titleLarge: TextStyle(
          fontSize: 16, fontWeight: FontWeight.w600, color: primary),
      titleMedium: TextStyle(
          fontSize: 14, fontWeight: FontWeight.w500, color: primary),
      bodyLarge: TextStyle(fontSize: 16, color: primary),
      bodyMedium: TextStyle(fontSize: 14, color: secondary),
      bodySmall: TextStyle(fontSize: 12, color: secondary),
      labelLarge: TextStyle(
          fontSize: 14, fontWeight: FontWeight.w600, color: primary),
    );
  }
}
