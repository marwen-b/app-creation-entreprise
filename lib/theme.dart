import 'package:flutter/material.dart';

/// Palette reprise des maquettes Figma (collection « Couleurs »).
class AppColors {
  static const primaire = Color(0xFF0F5C4D);
  static const primaireDoux = Color(0xFFE3EFEB);
  static const accent = Color(0xFFD9622B);
  static const accentDoux = Color(0xFFFBE9DF);
  static const fond = Color(0xFFF7F5F0);
  static const surface = Color(0xFFFFFFFF);
  static const texte = Color(0xFF1A1D1F);
  static const texteSecondaire = Color(0xFF5B6166);
  static const bordure = Color(0xFFE6E2DA);
  static const desactive = Color(0xFFA3A8AD);
}

/// Styles de texte communs.
class TS {
  static const h1 = TextStyle(fontSize: 26, fontWeight: FontWeight.w800, height: 1.2, color: AppColors.texte);
  static const h2 = TextStyle(fontSize: 22, fontWeight: FontWeight.w800, height: 1.25, color: AppColors.texte);
  static const h3 = TextStyle(fontSize: 16, fontWeight: FontWeight.w700, height: 1.3, color: AppColors.texte);
  static const title = TextStyle(fontSize: 14, fontWeight: FontWeight.w700, height: 1.3, color: AppColors.texte);
  static const body = TextStyle(fontSize: 14, height: 1.45, color: AppColors.texteSecondaire);
  static const bodyDark = TextStyle(fontSize: 14, height: 1.45, color: AppColors.texte);
  static const small = TextStyle(fontSize: 12, height: 1.35, fontWeight: FontWeight.w500, color: AppColors.texteSecondaire);
  static const label = TextStyle(fontSize: 12, fontWeight: FontWeight.w800, letterSpacing: 1.0, color: AppColors.accent);
}

ThemeData buildTheme() {
  final base = ThemeData(
    useMaterial3: true,
    fontFamily: 'PlusJakartaSans',
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.primaire,
      primary: AppColors.primaire,
      secondary: AppColors.accent,
      surface: AppColors.surface,
    ),
    scaffoldBackgroundColor: AppColors.fond,
  );
  return base.copyWith(
    textTheme: base.textTheme.apply(bodyColor: AppColors.texte, displayColor: AppColors.texte),
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.fond,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      foregroundColor: AppColors.texte,
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: AppColors.primaire,
        foregroundColor: Colors.white,
        disabledBackgroundColor: AppColors.bordure,
        disabledForegroundColor: AppColors.desactive,
        minimumSize: const Size.fromHeight(52),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        textStyle: const TextStyle(fontFamily: 'PlusJakartaSans', fontSize: 16, fontWeight: FontWeight.w700),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.primaire,
        minimumSize: const Size.fromHeight(48),
        side: const BorderSide(color: AppColors.bordure, width: 1.5),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        textStyle: const TextStyle(fontFamily: 'PlusJakartaSans', fontSize: 15, fontWeight: FontWeight.w700),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: AppColors.primaire,
        textStyle: const TextStyle(fontFamily: 'PlusJakartaSans', fontSize: 14, fontWeight: FontWeight.w700),
      ),
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.transparent,
      indicatorColor: AppColors.primaireDoux,
      height: 68,
      labelTextStyle: WidgetStateProperty.resolveWith((states) {
        final on = states.contains(WidgetState.selected);
        return TextStyle(
          fontFamily: 'PlusJakartaSans',
          fontSize: 11,
          fontWeight: on ? FontWeight.w700 : FontWeight.w500,
          color: on ? AppColors.primaire : AppColors.texteSecondaire,
        );
      }),
      iconTheme: WidgetStateProperty.resolveWith((states) {
        final on = states.contains(WidgetState.selected);
        return IconThemeData(color: on ? AppColors.primaire : AppColors.texteSecondaire);
      }),
    ),
    dividerTheme: const DividerThemeData(color: AppColors.bordure, thickness: 1, space: 1),
    snackBarTheme: const SnackBarThemeData(behavior: SnackBarBehavior.floating),
  );
}
