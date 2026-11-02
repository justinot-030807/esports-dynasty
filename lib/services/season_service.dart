import 'dart:math';
import '../models/game_state.dart';
import '../models/hall_of_fame.dart';
import '../models/player.dart';
import '../models/tournament.dart';
import '../models/ai_team.dart';
import 'data_service.dart';
import 'save_service.dart';
import 'transfer_service.dart';

class SeasonService {
  static final Random _rng = Random();

  /// Compute awards for Annual Awards Night (W48 Day 7)
  static List<SeasonAward> computeSeasonAwards(GameState state) {
    final awards = <SeasonAward>[];
    final allAi = DataService().allTeams.isNotEmpty
        ? DataService().allTeams
        : [
            AiTeam(
              id: 'ai_fallback',
              name: 'Kidlat Esports',
              tier: 1,
              region: 'NCR',
              colors: ['#1B2A49', '#F5B700'],
              rating: 45,
              circuitPoints: 100,
              captain: 'Kidlat Prime',
            )
          ];

    // 1. Team of the Year
    final topAi = (List.of(allAi)..sort((a, b) => b.circuitPoints.compareTo(a.circuitPoints))).first;
    final isUserTopTeam = state.circuitPoints >= topAi.circuitPoints || state.trophies.any((t) => t.contains('t7') || t.contains('t5'));
    final totWinner = isUserTopTeam ? state.teamName : topAi.name;
    awards.add(SeasonAward(
      category: 'tot',
      title: 'Team of the Year',
      winnerName: totWinner,
      teamName: totWinner,
      description: isUserTopTeam
          ? 'Nakamit ng ${state.teamName} ang pinakamalaking tagumpay ngayong taon!'
          : 'Dinomina ng $totWinner ang circuit ladder at mga malalaking entablado!',
      rewardMoney: isUserTopTeam ? 100000 : 0,
      rewardFame: isUserTopTeam ? 500 : 0,
      rewardFans: isUserTopTeam ? 10000 : 0,
      isUserWinner: isUserTopTeam,
    ));

    // 2. Player MVP
    Player? userBestPlayer;
    if (state.starters.isNotEmpty) {
      userBestPlayer = (List.of(state.starters)..sort((a, b) => b.ovr.compareTo(a.ovr))).first;
    }
    final isUserMvp = userBestPlayer != null && (userBestPlayer.ovr >= 65 || isUserTopTeam);
    final mvpName = isUserMvp ? userBestPlayer.gamerTag : ((topAi.captain != null && topAi.captain!.isNotEmpty) ? topAi.captain! : 'Blitz');
    final mvpTeam = isUserMvp ? state.teamName : topAi.name;
    awards.add(SeasonAward(
      category: 'mvp',
      title: 'Season MVP',
      winnerName: mvpName,
      teamName: mvpTeam,
      description: 'Pinakamalupit na indibidwal na performance sa buong season!',
      rewardMoney: isUserMvp ? 50000 : 0,
      rewardFame: isUserMvp ? 300 : 0,
      rewardFans: isUserMvp ? 5000 : 0,
      isUserWinner: isUserMvp,
    ));

    // 3. Rookie of the Year (Age <= 19)
    final userRookies = state.starters.where((p) => p.age <= 19).toList();
    userRookies.sort((a, b) => b.ovr.compareTo(a.ovr));
    final isUserRookie = userRookies.isNotEmpty && (userRookies.first.ovr >= 45 || isUserTopTeam);
    final rookieName = isUserRookie ? userRookies.first.gamerTag : 'Astro';
    final rookieTeam = isUserRookie ? state.teamName : 'Bakal Wolves';
    awards.add(SeasonAward(
      category: 'rookie',
      title: 'Rookie of the Year',
      winnerName: rookieName,
      teamName: rookieTeam,
      description: 'Pinakamakislap na bagong mukha sa pro gaming circuit!',
      rewardMoney: isUserRookie ? 25000 : 0,
      rewardFame: isUserRookie ? 200 : 0,
      rewardFans: isUserRookie ? 3000 : 0,
      isUserWinner: isUserRookie,
    ));

    // 4. Coach of the Year
    final coach = state.staff.cast<dynamic>().firstWhere((s) => s.role.toString().contains('headCoach'), orElse: () => null);
    final isUserCoach = coach != null && (coach.level >= 2 || isUserTopTeam);
    final coachName = isUserCoach ? coach.name : 'Master Oogway';
    final coachTeam = isUserCoach ? state.teamName : 'Mayon Flames';
    awards.add(SeasonAward(
      category: 'coach',
      title: 'Coach of the Year',
      winnerName: coachName,
      teamName: coachTeam,
      description: 'Henyo sa taktika, drafting, at pamamahala ng koponan!',
      rewardMoney: isUserCoach ? 25000 : 0,
      rewardFame: isUserCoach ? 150 : 0,
      rewardFans: isUserCoach ? 2000 : 0,
      isUserWinner: isUserCoach,
    ));

    // 5. Play of the Year
    final isUserPlay = isUserTopTeam || _rng.nextBool();
    final playPlayer = isUserPlay
        ? (userBestPlayer?.gamerTag ?? 'Player')
        : 'Mayon Dragon';
    awards.add(SeasonAward(
      category: 'play',
      title: 'Play of the Year',
      winnerName: playPlayer,
      teamName: isUserPlay ? state.teamName : 'Mayon Flames',
      description: '1v3 Base Defense Clutch sa Grand Finals! Grabe ang sigawan ng crowd!',
      rewardMoney: isUserPlay ? 20000 : 0,
      rewardFame: isUserPlay ? 100 : 0,
      rewardFans: isUserPlay ? 2000 : 0,
      isUserWinner: isUserPlay,
    ));

    return awards;
  }

  /// Apply awards to GameState and Hall of Fame
  static void applyAwards(GameState state, List<SeasonAward> awards) {
    for (final a in awards) {
      if (a.isUserWinner) {
        state.money += a.rewardMoney;
        state.fame += a.rewardFame;
        state.fans += a.rewardFans;
      }
      // Record in Hall of Fame
      state.hallOfFame.add(HallOfFameRecord(
        id: 'hof_${state.year}_${a.category}',
        year: state.year,
        category: a.category,
        title: a.title,
        recipientName: a.winnerName,
        teamName: a.teamName,
        details: a.description,
      ));
    }
  }

  /// Annual rollover at Year End: increment year, reset weeks, AI rating drift
  static void performAnnualRollover(GameState state) {
    state.year++;
    state.month = 1;
    state.week = 1;
    state.day = 1;

    // Reset circuit points with 50% rolling decay
    state.circuitPoints = (state.circuitPoints * 0.5).round();

    // Player Ageing & natural wear
    TransferService().performAnnualAgeing(state);

    // Re-seed tournament instances for new year
    state.tournamentInstances.clear();
    final defs = DataService().tournaments;
    for (final def in defs) {
      state.tournamentInstances.add(TournamentInstance(
        tournamentId: def.id,
        name: def.name,
        tier: def.tier,
        banner: def.banner,
        status: 'upcoming',
      ));
    }

    // AI Evolution: Rating drift & circuit decay
    final allAi = DataService().allTeams;
    final userRating = state.starters.isNotEmpty
        ? (state.starters.map((p) => p.ovr).reduce((a, b) => a + b) ~/ state.starters.length)
        : 40;

    for (final team in allAi) {
      team.circuitPoints = (team.circuitPoints * 0.5).round();
      // Drift rating by -2 to +3
      final drift = _rng.nextInt(6) - 2;
      team.rating = (team.rating + drift).clamp(25, 99);

      // Flagship rivals scale to stay competitive
      if (team.isFlagship) {
        if (team.rating < userRating - 5) {
          team.rating += 4;
        }
      }
    }

    // Reset monthly financial trackers
    state.monthIncome = 0;
    state.monthExpenses = 0;
    state.monthPlayerSalaries = 0;
    state.monthStaffSalaries = 0;
    state.monthRent = 0;

    SaveService.saveGame(state);
  }
}

