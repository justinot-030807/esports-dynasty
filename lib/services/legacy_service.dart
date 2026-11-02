import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/game_state.dart';
import '../models/legacy_state.dart';
import '../models/placed_furniture.dart';
import '../models/staff.dart';

class LegacyService {
  static final LegacyService _instance = LegacyService._internal();
  factory LegacyService() => _instance;
  LegacyService._internal();

  LegacyState globalLegacy = LegacyState();
  bool _initialized = false;

  Future<void> init() async {
    if (_initialized) return;
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString('global_legacy_state');
      if (raw != null) {
        final map = jsonDecode(raw) as Map<String, dynamic>;
        globalLegacy = LegacyState.fromJson(map);
      }
      _initialized = true;
    } catch (_) {
      _initialized = true;
    }
  }

  Future<void> saveLegacy() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final str = jsonEncode(globalLegacy.toJson());
      await prefs.setString('global_legacy_state', str);
    } catch (_) {}
  }

  /// Calculates Year 10 Dynasty score and awards Legacy Points
  FinalEvaluation evaluateYear10(GameState state) {
    final titlesCount = state.trophies.length;
    final legendsCount = state.hallOfFame.where((h) => h.category.toLowerCase().contains('legend')).length;
    final fameScore = state.fame * 2;
    final fansScore = (state.fans * 0.05).round();
    final houseScore = state.houseTier * 1000;
    final titleScore = titlesCount * 500;
    final legendScore = legendsCount * 800;
    final wealthScore = (state.money.clamp(0, 50000000) * 0.0001).round();

    final totalScore = titleScore + legendScore + fameScore + fansScore + houseScore + wealthScore;

    String rankTitle = 'Garage Owner';
    if (totalScore >= 15000) {
      rankTitle = 'World Dynasty';
    } else if (totalScore >= 7500) {
      rankTitle = "Asia's Finest";
    } else if (totalScore >= 3500) {
      rankTitle = 'National Treasure';
    } else if (totalScore >= 1500) {
      rankTitle = 'Provincial Pride';
    } else if (totalScore >= 500) {
      rankTitle = 'Local Hero';
    }

    final pointsEarned = (totalScore ~/ 400).clamp(1, 100);

    final evaluation = FinalEvaluation(
      score: totalScore,
      rankTitle: rankTitle,
      titlesCount: titlesCount,
      trophiesCount: titlesCount,
      legendsDeveloped: legendsCount,
      peakFame: state.fame,
      peakFans: state.fans,
      totalRevenue: state.money,
      legacyPointsEarned: pointsEarned,
      date: 'Y${state.year} W${state.week}',
    );

    // Update global legacy points & history
    globalLegacy.totalLegacyPoints += pointsEarned;
    globalLegacy.pastEvaluations.add(evaluation);
    saveLegacy();

    return evaluation;
  }

  /// Apply active Legacy Perks to a freshly initialized GameState
  void applyLegacyPerks(GameState state, List<String> perkIds) {
    for (final id in perkIds) {
      if (id == 'extra_cash_1') {
        state.money += 25000;
      } else if (id == 'extra_cash_2') {
        state.money += 50000;
      } else if (id == 'comfy_bed') {
        // Upgrade first bunk bed to comfy bed
        final bedIndex = state.furniture.indexWhere((f) => f.station == 'bed');
        if (bedIndex != -1) {
          state.furniture[bedIndex] = PlacedFurniture(
            id: state.furniture[bedIndex].id,
            itemId: 'comfy_bed',
            name: 'Comfy Bed',
            station: 'bed',
            tileX: state.furniture[bedIndex].tileX,
            tileY: state.furniture[bedIndex].tileY,
            sizeX: 2,
            sizeY: 1,
          );
        }
      } else if (id == 'pro_desk') {
        // Upgrade starter desks to pro desks
        for (int i = 0; i < state.furniture.length; i++) {
          if (state.furniture[i].station == 'pc') {
            state.furniture[i] = PlacedFurniture(
              id: state.furniture[i].id,
              itemId: 'pro_desk',
              name: 'Pro Gaming Desk',
              station: 'pc',
              tileX: state.furniture[i].tileX,
              tileY: state.furniture[i].tileY,
              sizeX: 2,
              sizeY: 1,
            );
          }
        }
      } else if (id == 'legend_coach') {
        // Add Level 3 Coach
        state.staff.removeWhere((s) => s.id == 'coach');
        state.staff.add(StaffMember(
          id: 'coach',
          name: 'Coach Norman',
          role: StaffRole.coach,
          level: 3,
          salary: 1200,
        ));
      } else if (id == 'dynasty_emblem') {
        state.fame += 100;
        state.emblemSymbol = 'crown';
      }
    }
  }
}
