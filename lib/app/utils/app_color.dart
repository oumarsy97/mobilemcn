import 'package:flutter/material.dart';

class AppColors {
  // Couleurs principales inspirées de l'art africain
  static const Color primary = Color(0xFFD4845C); // Terracotta/Orange doux
  static const Color primaryDark = Color(0xFFB8694A);
  static const Color primaryLight = Color(0xFFE8A888);
  
  // Couleurs secondaires
  static const Color secondary = Color(0xFF8B7355); // Brun chaud
  static const Color secondaryLight = Color(0xFFA89080);
  
  // Couleurs d'accent
  static const Color accent = Color(0xFFE8C4A0); // Beige/Crème
  static const Color accentGold = Color(0xFFD4A574);
  
  // Couleurs neutres - PLUS DE BLANC
  static const Color background = Color(0xFFFFFFFF); // Blanc pur au lieu de crème
  static const Color surface = Color(0xFFFFFFFF); // Blanc pur
  static const Color cardBackground = Color(0xFFFAFAFA); // Gris très clair
  
  // Texte
  static const Color textPrimary = Color(0xFF2D2520);
  static const Color textSecondary = Color(0xFF6B5D54);
  static const Color textTertiary = Color(0xFF9B8D84);
  static const Color textOnPrimary = Color(0xFFFFFFFF);
  
  // États
  static const Color success = Color(0xFF5D8B5F);
  static const Color error = Color(0xFFB85C5C);
  static const Color warning = Color(0xFFD49B5C);
  static const Color info = Color(0xFF5C85B8);
  
  // Overlay
  static const Color overlay = Color(0x80000000);
  static const Color divider = Color(0xFFEEEEEE); // Plus clair
  
  // Dégradés
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primary, primaryDark],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const LinearGradient accentGradient = LinearGradient(
    colors: [accent, accentGold],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );
  
  // Ombres - Plus légères pour fond blanc
  static List<BoxShadow> get cardShadow => [
    BoxShadow(
      color: textPrimary.withOpacity(0.05),
      blurRadius: 12,
      offset: const Offset(0, 2),
    ),
  ];
  
  static List<BoxShadow> get elevatedShadow => [
    BoxShadow(
      color: textPrimary.withOpacity(0.08),
      blurRadius: 20,
      offset: const Offset(0, 6),
    ),
  ];
}