import 'dart:convert';
import 'package:flutter/services.dart';

class AssetManager {
  static final AssetManager _instance = AssetManager._internal();
  factory AssetManager() => _instance;
  AssetManager._internal();

  Map<String, dynamic> _manifest = {};
  bool _isLoaded = false;

  Future<void> loadManifest() async {
    if (_isLoaded) return;
    try {
      final jsonStr = await rootBundle.loadString('assets/assets_manifest.json');
      _manifest = jsonDecode(jsonStr) as Map<String, dynamic>;
      _isLoaded = true;
    } catch (e) {
      // Fallback if manifest is missing
      _manifest = {};
    }
  }

  String getPath(String logicalId, {String fallback = ''}) {
    if (_manifest.containsKey(logicalId)) {
      final item = _manifest[logicalId];
      if (item is Map && item['file'] != null) {
        return item['file'] as String;
      }
    }
    return fallback.isNotEmpty ? fallback : 'assets/images/branding/app_icon.png';
  }

  // Pre-mapped direct asset getters
  static const String logo = 'assets/images/branding/logo.png';
  static const String splash = 'assets/images/branding/splash.png';
  static const String appIcon = 'assets/images/branding/app_icon.png';
  static const String panel = 'assets/images/ui/panel.png';
  static const String btnGreen = 'assets/images/ui/btn_green.png';
  static const String btnRed = 'assets/images/ui/btn_red.png';
  static const String btnYellow = 'assets/images/ui/btn_yellow.png';

  static const String iconMoney = 'assets/images/icons/icon_money.png';
  static const String iconFans = 'assets/images/icons/icon_fans.png';
  static const String iconFame = 'assets/images/icons/icon_fame.png';
  static const String iconTrophy = 'assets/images/icons/icon_trophy.png';
  static const String iconCalendar = 'assets/images/icons/icon_calendar.png';
  static const String iconEnergy = 'assets/images/icons/icon_energy.png';
  static const String iconMood = 'assets/images/icons/icon_mood.png';
  static const String iconTraining = 'assets/images/icons/icon_training.png';
  static const String iconStream = 'assets/images/icons/icon_stream.png';

  static const String gamerM01Idle = 'assets/images/characters/gamer_m01/gamer_m01_front_idle.png';
  static const String gamerM01Step1 = 'assets/images/characters/gamer_m01/gamer_m01_front_step1.png';
  static const String gamerM01Step2 = 'assets/images/characters/gamer_m01/gamer_m01_front_step2.png';

  static const String pcDesk = 'assets/images/furniture/pc_desk.png';
  static const String bunkBed = 'assets/images/furniture/bunk_bed.png';
  static const String kitchen = 'assets/images/furniture/kitchen.png';
  static const String trophyShelf = 'assets/images/furniture/trophy_shelf.png';

  static const String roomBg = 'assets/images/house/room_background.png';
  static const String wallSection = 'assets/images/house/wall_section.png';
  static const String floorTile = 'assets/images/house/floor_tile.png';
}
