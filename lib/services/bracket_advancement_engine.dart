import '../models/tournament.dart';
import '../models/ai_team.dart';
import '../models/game_state.dart';
import 'bracket_engine.dart';
import 'data_service.dart';

class BracketAdvancementEngine {
  /// Advance double elimination match winners and losers
  static void advanceDoubleElimMatch(TournamentInstance instance, MatchNode match) {
    if (match.winnerId.isEmpty) return;

    final isWinnerSlotA = match.winnerId == match.slotA.teamId;
    final winnerName = isWinnerSlotA ? match.slotA.teamName : match.slotB.teamName;
    final loserId = isWinnerSlotA ? match.slotB.teamId : match.slotA.teamId;
    final loserName = isWinnerSlotA ? match.slotB.teamName : match.slotA.teamName;

    final id = match.id;
    MatchNode? find(String suffix) =>
        instance.matches.cast<MatchNode?>().firstWhere((m) => m?.id.endsWith(suffix) == true, orElse: () => null);

    // 8-Team Bracket Logic
    if (id.contains('ub_qf_1')) {
      _setSlot(find('ub_sf_1'), true, match.winnerId, winnerName);
      _setSlot(find('lb_r1_1'), true, loserId, loserName);
    } else if (id.contains('ub_qf_2')) {
      _setSlot(find('ub_sf_1'), false, match.winnerId, winnerName);
      _setSlot(find('lb_r1_1'), false, loserId, loserName);
    } else if (id.contains('ub_qf_3')) {
      _setSlot(find('ub_sf_2'), true, match.winnerId, winnerName);
      _setSlot(find('lb_r1_2'), true, loserId, loserName);
    } else if (id.contains('ub_qf_4')) {
      _setSlot(find('ub_sf_2'), false, match.winnerId, winnerName);
      _setSlot(find('lb_r1_2'), false, loserId, loserName);
    } else if (id.contains('lb_r1_1')) {
      _setSlot(find('lb_r2_1'), true, match.winnerId, winnerName);
    } else if (id.contains('lb_r1_2')) {
      _setSlot(find('lb_r2_2'), true, match.winnerId, winnerName);
    } else if (id.contains('ub_sf_1')) {
      _setSlot(find('ub_fn'), true, match.winnerId, winnerName);
      _setSlot(find('lb_r2_2'), false, loserId, loserName);
    } else if (id.contains('ub_sf_2')) {
      _setSlot(find('ub_fn'), false, match.winnerId, winnerName);
      _setSlot(find('lb_r2_1'), false, loserId, loserName);
    } else if (id.contains('lb_r2_1')) {
      _setSlot(find('lb_fn'), true, match.winnerId, winnerName);
    } else if (id.contains('lb_r2_2')) {
      _setSlot(find('lb_fn'), false, match.winnerId, winnerName);
    } else if (id.contains('ub_fn')) {
      _setSlot(find('gf'), true, match.winnerId, winnerName);
      _setSlot(find('lb_fn'), false, loserId, loserName);
    } else if (id.contains('lb_fn')) {
      _setSlot(find('gf'), false, match.winnerId, winnerName);
    } else if (id.contains('gf')) {
      instance.championId = match.winnerId;
      instance.championName = winnerName;
      instance.status = 'completed';
    }
  }

  static void _setSlot(MatchNode? target, bool isSlotA, String teamId, String teamName) {
    if (target == null) return;
    if (isSlotA) {
      target.slotA.teamId = teamId;
      target.slotA.teamName = teamName;
    } else {
      target.slotB.teamId = teamId;
      target.slotB.teamName = teamName;
    }
  }

  /// Advance GSL group match winners and losers
  static void advanceGslMatch(TournamentInstance instance, MatchNode match) {
    if (match.winnerId.isEmpty) return;

    final isWinnerSlotA = match.winnerId == match.slotA.teamId;
    final winnerName = isWinnerSlotA ? match.slotA.teamName : match.slotB.teamName;
    final loserId = isWinnerSlotA ? match.slotB.teamId : match.slotA.teamId;
    final loserName = isWinnerSlotA ? match.slotB.teamName : match.slotA.teamName;

    // e.g. T4-RQ_grpA_m1
    final parts = match.id.split('_');
    final grpPrefix = parts.length >= 2 ? parts[parts.length - 2] : '';
    MatchNode? find(String mNum) =>
        instance.matches.cast<MatchNode?>().firstWhere((m) => m?.id == '${instance.tournamentId}_${grpPrefix}_$mNum', orElse: () => null);

    if (match.id.endsWith('_m1')) {
      _setSlot(find('m3'), true, match.winnerId, winnerName);
      _setSlot(find('m4'), true, loserId, loserName);
    } else if (match.id.endsWith('_m2')) {
      _setSlot(find('m3'), false, match.winnerId, winnerName);
      _setSlot(find('m4'), false, loserId, loserName);
    } else if (match.id.endsWith('_m3')) {
      // Winner advances as 1st seed
      _setSlot(find('m5'), true, loserId, loserName);
    } else if (match.id.endsWith('_m4')) {
      // Loser eliminated, winner to decider
      _setSlot(find('m5'), false, match.winnerId, winnerName);
    }
  }

  /// Generate next round for Swiss stage
  static void generateNextSwissRound(TournamentInstance instance, TournamentDef def, int nextRoundWeek) {
    // 1. Calculate current records for each team in Swiss matches
    final records = <String, int>{}; // teamId -> wins
    final losses = <String, int>{};
    final pastOpponents = <String, Set<String>>{};
    final teamNames = <String, String>{};

    for (final m in instance.matches.where((m) => m.stageIndex == 0 && m.isPlayed)) {
      final tA = m.slotA.teamId;
      final tB = m.slotB.teamId;
      teamNames[tA] = m.slotA.teamName;
      teamNames[tB] = m.slotB.teamName;

      records.putIfAbsent(tA, () => 0);
      records.putIfAbsent(tB, () => 0);
      losses.putIfAbsent(tA, () => 0);
      losses.putIfAbsent(tB, () => 0);
      pastOpponents.putIfAbsent(tA, () => {}).add(tB);
      pastOpponents.putIfAbsent(tB, () => {}).add(tA);

      if (m.winnerId == tA) {
        records[tA] = records[tA]! + 1;
        losses[tB] = losses[tB]! + 1;
      } else if (m.winnerId == tB) {
        records[tB] = records[tB]! + 1;
        losses[tA] = losses[tA]! + 1;
      }
    }

    // Active teams: wins < 3 and losses < 3
    final activeTeams = records.keys.where((t) => (records[t] ?? 0) < 3 && (losses[t] ?? 0) < 3).toList();
    if (activeTeams.isEmpty) return; // Swiss stage complete!

    // Group active teams by (wins, losses)
    final groups = <String, List<String>>{};
    for (final t in activeTeams) {
      final key = '${records[t]}-${losses[t]}';
      groups.putIfAbsent(key, () => []).add(t);
    }

    int matchCounter = instance.matches.where((m) => m.stageIndex == 0).length + 1;
    final curRound = (instance.matches.where((m) => m.stageIndex == 0).map((m) => m.round).reduce((a, b) => a > b ? a : b)) + 1;

    for (final entry in groups.entries) {
      final pool = List<String>.from(entry.value);
      while (pool.length >= 2) {
        final tA = pool.removeAt(0);
        // Find opponent without rematch
        int oppIdx = pool.indexWhere((t) => !(pastOpponents[tA]?.contains(t) ?? false));
        if (oppIdx == -1) oppIdx = 0; // fallback if rematch unavoidable
        final tB = pool.removeAt(oppIdx);

        final isDeciding = (records[tA] ?? 0) == 2 || (losses[tA] ?? 0) == 2;
        final bestOf = isDeciding ? 3 : 1;

        instance.matches.add(MatchNode(
          id: '${instance.tournamentId}_swiss_r${curRound}_m$matchCounter',
          tournamentId: instance.tournamentId,
          stageIndex: 0,
          round: curRound,
          roundName: 'Swiss Round $curRound (${entry.key})',
          week: nextRoundWeek,
          slotA: MatchSlot(teamId: tA, teamName: teamNames[tA] ?? 'Team'),
          slotB: MatchSlot(teamId: tB, teamName: teamNames[tB] ?? 'Team'),
          bestOf: bestOf,
        ));
        matchCounter++;
      }
    }
  }

  /// Check and trigger stage advancement (e.g. from Groups/Swiss into Single Elim Playoffs)
  static void checkAndAdvanceStages(GameState state, TournamentDef def, TournamentInstance instance) {
    if (instance.status == 'completed') return;

    final curStage = def.stages[instance.currentStageIndex];
    final curMatches = instance.matches.where((m) => m.stageIndex == instance.currentStageIndex).toList();

    // Check if stage is fully played
    if (curMatches.isEmpty || curMatches.any((m) => !m.isPlayed)) return;

    // Handle Swiss stage progression
    if (curStage.type == 'swiss') {
      final wins = <String, int>{};
      final losses = <String, int>{};
      for (final m in curMatches) {
        if (m.winnerId.isNotEmpty) {
          wins[m.winnerId] = (wins[m.winnerId] ?? 0) + 1;
          final loserId = m.winnerId == m.slotA.teamId ? m.slotB.teamId : m.slotA.teamId;
          if (loserId.isNotEmpty) {
            losses[loserId] = (losses[loserId] ?? 0) + 1;
          }
        }
      }
      final curMaxRound = curMatches.map((m) => m.round).fold(0, (a, b) => a > b ? a : b);
      final qualifiedCount = wins.values.where((w) => w >= 3).length;
      final targetAdvance = curStage.advanceCount > 0 ? curStage.advanceCount : 8;

      if (qualifiedCount < targetAdvance && curMaxRound < 5) {
        generateNextSwissRound(instance, def, state.weekOfYear + 1);
        return;
      }

      if (instance.currentStageIndex >= def.stages.length - 1) {
        final sortedIds = wins.keys.toList()..sort((a, b) => (wins[b] ?? 0).compareTo(wins[a] ?? 0));
        if (sortedIds.isNotEmpty) {
          instance.championId = sortedIds.first;
          final champTeam = sortedIds.first == 'user_team'
              ? null
              : DataService().findTeam(sortedIds.first);
          instance.championName = champTeam?.name ?? state.teamName;
        }
        instance.status = 'completed';
        return;
      }
    }

    if (instance.currentStageIndex >= def.stages.length - 1) return;

    // Stage complete! Advance to next stage (Playoffs)
    final nextStageIndex = instance.currentStageIndex + 1;
    final nextStageDef = def.stages[nextStageIndex];
    instance.currentStageIndex = nextStageIndex;

    // Collect advancing teams
    final qualifiedTeams = <AiTeam>[];
    if (curStage.type == 'swiss') {
      final wins = <String, int>{};
      for (final m in curMatches) {
        if (m.winnerId.isNotEmpty) {
          wins[m.winnerId] = (wins[m.winnerId] ?? 0) + 1;
        }
      }
      final sortedIds = wins.keys.toList()..sort((a, b) => (wins[b] ?? 0).compareTo(wins[a] ?? 0));
      for (final id in sortedIds.take(nextStageDef.teams)) {
        final t = id == 'user_team'
            ? AiTeam(id: 'user_team', name: state.teamName, tier: def.tier, region: 'NCR', colors: [], rating: 50)
            : DataService().findTeam(id) ?? AiTeam(id: id, name: 'Team $id', tier: def.tier, region: 'PH', colors: [], rating: 50);
        qualifiedTeams.add(t);
      }
    } else if (curStage.type == 'round_robin') {
      // Top N from standings
      instance.standings.sort((a, b) {
        if (b.points != a.points) return b.points.compareTo(a.points);
        return b.gameDiff.compareTo(a.gameDiff);
      });
      final topCount = nextStageDef.teams;
      for (int i = 0; i < topCount && i < instance.standings.length; i++) {
        final s = instance.standings[i];
        final t = s.teamId == 'user_team'
            ? AiTeam(id: 'user_team', name: state.teamName, tier: def.tier, region: 'NCR', colors: [], rating: 50)
            : DataService().findTeam(s.teamId) ?? AiTeam(id: s.teamId, name: s.teamName, tier: def.tier, region: 'PH', colors: [], rating: 50);
        qualifiedTeams.add(t);
      }
    } else {
      // Fallback: collect winners
      final winnerIds = curMatches.map((m) => m.winnerId).where((id) => id.isNotEmpty).toSet().toList();
      for (final id in winnerIds.take(nextStageDef.teams)) {
        final t = id == 'user_team'
            ? AiTeam(id: 'user_team', name: state.teamName, tier: def.tier, region: 'NCR', colors: [], rating: 50)
            : DataService().findTeam(id) ?? AiTeam(id: id, name: 'Team $id', tier: def.tier, region: 'PH', colors: [], rating: 50);
        qualifiedTeams.add(t);
      }
    }

    if (qualifiedTeams.length >= 2) {
      // Generate single elimination playoff matches
      final playoffMatches = BracketEngine.generateSingleElimMatches(
        tournamentId: def.id,
        participants: qualifiedTeams,
        startWeek: state.weekOfYear + 1,
        bo: nextStageDef.bo,
        grandFinalBo: nextStageDef.grandFinalBo,
        stageIndex: nextStageIndex,
      );

      instance.matches.addAll(playoffMatches);
      state.addNotification('${def.name}: Playoffs Started!', '#9B5DE5', 0.5, 0.4);
    }
  }
}
