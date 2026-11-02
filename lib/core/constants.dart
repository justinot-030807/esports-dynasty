import 'package:flutter/material.dart';

/// Style Bible and Game constants from GAME_DESIGN.md
class AppConstants {
  // Logical canvas dimensions
  static const double canvasWidth = 360.0;
  static const double canvasHeight = 640.0;
  static const double tileSize = 32.0;

  // Style Bible Colors
  static const Color darkNavy = Color(0xFF1B2A49);
  static const Color textNavy = Color(0xFF1B2A49);
  static const Color positiveGreen = Color(0xFF22C55E);
  static const Color negativeRed = Color(0xFFEF4444);
  static const Color moneyGold = Color(0xFFF5B700);
  static const Color famePurple = Color(0xFFC084FC);
  static const Color fansPink = Color(0xFFF472B6);
  static const Color energyBlue = Color(0xFF38BDF8);

  // Background and panels
  static const Color bgDark = Color(0xFF162032);
  static const Color panelLight = Color(0xFFF8FAFC);
  static const Color panelBorder = Color(0xFF2A3B5C);
  static const Color panelHeader = Color(0xFF1E293B);

  // Scaled Mobile Typography Standards (PixelifySans)
  static const double fontMicro = 11.0;
  static const double fontSmall = 13.0;
  static const double fontBody = 15.0;
  static const double fontTitle = 17.0;
  static const double fontHeader = 20.0;

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
