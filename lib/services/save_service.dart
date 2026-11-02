import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/game_state.dart';

class SaveService {
  static const String saveKey = 'esports_dynasty_save_v1';
  static const int currentVersion = 1;

  static Future<bool> saveGame(GameState state) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final map = {
        'version': currentVersion,
        'state': state.toJson(),
      };
      final jsonStr = jsonEncode(map);
      return await prefs.setString(saveKey, jsonStr);
    } catch (e) {
      return false;
    }
  }

  static Future<GameState?> loadGame() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonStr = prefs.getString(saveKey);
      if (jsonStr == null || jsonStr.isEmpty) return null;

      final map = jsonDecode(jsonStr) as Map<String, dynamic>;
      final stateJson = map['state'] as Map<String, dynamic>?;
      if (stateJson != null) {
        return GameState.fromJson(stateJson);
      }
    } catch (_) {}
    return null;
  }

  static Future<bool> hasSavedGame() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.containsKey(saveKey);
    } catch (_) {
      return false;
    }
  }

  static Future<bool> deleteSave() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return await prefs.remove(saveKey);
    } catch (_) {
      return false;
    }
  }
}
