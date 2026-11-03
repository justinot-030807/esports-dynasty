import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/game_state.dart';

class SaveSlotSummary {
  final int slot;
  final bool exists;
  final String teamName;
  final int year;
  final int month;
  final int week;
  final int day;
  final int money;
  final int fame;
  final String savedAt;

  SaveSlotSummary({
    required this.slot,
    required this.exists,
    this.teamName = '',
    this.year = 1,
    this.month = 1,
    this.week = 1,
    this.day = 1,
    this.money = 0,
    this.fame = 0,
    this.savedAt = '',
  });
}

class SaveService {
  static const String legacySaveKey = 'esports_dynasty_save_v1';
  static int currentSlot = 1;
  static const int currentVersion = 1;

  static String slotKey(int slot) => 'esports_dynasty_save_slot_$slot';

  static Future<bool> saveGame(GameState state, {int? slot}) async {
    final targetSlot = slot ?? currentSlot;
    currentSlot = targetSlot;
    try {
      final prefs = await SharedPreferences.getInstance();
      final map = {
        'version': currentVersion,
        'slot': targetSlot,
        'savedAt': DateTime.now().toIso8601String(),
        'state': state.toJson(),
      };
      final jsonStr = jsonEncode(map);
      await prefs.setString(slotKey(targetSlot), jsonStr);
      if (targetSlot == 1) {
        await prefs.setString(legacySaveKey, jsonStr);
      }
      return true;
    } catch (e) {
      return false;
    }
  }

  static Future<GameState?> loadGame({int? slot}) async {
    final targetSlot = slot ?? currentSlot;
    currentSlot = targetSlot;
    try {
      final prefs = await SharedPreferences.getInstance();
      var jsonStr = prefs.getString(slotKey(targetSlot));
      if ((jsonStr == null || jsonStr.isEmpty) && targetSlot == 1) {
        jsonStr = prefs.getString(legacySaveKey);
      }
      if (jsonStr == null || jsonStr.isEmpty) return null;

      final map = jsonDecode(jsonStr) as Map<String, dynamic>;
      final stateJson = map['state'] as Map<String, dynamic>?;
      if (stateJson != null) {
        return GameState.fromJson(stateJson);
      }
    } catch (_) {}
    return null;
  }

  static Future<bool> hasSavedGame({int? slot}) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      if (slot != null) {
        if (prefs.containsKey(slotKey(slot))) return true;
        if (slot == 1 && prefs.containsKey(legacySaveKey)) return true;
        return false;
      }
      return prefs.containsKey(slotKey(1)) ||
          prefs.containsKey(slotKey(2)) ||
          prefs.containsKey(slotKey(3)) ||
          prefs.containsKey(legacySaveKey);
    } catch (_) {
      return false;
    }
  }

  static Future<SaveSlotSummary> getSlotSummary(int slot) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      var jsonStr = prefs.getString(slotKey(slot));
      if ((jsonStr == null || jsonStr.isEmpty) && slot == 1) {
        jsonStr = prefs.getString(legacySaveKey);
      }
      if (jsonStr == null || jsonStr.isEmpty) {
        return SaveSlotSummary(slot: slot, exists: false);
      }
      final map = jsonDecode(jsonStr) as Map<String, dynamic>;
      final stateJson = map['state'] as Map<String, dynamic>? ?? {};
      return SaveSlotSummary(
        slot: slot,
        exists: true,
        teamName: stateJson['teamName'] as String? ?? 'Team',
        year: (stateJson['year'] as num?)?.toInt() ?? 1,
        month: (stateJson['month'] as num?)?.toInt() ?? 1,
        week: (stateJson['week'] as num?)?.toInt() ?? 1,
        day: (stateJson['day'] as num?)?.toInt() ?? 1,
        money: (stateJson['money'] as num?)?.toInt() ?? 0,
        fame: (stateJson['fame'] as num?)?.toInt() ?? 0,
        savedAt: (map['savedAt'] as String?)?.split('T').first ?? '',
      );
    } catch (_) {
      return SaveSlotSummary(slot: slot, exists: false);
    }
  }

  static Future<bool> deleteSave({int? slot}) async {
    final targetSlot = slot ?? currentSlot;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(slotKey(targetSlot));
      if (targetSlot == 1) await prefs.remove(legacySaveKey);
      return true;
    } catch (_) {
      return false;
    }
  }
}
