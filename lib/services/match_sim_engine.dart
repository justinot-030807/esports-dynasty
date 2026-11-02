import 'dart:math';
import '../models/game_state.dart';
import '../models/player.dart';
import '../models/division.dart';
import '../models/ai_team.dart';
import '../models/tournament.dart';
import '../models/match_result.dart';
import '../models/staff.dart';
import '../models/patch_data.dart';

class MatchSimEngine {
  static final Random _rng = Random();

  /// Strategy counter lookup: returns power modifier for Team A (-4, 0, or +4)
  static int getStrategyModifier(String strategyA, String strategyB, [String? divisionId]) {
    if (strategyA == strategyB) return 0;
    final div = EsportsDivision.getById(divisionId ?? 'arena_clash');
    final mod = div.getStrategyModifier(strategyA, strategyB);
    if (mod != 0) return mod;

    for (final d in EsportsDivision.all) {
      final m = d.getStrategyModifier(strategyA, strategyB);
      if (m != 0) return m;
    }
    return 0;
  }

  /// Calculate individual player performance score in OVR units
  static double calculatePlayerPerf(Player p, {bool isPlayoff = false, bool isLAN = false}) {
    double score = p.ovr.toDouble();

    // Condition modifier
    switch (p.condition) {
      case PlayerCondition.great: score += 3; break;
      case PlayerCondition.good: score += 1; break;
      case PlayerCondition.normal: score += 0; break;
      case PlayerCondition.tired: score -= 4; break;
      case PlayerCondition.exhausted: score -= 10; break;
    }

    // Morale modifier: (morale - 50) / 12.5
    score += (p.morale - 50) / 12.5;

    // Traits
    if (p.traits.contains('Clutch')) score += 1.5;
    if (p.traits.contains('Prodigy')) score += 1.0;

    // Pressure in semifinals / finals: (Mental - 50) / 10
    if (isPlayoff) {
      double pressure = (p.mental - 50) / 10.0;
      if (isLAN) pressure *= 2.0;
      score += pressure;
    }

    return score;
  }

  /// Calculate User Team overall power
  static double calculateUserTeamPower(
    GameState state, {
    String userStrategy = 'Teamfight',
    String opponentStrategy = 'Teamfight',
    bool isPlayoff = false,
    bool isLAN = false,
    double focusBonus = 1.0,
    PatchDef? patch,
    String? divisionId,
  }) {
    final starters = divisionId != null && divisionId.isNotEmpty
        ? state.getStartersForDivision(divisionId)
        : state.starters;
    if (starters.isEmpty) return 30.0;

    double totalPerf = 0;
    for (final p in starters) {
      totalPerf += calculatePlayerPerf(p, isPlayoff: isPlayoff, isLAN: isLAN);
    }
    double avgPerf = totalPerf / starters.length;

    // Chemistry: 60 base + combos
    double chemistryBonus = (65 / 100.0) * 6.0;

    // Staff bonuses (Coach 0.4/lvl, Analyst 0.5/lvl, max 4.0)
    final coach = state.staff.where((s) => s.role == StaffRole.coach).firstOrNull;
    final analyst = state.staff.where((s) => s.role == StaffRole.analyst).firstOrNull;
    double staffBonus = (coach != null ? coach.level * 0.4 : 0.0) +
        (analyst != null ? analyst.level * 0.5 : 0.0);
    staffBonus = min(4.0, staffBonus);

    // Strategy Counter (+4 / -4)
    int strategyMod = getStrategyModifier(userStrategy, opponentStrategy);

    // Patch Meta (+3 / -3)
    int patchMod = patch != null ? patch.getStrategyModifier(userStrategy) : 0;

    return avgPerf + chemistryBonus + staffBonus + strategyMod + patchMod + focusBonus;
  }

  /// Calculate AI Team Power
  static double calculateAiTeamPower(
    AiTeam aiTeam, {
    String opponentStrategy = 'Teamfight',
    PatchDef? patch,
  }) {
    double power = aiTeam.rating.toDouble();
    int strategyMod = getStrategyModifier(aiTeam.style, opponentStrategy);
    int patchMod = patch != null ? patch.getStrategyModifier(aiTeam.style) : 0;
    return power + strategyMod + patchMod;
  }

  /// Win probability using logistic function
  static double getWinProbability(double powerA, double powerB) {
    final diff = powerA - powerB;
    return 1.0 / (1.0 + exp(-diff / 12.0));
  }

  /// Simulate a single game between User and AI Team
  static GameResult simulateSingleGame({
    required GameState state,
    required AiTeam opponent,
    required String userStrategy,
    required double focusBonus,
    required double momentumUser,
    required double momentumOpponent,
    required int gameNumber,
    bool isPlayoff = false,
    bool isLAN = false,
    PatchDef? patch,
  }) {
    final powerUser = calculateUserTeamPower(
      state,
      userStrategy: userStrategy,
      opponentStrategy: opponent.style,
      isPlayoff: isPlayoff,
      isLAN: isLAN,
      focusBonus: focusBonus,
      patch: patch,
    ) + momentumUser;

    final powerOpponent = calculateAiTeamPower(
      opponent,
      opponentStrategy: userStrategy,
      patch: patch,
    ) + momentumOpponent;

    final pWin = getWinProbability(powerUser, powerOpponent);
    final userWon = _rng.nextDouble() < pWin;

    final killMargin = 3 + _rng.nextInt(8);
    final duration = 16 + _rng.nextInt(16); // 16 to 32 mins

    return GameResult(
      gameNumber: gameNumber,
      teamAScore: userWon ? (15 + killMargin) : max(0, 15 - killMargin ~/ 2),
      teamBScore: userWon ? max(0, 15 - killMargin ~/ 2) : (15 + killMargin),
      winnerTeamId: userWon ? 'user_team' : opponent.id,
      durationMinutes: duration,
    );
  }

  /// Finalize rewards, fatigue, morale, and records after a user series completes
  static MatchSeriesResult finalizeUserSeriesResult({
    required GameState state,
    required AiTeam opponent,
    required MatchNode match,
    required TournamentDef tournament,
    required List<GameResult> games,
  }) {
    int winsUser = games.where((g) => g.winnerTeamId == 'user_team').length;
    int winsOpponent = games.where((g) => g.winnerTeamId == opponent.id).length;

    final userWonSeries = winsUser > winsOpponent;
    final winnerId = userWonSeries ? 'user_team' : opponent.id;
    final winnerName = userWonSeries ? state.teamName : opponent.name;

    // Apply fatigue & morale to starters
    final divStarters = state.getStartersForDivision(tournament.division);
    final fatigueDelta = match.bestOf == 1 ? 8 : (match.bestOf == 3 ? 15 : 22);
    for (final p in divStarters) {
      p.fatigue = min(100, p.fatigue + fatigueDelta);
      p.morale = userWonSeries ? min(100, p.morale + 6) : max(0, p.morale - 8);
    }

    // Match rewards
    int prizeEarned = 0;
    int fameEarned = 0;
    int fansEarned = 0;
    int pointsEarned = 0;

    if (userWonSeries) {
      state.consecutiveWins++;
      fameEarned = (tournament.championFame * 0.25).round();
      fansEarned = (tournament.championFans * 0.25).round();
      pointsEarned = (tournament.circuitPoints * 0.25).round();

      if (match.roundName == 'Grand Final') {
        prizeEarned = tournament.championPrize;
        fameEarned = tournament.championFame;
        fansEarned = tournament.championFans;
        pointsEarned = tournament.circuitPoints;
        if (!state.trophies.contains(tournament.trophy)) {
          state.trophies.add(tournament.trophy);
        }
      }
    } else {
      state.consecutiveWins = 0;
    }

    state.money += prizeEarned;
    state.fame += fameEarned;
    state.fans += fansEarned;
    state.addDivisionCircuitPoints(tournament.division, pointsEarned);

    final mvp = userWonSeries
        ? (divStarters.isNotEmpty ? divStarters[_rng.nextInt(divStarters.length)].gamerTag : 'Player')
        : (opponent.captain ?? 'Opponent Ace');

    final headline = userWonSeries
        ? 'MALUPET! ${state.teamName} dinaig ang ${opponent.name} sa ${match.roundName}!'
        : 'Sayang! ${state.teamName} yumukod sa ${opponent.name} ($winsUser-$winsOpponent).';

    return MatchSeriesResult(
      matchId: match.id,
      tournamentId: tournament.id,
      tournamentName: tournament.name,
      roundName: match.roundName,
      teamAId: 'user_team',
      teamAName: state.teamName,
      teamBId: opponent.id,
      teamBName: opponent.name,
      scoreA: winsUser,
      scoreB: winsOpponent,
      winnerId: winnerId,
      winnerName: winnerName,
      games: games,
      mvpName: mvp,
      fameChange: fameEarned,
      fansChange: fansEarned,
      prizeMoney: prizeEarned,
      circuitPoints: pointsEarned,
      newsHeadline: headline,
    );
  }

  /// Simulate a full series between User Team and an AI Team in one go (Auto-Sim)
  static MatchSeriesResult simulateUserSeries({
    required GameState state,
    required AiTeam opponent,
    required MatchNode match,
    required TournamentDef tournament,
    String userStrategy = 'Teamfight',
    double focusBonus = 1.0,
    PatchDef? patch,
  }) {
    final targetWins = (match.bestOf / 2).ceil();
    int winsUser = 0;
    int winsOpponent = 0;
    final games = <GameResult>[];

    final isPlayoff = match.roundName.contains('Final') || match.roundName.contains('Semi');
    final isLAN = tournament.tier >= 4;

    double momentumUser = 0;
    double momentumOpponent = 0;

    int gameNumber = 1;
    while (winsUser < targetWins && winsOpponent < targetWins) {
      final game = simulateSingleGame(
        state: state,
        opponent: opponent,
        userStrategy: userStrategy,
        focusBonus: focusBonus,
        momentumUser: momentumUser,
        momentumOpponent: momentumOpponent,
        gameNumber: gameNumber,
        isPlayoff: isPlayoff,
        isLAN: isLAN,
        patch: patch,
      );
      games.add(game);

      if (game.winnerTeamId == 'user_team') {
        winsUser++;
        momentumUser = 1.0;
        momentumOpponent = 0.0;
      } else {
        winsOpponent++;
        momentumOpponent = 1.0;
        momentumUser = 0.0;
      }
      gameNumber++;
    }

    return finalizeUserSeriesResult(
      state: state,
      opponent: opponent,
      match: match,
      tournament: tournament,
      games: games,
    );
  }

  /// Fast Headless Simulation for AI vs AI matches (<5 ms)
  static MatchSeriesResult simulateAiVsAi({
    required AiTeam teamA,
    required AiTeam teamB,
    required MatchNode match,
    required TournamentDef tournament,
    PatchDef? patch,
  }) {
    final targetWins = (match.bestOf / 2).ceil();
    int winsA = 0;
    int winsB = 0;

    final powerA = calculateAiTeamPower(teamA, opponentStrategy: teamB.style, patch: patch);
    final powerB = calculateAiTeamPower(teamB, opponentStrategy: teamA.style, patch: patch);
    final pWinA = getWinProbability(powerA, powerB);

    final games = <GameResult>[];
    int g = 1;

    while (winsA < targetWins && winsB < targetWins) {
      final aWon = _rng.nextDouble() < pWinA;
      if (aWon) {
        winsA++;
        games.add(GameResult(gameNumber: g, teamAScore: 16, teamBScore: 10, winnerTeamId: teamA.id, durationMinutes: 20));
      } else {
        winsB++;
        games.add(GameResult(gameNumber: g, teamAScore: 10, teamBScore: 16, winnerTeamId: teamB.id, durationMinutes: 20));
      }
      g++;
    }

    final winnerId = winsA > winsB ? teamA.id : teamB.id;
    final winnerName = winsA > winsB ? teamA.name : teamB.name;

    // Update form
    if (winsA > winsB) {
      teamA.form.insert(0, 'W');
      if (teamA.form.length > 5) teamA.form.removeLast();
      teamB.form.insert(0, 'L');
      if (teamB.form.length > 5) teamB.form.removeLast();
    } else {
      teamA.form.insert(0, 'L');
      if (teamA.form.length > 5) teamA.form.removeLast();
      teamB.form.insert(0, 'W');
      if (teamB.form.length > 5) teamB.form.removeLast();
    }

    return MatchSeriesResult(
      matchId: match.id,
      tournamentId: tournament.id,
      tournamentName: tournament.name,
      roundName: match.roundName,
      teamAId: teamA.id,
      teamAName: teamA.name,
      teamBId: teamB.id,
      teamBName: teamB.name,
      scoreA: winsA,
      scoreB: winsB,
      winnerId: winnerId,
      winnerName: winnerName,
      games: games,
      mvpName: winnerId == teamA.id ? (teamA.captain ?? 'Ace') : (teamB.captain ?? 'Ace'),
      fameChange: 0,
      fansChange: 0,
      prizeMoney: 0,
      circuitPoints: 0,
      newsHeadline: '$winnerName wagi laban sa ${winnerId == teamA.id ? teamB.name : teamA.name} ($winsA-$winsB)',
    );
  }
}
