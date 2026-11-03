import 'dart:math';
import '../models/tournament.dart';
import '../models/ai_team.dart';
import '../models/match_result.dart';
import 'bracket_advancement_engine.dart';

class BracketEngine {
  /// Generate seed order recursively for any power of two
  static List<int> generateSeedOrder(int n) {
    if (n <= 1) return [1];
    if (n == 2) return [1, 2];

    List<int> previous = generateSeedOrder(n ~/ 2);
    List<int> current = [];
    for (int seed in previous) {
      current.add(seed);
      current.add(n + 1 - seed);
    }
    return current;
  }

  /// Next power of 2 >= n
  static int nextPowerOfTwo(int n) {
    int p = 1;
    while (p < n) {
      p *= 2;
    }
    return p;
  }

  /// Round name based on teams remaining in single elimination
  static String getRoundName(int teamsInRound) {
    switch (teamsInRound) {
      case 2: return 'Grand Final';
      case 4: return 'Semifinals';
      case 8: return 'Quarterfinals';
      case 16: return 'Round of 16';
      case 32: return 'Round of 32';
      default: return 'Round of $teamsInRound';
    }
  }

  /// Build a single elimination bracket graph of MatchNodes
  static List<MatchNode> generateSingleElimMatches({
    required String tournamentId,
    required List<AiTeam> participants,
    required int startWeek,
    required int bo,
    required int grandFinalBo,
    int stageIndex = 0,
  }) {
    final count = participants.length;
    if (count < 2) return [];
    final bracketSize = nextPowerOfTwo(count);
    final numRounds = (log(bracketSize) / log(2)).round();
    final seedOrder = generateSeedOrder(bracketSize);

    final allMatches = <MatchNode>[];
    int matchCounter = 1;

    // Track round match nodes to connect parent winners to next round
    Map<int, List<MatchNode>> roundsMap = {};

    // 1. Generate Round 1 matches
    final r1Matches = <MatchNode>[];
    final r1Teams = bracketSize;
    final r1Week = startWeek;

    for (int i = 0; i < seedOrder.length; i += 2) {
      final seedA = seedOrder[i];
      final seedB = seedOrder[i + 1];

      final teamA = seedA <= count ? participants[seedA - 1] : null;
      final teamB = seedB <= count ? participants[seedB - 1] : null;

      final isBye = teamA == null || teamB == null;
      String winnerId = '';
      if (teamA != null && teamB == null) winnerId = teamA.id;
      if (teamB != null && teamA == null) winnerId = teamB.id;

      final match = MatchNode(
        id: '${tournamentId}_s${stageIndex}_m$matchCounter',
        tournamentId: tournamentId,
        stageIndex: stageIndex,
        round: 1,
        roundName: getRoundName(r1Teams),
        week: r1Week,
        day: 5,
        slotA: MatchSlot(
          teamId: teamA?.id ?? '',
          teamName: teamA?.name ?? 'BYE',
          seed: seedA,
          isWinner: winnerId == teamA?.id && winnerId.isNotEmpty,
        ),
        slotB: MatchSlot(
          teamId: teamB?.id ?? '',
          teamName: teamB?.name ?? 'BYE',
          seed: seedB,
          isWinner: winnerId == teamB?.id && winnerId.isNotEmpty,
        ),
        bestOf: numRounds == 1 ? grandFinalBo : bo,
        isPlayed: isBye,
        isBye: isBye,
        winnerId: winnerId,
      );

      r1Matches.add(match);
      allMatches.add(match);
      matchCounter++;
    }
    roundsMap[1] = r1Matches;

    // 2. Generate subsequent rounds (SF, Final, etc.)
    for (int r = 2; r <= numRounds; r++) {
      final prevRoundMatches = roundsMap[r - 1]!;
      final curRoundMatches = <MatchNode>[];
      final teamsInCurRound = bracketSize ~/ pow(2, r - 1).toInt();
      final roundWeek = startWeek + (r - 1);
      final isGrandFinal = r == numRounds;

      for (int i = 0; i < prevRoundMatches.length; i += 2) {
        final parent1 = prevRoundMatches[i];
        final parent2 = prevRoundMatches[i + 1];

        // If parent was already decided (e.g. by bye)
        String slotATeamId = parent1.winnerId;
        String slotATeamName = slotATeamId.isNotEmpty
            ? (slotATeamId == parent1.slotA.teamId ? parent1.slotA.teamName : parent1.slotB.teamName)
            : 'Winner of M${parent1.id.split('_').last}';

        String slotBTeamId = parent2.winnerId;
        String slotBTeamName = slotBTeamId.isNotEmpty
            ? (slotBTeamId == parent2.slotA.teamId ? parent2.slotA.teamName : parent2.slotB.teamName)
            : 'Winner of M${parent2.id.split('_').last}';

        final match = MatchNode(
          id: '${tournamentId}_s${stageIndex}_m$matchCounter',
          tournamentId: tournamentId,
          stageIndex: stageIndex,
          round: r,
          roundName: getRoundName(teamsInCurRound),
          week: roundWeek,
          day: 5,
          slotA: MatchSlot(teamId: slotATeamId, teamName: slotATeamName),
          slotB: MatchSlot(teamId: slotBTeamId, teamName: slotBTeamName),
          bestOf: isGrandFinal ? grandFinalBo : bo,
        );

        curRoundMatches.add(match);
        allMatches.add(match);
        matchCounter++;
      }
      roundsMap[r] = curRoundMatches;
    }

    return allMatches;
  }

  /// Generate a Round Robin schedule using the circle method
  static List<MatchNode> generateRoundRobinMatches({
    required String tournamentId,
    required List<AiTeam> participants,
    required int startWeek,
    required int bo,
    int stageIndex = 0,
  }) {
    final teams = List<AiTeam?>.from(participants);
    // If odd, add a dummy null team for byes
    if (teams.length % 2 != 0) {
      teams.add(null);
    }

    final n = teams.length;
    final numRounds = n - 1;
    final half = n ~/ 2;

    final allMatches = <MatchNode>[];
    int matchCounter = 1;

    for (int r = 0; r < numRounds; r++) {
      final roundWeek = startWeek + r;

      for (int i = 0; i < half; i++) {
        final teamA = teams[i];
        final teamB = teams[n - 1 - i];

        if (teamA == null || teamB == null) {
          // Bye match - can skip or mark bye
          continue;
        }

        final match = MatchNode(
          id: '${tournamentId}_rr_m$matchCounter',
          tournamentId: tournamentId,
          stageIndex: stageIndex,
          round: r + 1,
          roundName: 'Round ${r + 1}',
          week: roundWeek,
          day: 5,
          slotA: MatchSlot(teamId: teamA.id, teamName: teamA.name),
          slotB: MatchSlot(teamId: teamB.id, teamName: teamB.name),
          bestOf: bo,
        );

        allMatches.add(match);
        matchCounter++;
      }

      // Rotate circle: keep index 0 fixed, rotate others
      final last = teams.removeLast();
      teams.insert(1, last);
    }

    return allMatches;
  }

  /// Advance a single elimination tournament after a match is played
  static void advanceSingleElimWinner(TournamentInstance instance, MatchNode completedMatch) {
    if (completedMatch.winnerId.isEmpty) return;

    // Find if there is a child match expecting winner of this match
    final currentRound = completedMatch.round;
    final nextRoundMatches = instance.matches.where((m) => m.round == currentRound + 1).toList();

    // The index of this match in its round
    final roundMatches = instance.matches.where((m) => m.round == currentRound).toList();
    final matchIndexInRound = roundMatches.indexWhere((m) => m.id == completedMatch.id);
    if (matchIndexInRound == -1) return;

    final childMatchIndex = matchIndexInRound ~/ 2;
    if (childMatchIndex >= nextRoundMatches.length) {
      // Completed match was Grand Final!
      instance.championId = completedMatch.winnerId;
      instance.championName = completedMatch.winnerId == completedMatch.slotA.teamId
          ? completedMatch.slotA.teamName
          : completedMatch.slotB.teamName;
      instance.status = 'completed';
      return;
    }

    final childMatch = nextRoundMatches[childMatchIndex];
    final isSlotA = matchIndexInRound % 2 == 0;
    final winnerName = completedMatch.winnerId == completedMatch.slotA.teamId
        ? completedMatch.slotA.teamName
        : completedMatch.slotB.teamName;

    if (isSlotA) {
      childMatch.slotA.teamId = completedMatch.winnerId;
      childMatch.slotA.teamName = winnerName;
    } else {
      childMatch.slotB.teamId = completedMatch.winnerId;
      childMatch.slotB.teamName = winnerName;
    }
  }

  /// Record match outcome and advance bracket or round robin standings
  static void recordMatchOutcome({
    required TournamentInstance instance,
    required TournamentDef tournament,
    required MatchNode match,
    required MatchSeriesResult result,
  }) {
    match.isPlayed = true;
    final isSlotA = match.slotA.teamId == 'user_team';
    if (isSlotA) {
      match.slotA.score = result.scoreA;
      match.slotB.score = result.scoreB;
      match.slotA.isWinner = result.winnerId == 'user_team';
      match.slotB.isWinner = result.winnerId != 'user_team';
    } else {
      match.slotA.score = result.scoreB;
      match.slotB.score = result.scoreA;
      match.slotB.isWinner = result.winnerId == 'user_team';
      match.slotA.isWinner = result.winnerId != 'user_team';
    }
    match.winnerId = result.winnerId;

    final stage = tournament.stages[match.stageIndex.clamp(0, tournament.stages.length - 1)];
    if (stage.type == 'single_elim') {
      advanceSingleElimWinner(instance, match);
    } else if (stage.type == 'double_elim') {
      BracketAdvancementEngine.advanceDoubleElimMatch(instance, match);
    } else if (stage.type == 'gsl_group') {
      BracketAdvancementEngine.advanceGslMatch(instance, match);
    } else if (stage.type == 'round_robin') {
      final oppId = isSlotA ? match.slotB.teamId : match.slotA.teamId;
      for (final s in instance.standings) {
        final isUser = s.teamId == 'user_team';
        final isOpp = s.teamId == oppId;
        if (isUser || isOpp) {
          s.played++;
          final teamWon = isUser ? result.isUserVictory : !result.isUserVictory;
          if (teamWon) {
            s.wins++;
            s.points += 3;
            s.form.insert(0, 'W');
          } else {
            s.losses++;
            s.form.insert(0, 'L');
          }
          s.gamesWon += isUser ? result.scoreA : result.scoreB;
          s.gamesLost += isUser ? result.scoreB : result.scoreA;
          if (s.form.length > 5) s.form.removeLast();
        }
      }
    }
  }
}
