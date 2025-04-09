import 'package:flutter/material.dart';

class ThemeConstants {
  // Colors
  static const Color primaryColor = Color(0xFF00BFA5);
  static const Color primaryDarkColor = Color(0xFF007A68);
  static const Color primaryLightColor = Color(0xFF5DF2D6);

  static const Color secondaryColor = Color(0xFFFF4081);
  static const Color secondaryDarkColor = Color(0xFFC60055);
  static const Color secondaryLightColor = Color(0xFFFF79B0);

  static const Color backgroundLightColor = Color(0xFFF5F5F5);
  static const Color backgroundDarkColor = Color(0xFF121212);

  static const Color surfaceLightColor = Colors.white;
  static const Color surfaceDarkColor = Color(0xFF1E1E1E);

  static const Color textLightColor = Color(0xFF212121);
  static const Color textDarkColor = Color(0xFFF5F5F5);

  static const Color errorColor = Color(0xFFB00020);

  // Text styles
  static const TextStyle headlineStyle = TextStyle(
    fontFamily: 'Poppins',
    fontWeight: FontWeight.w600,
    fontSize: 24,
    letterSpacing: 0.15,
  );

  static const TextStyle titleStyle = TextStyle(
    fontFamily: 'Poppins',
    fontWeight: FontWeight.w600,
    fontSize: 20,
    letterSpacing: 0.15,
  );

  static const TextStyle subtitleStyle = TextStyle(
    fontFamily: 'Poppins',
    fontWeight: FontWeight.w500,
    fontSize: 16,
    letterSpacing: 0.15,
  );

  static const TextStyle bodyStyle = TextStyle(
    fontFamily: 'Poppins',
    fontWeight: FontWeight.w400,
    fontSize: 14,
    letterSpacing: 0.25,
  );

  static const TextStyle buttonStyle = TextStyle(
    fontFamily: 'Poppins',
    fontWeight: FontWeight.w500,
    fontSize: 14,
    letterSpacing: 1.25,
  );

  static const TextStyle captionStyle = TextStyle(
    fontFamily: 'Poppins',
    fontWeight: FontWeight.w400,
    fontSize: 12,
    letterSpacing: 0.4,
  );

  // Padding
  static const double smallPadding = 8.0;
  static const double mediumPadding = 16.0;
  static const double largePadding = 20.0;
  static const double extraLargePadding = 32.0;

  // Border radius
  static const double smallRadius = 4.0;
  static const double mediumRadius = 8.0;
  static const double largeRadius = 16.0;
  static const double extraLargeRadius = 24.0;

  // Elevation
  static const double smallElevation = 2.0;
  static const double mediumElevation = 4.0;
  static const double largeElevation = 8.0;

  // Animation duration
  static const Duration shortDuration = Duration(milliseconds: 200);
  static const Duration mediumDuration = Duration(milliseconds: 300);
  static const Duration longDuration = Duration(milliseconds: 500);
}
