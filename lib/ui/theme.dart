import 'package:flutter/material.dart';
import '../core/constants.dart';

class GameTheme {
  static TextStyle pixelStyle({
    double fontSize = 14,
    Color color = AppConstants.darkNavy,
    FontWeight fontWeight = FontWeight.normal,
    double letterSpacing = 0.5,
  }) {
    return TextStyle(
      fontFamily: AppConstants.pixelFont,
      fontSize: fontSize,
      color: color,
      fontWeight: fontWeight,
      letterSpacing: letterSpacing,
      decoration: TextDecoration.none,
    );
  }

  static ThemeData get themeData {
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppConstants.bgDark,
      fontFamily: AppConstants.pixelFont,
      primaryColor: AppConstants.moneyGold,
    );
  }
}
