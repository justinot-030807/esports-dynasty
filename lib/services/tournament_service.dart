import 'dart:math';
import '../models/game_state.dart';
import '../models/tournament.dart';
import '../models/division.dart';
import '../models/ai_team.dart';
import 'data_service.dart';
import 'bracket_engine.dart';
import 'advanced_bracket_engine.dart';
import 'bracket_advancement_engine.dart';
import 'match_sim_engine.dart';

class TournamentService {
  static final Random _rng = Random();

  /// Initialize tournament instances for the season if not already present
  static void initializeTournaments(GameState state) {
    final existingIds = state.tournamentInstances.map((t) => t.tournamentId).toSet();
    final defs = DataService().tournaments;
    for (final def in defs) {
      if (!existingIds.contains(def.id)) {
        state.tournamentInstances.add(TournamentInstance(
          tournamentId: def.id,
          name: def.name,
          tier: def.tier,
          banner: def.banner,
          division: def.division,
          status: 'upcoming',
        ));
      }
    }
  }

  /// Get status of an event for the current week of year
  static String calculateStatus(TournamentDef def, int currentWeek, TournamentInstance instance) {
    if (instance.status == 'completed') return 'completed';

    final openWeek = def.startWeek + def.regOpenOffset;
    final closeWeek = def.startWeek + def.regCloseOffset;

    if (currentWeek > def.endWeek) return 'completed';
    if (currentWeek >= def.startWeek && currentWeek <= def.endWeek) return 'in_progress';
    if (currentWeek >= openWeek && currentWeek <= closeWeek) return 'registration_open';
    return 'upcoming';
  }

  /// Check if user meets qualification rules (feeder tournament placement or circuit rank)
  static bool checkUserQualified(GameState state, TournamentDef def) {
    if (def.qualifyRules.isEmpty) return true;
    if (def.qualifyRules.any((r) => r['open'] == true)) return true;

    for (final rule in def.qualifyRules) {
      if (rule.containsKey('from')) {
        final feederId = rule['from'] as String;
        final topReq = (rule['top'] as num?)?.toInt() ?? 1;
        final feederInst = state.tournamentInstances.cast<TournamentInstance?>().firstWhere(
          (t) => t?.tournamentId == feederId,
          orElse: () => null,
        );
        if (feederInst != null && feederInst.isUserRegistered) {
          final p = feederInst.userPlacement.toLowerCase();
          if (p.contains('1st') || (topReq >= 2 && p.contains('2nd')) || (topReq >= 4 && (p.contains('3rd') || p.contains('4th')))) {
            return true;
          }
        }
      }
      if (rule.containsKey('fill') && rule['fill'] == 'circuit_rank') {
        final topReq = (rule['top'] as num?)?.toInt() ?? 100;
        // User qualified if circuit points are within active tier range
        if (state.circuitPoints >= (def.tier >= 6 ? 1500 : (def.tier >= 4 ? 600 : 150)) || topReq >= 50) {
          return true;
        }
      }
    }
    return false;
  }

  /// Check if user meets all requirements to register
  static String? checkRegistrationEligibility(GameState state, TournamentDef def) {
    if (state.fame < def.minFame) {
      return 'Kulang sa Fame! Kailangan ng ${def.minFame} Fame.';
    }
    if (state.fame > def.maxFame) {
      return 'Masyado nang mataas ang Fame ng squad para dito!';
    }
    if (!checkUserQualified(state, def)) {
      return 'Kailangan mag-qualify sa feeder tournament o top circuit rank!';
    }
    final totalCost = def.entryFee + def.travelCost;
    if (state.money < totalCost) {
      return 'Kulang ang pera! Kailangan ng P$totalCost.';
    }
    final div = EsportsDivision.getById(def.division);
    if (!state.isDivisionUnlocked(def.division)) {
      return 'I-unlock muna ang ${div.name} division sa Club Divisions!';
    }
    final starters = state.getStartersForDivision(def.division);
    if (starters.length < div.squadSize) {
      return 'Kailangan ng ${div.squadSize} aktibong starters sa lineup para sa ${div.name}!';
    }
    for (final p in starters) {
      if (p.isExhausted) {
        return 'May exhausted starter (${p.gamerTag})! Magpahinga muna.';
      }
    }
    return null;
  }

  /// Register user team for tournament
  static bool registerUser(GameState state, TournamentDef def) {
    final error = checkRegistrationEligibility(state, def);
    if (error != null) return false;

    final instance = state.tournamentInstances.firstWhere((t) => t.tournamentId == def.id);
    if (instance.registeredTeamIds.contains('user_team')) return false;

    final totalCost = def.entryFee + def.travelCost;
    state.money -= totalCost;
    instance.registeredTeamIds.add('user_team');
    state.addNotification('Registered: ${def.name}', '#3DBE5A', 0.5, 0.4);

    if (state.tutorial.step == 4) state.tutorial.step = 5;
    return true;
  }

  /// Withdraw from tournament (50% refund)
  static bool withdrawUser(GameState state, TournamentDef def) {
    final instance = state.tournamentInstances.firstWhere((t) => t.tournamentId == def.id);
    if (!instance.registeredTeamIds.contains('user_team')) return false;
    if (state.weekOfYear >= def.startWeek) return false;

    final refund = ((def.entryFee + def.travelCost) * 0.50).round();
    state.money += refund;
    instance.registeredTeamIds.remove('user_team');
    state.addNotification('+P$refund Refund', '#F5B700', 0.5, 0.4);
    return true;
  }

  /// Populate participants and build initial bracket
  static void startTournament(GameState state, TournamentDef def, TournamentInstance instance) {
    instance.status = 'in_progress';
    final allAi = DataService().allTeams;
    final eligibleAi = allAi.where((t) => t.tier <= def.tier + 1).toList()..shuffle(_rng);

    final participants = <AiTeam>[];
    if (instance.registeredTeamIds.contains('user_team')) {
      participants.add(AiTeam(
        id: 'user_team',
        name: state.teamName,
        tier: def.tier,
        region: 'NCR',
        colors: [state.primaryColorHex, state.secondaryColorHex],
        rating: state.getStartersForDivision(def.division).isNotEmpty
            ? (state.getStartersForDivision(def.division).map((p) => p.ovr).reduce((a, b) => a + b) ~/ state.getStartersForDivision(def.division).length)
            : 40,
        circuitPoints: state.getDivisionCircuitPoints(def.division),
      ));
    }

    int needed = def.slots - participants.length;
    for (int i = 0; i < needed && i < eligibleAi.length; i++) {
      participants.add(eligibleAi[i]);
      if (!instance.registeredTeamIds.contains(eligibleAi[i].id)) {
        instance.registeredTeamIds.add(eligibleAi[i].id);
      }
    }
    participants.sort((a, b) => b.rating.compareTo(a.rating));

    final stage1 = def.stages.first;
    if (stage1.type == 'single_elim') {
      instance.matches = BracketEngine.generateSingleElimMatches(
        tournamentId: def.id,
        participants: participants,
        startWeek: def.startWeek,
        bo: stage1.bo,
        grandFinalBo: stage1.grandFinalBo,
      );
    } else if (stage1.type == 'double_elim') {
      instance.matches = AdvancedBracketEngine.generateDoubleElimMatches(
        tournamentId: def.id,
        participants: participants,
        startWeek: def.startWeek,
        bo: stage1.bo,
        grandFinalBo: stage1.grandFinalBo,
        gfAdvantage: stage1.gfAdvantage,
      );
    } else if (stage1.type == 'round_robin') {
      instance.matches = BracketEngine.generateRoundRobinMatches(
        tournamentId: def.id,
        participants: participants,
        startWeek: def.startWeek,
        bo: stage1.bo,
      );
      instance.standings = participants.map((p) => RoundRobinTeamStat(teamId: p.id, teamName: p.name)).toList();
    } else if (stage1.type == 'gsl_group') {
      // 4 groups of 4
      const prefixes = ['grpA', 'grpB', 'grpC', 'grpD'];
      final gMatches = <MatchNode>[];
      for (int g = 0; g < 4 && g * 4 < participants.length; g++) {
        final gTeams = participants.skip(g * 4).take(4).toList();
        gMatches.addAll(AdvancedBracketEngine.generateGslGroupMatches(
          tournamentId: def.id,
          groupPrefix: prefixes[g],
          groupTeams: gTeams,
          startWeek: def.startWeek,
          bo: stage1.bo,
        ));
      }
      instance.matches = gMatches;
    } else if (stage1.type == 'groups') {
      instance.matches = AdvancedBracketEngine.generateSnakeGroupMatches(
        tournamentId: def.id,
        participants: participants,
        groupsCount: stage1.groupsCount,
        startWeek: def.startWeek,
        bo: stage1.bo,
      );
    } else if (stage1.type == 'swiss') {
      instance.matches = AdvancedBracketEngine.generateSwissRound1(
        tournamentId: def.id,
        participants: participants,
        startWeek: def.startWeek,
        bo: stage1.bo,
      );
    }
  }

  /// Typhoon mechanic: W25-W40 has 10% chance to postpone outdoor/LAN tournament matches
  static void checkTyphoonPostponement(GameState state) {
    final curWeek = state.weekOfYear;
    if (curWeek < 25 || curWeek > 40) return;
    if (_rng.nextDouble() >= 0.10) return; // 10% chance

    // Find active tournaments marked typhoon_ok
    final defs = DataService().tournaments;
    bool typhoonHit = false;

    for (final def in defs) {
      if (def.reschedule != 'typhoon_ok') continue;
      final inst = state.tournamentInstances.cast<TournamentInstance?>().firstWhere(
        (t) => t?.tournamentId == def.id,
        orElse: () => null,
      );
      if (inst == null || inst.status != 'in_progress') continue;

      // Postpone active & subsequent matches by +1 week
      final matchesToShift = inst.matches.where((m) => m.week >= curWeek && !m.isPlayed).toList();
      if (matchesToShift.isNotEmpty) {
        for (final m in matchesToShift) {
          m.week++;
        }
        typhoonHit = true;
      }
    }

    if (typhoonHit) {
      state.addNotification('BAGYO ALERT: Signal #2! Postponed matches.', '#E5484D', 0.5, 0.25);
    }
  }

  /// Weekly update: triggers starts, updates statuses, simulates AI matches, and advances stages
  static void processWeeklyTournaments(GameState state) {
    initializeTournaments(state);
    final curWeek = state.weekOfYear;
    checkTyphoonPostponement(state);

    final defs = DataService().tournaments;
    for (final def in defs) {
      final instance = state.tournamentInstances.firstWhere((t) => t.tournamentId == def.id);
      final currentStatus = calculateStatus(def, curWeek, instance);

      if (currentStatus == 'in_progress' && instance.matches.isEmpty) {
        startTournament(state, def, instance);
      } else {
        instance.status = currentStatus;
      }

      // Check stage advancement or Swiss next round
      BracketAdvancementEngine.checkAndAdvanceStages(state, def, instance);

      // AI vs AI matches on current week
      final currentWeekMatches = instance.matches.where(
        (m) => m.week == curWeek && !m.isPlayed && m.isReady,
      ).toList();

      for (final match in currentWeekMatches) {
        if (!match.hasUser) {
          final teamA = DataService().findTeam(match.slotA.teamId) ??
              AiTeam(id: match.slotA.teamId, name: match.slotA.teamName, tier: def.tier, region: 'PH', colors: [], rating: 35);
          final teamB = DataService().findTeam(match.slotB.teamId) ??
              AiTeam(id: match.slotB.teamId, name: match.slotB.teamName, tier: def.tier, region: 'PH', colors: [], rating: 35);

          final result = MatchSimEngine.simulateAiVsAi(teamA: teamA, teamB: teamB, match: match, tournament: def);
          BracketEngine.recordMatchOutcome(instance: instance, tournament: def, match: match, result: result);
        }
      }
    }
  }

  /// Find pending user match on Day 5 (if any)
  static MatchNode? getScheduledUserMatch(GameState state) {
    final curWeek = state.weekOfYear;
    for (final instance in state.tournamentInstances) {
      for (final match in instance.matches) {
        if (match.week == curWeek && match.day == state.day && match.hasUser && !match.isPlayed && match.isReady) {
          return match;
        }
      }
    }
    return null;
  }
}
