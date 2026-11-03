import '../models/tournament.dart';
import '../models/ai_team.dart';
import 'bracket_engine.dart';

/// Advanced tournament formats: double elimination, GSL groups, Swiss, and Group stages
class AdvancedBracketEngine {
  /// Generate an 8-team or 16-team double elimination bracket graph
  static List<MatchNode> generateDoubleElimMatches({
    required String tournamentId,
    required List<AiTeam> participants,
    required int startWeek,
    required int bo,
    required int grandFinalBo,
    String gfAdvantage = 'none',
    int stageIndex = 0,
  }) {
    final matches = <MatchNode>[];
    final count = participants.length;
    final seedOrder = BracketEngine.generateSeedOrder(count == 16 ? 16 : 8);

    if (count <= 8) {
      // 8-Team Double Elimination: 14 matches total
      // UB Round 1 (Quarterfinals) - 4 matches (Week startWeek)
      for (int i = 0; i < 4; i++) {
        final seedA = seedOrder[i * 2];
        final seedB = seedOrder[i * 2 + 1];
        final tA = seedA <= participants.length ? participants[seedA - 1] : null;
        final tB = seedB <= participants.length ? participants[seedB - 1] : null;

        matches.add(MatchNode(
          id: '${tournamentId}_ub_qf_${i + 1}',
          tournamentId: tournamentId,
          stageIndex: stageIndex,
          round: 1,
          roundName: 'UB Quarterfinals',
          week: startWeek,
          slotA: MatchSlot(teamId: tA?.id ?? '', teamName: tA?.name ?? 'TBD', seed: seedA),
          slotB: MatchSlot(teamId: tB?.id ?? '', teamName: tB?.name ?? 'TBD', seed: seedB),
          bestOf: bo,
        ));
      }

      // LB Round 1 - 2 matches (Week startWeek + 1)
      for (int i = 0; i < 2; i++) {
        matches.add(MatchNode(
          id: '${tournamentId}_lb_r1_${i + 1}',
          tournamentId: tournamentId,
          stageIndex: stageIndex,
          round: 2,
          roundName: 'LB Round 1',
          week: startWeek + 1,
          slotA: MatchSlot(teamId: '', teamName: 'Loser UB QF ${i * 2 + 1}'),
          slotB: MatchSlot(teamId: '', teamName: 'Loser UB QF ${i * 2 + 2}'),
          bestOf: bo,
        ));
        matches.add(MatchNode(
          id: '${tournamentId}_ub_sf_${i + 1}',
          tournamentId: tournamentId,
          stageIndex: stageIndex,
          round: 2,
          roundName: 'UB Semifinals',
          week: startWeek + 1,
          slotA: MatchSlot(teamId: '', teamName: 'Winner UB QF ${i * 2 + 1}'),
          slotB: MatchSlot(teamId: '', teamName: 'Winner UB QF ${i * 2 + 2}'),
          bestOf: bo,
        ));
      }

      // LB Round 2 - 2 matches (Week startWeek + 2)
      for (int i = 0; i < 2; i++) {
        matches.add(MatchNode(
          id: '${tournamentId}_lb_r2_${i + 1}',
          tournamentId: tournamentId,
          stageIndex: stageIndex,
          round: 3,
          roundName: 'LB Round 2',
          week: startWeek + 2,
          slotA: MatchSlot(teamId: '', teamName: 'Winner LB R1 ${i + 1}'),
          slotB: MatchSlot(teamId: '', teamName: 'Loser UB SF ${2 - i}'),
          bestOf: bo,
        ));
      }

      // UB Final - 1 match (Week startWeek + 2)
      matches.add(MatchNode(
        id: '${tournamentId}_ub_fn',
        tournamentId: tournamentId,
        stageIndex: stageIndex,
        round: 3,
        roundName: 'UB Final',
        week: startWeek + 2,
        slotA: MatchSlot(teamId: '', teamName: 'Winner UB SF 1'),
        slotB: MatchSlot(teamId: '', teamName: 'Winner UB SF 2'),
        bestOf: bo,
      ));

      // LB Final - 1 match (Week startWeek + 3)
      matches.add(MatchNode(
        id: '${tournamentId}_lb_fn',
        tournamentId: tournamentId,
        stageIndex: stageIndex,
        round: 4,
        roundName: 'LB Final',
        week: startWeek + 3,
        slotA: MatchSlot(teamId: '', teamName: 'Winner LB R2 1'),
        slotB: MatchSlot(teamId: '', teamName: 'Loser UB Final'),
        bestOf: bo,
      ));

      // Grand Final - 1 match (Week startWeek + 4)
      final gfSlotA = MatchSlot(teamId: '', teamName: 'Winner UB Final');
      if (gfAdvantage == 'upper') {
        gfSlotA.score = 1; // 1-0 advantage for upper bracket winner
      }
      matches.add(MatchNode(
        id: '${tournamentId}_gf',
        tournamentId: tournamentId,
        stageIndex: stageIndex,
        round: 5,
        roundName: 'Grand Final',
        week: startWeek + 4,
        slotA: gfSlotA,
        slotB: MatchSlot(teamId: '', teamName: 'Winner LB Final'),
        bestOf: grandFinalBo,
      ));
    } else {
      // 16-team Double Elimination
      // For 16 teams, rounds run across startWeek to startWeek + 5
      for (int i = 0; i < 8; i++) {
        final seedA = seedOrder[i * 2];
        final seedB = seedOrder[i * 2 + 1];
        final tA = seedA <= participants.length ? participants[seedA - 1] : null;
        final tB = seedB <= participants.length ? participants[seedB - 1] : null;

        matches.add(MatchNode(
          id: '${tournamentId}_ub_r1_${i + 1}',
          tournamentId: tournamentId,
          stageIndex: stageIndex,
          round: 1,
          roundName: 'UB Round of 16',
          week: startWeek,
          slotA: MatchSlot(teamId: tA?.id ?? '', teamName: tA?.name ?? 'TBD', seed: seedA),
          slotB: MatchSlot(teamId: tB?.id ?? '', teamName: tB?.name ?? 'TBD', seed: seedB),
          bestOf: bo,
        ));
      }
      // UB QF (4 matches) & LB R1 (4 matches) in week startWeek + 1
      for (int i = 0; i < 4; i++) {
        matches.add(MatchNode(
          id: '${tournamentId}_ub_qf_${i + 1}',
          tournamentId: tournamentId,
          stageIndex: stageIndex,
          round: 2,
          roundName: 'UB Quarterfinals',
          week: startWeek + 1,
          slotA: MatchSlot(teamId: '', teamName: 'Winner UB R16 ${i * 2 + 1}'),
          slotB: MatchSlot(teamId: '', teamName: 'Winner UB R16 ${i * 2 + 2}'),
          bestOf: bo,
        ));
        matches.add(MatchNode(
          id: '${tournamentId}_lb_r1_${i + 1}',
          tournamentId: tournamentId,
          stageIndex: stageIndex,
          round: 2,
          roundName: 'LB Round 1',
          week: startWeek + 1,
          slotA: MatchSlot(teamId: '', teamName: 'Loser UB R16 ${i * 2 + 1}'),
          slotB: MatchSlot(teamId: '', teamName: 'Loser UB R16 ${i * 2 + 2}'),
          bestOf: bo,
        ));
      }
      // UB SF & LB R2 in startWeek + 2
      for (int i = 0; i < 2; i++) {
        matches.add(MatchNode(
          id: '${tournamentId}_ub_sf_${i + 1}',
          tournamentId: tournamentId,
          stageIndex: stageIndex,
          round: 3,
          roundName: 'UB Semifinals',
          week: startWeek + 2,
          slotA: MatchSlot(teamId: '', teamName: 'Winner UB QF ${i * 2 + 1}'),
          slotB: MatchSlot(teamId: '', teamName: 'Winner UB QF ${i * 2 + 2}'),
          bestOf: bo,
        ));
        matches.add(MatchNode(
          id: '${tournamentId}_lb_r2_${i + 1}',
          tournamentId: tournamentId,
          stageIndex: stageIndex,
          round: 3,
          roundName: 'LB Round 2',
          week: startWeek + 2,
          slotA: MatchSlot(teamId: '', teamName: 'Winner LB R1 ${i + 1}'),
          slotB: MatchSlot(teamId: '', teamName: 'Loser UB QF ${i + 1}'),
          bestOf: bo,
        ));
      }
      // UB Final & LB Final in startWeek + 3 & startWeek + 4
      matches.add(MatchNode(
        id: '${tournamentId}_ub_fn',
        tournamentId: tournamentId,
        stageIndex: stageIndex,
        round: 4,
        roundName: 'UB Final',
        week: startWeek + 3,
        slotA: MatchSlot(teamId: '', teamName: 'Winner UB SF 1'),
        slotB: MatchSlot(teamId: '', teamName: 'Winner UB SF 2'),
        bestOf: bo,
      ));
      matches.add(MatchNode(
        id: '${tournamentId}_lb_fn',
        tournamentId: tournamentId,
        stageIndex: stageIndex,
        round: 5,
        roundName: 'LB Final',
        week: startWeek + 4,
        slotA: MatchSlot(teamId: '', teamName: 'Winner LB R2 1'),
        slotB: MatchSlot(teamId: '', teamName: 'Loser UB Final'),
        bestOf: bo,
      ));
      // Grand Final
      final gfSlotA = MatchSlot(teamId: '', teamName: 'Winner UB Final');
      if (gfAdvantage == 'upper') gfSlotA.score = 1;
      matches.add(MatchNode(
        id: '${tournamentId}_gf',
        tournamentId: tournamentId,
        stageIndex: stageIndex,
        round: 6,
        roundName: 'Grand Final',
        week: startWeek + 5,
        slotA: gfSlotA,
        slotB: MatchSlot(teamId: '', teamName: 'Winner LB Final'),
        bestOf: grandFinalBo,
      ));
    }

    return matches;
  }

  /// Generate GSL 4-team group matches
  static List<MatchNode> generateGslGroupMatches({
    required String tournamentId,
    required String groupPrefix,
    required List<AiTeam> groupTeams,
    required int startWeek,
    required int bo,
    int stageIndex = 0,
  }) {
    final matches = <MatchNode>[];
    // 4 teams: Seed 1, 2, 3, 4
    final t1 = groupTeams.isNotEmpty ? groupTeams[0] : null;
    final t2 = groupTeams.length > 1 ? groupTeams[1] : null;
    final t3 = groupTeams.length > 2 ? groupTeams[2] : null;
    final t4 = groupTeams.length > 3 ? groupTeams[3] : null;

    // Match 1: 1 vs 4 (Opening Match A)
    matches.add(MatchNode(
      id: '${tournamentId}_${groupPrefix}_m1',
      tournamentId: tournamentId,
      stageIndex: stageIndex,
      round: 1,
      roundName: '$groupPrefix Opening A',
      week: startWeek,
      slotA: MatchSlot(teamId: t1?.id ?? '', teamName: t1?.name ?? 'TBD', seed: 1),
      slotB: MatchSlot(teamId: t4?.id ?? '', teamName: t4?.name ?? 'TBD', seed: 4),
      bestOf: bo,
    ));

    // Match 2: 2 vs 3 (Opening Match B)
    matches.add(MatchNode(
      id: '${tournamentId}_${groupPrefix}_m2',
      tournamentId: tournamentId,
      stageIndex: stageIndex,
      round: 1,
      roundName: '$groupPrefix Opening B',
      week: startWeek,
      slotA: MatchSlot(teamId: t2?.id ?? '', teamName: t2?.name ?? 'TBD', seed: 2),
      slotB: MatchSlot(teamId: t3?.id ?? '', teamName: t3?.name ?? 'TBD', seed: 3),
      bestOf: bo,
    ));

    // Match 3: Winners Match (W1 vs W2)
    matches.add(MatchNode(
      id: '${tournamentId}_${groupPrefix}_m3',
      tournamentId: tournamentId,
      stageIndex: stageIndex,
      round: 2,
      roundName: '$groupPrefix Winners Match',
      week: startWeek + 1,
      slotA: MatchSlot(teamId: '', teamName: 'Winner Opening A'),
      slotB: MatchSlot(teamId: '', teamName: 'Winner Opening B'),
      bestOf: bo,
    ));

    // Match 4: Elimination Match (L1 vs L2)
    matches.add(MatchNode(
      id: '${tournamentId}_${groupPrefix}_m4',
      tournamentId: tournamentId,
      stageIndex: stageIndex,
      round: 2,
      roundName: '$groupPrefix Elimination Match',
      week: startWeek + 1,
      slotA: MatchSlot(teamId: '', teamName: 'Loser Opening A'),
      slotB: MatchSlot(teamId: '', teamName: 'Loser Opening B'),
      bestOf: bo,
    ));

    // Match 5: Decider Match (L3 vs W4)
    matches.add(MatchNode(
      id: '${tournamentId}_${groupPrefix}_m5',
      tournamentId: tournamentId,
      stageIndex: stageIndex,
      round: 3,
      roundName: '$groupPrefix Decider Match',
      week: startWeek + 2,
      slotA: MatchSlot(teamId: '', teamName: 'Loser Winners Match'),
      slotB: MatchSlot(teamId: '', teamName: 'Winner Elimination Match'),
      bestOf: bo,
    ));

    return matches;
  }

  /// Generate Snake Groups Round-Robin matches (e.g. 16 teams into 4 groups of 4)
  static List<MatchNode> generateSnakeGroupMatches({
    required String tournamentId,
    required List<AiTeam> participants,
    required int groupsCount,
    required int startWeek,
    required int bo,
    int stageIndex = 0,
  }) {
    final allMatches = <MatchNode>[];
    final groupTeamsMap = {for (int g = 0; g < groupsCount; g++) g: <AiTeam>[]};
    for (int i = 0; i < participants.length; i++) {
      int round = i ~/ groupsCount;
      int gIdx = round % 2 == 1 ? groupsCount - 1 - (i % groupsCount) : i % groupsCount;
      groupTeamsMap[gIdx]?.add(participants[i]);
    }

    // Generate round robin for each group
    const letters = ['A', 'B', 'C', 'D'];
    for (int g = 0; g < groupsCount; g++) {
      final letter = g < letters.length ? letters[g] : 'G${g + 1}';
      final gTeams = groupTeamsMap[g] ?? [];
      final rrMatches = BracketEngine.generateRoundRobinMatches(
        tournamentId: '${tournamentId}_grp$letter',
        participants: gTeams,
        startWeek: startWeek,
        bo: bo,
        stageIndex: stageIndex,
      );
      allMatches.addAll(rrMatches);
    }

    return allMatches;
  }

  /// Generate initial Round 1 matches for Swiss tournament (16 teams)
  static List<MatchNode> generateSwissRound1({
    required String tournamentId,
    required List<AiTeam> participants,
    required int startWeek,
    required int bo,
    int stageIndex = 0,
  }) {
    final matches = <MatchNode>[];
    // Seed 1 vs Seed 16, 2 vs 15, 3 vs 14 ... 8 vs 9
    final count = participants.length;
    final half = count ~/ 2;
    for (int i = 0; i < half; i++) {
      final teamA = participants[i];
      final teamB = participants[count - 1 - i];

      matches.add(MatchNode(
        id: '${tournamentId}_swiss_r1_m${i + 1}',
        tournamentId: tournamentId,
        stageIndex: stageIndex,
        round: 1,
        roundName: 'Swiss Round 1 (0-0)',
        week: startWeek,
        slotA: MatchSlot(teamId: teamA.id, teamName: teamA.name, seed: i + 1),
        slotB: MatchSlot(teamId: teamB.id, teamName: teamB.name, seed: count - i),
        bestOf: bo,
      ));
    }
    return matches;
  }
}
