import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/game_data.dart';
import '../models/tournament.dart';
import '../models/ai_team.dart';
import '../models/patch_data.dart';
import '../models/sponsor.dart';
import '../models/game_event.dart';
import '../models/achievement.dart';

class DataService {
  static final DataService _instance = DataService._internal();
  factory DataService() => _instance;
  DataService._internal();

  BalanceData? balance;
  List<ItemDef> items = [];
  List<TournamentDef> tournaments = [];
  List<AiTeam> flagshipRivals = [];
  List<AiTeam> aiTeams = [];
  List<GameEventDef> events = [];
  List<NarrativeEvent> narrativeEvents = [];
  List<SponsorDef> sponsors = [];
  List<AchievementDef> achievements = [];
  List<PatchDef> patches = [];
  List<String> newsTicker = [];
  List<String> matchCommentary = [];
  Map<String, String> mikaDialogues = {};
  bool _loaded = false;

  bool get isLoaded => _loaded;

  List<AiTeam> get allTeams => [...flagshipRivals, ...aiTeams];

  PatchDef get currentPatch => patches.isNotEmpty
      ? patches.first
      : const PatchDef(
          version: '1.1',
          name: 'Midlane Roaming Meta',
          favoredStrategy: 'Rush',
          nerfedStrategy: 'Scale',
          changes: ['Rush +3', 'Scale -3'],
        );

  PatchDef getPatchForWeek(int week) {
    if (patches.isEmpty) return currentPatch;
    final idx = ((week - 1) ~/ 13) % patches.length;
    return patches[idx];
  }

  Future<void> loadAllData() async {
    if (_loaded) return;

    // 1. balance.json
    try {
      final balStr = await rootBundle.loadString('assets/data/balance.json');
      balance = BalanceData.fromJson(jsonDecode(balStr) as Map<String, dynamic>);
    } catch (_) {}

    // 2. items.json
    try {
      final itemStr = await rootBundle.loadString('assets/data/items.json');
      final itemList = jsonDecode(itemStr) as List<dynamic>;
      items = itemList.map((e) => ItemDef.fromJson(e as Map<String, dynamic>)).toList();
    } catch (_) {}

    // 3. tournaments.json
    try {
      final tourStr = await rootBundle.loadString('assets/data/tournaments.json');
      final tourList = jsonDecode(tourStr) as List<dynamic>;
      tournaments = tourList.map((e) => TournamentDef.fromJson(e as Map<String, dynamic>)).toList();
    } catch (_) {}

    // 4. teams.json
    try {
      final teamStr = await rootBundle.loadString('assets/data/teams.json');
      final teamMap = jsonDecode(teamStr) as Map<String, dynamic>;
      final rivals = teamMap['flagship_rivals'] as List<dynamic>? ?? [];
      flagshipRivals = rivals.map((e) => AiTeam.fromJson(e as Map<String, dynamic>)).toList();

      final list = teamMap['ai_teams'] as List<dynamic>? ?? [];
      aiTeams = list.map((e) => AiTeam.fromJson(e as Map<String, dynamic>)).toList();

      for (final t in allTeams) {
        if (t.circuitPoints == 0) {
          t.circuitPoints = _computeInitialTierPoints(t.tier, t.rating);
        }
      }
    } catch (_) {}

    // 5. events.json
    try {
      final evtStr = await rootBundle.loadString('assets/data/events.json');
      final evtList = jsonDecode(evtStr) as List<dynamic>;
      events = evtList.map((e) => GameEventDef.fromJson(e as Map<String, dynamic>)).toList();
      narrativeEvents = evtList.map((e) => NarrativeEvent.fromJson(e as Map<String, dynamic>)).toList();
    } catch (_) {}

    // 6. sponsors.json
    try {
      final spStr = await rootBundle.loadString('assets/data/sponsors.json');
      final spList = jsonDecode(spStr) as List<dynamic>;
      sponsors = spList.map((e) => SponsorDef.fromJson(e as Map<String, dynamic>)).toList();
    } catch (_) {}

    // 7. achievements.json
    try {
      final achStr = await rootBundle.loadString('assets/data/achievements.json');
      final achList = jsonDecode(achStr) as List<dynamic>;
      achievements = achList.map((e) => AchievementDef.fromJson(e as Map<String, dynamic>)).toList();
    } catch (_) {}

    // 8. patches.json
    try {
      final patchStr = await rootBundle.loadString('assets/data/patches.json');
      final patchList = jsonDecode(patchStr) as List<dynamic>;
      patches = patchList.map((e) => PatchDef.fromJson(e as Map<String, dynamic>)).toList();
    } catch (_) {}

    // 9. strings_taglish.json
    try {
      final strJson = await rootBundle.loadString('assets/data/strings_taglish.json');
      final map = jsonDecode(strJson) as Map<String, dynamic>;
      final news = map['news_ticker'] as List<dynamic>? ?? [];
      newsTicker = news.map((e) => e.toString()).toList();
      final commentary = map['match_commentary'] as List<dynamic>? ?? [];
      matchCommentary = commentary.map((e) => e.toString()).toList();
      final mika = map['mika_dialogues'] as Map<String, dynamic>? ?? {};
      mikaDialogues = mika.map((k, v) => MapEntry(k, v.toString()));
    } catch (_) {}

    _loaded = true;
  }

  ItemDef? findItem(String id) {
    try {
      return items.firstWhere((i) => i.id == id);
    } catch (_) {
      return null;
    }
  }

  TournamentDef? findTournament(String id) {
    try {
      return tournaments.firstWhere((t) => t.id == id);
    } catch (_) {
      return null;
    }
  }

  AiTeam? findTeam(String id) {
    try {
      return allTeams.firstWhere((t) => t.id == id);
    } catch (_) {
      return null;
    }
  }

  int _computeInitialTierPoints(int tier, int rating) {
    switch (tier) {
      case 7: return 1600 + ((rating - 80).clamp(0, 30) * 20);
      case 6: return 1000 + ((rating - 70).clamp(0, 30) * 15);
      case 5: return 600 + ((rating - 60).clamp(0, 30) * 12);
      case 4: return 320 + ((rating - 50).clamp(0, 30) * 10);
      case 3: return 140 + ((rating - 42).clamp(0, 30) * 8);
      case 2: return 50 + ((rating - 36).clamp(0, 30) * 5);
      default: return (rating - 30).clamp(0, 40);
    }
  }
}
