import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'app_colors.dart';
import 'app_text_styles.dart';

class HATheme {
  HATheme._();

  // ─────────────────────────────────────────────────── DARK THEME ──
  static ThemeData get dark => ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    fontFamily: 'Inter',
    colorScheme: const ColorScheme.dark(
      primary: HAColors.secondary,
      secondary: HAColors.accent,
      surface: HAColors.darkSurface,
      error: HAColors.error,
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onSurface: HAColors.textPrimaryDark,
      onError: Colors.white,
      outline: HAColors.darkBorder,
    ),

    scaffoldBackgroundColor: HAColors.darkBg,
    cardColor: HAColors.darkCard,
    dividerColor: HAColors.darkDivider,

    // AppBar
    appBarTheme: const AppBarTheme(
      backgroundColor: HAColors.darkBg,
      foregroundColor: HAColors.textPrimaryDark,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: false,
      systemOverlayStyle: SystemUiOverlayStyle(
        statusBarBrightness: Brightness.dark,
        statusBarIconBrightness: Brightness.light,
      ),
      titleTextStyle: TextStyle(
        fontFamily: 'Inter',
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: HAColors.textPrimaryDark,
      ),
    ),

    // Bottom Nav
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: HAColors.darkSurface,
      selectedItemColor: HAColors.secondary,
      unselectedItemColor: HAColors.slate500,
      type: BottomNavigationBarType.fixed,
      elevation: 0,
    ),

    // NavigationBar
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: HAColors.darkSurface,
      indicatorColor: HAColors.secondary.withOpacity(0.2),
      iconTheme: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return const IconThemeData(color: HAColors.secondary);
        }
        return const IconThemeData(color: HAColors.slate500);
      }),
      labelTextStyle: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return HATextStyles.labelSmall.copyWith(color: HAColors.secondary);
        }
        return HATextStyles.labelSmall.copyWith(color: HAColors.slate500);
      }),
    ),

    // Cards
    cardTheme: CardTheme(
      color: HAColors.darkCard,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: HAColors.darkBorder, width: 1),
      ),
      margin: EdgeInsets.zero,
    ),

    // Elevated Button
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: HAColors.secondary,
        foregroundColor: Colors.white,
        disabledBackgroundColor: HAColors.slate700,
        disabledForegroundColor: HAColors.slate500,
        elevation: 0,
        minimumSize: const Size(double.infinity, 52),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        textStyle: HATextStyles.labelLarge,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
      ),
    ),

    // Outlined Button
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: HAColors.secondary,
        side: const BorderSide(color: HAColors.secondary, width: 1.5),
        minimumSize: const Size(double.infinity, 52),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        textStyle: HATextStyles.labelLarge,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
      ),
    ),

    // Text Button
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: HAColors.secondary,
        textStyle: HATextStyles.labelLarge,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
    ),

    // Input Decoration
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: HAColors.darkElevated,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: HAColors.darkBorder),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: HAColors.darkBorder),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: HAColors.secondary, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: HAColors.error),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      hintStyle: HATextStyles.bodyMedium.copyWith(color: HAColors.slate500),
      labelStyle: HATextStyles.bodyMedium.copyWith(color: HAColors.slate400),
    ),

    // Chip
    chipTheme: ChipThemeData(
      backgroundColor: HAColors.darkElevated,
      selectedColor: HAColors.secondary.withOpacity(0.2),
      disabledColor: HAColors.darkCard,
      labelStyle: HATextStyles.labelMedium.copyWith(color: HAColors.textPrimaryDark),
      side: const BorderSide(color: HAColors.darkBorder),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
    ),

    // Text
    textTheme: _buildTextTheme(Brightness.dark),

    // Divider
    dividerTheme: const DividerThemeData(
      color: HAColors.darkDivider,
      thickness: 1,
      space: 1,
    ),
  );

  // ────────────────────────────────────────────────── LIGHT THEME ──
  static ThemeData get light => ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    fontFamily: 'Inter',
    colorScheme: const ColorScheme.light(
      primary: HAColors.secondary,
      secondary: HAColors.accent,
      surface: HAColors.lightSurface,
      error: HAColors.error,
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onSurface: HAColors.textPrimaryLight,
      onError: Colors.white,
      outline: HAColors.lightBorder,
    ),

    scaffoldBackgroundColor: HAColors.lightBg,
    cardColor: HAColors.lightCard,
    dividerColor: HAColors.lightDivider,

    appBarTheme: const AppBarTheme(
      backgroundColor: HAColors.lightBg,
      foregroundColor: HAColors.textPrimaryLight,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: false,
      systemOverlayStyle: SystemUiOverlayStyle(
        statusBarBrightness: Brightness.light,
        statusBarIconBrightness: Brightness.dark,
      ),
      titleTextStyle: TextStyle(
        fontFamily: 'Inter',
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: HAColors.textPrimaryLight,
      ),
    ),

    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: HAColors.lightSurface,
      selectedItemColor: HAColors.secondary,
      unselectedItemColor: HAColors.slate400,
      type: BottomNavigationBarType.fixed,
      elevation: 0,
    ),

    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: HAColors.lightSurface,
      indicatorColor: HAColors.secondary.withOpacity(0.12),
      iconTheme: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return const IconThemeData(color: HAColors.secondary);
        }
        return const IconThemeData(color: HAColors.slate400);
      }),
      labelTextStyle: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return HATextStyles.labelSmall.copyWith(color: HAColors.secondary);
        }
        return HATextStyles.labelSmall.copyWith(color: HAColors.slate400);
      }),
    ),

    cardTheme: CardTheme(
      color: HAColors.lightCard,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: HAColors.lightBorder, width: 1),
      ),
      margin: EdgeInsets.zero,
    ),

    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: HAColors.secondary,
        foregroundColor: Colors.white,
        elevation: 0,
        minimumSize: const Size(double.infinity, 52),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        textStyle: HATextStyles.labelLarge,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
      ),
    ),

    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: HAColors.secondary,
        side: const BorderSide(color: HAColors.secondary, width: 1.5),
        minimumSize: const Size(double.infinity, 52),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        textStyle: HATextStyles.labelLarge,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
      ),
    ),

    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: HAColors.lightElevated,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: HAColors.lightBorder),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: HAColors.lightBorder),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: HAColors.secondary, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: HAColors.error),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      hintStyle: HATextStyles.bodyMedium.copyWith(color: HAColors.slate400),
      labelStyle: HATextStyles.bodyMedium.copyWith(color: HAColors.slate500),
    ),

    chipTheme: ChipThemeData(
      backgroundColor: HAColors.lightElevated,
      selectedColor: HAColors.secondary.withOpacity(0.1),
      labelStyle: HATextStyles.labelMedium.copyWith(color: HAColors.textPrimaryLight),
      side: const BorderSide(color: HAColors.lightBorder),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
    ),

    textTheme: _buildTextTheme(Brightness.light),

    dividerTheme: const DividerThemeData(
      color: HAColors.lightDivider,
      thickness: 1,
      space: 1,
    ),
  );

  static TextTheme _buildTextTheme(Brightness brightness) {
    final bool isDark = brightness == Brightness.dark;
    final Color primary = isDark ? HAColors.textPrimaryDark : HAColors.textPrimaryLight;
    final Color secondary = isDark ? HAColors.textSecondaryDark : HAColors.textSecondaryLight;

    return TextTheme(
      displayLarge: HATextStyles.displayLarge.copyWith(color: primary),
      displayMedium: HATextStyles.displayMedium.copyWith(color: primary),
      headlineLarge: HATextStyles.h1.copyWith(color: primary),
      headlineMedium: HATextStyles.h2.copyWith(color: primary),
      headlineSmall: HATextStyles.h3.copyWith(color: primary),
      titleLarge: HATextStyles.h4.copyWith(color: primary),
      titleMedium: HATextStyles.h5.copyWith(color: primary),
      titleSmall: HATextStyles.labelLarge.copyWith(color: primary),
      bodyLarge: HATextStyles.bodyLarge.copyWith(color: primary),
      bodyMedium: HATextStyles.bodyMedium.copyWith(color: secondary),
      bodySmall: HATextStyles.bodySmall.copyWith(color: secondary),
      labelLarge: HATextStyles.labelLarge.copyWith(color: primary),
      labelMedium: HATextStyles.labelMedium.copyWith(color: secondary),
      labelSmall: HATextStyles.labelSmall.copyWith(color: secondary),
    );
  }
}

// ── Radius constants ──────────────────────────────────────────────────────────
class AppRadius {
  AppRadius._();
  static const double xs  = 4.0;
  static const double sm  = 8.0;
  static const double md  = 12.0;
  static const double lg  = 16.0;
  static const double xl  = 20.0;
  static const double xxl = 24.0;
  static const double full = 999.0;
}

// ── Theme extensions ──────────────────────────────────────────────────────────
extension ThemeExtensions on BuildContext {
  ColorScheme get cs => Theme.of(this).colorScheme;
  TextTheme   get tt => Theme.of(this).textTheme;
  bool        get isDark => Theme.of(this).brightness == Brightness.dark;
}

