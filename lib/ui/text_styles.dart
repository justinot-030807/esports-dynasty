import 'package:flutter/material.dart';
import '../core/constants.dart';

/// Centralized Typography System for ESPORTS DYNASTY.
/// Enforces MATCH_SCREEN_SPEC A1 Rules:
/// - Sizes in dp: scoreboard numbers 32, team names 16 bold, kill banners 24,
///   current commentary 16, history lines 14, nameplates 13, anything else 12 min.
/// - Light text with 1 to 2 px dark navy outline or shadow over art (contrast >= 4.5:1).
/// - Whole-number sizes only, bundled pixel font.
class AppTextStyles {
  static const Color darkNavy = Color(0xFF1B2A49);
  static const Color textWhite = Color(0xFFFFFFFF);
  static const Color textGold = AppConstants.moneyGold;
  static const Color textBlue = AppConstants.energyBlue;
  static const Color textGreen = AppConstants.positiveGreen;
  static const Color textRed = AppConstants.negativeRed;

  /// 1-2px dark navy shadow for crisp pixel readability over art
  static const List<Shadow> navyOutline = [
    Shadow(offset: Offset(-1, -1), color: darkNavy, blurRadius: 0),
    Shadow(offset: Offset(1, -1), color: darkNavy, blurRadius: 0),
    Shadow(offset: Offset(-1, 1), color: darkNavy, blurRadius: 0),
    Shadow(offset: Offset(1, 1), color: darkNavy, blurRadius: 0),
  ];

  static const List<Shadow> softShadow = [
    Shadow(offset: Offset(1, 1), color: darkNavy, blurRadius: 1),
  ];

  /// Scoreboard big numbers (32 dp)
  static const TextStyle scoreboardNumber = TextStyle(
    fontFamily: AppConstants.pixelFont,
    fontSize: 32,
    fontWeight: FontWeight.bold,
    color: textGold,
    shadows: navyOutline,
    height: 1.1,
  );

  /// Team names in scoreboard (16 dp bold)
  static const TextStyle teamName = TextStyle(
    fontFamily: AppConstants.pixelFont,
    fontSize: 16,
    fontWeight: FontWeight.bold,
    color: textWhite,
    shadows: navyOutline,
  );

  /// Kill banner & event alerts (24 dp bold)
  static const TextStyle killBanner = TextStyle(
    fontFamily: AppConstants.pixelFont,
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: textWhite,
    letterSpacing: 1.2,
    shadows: navyOutline,
  );

  /// Current live commentary line (16 dp)
  static const TextStyle currentCommentary = TextStyle(
    fontFamily: AppConstants.pixelFont,
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: darkNavy,
    height: 1.25,
  );

  /// History commentary lines (14 dp)
  static const TextStyle historyCommentary = TextStyle(
    fontFamily: AppConstants.pixelFont,
    fontSize: 14,
    fontWeight: FontWeight.normal,
    color: Color(0xFF2C3E60),
    height: 1.2,
  );

  /// Chibi player nameplates (13 dp bold)
  static const TextStyle nameplate = TextStyle(
    fontFamily: AppConstants.pixelFont,
    fontSize: 13,
    fontWeight: FontWeight.bold,
    color: textWhite,
    shadows: navyOutline,
  );

  /// Sub-labels, role badges, clock, win chance (14 dp)
  static const TextStyle label14 = TextStyle(
    fontFamily: AppConstants.pixelFont,
    fontSize: 14,
    fontWeight: FontWeight.bold,
    color: textWhite,
    shadows: softShadow,
  );

  /// Minimum allowed text size for chips, small badges, captions (12 dp)
  static const TextStyle caption12 = TextStyle(
    fontFamily: AppConstants.pixelFont,
    fontSize: 12,
    fontWeight: FontWeight.w600,
    color: textWhite,
    shadows: softShadow,
  );

  /// Button text (14 dp bold)
  static const TextStyle buttonText = TextStyle(
    fontFamily: AppConstants.pixelFont,
    fontSize: 14,
    fontWeight: FontWeight.bold,
    color: textWhite,
    shadows: navyOutline,
    letterSpacing: 0.5,
  );

  /// Navy colored caption for light windows (12 dp)
  static const TextStyle windowCaption = TextStyle(
    fontFamily: AppConstants.pixelFont,
    fontSize: 12,
    fontWeight: FontWeight.bold,
    color: darkNavy,
  );
}
