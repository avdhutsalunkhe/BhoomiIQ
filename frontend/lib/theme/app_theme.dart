import 'package:flutter/material.dart';

class AppColors {
  // Pure Crisp White Light Palette (Section 2 Visual Design System)
  static const Color bgDark = Color(0xFFFFFFFF);        // White background: #FFFFFF
  static const Color bgCard = Color(0xFFFFFFFF);        // Clean Card Surface
  static const Color bgCardGlass = Color(0xF8FFFFFF);   // Soft Translucent White
  static const Color bgSurface = Color(0xFFFFF7ED);     // Warm card background: #FFF7ED
  static const Color bgSurfaceMuted = Color(0xFFFAFAFA); // Ultra Clean Canvas

  // Agricultural Orange Accents (Primary Brand)
  static const Color orange = Color(0xFFEA580C);         // Primary agricultural orange: #EA580C
  static const Color orangeDark = Color(0xFFC2410C);     // Deep Burnt Orange
  static const Color orangeLight = Color(0xFFFFEDD5);    // Light Orange-100 Chip Background
  static const Color orangeGlow = Color(0xFFF97316);     // Secondary orange: #F97316
  static const Color orangeHover = Color(0xFFFB923C);

  // Crop Health & Alert Indicators
  static const Color emerald = Color(0xFF15803D);       // Healthy crop green: #15803D
  static const Color emeraldDark = Color(0xFF166534);
  static const Color emeraldGlow = Color(0xFF22C55E);
  
  static const Color cyan = Color(0xFF0284C7);          // Water / NDMI sensor: Sky Blue
  static const Color cyanDark = Color(0xFF0369A1);
  
  static const Color amber = Color(0xFFB45309);         // Warning amber: #B45309
  static const Color rose = Color(0xFFB91C1C);          // Urgent alert red: #B91C1C

  // Borders & Dividers
  static const Color border = Color(0xFFE5E5E5);        // Borders: #E5E5E5
  static const Color borderGlow = Color(0x66EA580C);    // Orange Accent Border
  static const Color divider = Color(0xFFF0F0F0);

  // Farmer-Friendly High-Contrast Typography (Black on White)
  static const Color textPrimary = Color(0xFF171717);   // Primary text: #171717
  static const Color textSecondary = Color(0xFF525252); // Secondary text: #525252
  static const Color textMuted = Color(0xFF737373);     // Neutral text

  // Cross-Widget Compatibility Aliases
  static const Color primary = orange;
  static const Color primaryDark = Color(0xFF9A3412);
  static const Color primaryLight = orangeLight;
  static const Color surface = bgCard;
  static const Color background = bgDark;
  static const Color statusGreen = emerald;
  static const Color statusYellow = amber;
  static const Color statusRed = rose;
  static const Color moistureBlue = cyan;
  static const Color moistureYellow = amber;
  static const Color moistureOrange = orange;
  static const Color accentMint = emerald;
  static const Color accentOrange = orange;
}

class AppTheme {
  static ThemeData get lightOrangeTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: const ColorScheme.light(
        primary: AppColors.orange,
        onPrimary: Colors.white,
        secondary: AppColors.orangeDark,
        onSecondary: Colors.white,
        surface: AppColors.bgCard,
        onSurface: AppColors.textPrimary,
      ),
      scaffoldBackgroundColor: AppColors.bgDark,
      canvasColor: AppColors.bgDark,
      cardColor: AppColors.bgCard,
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.white,
        foregroundColor: AppColors.textPrimary,
        elevation: 1,
        shadowColor: Color(0x14000000),
        centerTitle: false,
        scrolledUnderElevation: 1,
      ),
      cardTheme: CardThemeData(
        color: AppColors.bgCard,
        elevation: 2,
        shadowColor: const Color(0x0F000000),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AppColors.border, width: 1.2),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        elevation: 8,
        shadowColor: const Color(0x26000000),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: AppColors.border, width: 1.2),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.orange,
          foregroundColor: Colors.white,
          elevation: 1,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.3,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.orange,
          side: const BorderSide(color: AppColors.orange, width: 1.5),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Colors.white,
        selectedItemColor: AppColors.orange,
        unselectedItemColor: AppColors.textMuted,
        elevation: 8,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.bgSurfaceMuted,
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.orange, width: 2),
        ),
        hintStyle: const TextStyle(color: AppColors.textMuted, fontSize: 13),
      ),
    );
  }

  // Alias for backward compatibility
  static ThemeData get darkCommandTheme => lightOrangeTheme;
}
