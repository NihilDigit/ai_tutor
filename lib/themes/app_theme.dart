import 'package:flutter/material.dart';

class AppTheme {
  // 颜色常量
  static const Color primaryColor = Colors.blue;
  static const Color secondaryColor = Colors.blueAccent;
  static const Color successColor = Colors.green;
  static const Color errorColor = Colors.red;
  static const Color warningColor = Colors.orange;

  // 尺寸常量
  static const double defaultPadding = 16.0;
  static const double defaultRadius = 8.0;
  static const double buttonHeight = 48.0;

  // 文字样式
  static TextTheme textTheme = const TextTheme(
    displayLarge: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
    displayMedium: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
    displaySmall: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
    headlineMedium: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
    headlineSmall: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
    titleLarge: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
    bodyLarge: TextStyle(fontSize: 16),
    bodyMedium: TextStyle(fontSize: 14),
    bodySmall: TextStyle(fontSize: 12),
  );

  // 浅色主题
  static ThemeData light = ThemeData(
    brightness: Brightness.light,
    useMaterial3: true,
    colorSchemeSeed: primaryColor,
    textTheme: textTheme,
    appBarTheme: const AppBarTheme(
      elevation: 0,
      centerTitle: true,
    ),
    buttonTheme: const ButtonThemeData(
      height: buttonHeight,
      padding: EdgeInsets.symmetric(horizontal: defaultPadding),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        minimumSize: const Size.fromHeight(buttonHeight),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(defaultRadius),
        ),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(defaultRadius),
      ),
      contentPadding: const EdgeInsets.all(defaultPadding),
    ),
    cardTheme: CardTheme(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(defaultRadius),
      ),
      margin: const EdgeInsets.all(defaultPadding),
    ),
    dialogTheme: DialogTheme(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(defaultRadius),
      ),
    ),
  );

  // 深色主题
  static ThemeData dark = ThemeData(
    brightness: Brightness.dark,
    useMaterial3: true,
    colorSchemeSeed: primaryColor,
    textTheme: textTheme,
    appBarTheme: const AppBarTheme(
      elevation: 0,
      centerTitle: true,
    ),
    buttonTheme: const ButtonThemeData(
      height: buttonHeight,
      padding: EdgeInsets.symmetric(horizontal: defaultPadding),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        minimumSize: const Size.fromHeight(buttonHeight),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(defaultRadius),
        ),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(defaultRadius),
      ),
      contentPadding: const EdgeInsets.all(defaultPadding),
    ),
    cardTheme: CardTheme(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(defaultRadius),
      ),
      margin: const EdgeInsets.all(defaultPadding),
    ),
    dialogTheme: DialogTheme(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(defaultRadius),
      ),
    ),
  );
}
