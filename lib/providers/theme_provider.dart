import 'package:flutter/material.dart';
import '../themes/app_theme.dart';

class ThemeProvider with ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.system;

  ThemeMode get themeMode => _themeMode;

  void setThemeMode(ThemeMode mode) {
    _themeMode = mode;
    notifyListeners();
  }

  ThemeData get theme {
    switch (_themeMode) {
      case ThemeMode.light:
        return AppTheme.light;
      case ThemeMode.dark:
        return AppTheme.dark;
      default:
        return AppTheme.light;
    }
  }
}
