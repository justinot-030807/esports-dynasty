import 'dart:convert';
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:esports_dynasty/models/game_state.dart';
import 'package:esports_dynasty/models/player.dart';
import 'package:esports_dynasty/models/division.dart';
import 'package:esports_dynasty/models/tournament.dart';
import 'package:esports_dynasty/services/data_service.dart';
import 'package:esports_dynasty/services/division_service.dart';
import 'package:esports_dynasty/services/tournament_service.dart';
import 'package:esports_dynasty/services/match_sim_engine.dart';
import 'package:esports_dynasty/services/scouting_service.dart';
import 'package:esports_dynasty/services/sim_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    try {
      await DataService().loadAllData();
    } catch (_) {}
    if (DataService().tournaments.isEmpty) {
      final file = File('assets/data/tournaments.json');
      if (file.existsSync()) {
        final list = jsonDecode(file.readAsStringSync()) as List<dynamic>;
        DataService().tournaments = list.map((e) => TournamentDef.fromJson(e as Map<String, dynamic>)).toList();
      }
    }
  });

  group('Phase 8: Multi-Division Architecture & Models', () {
    test('All 3 Esports Divisions are defined with valid squad sizes and roles', () {
      expect(EsportsDivision.all.length, 3);

      final ac = EsportsDivision.arenaClash;
      expect(ac.id, 'arena_clash');
      expect(ac.squadSize, 5);
      expect(ac.roles.length, 5);

      final sz = EsportsDivision.strikeZone;
      expect(sz.id, 'strike_zone');
      expect(sz.genre, 'Tactical FPS');
      expect(sz.squadSize, 5);
      expect(sz.minFame, 200);
      expect(sz.unlockCost, 20000);
      expect(sz.roles, contains(PlayerRole.entry));
      expect(sz.roles, contains(PlayerRole.sniper));

      final li = EsportsDivision.lastIsland;
      expect(li.id, 'last_island');
      expect(li.genre, 'Battle Royale');
      expect(li.squadSize, 4);
      expect(li.minFame, 500);
      expect(li.unlockCost, 40000);
      expect(li.roles, contains(PlayerRole.scout));
      expect(li.roles, contains(PlayerRole.medic));
    });

    test('Strategy cycles evaluate counter advantages across all divisions', () {
      // Arena Clash: Rush > Scale > Split > Teamfight > Rush
      expect(EsportsDivision.arenaClash.getStrategyModifier('Rush', 'Scale'), 4);
      expect(EsportsDivision.arenaClash.getStrategyModifier('Scale', 'Rush'), -4);
      expect(EsportsDivision.arenaClash.getStrategyModifier('Rush', 'Rush'), 0);

      // Strike Zone: Fast Site Take > Default Pick > Retake Setup > Eco Rush > Fast Site Take
      expect(EsportsDivision.strikeZone.getStrategyModifier('Fast Site Take', 'Default Pick'), 4);
      expect(EsportsDivision.strikeZone.getStrategyModifier('Default Pick', 'Fast Site Take'), -4);

      // Last Island: Hot Drop > Edge Loot & Rotate > Center Circle Hold > Ambush & Gatekeep > Hot Drop
      expect(EsportsDivision.lastIsland.getStrategyModifier('Hot Drop', 'Edge Loot & Rotate'), 4);
      expect(EsportsDivision.lastIsland.getStrategyModifier('Center Circle Hold', 'Edge Loot & Rotate'), -4);

      // Engine general lookup
      expect(MatchSimEngine.getStrategyModifier('Fast Site Take', 'Default Pick'), 4);
      expect(MatchSimEngine.getStrategyModifier('Hot Drop', 'Edge Loot & Rotate'), 4);
    });

    test('All player roles calculate OVR, display names, and stat caps without error', () {
      for (final r in PlayerRole.values) {
        final p = Player(
          id: 'test_${r.name}',
          realName: 'Test Player',
          gamerTag: 'Ace',
          role: r,
          aim: 50,
          reaction: 50,
          gameSense: 50,
          teamwork: 50,
          mental: 50,
          stamina: 50,
          potentialStars: 5,
        );

        expect(p.ovr, inInclusiveRange(40, 60));
        expect(p.roleDisplayName.isNotEmpty, true);
        expect(p.getStatCap('aim'), inInclusiveRange(99, 107));
      }
    });
  });

  group('Phase 8: Multi-Division Management & DivisionService', () {
    test('GameState starts with Arena Clash unlocked and switches active division', () {
      final state = GameState(teamName: 'Kidlat Club');
      expect(state.activeDivisionId, 'arena_clash');
      expect(state.isDivisionUnlocked('arena_clash'), true);
      expect(state.isDivisionUnlocked('strike_zone'), false);
      expect(state.isDivisionUnlocked('last_island'), false);

      state.unlockDivision('strike_zone');
      expect(state.isDivisionUnlocked('strike_zone'), true);

      state.setActiveDivision('strike_zone');
      expect(state.activeDivisionId, 'strike_zone');
      expect(state.activeDivision.name, 'Strike Zone');
    });

    test('DivisionService checks eligibility, deducts cost, and auto-signs starter squad', () {
      final state = GameState(
        teamName: 'Bakal Esports',
        money: 60000,
        fame: 350,
      );

      final sz = EsportsDivision.strikeZone;
      expect(DivisionService.canUnlockDivision(state, sz), true);

      final success = DivisionService.unlockDivision(state, 'strike_zone');
      expect(success, true);
      expect(state.money, 40000); // 60K - 20K
      expect(state.isDivisionUnlocked('strike_zone'), true);
      expect(state.activeDivisionId, 'strike_zone');

      final szPlayers = state.getPlayersForDivision('strike_zone');
      expect(szPlayers.length, 5);
      final szStarters = state.getStartersForDivision('strike_zone');
      expect(szStarters.length, 5);

      final stats = DivisionService.getDivisionStats(state, 'strike_zone');
      expect(stats['totalPlayers'], 5);
      expect(stats['startersCount'], 5);
      expect(stats['avgOvr'], greaterThan(25));
    });

    test('Last Island unlocks and spawns 4-player squad', () {
      final state = GameState(
        teamName: 'Dagat Gaming',
        money: 100000,
        fame: 800,
      );

      final success = DivisionService.unlockDivision(state, 'last_island');
      expect(success, true);
      expect(state.money, 60000); // 100K - 40K

      final liPlayers = state.getPlayersForDivision('last_island');
      expect(liPlayers.length, 4);
      expect(state.getStartersForDivision('last_island').length, 4);
    });

    test('ScoutingService generates division-tagged candidates', () {
      final state = GameState();
      final szCandidates = ScoutingService.generateFreeAgents(state, count: 4, divisionId: 'strike_zone');
      expect(szCandidates.length, 4);
      for (final c in szCandidates) {
        expect(c.divisionId, 'strike_zone');
        expect(EsportsDivision.strikeZone.roles.contains(c.role), true);
      }
    });
  });

  group('Phase 8: Multi-Division Circuit & Tournaments', () {
    test('Tournament circuit includes Strike Zone and Last Island events', () {
      final defs = DataService().tournaments;
      expect(defs.length, greaterThanOrEqualTo(33));

      final acTournaments = defs.where((t) => t.division == 'arena_clash').toList();
      final szTournaments = defs.where((t) => t.division == 'strike_zone').toList();
      final liTournaments = defs.where((t) => t.division == 'last_island').toList();

      expect(acTournaments.isNotEmpty, true);
      expect(szTournaments.length, 5);
      expect(liTournaments.length, 5);
    });

    test('Registration requires division unlock and exact squad size', () {
      final state = GameState(money: 50000, fame: 50);
      final szDef = DataService().findTournament('T1-SZ-CC')!;

      // Locked division error
      final errLocked = TournamentService.checkRegistrationEligibility(state, szDef);
      expect(errLocked, contains('I-unlock muna'));

      // Unlock without squad
      state.unlockDivision('strike_zone');
      final errSquad = TournamentService.checkRegistrationEligibility(state, szDef);
      expect(errSquad, contains('Kailangan ng 5 aktibong starters'));

      // Sign squad
      DivisionService.autoSignStarterRosterIfEmpty(state, 'strike_zone');
      final errReady = TournamentService.checkRegistrationEligibility(state, szDef);
      expect(errReady, isNull);
    });

    test('MatchSimEngine computes division-specific team power and awards division circuit points', () {
      final state = GameState(money: 50000, fame: 300);
      DivisionService.unlockDivision(state, 'strike_zone');

      final power = MatchSimEngine.calculateUserTeamPower(
        state,
        divisionId: 'strike_zone',
      );
      expect(power, greaterThan(25.0));

      state.addDivisionCircuitPoints('strike_zone', 250);
      expect(state.getDivisionCircuitPoints('strike_zone'), 250);
      expect(state.getDivisionCircuitPoints('arena_clash'), 0);
    });
  });

  group('Phase 8: Serialization & 10-Year Multi-Division Bot Sim', () {
    test('GameState round-trip serialization preserves multi-division state', () {
      final state = GameState(
        teamName: 'Empire Dynasty',
        money: 88000,
        fame: 650,
      );
      state.unlockDivision('strike_zone');
      state.unlockDivision('last_island');
      state.setActiveDivision('last_island');
      state.addDivisionCircuitPoints('strike_zone', 400);
      state.addDivisionCircuitPoints('last_island', 800);

      final json = state.toJson();
      final restored = GameState.fromJson(json);

      expect(restored.activeDivisionId, 'last_island');
      expect(restored.unlockedDivisions, contains('strike_zone'));
      expect(restored.unlockedDivisions, contains('last_island'));
      expect(restored.getDivisionCircuitPoints('strike_zone'), 400);
      expect(restored.getDivisionCircuitPoints('last_island'), 800);
    });

    test('Headless 10-year simulation scales and unlocks multiple divisions', () {
      final result = SimService.runTenYearSimulation(difficulty: 'normal');

      expect(result.durationMs, lessThan(60000));
      expect(result.bankrupt, false);
      expect(result.yearRecords.length, 10);

      // By Year 10, Fame has scaled and unlocked multi-divisions
      final y10 = result.yearRecords.last;
      expect(y10.divisionsCount, greaterThanOrEqualTo(2));
      expect(y10.formattedLine, contains('Divs:'));
    });
  });
}
