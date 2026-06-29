import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../constants/app_colors.dart';

/// Configuración completa del tema Material Design 3 de la aplicación
class AppTheme {
  AppTheme._();

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primary,
        primary: AppColors.primary,
        secondary: AppColors.secondary,
        tertiary: AppColors.accent,
        surface: AppColors.surface,
        error: AppColors.error,
        brightness: Brightness.light,
      ),
      scaffoldBackgroundColor: AppColors.background,

      // ── AppBar ─────────────────────────────────────────────────────
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.textLight,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          color: AppColors.textLight,
          fontSize: 18,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.5,
        ),
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: AppColors.primaryDark,
          statusBarIconBrightness: Brightness.light,
        ),
      ),

      // ── Cards ──────────────────────────────────────────────────────
      cardTheme: CardThemeData(
        elevation: 3,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(16)),
        ),
        color: AppColors.surface,
        surfaceTintColor: Colors.transparent,
      ),

      // ── ElevatedButton ─────────────────────────────────────────────
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.textLight,
          elevation: 2,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
      ),

      // ── OutlinedButton ─────────────────────────────────────────────
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primary,
          side: const BorderSide(color: AppColors.primary, width: 1.5),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      // ── TextButton ─────────────────────────────────────────────────
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.secondary,
          textStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      // ── InputDecoration ────────────────────────────────────────────
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surface,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFBDBDBD)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFBDBDBD), width: 1.2),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.error, width: 1.5),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.error, width: 2),
        ),
        labelStyle: const TextStyle(color: AppColors.textSecondary),
        hintStyle: const TextStyle(color: AppColors.textHint),
        errorStyle: const TextStyle(color: AppColors.error, fontSize: 12),
        prefixIconColor: AppColors.primary,
        suffixIconColor: AppColors.textSecondary,
      ),

      // ── FAB ────────────────────────────────────────────────────────
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.textLight,
        elevation: 4,
        shape: CircleBorder(),
      ),

      // ── Chip ───────────────────────────────────────────────────────
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.surfaceVariant,
        labelStyle: const TextStyle(color: AppColors.primary),
        side: const BorderSide(color: AppColors.primaryLight, width: 1),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),

      // ── Divider ────────────────────────────────────────────────────
      dividerTheme: const DividerThemeData(
        color: Color(0xFFE0E0E0),
        thickness: 1,
        space: 1,
      ),

      // ── Tipografía ─────────────────────────────────────────────────
      textTheme: const TextTheme(
        displayLarge: TextStyle(
          fontSize: 32, fontWeight: FontWeight.w800, color: AppColors.textPrimary, letterSpacing: -0.5,
        ),
        headlineLarge: TextStyle(
          fontSize: 26, fontWeight: FontWeight.w700, color: AppColors.textPrimary,
        ),
        headlineMedium: TextStyle(
          fontSize: 22, fontWeight: FontWeight.w700, color: AppColors.textPrimary,
        ),
        titleLarge: TextStyle(
          fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.textPrimary,
        ),
        titleMedium: TextStyle(
          fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.textPrimary,
        ),
        bodyLarge: TextStyle(
          fontSize: 16, fontWeight: FontWeight.w400, color: AppColors.textPrimary,
        ),
        bodyMedium: TextStyle(
          fontSize: 14, fontWeight: FontWeight.w400, color: AppColors.textSecondary,
        ),
        labelLarge: TextStyle(
          fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textPrimary,
        ),
      ),
    );
  }
}
