import 'package:flutter/material.dart';

/// Style Bible and Game constants from GAME_DESIGN.md
class AppConstants {
  // Logical canvas dimensions
  static const double canvasWidth = 360.0;
  static const double canvasHeight = 640.0;
  static const double tileSize = 32.0;

  // Style Bible Colors
  static const Color darkNavy = Color(0xFF0F172A);
  static const Color textDark = Color(0xFF0F172A);
  static const Color textNavy = Color(0xFF0F172A);
  static const Color textMuted = Color(0xFF475569);
  static const Color positiveGreen = Color(0xFF16A34A);
  static const Color negativeRed = Color(0xFFDC2626);
  static const Color moneyGold = Color(0xFFD97706);
  static const Color famePurple = Color(0xFF9333EA);
  static const Color fansPink = Color(0xFFDB2777);
  static const Color energyBlue = Color(0xFF0284C7);

  // Background and panels (Light Mode)
  static const Color bgDark = Color(0xFFF1F5F9);
  static const Color panelLight = Color(0xFFFFFFFF);
  static const Color panelBorder = Color(0xFFCBD5E1);
  static const Color panelHeader = Color(0xFFE2E8F0);

  // Scaled Mobile Typography Standards
  static const double fontMicro = 12.0;
  static const double fontSmall = 14.0;
  static const double fontBody = 16.0;
  static const double fontTitle = 18.0;
  static const double fontHeader = 22.0;

  // Time rules
  static const int daysPerWeek = 7;
  static const int weeksPerMonth = 4;
  static const int monthsPerYear = 12;
  static const int weeksPerYear = 48;
  static const int totalYears = 10;
  static const int totalWeeks = 480;

  // Font family
  static const String pixelFont = 'PixelifySans';
  static const String? bodyFont = null;
}
