// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'theme_constants.dart';

class AppTheme {
  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    primaryColor: ThemeConstants.primaryColor,
    colorScheme: const ColorScheme.light(
      primary: ThemeConstants.primaryColor,
      secondary: ThemeConstants.secondaryColor,
      error: ThemeConstants.errorColor,
      background: ThemeConstants.backgroundLightColor,
      surface: ThemeConstants.surfaceLightColor,
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onBackground: ThemeConstants.textLightColor,
      onSurface: ThemeConstants.textLightColor,
    ),
    scaffoldBackgroundColor: ThemeConstants.backgroundLightColor,
    cardTheme: CardTheme(
      color: ThemeConstants.surfaceLightColor,
      elevation: ThemeConstants.smallElevation,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(ThemeConstants.mediumRadius),
      ),
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: ThemeConstants.primaryColor,
      elevation: 0,
      systemOverlayStyle: SystemUiOverlayStyle.light,
      iconTheme: const IconThemeData(color: Colors.white),
      titleTextStyle: ThemeConstants.titleStyle.copyWith(color: Colors.white),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        foregroundColor: Colors.white,
        backgroundColor: ThemeConstants.primaryColor,
        textStyle: ThemeConstants.buttonStyle,
        padding: const EdgeInsets.symmetric(
          vertical: ThemeConstants.mediumPadding,
          horizontal: ThemeConstants.largePadding,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(ThemeConstants.mediumRadius),
        ),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: ThemeConstants.primaryColor,
        textStyle: ThemeConstants.buttonStyle,
        padding: const EdgeInsets.symmetric(
          vertical: ThemeConstants.smallPadding,
          horizontal: ThemeConstants.mediumPadding,
        ),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: ThemeConstants.primaryColor,
        textStyle: ThemeConstants.buttonStyle,
        side: const BorderSide(color: ThemeConstants.primaryColor),
        padding: const EdgeInsets.symmetric(
          vertical: ThemeConstants.mediumPadding,
          horizontal: ThemeConstants.largePadding,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(ThemeConstants.mediumRadius),
        ),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,
      hintStyle: ThemeConstants.bodyStyle.copyWith(color: Colors.grey),
      contentPadding: const EdgeInsets.all(ThemeConstants.mediumPadding),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(ThemeConstants.mediumRadius),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(ThemeConstants.mediumRadius),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(ThemeConstants.mediumRadius),
        borderSide: const BorderSide(color: ThemeConstants.primaryColor),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(ThemeConstants.mediumRadius),
        borderSide: const BorderSide(color: ThemeConstants.errorColor),
      ),
    ),
    textTheme: const TextTheme(
      displayLarge: ThemeConstants.headlineStyle,
      displayMedium: ThemeConstants.titleStyle,
      displaySmall: ThemeConstants.subtitleStyle,
      bodyLarge: ThemeConstants.bodyStyle,
      bodyMedium: ThemeConstants.bodyStyle,
      bodySmall: ThemeConstants.captionStyle,
      labelLarge: ThemeConstants.buttonStyle,
    ),
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: Colors.white,
      selectedItemColor: ThemeConstants.primaryColor,
      unselectedItemColor: Colors.grey,
      type: BottomNavigationBarType.fixed,
      elevation: ThemeConstants.mediumElevation,
      showSelectedLabels: true,
      showUnselectedLabels: true,
      selectedLabelStyle: ThemeConstants.captionStyle.copyWith(
        fontWeight: FontWeight.w500,
      ),
      unselectedLabelStyle: ThemeConstants.captionStyle,
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: ThemeConstants.primaryColor,
      foregroundColor: Colors.white,
    ),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: Colors.black.withOpacity(0.8),
      contentTextStyle: ThemeConstants.bodyStyle.copyWith(color: Colors.white),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(ThemeConstants.mediumRadius),
      ),
    ),
    dialogTheme: DialogTheme(
      backgroundColor: ThemeConstants.surfaceLightColor,
      elevation: ThemeConstants.largeElevation,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(ThemeConstants.largeRadius),
      ),
    ),
    dividerTheme: const DividerThemeData(color: Colors.grey, thickness: 0.5),
    checkboxTheme: CheckboxThemeData(
      fillColor: MaterialStateProperty.resolveWith<Color>((states) {
        if (states.contains(MaterialState.selected)) {
          return ThemeConstants.primaryColor;
        }
        return Colors.grey;
      }),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(ThemeConstants.smallRadius),
      ),
    ),
    switchTheme: SwitchThemeData(
      thumbColor: MaterialStateProperty.resolveWith<Color>((states) {
        if (states.contains(MaterialState.selected)) {
          return ThemeConstants.primaryColor;
        }
        return Colors.grey;
      }),
      trackColor: MaterialStateProperty.resolveWith<Color>((states) {
        if (states.contains(MaterialState.selected)) {
          return ThemeConstants.primaryLightColor;
        }
        return Colors.grey.withOpacity(0.5);
      }),
    ),
  );

  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    primaryColor: ThemeConstants.primaryColor,
    colorScheme: const ColorScheme.dark(
      primary: ThemeConstants.primaryColor,
      secondary: ThemeConstants.secondaryColor,
      error: ThemeConstants.errorColor,
      background: ThemeConstants.backgroundDarkColor,
      surface: ThemeConstants.surfaceDarkColor,
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onBackground: ThemeConstants.textDarkColor,
      onSurface: ThemeConstants.textDarkColor,
    ),
    scaffoldBackgroundColor: ThemeConstants.backgroundDarkColor,
    cardTheme: CardTheme(
      color: ThemeConstants.surfaceDarkColor,
      elevation: ThemeConstants.smallElevation,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(ThemeConstants.mediumRadius),
      ),
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: ThemeConstants.surfaceDarkColor,
      elevation: 0,
      systemOverlayStyle: SystemUiOverlayStyle.light,
      iconTheme: const IconThemeData(color: Colors.white),
      titleTextStyle: ThemeConstants.titleStyle.copyWith(color: Colors.white),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        foregroundColor: Colors.white,
        backgroundColor: ThemeConstants.primaryColor,
        textStyle: ThemeConstants.buttonStyle,
        padding: const EdgeInsets.symmetric(
          vertical: ThemeConstants.mediumPadding,
          horizontal: ThemeConstants.largePadding,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(ThemeConstants.mediumRadius),
        ),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: ThemeConstants.primaryColor,
        textStyle: ThemeConstants.buttonStyle,
        padding: const EdgeInsets.symmetric(
          vertical: ThemeConstants.smallPadding,
          horizontal: ThemeConstants.mediumPadding,
        ),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: ThemeConstants.primaryColor,
        textStyle: ThemeConstants.buttonStyle,
        side: const BorderSide(color: ThemeConstants.primaryColor),
        padding: const EdgeInsets.symmetric(
          vertical: ThemeConstants.mediumPadding,
          horizontal: ThemeConstants.largePadding,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(ThemeConstants.mediumRadius),
        ),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: ThemeConstants.surfaceDarkColor,
      hintStyle: ThemeConstants.bodyStyle.copyWith(color: Colors.grey),
      contentPadding: const EdgeInsets.all(ThemeConstants.mediumPadding),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(ThemeConstants.mediumRadius),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(ThemeConstants.mediumRadius),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(ThemeConstants.mediumRadius),
        borderSide: const BorderSide(color: ThemeConstants.primaryColor),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(ThemeConstants.mediumRadius),
        borderSide: const BorderSide(color: ThemeConstants.errorColor),
      ),
    ),
    textTheme: TextTheme(
      displayLarge: ThemeConstants.headlineStyle.copyWith(
        color: ThemeConstants.textDarkColor,
      ),
      displayMedium: ThemeConstants.titleStyle.copyWith(
        color: ThemeConstants.textDarkColor,
      ),
      displaySmall: ThemeConstants.subtitleStyle.copyWith(
        color: ThemeConstants.textDarkColor,
      ),
      bodyLarge: ThemeConstants.bodyStyle.copyWith(
        color: ThemeConstants.textDarkColor,
      ),
      bodyMedium: ThemeConstants.bodyStyle.copyWith(
        color: ThemeConstants.textDarkColor,
      ),
      bodySmall: ThemeConstants.captionStyle.copyWith(
        color: ThemeConstants.textDarkColor,
      ),
      labelLarge: ThemeConstants.buttonStyle.copyWith(
        color: ThemeConstants.textDarkColor,
      ),
    ),
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: ThemeConstants.surfaceDarkColor,
      selectedItemColor: ThemeConstants.primaryColor,
      unselectedItemColor: Colors.grey,
      type: BottomNavigationBarType.fixed,
      elevation: ThemeConstants.mediumElevation,
      showSelectedLabels: true,
      showUnselectedLabels: true,
      selectedLabelStyle: ThemeConstants.captionStyle.copyWith(
        fontWeight: FontWeight.w500,
      ),
      unselectedLabelStyle: ThemeConstants.captionStyle,
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: ThemeConstants.primaryColor,
      foregroundColor: Colors.white,
    ),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: Colors.black.withOpacity(0.8),
      contentTextStyle: ThemeConstants.bodyStyle.copyWith(color: Colors.white),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(ThemeConstants.mediumRadius),
      ),
    ),
    dialogTheme: DialogTheme(
      backgroundColor: ThemeConstants.surfaceDarkColor,
      elevation: ThemeConstants.largeElevation,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(ThemeConstants.largeRadius),
      ),
    ),
    dividerTheme: const DividerThemeData(color: Colors.grey, thickness: 0.5),
    checkboxTheme: CheckboxThemeData(
      fillColor: MaterialStateProperty.resolveWith<Color>((states) {
        if (states.contains(MaterialState.selected)) {
          return ThemeConstants.primaryColor;
        }
        return Colors.grey;
      }),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(ThemeConstants.smallRadius),
      ),
    ),
    switchTheme: SwitchThemeData(
      thumbColor: MaterialStateProperty.resolveWith<Color>((states) {
        if (states.contains(MaterialState.selected)) {
          return ThemeConstants.primaryColor;
        }
        return Colors.grey;
      }),
      trackColor: MaterialStateProperty.resolveWith<Color>((states) {
        if (states.contains(MaterialState.selected)) {
          return ThemeConstants.primaryLightColor;
        }
        return Colors.grey.withOpacity(0.5);
      }),
    ),
  );
}
