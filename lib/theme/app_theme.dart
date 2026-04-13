import 'package:flutter/material.dart';

class AppColorsExtension extends ThemeExtension<AppColorsExtension> {
  final Color success;
  final Color textSecondary;
  final Color textTertiary;

  const AppColorsExtension({
    required this.success,
    required this.textSecondary,
    required this.textTertiary,
  });

  @override
  AppColorsExtension copyWith({
    Color? success,
    Color? textSecondary,
    Color? textTertiary,
  }) {
    return AppColorsExtension(
      success: success ?? this.success,
      textSecondary: textSecondary ?? this.textSecondary,
      textTertiary: textTertiary ?? this.textTertiary,
    );
  }

  @override
  AppColorsExtension lerp(AppColorsExtension? other, double t) {
    if (other is! AppColorsExtension) return this;
    return AppColorsExtension(
      success: Color.lerp(success, other.success, t)!,
      textSecondary: Color.lerp(textSecondary, other.textSecondary, t)!,
      textTertiary: Color.lerp(textTertiary, other.textTertiary, t)!,
    );
  }
}

extension AppColorsContext on BuildContext {
  AppColorsExtension get appColors =>
      Theme.of(this).extension<AppColorsExtension>()!;
}

class AppTheme {
  AppTheme._();

  // Spacing
  static const double spaceXS = 4.0;
  static const double spaceSM = 8.0;
  static const double spaceMD = 16.0;
  static const double spaceLG = 24.0;
  static const double spaceXL = 32.0;
  static const double spaceXXL = 48.0;

  // Border radius
  static const double radiusSM = 8.0;
  static const double radiusMD = 12.0;
  static const double radiusLG = 16.0;
  static const double radiusPill = 100.0;

  // Light palette
  static const Color _background = Color(0xFFF8F9FA);
  static const Color _surface = Color(0xFFFFFFFF);
  static const Color _accent = Color(0xFF4DABF7);
  static const Color _accentLight = Color(0xFFCDE9FD);
  static const Color _textPrimary = Color(0xFF212529);
  static const Color _textSecondary = Color(0xFF6C757D);
  static const Color _textTertiary = Color(0xFFADB5BD);
  static const Color _divider = Color(0xFFE9ECEF);
  static const Color _danger = Color(0xFFFF6B6B);
  static const Color _success = Color(0xFF51CF66);

  // Dark palette
  static const Color _darkBackground = Color(0xFF1A1A2E);
  static const Color _darkSurface = Color(0xFF25253D);
  static const Color _darkAccent = Color(0xFF6C9FFF);
  static const Color _darkAccentLight = Color(0x546C9FFF);
  static const Color _darkTextPrimary = Color(0xFFE0E0E0);
  static const Color _darkTextSecondary = Color(0xFF9E9EAE);
  static const Color _darkTextTertiary = Color(0xFF6E6E82);
  static const Color _darkDivider = Color(0xFF2E2E45);
  static const Color _darkDanger = Color(0xFFFF7B7B);
  static const Color _darkSuccess = Color(0xFF69DB7C);

  static ThemeData get lightTheme => _buildTheme(
        colorScheme: const ColorScheme.light(
          primary: _accent,
          onPrimary: Colors.white,
          secondary: _accentLight,
          onSecondary: _textPrimary,
          surface: _surface,
          onSurface: _textPrimary,
          error: _danger,
          onError: Colors.white,
        ),
        scaffoldBg: _background,
        colors: const AppColorsExtension(
          success: _success,
          textSecondary: _textSecondary,
          textTertiary: _textTertiary,
        ),
        textPrimary: _textPrimary,
        textSecondaryColor: _textSecondary,
        textTertiaryColor: _textTertiary,
        accentColor: _accent,
        accentLightColor: _accentLight,
        surfaceColor: _surface,
        dividerColor: _divider,
        bgColor: _background,
      );

  static ThemeData get darkTheme => _buildTheme(
        colorScheme: const ColorScheme.dark(
          primary: _darkAccent,
          onPrimary: _darkBackground,
          secondary: _darkAccentLight,
          onSecondary: _darkTextPrimary,
          surface: _darkSurface,
          onSurface: _darkTextPrimary,
          error: _darkDanger,
          onError: Colors.white,
        ),
        scaffoldBg: _darkBackground,
        colors: const AppColorsExtension(
          success: _darkSuccess,
          textSecondary: _darkTextSecondary,
          textTertiary: _darkTextTertiary,
        ),
        textPrimary: _darkTextPrimary,
        textSecondaryColor: _darkTextSecondary,
        textTertiaryColor: _darkTextTertiary,
        accentColor: _darkAccent,
        accentLightColor: _darkAccentLight,
        surfaceColor: _darkSurface,
        dividerColor: _darkDivider,
        bgColor: _darkBackground,
        bottomSheetBg: _darkSurface,
      );

  static ThemeData _buildTheme({
    required ColorScheme colorScheme,
    required Color scaffoldBg,
    required AppColorsExtension colors,
    required Color textPrimary,
    required Color textSecondaryColor,
    required Color textTertiaryColor,
    required Color accentColor,
    required Color accentLightColor,
    required Color surfaceColor,
    required Color dividerColor,
    required Color bgColor,
    Color? bottomSheetBg,
  }) {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: scaffoldBg,
      colorScheme: colorScheme,
      extensions: [colors],

      textTheme: TextTheme(
        displayLarge: TextStyle(
          fontSize: 32, fontWeight: FontWeight.w700, color: textPrimary,
          letterSpacing: -0.5, height: 1.2,
        ),
        displayMedium: TextStyle(
          fontSize: 28, fontWeight: FontWeight.w700, color: textPrimary,
          letterSpacing: -0.5, height: 1.2,
        ),
        headlineLarge: TextStyle(
          fontSize: 24, fontWeight: FontWeight.w600, color: textPrimary,
          letterSpacing: -0.3, height: 1.3,
        ),
        headlineMedium: TextStyle(
          fontSize: 20, fontWeight: FontWeight.w600, color: textPrimary,
          letterSpacing: -0.2, height: 1.3,
        ),
        headlineSmall: TextStyle(
          fontSize: 18, fontWeight: FontWeight.w600, color: textPrimary,
          height: 1.4,
        ),
        titleLarge: TextStyle(
          fontSize: 16, fontWeight: FontWeight.w600, color: textPrimary,
          height: 1.4,
        ),
        titleMedium: TextStyle(
          fontSize: 15, fontWeight: FontWeight.w500, color: textPrimary,
          height: 1.4,
        ),
        titleSmall: TextStyle(
          fontSize: 14, fontWeight: FontWeight.w500, color: textSecondaryColor,
          height: 1.4,
        ),
        bodyLarge: TextStyle(
          fontSize: 16, fontWeight: FontWeight.w400, color: textPrimary,
          height: 1.5,
        ),
        bodyMedium: TextStyle(
          fontSize: 14, fontWeight: FontWeight.w400, color: textPrimary,
          height: 1.5,
        ),
        bodySmall: TextStyle(
          fontSize: 12, fontWeight: FontWeight.w400, color: textSecondaryColor,
          height: 1.5,
        ),
        labelLarge: const TextStyle(
          fontSize: 15, fontWeight: FontWeight.w600, color: Colors.white,
          letterSpacing: 0.2,
        ),
        labelMedium: TextStyle(
          fontSize: 13, fontWeight: FontWeight.w500, color: textSecondaryColor,
          letterSpacing: 0.1,
        ),
        labelSmall: TextStyle(
          fontSize: 11, fontWeight: FontWeight.w500, color: textTertiaryColor,
          letterSpacing: 0.5,
        ),
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: accentColor,
          foregroundColor: colorScheme.onPrimary,
          elevation: 0,
          shadowColor: Colors.transparent,
          padding: const EdgeInsets.symmetric(horizontal: spaceLG, vertical: spaceMD),
          shape: const StadiumBorder(),
          textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, letterSpacing: 0.2),
          minimumSize: const Size(0, 48),
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: accentColor,
          side: BorderSide(color: accentColor, width: 1.5),
          padding: const EdgeInsets.symmetric(horizontal: spaceLG, vertical: spaceMD),
          shape: const StadiumBorder(),
          textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, letterSpacing: 0.2),
          minimumSize: const Size(0, 48),
        ),
      ),

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: accentColor,
          padding: const EdgeInsets.symmetric(horizontal: spaceMD, vertical: spaceSM),
          shape: const StadiumBorder(),
          textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, letterSpacing: 0.1),
        ),
      ),

      cardTheme: CardThemeData(
        color: surfaceColor,
        elevation: 0,
        shadowColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusLG),
          side: BorderSide(color: dividerColor, width: 1),
        ),
        margin: const EdgeInsets.all(0),
      ),

      appBarTheme: AppBarTheme(
        backgroundColor: bgColor,
        foregroundColor: textPrimary,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          fontSize: 20, fontWeight: FontWeight.w700, color: textPrimary, letterSpacing: -0.2,
        ),
        iconTheme: IconThemeData(color: textPrimary, size: 22),
      ),

      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: surfaceColor,
        selectedItemColor: accentColor,
        unselectedItemColor: textTertiaryColor,
        elevation: 0,
        type: BottomNavigationBarType.fixed,
        showSelectedLabels: true,
        showUnselectedLabels: true,
        selectedLabelStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
        unselectedLabelStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.w400),
      ),

      dividerTheme: DividerThemeData(color: dividerColor, thickness: 1, space: 1),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surfaceColor,
        contentPadding: const EdgeInsets.symmetric(horizontal: spaceMD, vertical: spaceMD),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMD),
          borderSide: BorderSide(color: dividerColor),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMD),
          borderSide: BorderSide(color: dividerColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMD),
          borderSide: BorderSide(color: accentColor, width: 1.5),
        ),
        hintStyle: TextStyle(color: textTertiaryColor, fontSize: 14),
      ),

      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return accentColor;
          return textTertiaryColor;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return accentLightColor;
          return dividerColor;
        }),
      ),

      listTileTheme: const ListTileThemeData(
        contentPadding: EdgeInsets.symmetric(horizontal: spaceMD, vertical: spaceXS),
        minVerticalPadding: spaceXS,
      ),

      chipTheme: ChipThemeData(
        backgroundColor: bgColor,
        selectedColor: accentLightColor,
        labelStyle: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: textPrimary),
        side: BorderSide(color: dividerColor),
        shape: const StadiumBorder(),
        padding: const EdgeInsets.symmetric(horizontal: spaceSM, vertical: spaceXS),
      ),

      bottomSheetTheme: bottomSheetBg != null
          ? BottomSheetThemeData(backgroundColor: bottomSheetBg)
          : null,
    );
  }
}
