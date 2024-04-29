import 'package:flutter/material.dart';
import 'package:flutter_finance_app/theme/themes.dart';

class ThemeModel extends ChangeNotifier {
  ThemeData currentTheme = lightMode;
  bool isHighContrast = false;


  void toggleTheme() {
    if (currentTheme == lightMode) {
      currentTheme = darkMode;
    } else if (currentTheme == darkMode) {
      currentTheme = lightMode;
    }
    notifyListeners();
  }


  bool get isDark => currentTheme == darkMode ;

}
