import 'package:flutter/material.dart';

/// Style Bible and Game constants from GAME_DESIGN.md
class AppConstants {
  // Logical canvas dimensions
  static const double canvasWidth = 360.0;
  static const double canvasHeight = 640.0;
  static const double tileSize = 32.0;

  // Style Bible Colors
  static const Color darkNavy = Color(0xFF1B2A49); // Outlines and dark text
  static const Color textNavy = Color(0xFF1B2A49);
  static const Color positiveGreen = Color(0xFF3DBE5A);
  static const Color negativeRed = Color(0xFFE5484D);
  static const Color moneyGold = Color(0xFFF5B700);
  static const Color famePurple = Color(0xFF9B5DE5);
  static const Color fansPink = Color(0xFFFF6FA5);
  static const Color energyBlue = Color(0xFF3FA7FF);

  // Background and panels
  static const Color bgDark = Color(0xFF0F172A);
  static const Color panelLight = Color(0xFFF8FAFC);
  static const Color panelBorder = Color(0xFF1B2A49);
  static const Color panelHeader = Color(0xFF2B3A5E);

  // Time rules
  static const int daysPerWeek = 7;
  static const int weeksPerMonth = 4;
  static const int monthsPerYear = 12;
  static const int weeksPerYear = 48;
  static const int totalYears = 10;
  static const int totalWeeks = 480;

  // Font family
  static const String pixelFont = 'PixelifySans';
}
