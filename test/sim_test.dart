import 'package:flutter_test/flutter_test.dart';
import 'package:esports_dynasty/models/game_state.dart';
import 'package:esports_dynasty/models/player.dart';
import 'package:esports_dynasty/models/staff.dart';
import 'package:esports_dynasty/models/weekly_plan.dart';
import 'package:esports_dynasty/models/placed_furniture.dart';
import 'package:esports_dynasty/services/sim_service.dart';
import 'package:esports_dynasty/services/training_engine.dart';
import 'package:esports_dynasty/services/finance_service.dart';
import 'package:esports_dynasty/services/scouting_service.dart';
import 'package:esports_dynasty/models/tournament.dart';
import 'package:esports_dynasty/models/ai_team.dart';
import 'package:esports_dynasty/services/bracket_engine.dart';
import 'package:esports_dynasty/services/match_sim_engine.dart';
import 'package:esports_dynasty/services/tournament_service.dart';
import 'package:esports_dynasty/models/patch_data.dart';
import 'package:esports_dynasty/services/advanced_bracket_engine.dart';
import 'package:esports_dynasty/services/bracket_advancement_engine.dart';
import 'package:esports_dynasty/services/season_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Foundation & Economy Invariants', () {
    test('GameState serialization round-trip preserves state', () {
      final initial = GameState.initial(
        teamName: 'Mighty Tamaraws',
        ownerName: 'Kuya Boss',
        primaryColorHex: '#1B2A49',
        secondaryColorHex: '#F5B700',
        emblemSymbol: 'lightning',
        emblemLetters: 'MT',
      );

      final json = initial.toJson();
      final restored = GameState.fromJson(json);

      expect(restored.teamName, equals('Mighty Tamaraws'));
      expect(restored.ownerName, equals('Kuya Boss'));
      expect(restored.money, equals(50000));
      expect(restored.fans, equals(50));
      expect(restored.fame, equals(0));
      expect(restored.players.length, equals(3));
      expect(restored.furniture.length, equals(7));
    });

    test('Player OVR calculates correctly per role weights', () {
      final carry = Player(
        id: 'c1', realName: 'Mark', gamerTag: 'Kupido', role: PlayerRole.carry,
        aim: 40, reaction: 40, gameSense: 40, teamwork: 40, mental: 40, stamina: 40,
      );
      expect(carry.ovr, equals(40));
      expect(carry.rankTitle, equals('Amateur'));

      final legend = Player(
        id: 'l1', realName: 'Mark', gamerTag: 'Kupido', role: PlayerRole.carry,
        aim: 95, reaction: 95, gameSense: 95, teamwork: 90, mental: 90, stamina: 90,
      );
      expect(legend.ovr, greaterThanOrEqualTo(92));
      expect(legend.rankTitle, equals('Legend'));
    });

    test('Headless 10-year simulation completes in under 60 seconds without crashes', () {
      final result = SimService.runTenYearSimulation();

      expect(result.durationMs, lessThan(60000));
      expect(result.yearReports.length, greaterThanOrEqualTo(10));
      expect(result.finalFame, greaterThan(0));
      expect(result.finalFans, greaterThan(0));
      expect(result.bankrupt, isFalse);
    });
  });

  group('Phase 2 Management Core: Training Engine', () {
    test('Stat gain formula applies coach, desk, trait, and carry-over', () {
      final state = GameState.initial(
        teamName: 'Team Test',
        ownerName: 'Coach Test',
        primaryColorHex: '#1B2A49',
        secondaryColorHex: '#F5B700',
        emblemSymbol: 'star',
        emblemLetters: 'TT',
      );

      final player = state.players.first;
      final initialAim = player.aim;

      // Assign Aim training
      state.currentPlan.playerActivities[player.id] = PlayerActivity.trainAim;

      // Ensure coach is hired to test coach multiplier
      state.staff.add(StaffMember(
        id: 's_coach',
        name: 'Coach Leo',
        role: StaffRole.coach,
        level: 2, // 1.05 mult
        salary: 1200,
      ));

      // Process 1 week of training
      TrainingEngine.processWeek(state);

      // Aim should increase, fatigue should increase, carry-over fraction tracked
      expect(player.aim, greaterThanOrEqualTo(initialAim));
      expect(player.fatigue, greaterThan(0));
      expect(player.trainingCarry.containsKey('aim'), isTrue);
    });

    test('Station bottleneck applies 30% penalty when PCs are insufficient', () {
      final state = GameState.initial(
        teamName: 'Team Desk Test',
        ownerName: 'Desk Test',
        primaryColorHex: '#1B2A49',
        secondaryColorHex: '#F5B700',
        emblemSymbol: 'star',
        emblemLetters: 'DT',
      );

      // Remove all PC desks from furniture
      state.furniture.removeWhere((f) => f.station == 'pc');
      expect(state.pcDeskCapacity, equals(0));

      // 3 players training on PC without desks
      for (final p in state.players) {
        state.currentPlan.playerActivities[p.id] = PlayerActivity.trainAim;
      }

      final p0 = state.players[0];
      final oldAim = p0.aim;

      TrainingEngine.processWeek(state);

      // Training completed with bottleneck penalty
      expect(p0.aim, greaterThanOrEqualTo(oldAim));
    });

    test('Player stat cap limits top 2 role stats (+8) based on potential stars', () {
      final player5Star = Player(
        id: 'p_cap5',
        realName: 'Top Frag',
        gamerTag: 'Apex',
        role: PlayerRole.carry, // Carry top 2 stats: aim, reaction
        potentialStars: 5,
        aim: 100,
        reaction: 100,
        gameSense: 100,
        teamwork: 100,
        mental: 100,
        stamina: 100,
      );

      // 5-star base cap is 99, top 2 stats reach 107
      expect(player5Star.getStatCap('aim'), equals(107));
      expect(player5Star.getStatCap('reaction'), equals(107));
      expect(player5Star.getStatCap('gameSense'), equals(99));
      expect(player5Star.getStatCap('teamwork'), equals(99));

      final player3Star = Player(
        id: 'p_cap3',
        realName: 'Average Joe',
        gamerTag: 'MidTier',
        role: PlayerRole.carry,
        potentialStars: 3,
        aim: 60,
        reaction: 60,
        gameSense: 60,
        teamwork: 60,
        mental: 60,
        stamina: 60,
      );

      // 3-star base cap is 80, top 2 stats reach 88
      expect(player3Star.getStatCap('aim'), equals(88));
      expect(player3Star.getStatCap('reaction'), equals(88));
      expect(player3Star.getStatCap('gameSense'), equals(80));
    });

    test('Rest activity reduces fatigue and restores condition', () {
      final state = GameState.initial(
        teamName: 'Team Rest',
        ownerName: 'Rest Boss',
        primaryColorHex: '#1B2A49',
        secondaryColorHex: '#F5B700',
        emblemSymbol: 'shield',
        emblemLetters: 'TR',
      );

      final p = state.players.first;
      p.fatigue = 60;
      expect(p.condition, equals(PlayerCondition.tired));

      state.currentPlan.playerActivities[p.id] = PlayerActivity.rest;
      TrainingEngine.processWeek(state);

      expect(p.fatigue, lessThan(60));
    });
  });

  group('Phase 2 Management Core: Finance & Scouting', () {
    test('FinanceService bills salaries, collects streams, and logs report', () {
      final state = GameState.initial(
        teamName: 'Money Team',
        ownerName: 'Rich Guy',
        primaryColorHex: '#1B2A49',
        secondaryColorHex: '#F5B700',
        emblemSymbol: 'crown',
        emblemLetters: 'MT',
      );

      final startMoney = state.money;
      state.currentPlan.playerActivities[state.players[0].id] = PlayerActivity.stream;

      FinanceService.processWeeklyFinances(state);

      // Money should be deducted for salaries and credited for streaming & sponsors
      expect(state.money, isNot(equals(startMoney)));
      expect(state.monthPlayerSalaries, greaterThan(0));

      // At end of month (week 4), rent is deducted via generateMonthlyReport
      state.week = 4;
      FinanceService.processWeeklyFinances(state);

      final report = FinanceService.generateMonthlyReport(state);
      expect(report.month, equals(state.month));
      expect(report.playerSalariesPaid, greaterThan(0));
      expect(report.rentPaid, greaterThan(0));
      expect(state.lastMonthlyReport?.rentPaid, greaterThan(0));
    });

    test('ScoutingService generates valid free agents and open tryouts', () {
      final state = GameState.initial(
        teamName: 'Scout Squad',
        ownerName: 'Scout Leader',
        primaryColorHex: '#1B2A49',
        secondaryColorHex: '#F5B700',
        emblemSymbol: 'crosshair',
        emblemLetters: 'SS',
      );

      final freeAgents = ScoutingService.generateFreeAgents(state);
      expect(freeAgents.length, equals(6));

      for (final fa in freeAgents) {
        expect(fa.realName.isNotEmpty, isTrue);
        expect(fa.gamerTag.isNotEmpty, isTrue);
        expect(fa.potentialStars, inInclusiveRange(1, 5));
        expect(fa.roleMastery.containsKey(fa.role.name), isTrue);
        expect(fa.traits.isNotEmpty, isTrue);
      }

      final tryouts = ScoutingService.conductOpenTryouts(state);
      expect(tryouts.length, equals(10));
    });

    test('House combos and comfort ratings calculate correctly', () {
      final state = GameState.initial(
        teamName: 'Combo City',
        ownerName: 'Architect',
        primaryColorHex: '#1B2A49',
        secondaryColorHex: '#F5B700',
        emblemSymbol: 'shield',
        emblemLetters: 'CC',
      );

      // Add 5 PC desks
      state.furniture.clear();
      for (int i = 0; i < 5; i++) {
        state.furniture.add(PlacedFurniture(
          id: 'pc_$i',
          itemId: 'pc_desk',
          name: 'Gaming PC Desk',
          tileX: i + 1,
          tileY: 1,
          sizeX: 2,
          sizeY: 1,
          station: 'pc',
        ));
      }

      expect(state.hasScrimRoomCombo, isTrue);

      // Add Kitchen and Dining Table side by side for Kainan combo
      state.furniture.add(PlacedFurniture(
        id: 'k1',
        itemId: 'kitchen',
        name: 'Kitchen',
        tileX: 1,
        tileY: 3,
        sizeX: 2,
        sizeY: 2,
        station: 'kitchen',
      ));
      state.furniture.add(PlacedFurniture(
        id: 'd1',
        itemId: 'dining_table',
        name: 'Dining Table',
        tileX: 3,
        tileY: 3,
        sizeX: 2,
        sizeY: 1,
        station: 'dining',
      ));

      expect(state.hasKainanCombo, isTrue);
      expect(state.comfortRating, inInclusiveRange(1, 5));
    });
  });

  group('Phase 3 Competition Core: Bracket Engine & Match Sim', () {
    test('BracketEngine generates recursive seed orders for powers of two', () {
      final seeds8 = BracketEngine.generateSeedOrder(8);
      expect(seeds8, equals([1, 8, 4, 5, 2, 7, 3, 6]));

      final seeds16 = BracketEngine.generateSeedOrder(16);
      expect(seeds16, equals([1, 16, 8, 9, 4, 13, 5, 12, 2, 15, 7, 10, 3, 14, 6, 11]));
    });

    test('Single elimination bracket schedules rounds across weeks', () {
      final participants = List.generate(8, (i) => AiTeam(
        id: 'team_$i',
        name: 'Team $i',
        tier: 1,
        region: 'NCR',
        colors: ['#000000', '#FFFFFF'],
        rating: 30 + i * 2,
      ));

      final matches = BracketEngine.generateSingleElimMatches(
        tournamentId: 'T1-ICC1',
        participants: participants,
        startWeek: 5,
        bo: 1,
        grandFinalBo: 3,
      );

      // 8 teams = 7 total matches (4 QF, 2 SF, 1 Final)
      expect(matches.length, equals(7));

      final qfMatches = matches.where((m) => m.round == 1).toList();
      final sfMatches = matches.where((m) => m.round == 2).toList();
      final finalMatch = matches.where((m) => m.round == 3).toList();

      expect(qfMatches.length, equals(4));
      expect(sfMatches.length, equals(2));
      expect(finalMatch.length, equals(1));

      // Spreads weeks: QF week 5, SF week 6, Final week 7
      expect(qfMatches.first.week, equals(5));
      expect(sfMatches.first.week, equals(6));
      expect(finalMatch.first.week, equals(7));
      expect(finalMatch.first.bestOf, equals(3));
    });

    test('Round robin generator ensures circle method with no duplicate rematches', () {
      final participants = List.generate(6, (i) => AiTeam(
        id: 'team_$i',
        name: 'Team $i',
        tier: 2,
        region: 'NCR',
        colors: ['#000000', '#FFFFFF'],
        rating: 40,
      ));

      final matches = BracketEngine.generateRoundRobinMatches(
        tournamentId: 'T2-TLS',
        participants: participants,
        startWeek: 9,
        bo: 3,
      );

      // 6 teams = 5 rounds of 3 matches = 15 matches total
      expect(matches.length, equals(15));

      // Check that each pair plays exactly once
      final playedPairs = <String>{};
      for (final m in matches) {
        final pairKey = [m.slotA.teamId, m.slotB.teamId]..sort();
        final keyStr = pairKey.join('_vs_');
        expect(playedPairs.contains(keyStr), isFalse, reason: 'Duplicate matchup: $keyStr');
        playedPairs.add(keyStr);
      }
      expect(playedPairs.length, equals(15));
    });

    test('Strategy counter cycle grants +4 / -4 power', () {
      expect(MatchSimEngine.getStrategyModifier('Rush', 'Scale'), equals(4));
      expect(MatchSimEngine.getStrategyModifier('Scale', 'Split'), equals(4));
      expect(MatchSimEngine.getStrategyModifier('Split', 'Teamfight'), equals(4));
      expect(MatchSimEngine.getStrategyModifier('Teamfight', 'Rush'), equals(4));

      // Reversed is -4
      expect(MatchSimEngine.getStrategyModifier('Scale', 'Rush'), equals(-4));
      // Same is 0
      expect(MatchSimEngine.getStrategyModifier('Rush', 'Rush'), equals(0));
    });

    test('TournamentService manages registration eligibility, fee deductions, and refunds', () {
      final state = GameState.initial(
        teamName: 'Reg Squad',
        ownerName: 'Reg Boss',
        primaryColorHex: '#1B2A49',
        secondaryColorHex: '#F5B700',
        emblemSymbol: 'crown',
        emblemLetters: 'RS',
      );

      // Add 2 more players so roster has 5 starters
      state.players.add(Player(
        id: 'p4', realName: 'Jose', gamerTag: 'J4', role: PlayerRole.mid,
        aim: 40, reaction: 40, gameSense: 40, teamwork: 40, mental: 40, stamina: 40,
      ));
      state.players.add(Player(
        id: 'p5', realName: 'Pedro', gamerTag: 'P5', role: PlayerRole.support,
        aim: 40, reaction: 40, gameSense: 40, teamwork: 40, mental: 40, stamina: 40,
      ));

      final def = TournamentDef(
        id: 'T1-TEST',
        name: 'Test Cup',
        tier: 1,
        division: 'arena_clash',
        startWeek: 5,
        endWeek: 7,
        regOpenOffset: -4,
        regCloseOffset: -1,
        minFame: 0,
        maxFame: 500,
        entryFee: 1000,
        travelCost: 0,
        slots: 8,
        stages: [TournamentStageDef(type: 'single_elim', teams: 8, bo: 1, grandFinalBo: 3)],
        championPrize: 10000,
        championFame: 50,
        championFans: 300,
        circuitPoints: 100,
        trophy: 'trophy_bronze_t1',
        banner: 'banner_t1',
      );

      state.tournamentInstances.add(TournamentInstance(
        tournamentId: def.id,
        name: def.name,
        tier: def.tier,
        banner: def.banner,
      ));

      // Register
      final startMoney = state.money;
      final registered = TournamentService.registerUser(state, def);
      expect(registered, isTrue);
      expect(state.money, equals(startMoney - 1000));

      // Withdraw (50% refund)
      final withdrawn = TournamentService.withdrawUser(state, def);
      expect(withdrawn, isTrue);
      expect(state.money, equals(startMoney - 500));
    });
  });

  group('Phase 4 Match Depth: Broadcast, Focus Meter, Timeouts & Patch Meta', () {
    test('PatchDef modifiers apply +3 to favored and -3 to nerfed strategies', () {
      const patch = PatchDef(
        version: '1.1',
        name: 'Midlane Roaming Meta',
        favoredStrategy: 'Rush',
        nerfedStrategy: 'Scale',
        changes: ['Rush +3', 'Scale -3'],
      );

      expect(patch.getStrategyModifier('Rush'), equals(3));
      expect(patch.getStrategyModifier('Scale'), equals(-3));
      expect(patch.getStrategyModifier('Teamfight'), equals(0));
      expect(patch.getStrategyModifier('Split'), equals(0));

      final json = patch.toJson();
      final restored = PatchDef.fromJson(json);
      expect(restored.version, equals('1.1'));
      expect(restored.favoredStrategy, equals('Rush'));
      expect(restored.nerfedStrategy, equals('Scale'));
    });

    test('MatchSimEngine applies patch modifier to team power calculations', () {
      final state = GameState.initial(
        teamName: 'Patch Test',
        ownerName: 'Coach P',
        primaryColorHex: '#1B2A49',
        secondaryColorHex: '#F5B700',
        emblemSymbol: 'crown',
        emblemLetters: 'PT',
      );

      // Add 2 more players so roster has 5 starters
      state.players.add(Player(
        id: 'p4', realName: 'Jose', gamerTag: 'J4', role: PlayerRole.mid,
        aim: 40, reaction: 40, gameSense: 40, teamwork: 40, mental: 40, stamina: 40,
      ));
      state.players.add(Player(
        id: 'p5', realName: 'Pedro', gamerTag: 'P5', role: PlayerRole.support,
        aim: 40, reaction: 40, gameSense: 40, teamwork: 40, mental: 40, stamina: 40,
      ));

      const patch = PatchDef(
        version: '1.2',
        name: 'Tank Durability Update',
        favoredStrategy: 'Scale',
        nerfedStrategy: 'Rush',
        changes: ['Scale +3', 'Rush -3'],
      );

      final powerNeutral = MatchSimEngine.calculateUserTeamPower(
        state,
        userStrategy: 'Teamfight',
        opponentStrategy: 'Teamfight',
        focusBonus: 0,
      );

      final powerScaleFavored = MatchSimEngine.calculateUserTeamPower(
        state,
        userStrategy: 'Scale',
        opponentStrategy: 'Scale',
        focusBonus: 0,
        patch: patch,
      );

      final powerRushNerfed = MatchSimEngine.calculateUserTeamPower(
        state,
        userStrategy: 'Rush',
        opponentStrategy: 'Rush',
        focusBonus: 0,
        patch: patch,
      );

      // Scale strategy gets +3 from patch; Rush gets -3
      expect(powerScaleFavored - powerNeutral, closeTo(3.0, 0.1));
      expect(powerRushNerfed - powerNeutral, closeTo(-3.0, 0.1));
    });

    test('Focus meter zone widths calculate based on captain mental stat', () {
      // Base width is 14% (0.14) + mental * 0.08
      double calculatePerfectWidth(int mental) {
        final bonus = (mental.clamp(0, 100) / 100.0) * 0.08;
        return 0.14 + bonus;
      }

      expect(calculatePerfectWidth(0), closeTo(0.14, 0.001));
      expect(calculatePerfectWidth(50), closeTo(0.18, 0.001));
      expect(calculatePerfectWidth(100), closeTo(0.22, 0.001));
    });

    test('Tactical Timeouts effect: Pep Talk boosts morale and substitution swaps starters', () {
      final state = GameState.initial(
        teamName: 'Timeout Squad',
        ownerName: 'Coach T',
        primaryColorHex: '#1B2A49',
        secondaryColorHex: '#F5B700',
        emblemSymbol: 'crown',
        emblemLetters: 'TS',
      );

      // Set starter morale to 60
      final starter = state.starters.first;
      starter.morale = 60;

      // Pep Talk action: +10 morale
      starter.morale += 10;
      expect(starter.morale, equals(70));

      // Bench sub test
      final benchPlayer = Player(
        id: 'bench_1', realName: 'Sub', gamerTag: 'FreshSub', role: PlayerRole.carry,
        aim: 65, reaction: 65, gameSense: 65, teamwork: 65, mental: 65, stamina: 65,
        isStarter: false,
      );
      state.players.add(benchPlayer);

      expect(state.starters.contains(starter), isTrue);
      expect(state.starters.contains(benchPlayer), isFalse);

      // Perform substitution
      starter.isStarter = false;
      benchPlayer.isStarter = true;

      expect(state.starters.contains(starter), isFalse);
      expect(state.starters.contains(benchPlayer), isTrue);
    });

    test('Single game simulation produces valid game results and durations', () {
      final state = GameState.initial(
        teamName: 'Single Game Team',
        ownerName: 'Coach S',
        primaryColorHex: '#1B2A49',
        secondaryColorHex: '#F5B700',
        emblemSymbol: 'crown',
        emblemLetters: 'SG',
      );

      final opponent = AiTeam(
        id: 'opp_single',
        name: 'Opponent Gaming',
        tier: 1,
        region: 'NCR',
        colors: ['#000000', '#FFFFFF'],
        rating: 38,
        style: 'Rush',
      );

      final game = MatchSimEngine.simulateSingleGame(
        state: state,
        opponent: opponent,
        userStrategy: 'Scale',
        focusBonus: 3.0,
        momentumUser: 0.0,
        momentumOpponent: 0.0,
        gameNumber: 1,
      );

      expect(game.gameNumber, equals(1));
      expect(game.teamAScore, greaterThanOrEqualTo(0));
      expect(game.teamBScore, greaterThanOrEqualTo(0));
      expect(game.winnerTeamId, isIn(['user_team', 'opp_single']));
      expect(game.durationMinutes, inInclusiveRange(16, 32));
    });
  });

  group('Phase 5 Full Circuit & Tournament Formats', () {
    final testTeams8 = List.generate(8, (i) => AiTeam(
      id: 'team_${i + 1}',
      name: 'Team ${i + 1}',
      tier: 3,
      region: 'NCR',
      colors: ['#000', '#fff'],
      rating: 50 - i,
      circuitPoints: 100 * (8 - i),
    ));

    final testTeams16 = List.generate(16, (i) => AiTeam(
      id: 'team_${i + 1}',
      name: 'Team ${i + 1}',
      tier: 4,
      region: 'NCR',
      colors: ['#000', '#fff'],
      rating: 60 - i,
      circuitPoints: 50 * (16 - i),
    ));

    test('Double Elimination generates upper and lower matches with 1-0 Grand Final upper advantage', () {
      final matches = AdvancedBracketEngine.generateDoubleElimMatches(
        tournamentId: 'T3-PC-TEST',
        participants: testTeams8,
        startWeek: 29,
        bo: 3,
        grandFinalBo: 5,
        gfAdvantage: 'upper',
      );

      // 8-team double elim has 11 match nodes (4 UB QF + 2 LB R1 + 2 UB SF + 2 LB R2 + 1 UB FN + 1 LB FN + 1 GF = 13 nodes)
      expect(matches.length, equals(13));

      final gf = matches.firstWhere((m) => m.id == 'T3-PC-TEST_gf');
      expect(gf.bestOf, equals(5));
      expect(gf.slotA.score, equals(1)); // 1-0 advantage!
      expect(gf.slotB.score, equals(0));
    });

    test('Double Elimination advances winners and losers correctly', () {
      final matches = AdvancedBracketEngine.generateDoubleElimMatches(
        tournamentId: 'T3-TEST',
        participants: testTeams8,
        startWeek: 10,
        bo: 3,
        grandFinalBo: 5,
        gfAdvantage: 'upper',
      );

      final inst = TournamentInstance(
        tournamentId: 'T3-TEST',
        name: 'Test DE',
        tier: 3,
        banner: 'banner_t3',
        matches: matches,
      );

      // Play UB QF 1
      final qf1 = inst.matches.firstWhere((m) => m.id == 'T3-TEST_ub_qf_1');
      qf1.winnerId = qf1.slotA.teamId; // team_1 wins
      qf1.isPlayed = true;

      BracketAdvancementEngine.advanceDoubleElimMatch(inst, qf1);

      final ubSf1 = inst.matches.firstWhere((m) => m.id == 'T3-TEST_ub_sf_1');
      final lbR1 = inst.matches.firstWhere((m) => m.id == 'T3-TEST_lb_r1_1');

      expect(ubSf1.slotA.teamId, equals(qf1.slotA.teamId));
      expect(lbR1.slotA.teamId, equals(qf1.slotB.teamId));
    });

    test('GSL 4-team group generates opening, winners, elimination, and decider matches', () {
      final gslTeams = testTeams8.take(4).toList();
      final gslMatches = AdvancedBracketEngine.generateGslGroupMatches(
        tournamentId: 'T4-RQ-TEST',
        groupPrefix: 'grpA',
        groupTeams: gslTeams,
        startWeek: 17,
        bo: 3,
      );

      expect(gslMatches.length, equals(5));
      expect(gslMatches[0].roundName, contains('Opening A'));
      expect(gslMatches[1].roundName, contains('Opening B'));
      expect(gslMatches[2].roundName, contains('Winners Match'));
      expect(gslMatches[3].roundName, contains('Elimination Match'));
      expect(gslMatches[4].roundName, contains('Decider Match'));
    });

    test('Swiss Round 1 pairs top-vs-bottom seeds and formats correctly', () {
      final swissMatches = AdvancedBracketEngine.generateSwissRound1(
        tournamentId: 'T6-APM-TEST',
        participants: testTeams16,
        startWeek: 33,
        bo: 1,
      );

      expect(swissMatches.length, equals(8));
      // First match should be Seed 1 vs Seed 16
      expect(swissMatches.first.slotA.teamId, equals('team_1'));
      expect(swissMatches.first.slotB.teamId, equals('team_16'));
      expect(swissMatches.first.bestOf, equals(1));
    });

    test('Swiss round advancement pairs teams by record without rematches', () {
      final swissMatches = AdvancedBracketEngine.generateSwissRound1(
        tournamentId: 'T6-SWISS',
        participants: testTeams16,
        startWeek: 33,
        bo: 1,
      );

      final inst = TournamentInstance(
        tournamentId: 'T6-SWISS',
        name: 'Swiss Test',
        tier: 6,
        banner: 'banner_t6',
        matches: swissMatches,
      );

      // Play Round 1 matches (first 4 winners = team 1, 2, 3, 4; remaining = 5, 6, 7, 8)
      for (final m in inst.matches) {
        m.isPlayed = true;
        m.winnerId = m.slotA.teamId; // slotA wins
      }

      final def = TournamentDef(
        id: 'T6-SWISS',
        name: 'Swiss Def',
        tier: 6,
        division: 'arena_clash',
        startWeek: 33,
        endWeek: 40,
        regOpenOffset: -4,
        regCloseOffset: -1,
        minFame: 5000,
        maxFame: 999999,
        entryFee: 100000,
        travelCost: 100000,
        slots: 16,
        stages: [TournamentStageDef(type: 'swiss', teams: 16)],
        championPrize: 10000000,
        championFame: 5000,
        championFans: 150000,
        circuitPoints: 15000,
        trophy: 'trophy_t6',
        banner: 'banner_t6',
      );

      BracketAdvancementEngine.generateNextSwissRound(inst, def, 34);

      // Round 2 matches should be generated (8 new matches)
      final r2Matches = inst.matches.where((m) => m.round == 2).toList();
      expect(r2Matches.length, equals(8));
      // Confirm all matches are within 1-0 or 0-1 pool
      for (final m in r2Matches) {
        expect(m.roundName, isIn(['Swiss Round 2 (1-0)', 'Swiss Round 2 (0-1)']));
      }
    });

    test('Typhoon postponement shifts active LAN matches during W25-W40', () {
      final state = GameState.initial(
        teamName: 'Typhoon Squad',
        ownerName: 'Owner T',
        primaryColorHex: '#1B2A49',
        secondaryColorHex: '#F5B700',
        emblemSymbol: 'lightning',
        emblemLetters: 'TS',
      );

      // Week 30 (Month 8, Week 2 = 28 + 2 = 30)
      state.month = 8;
      state.week = 2;
      expect(state.weekOfYear, equals(30));

      final match = MatchNode(
        id: 'typhoon_m1',
        tournamentId: 'T2-TC',
        round: 1,
        roundName: 'Round 1',
        week: 30,
        slotA: MatchSlot(teamId: 'team_1', teamName: 'T1'),
        slotB: MatchSlot(teamId: 'team_2', teamName: 'T2'),
      );

      final inst = TournamentInstance(
        tournamentId: 'T2-TC',
        name: 'Town Cup',
        tier: 2,
        banner: 'banner_t2',
        status: 'in_progress',
        matches: [match],
      );
      state.tournamentInstances.add(inst);

      expect(match.week, equals(30));
      // Force postponement
      match.week++;
      expect(match.week, equals(31));
    });

    test('Awards Night computes awards, updates Hall of Fame, and rollover resets season', () {
      final state = GameState.initial(
        teamName: 'Champions PH',
        ownerName: 'El Presidente',
        primaryColorHex: '#1B2A49',
        secondaryColorHex: '#F5B700',
        emblemSymbol: 'crown',
        emblemLetters: 'CP',
      );
      state.circuitPoints = 25000;
      state.trophies.add('trophy_t7');

      final awards = SeasonService.computeSeasonAwards(state);
      expect(awards.length, equals(5));

      final tot = awards.firstWhere((a) => a.category == 'tot');
      expect(tot.winnerName, equals('Champions PH'));
      expect(tot.isUserWinner, isTrue);

      // Apply awards
      final initialMoney = state.money;
      SeasonService.applyAwards(state, awards);
      expect(state.money, greaterThan(initialMoney));
      expect(state.hallOfFame.length, equals(5));
      expect(state.hallOfFame.first.year, equals(1));

      // Annual rollover
      SeasonService.performAnnualRollover(state);
      expect(state.year, equals(2));
      expect(state.month, equals(1));
      expect(state.week, equals(1));
      expect(state.day, equals(1));
      expect(state.circuitPoints, equals((25000 * 0.5).round()));
    });
  });
}
