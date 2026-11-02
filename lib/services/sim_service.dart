import 'dart:math';
import '../models/game_state.dart';
import '../models/player.dart';
import '../models/staff.dart';
import '../models/legacy_state.dart';
import 'legacy_service.dart';

class SimYearRecord {
  final int year;
  final int money;
  final int fame;
  final int fans;
  final int houseTier;
  final int highestTier;
  final double avgOvr;
  final int rosterSize;
  final int divisionsCount;

  const SimYearRecord({
    required this.year,
    required this.money,
    required this.fame,
    required this.fans,
    required this.houseTier,
    required this.highestTier,
    required this.avgOvr,
    required this.rosterSize,
    this.divisionsCount = 1,
  });

  String get formattedLine {
    final mStr = money.abs() >= 1000000
        ? 'P${(money / 1000000).toStringAsFixed(1)}M'
        : 'P${(money / 1000).toStringAsFixed(1)}K';
    final fanStr = fans >= 1000 ? '${(fans / 1000).toStringAsFixed(1)}K' : '$fans';
    return 'Y$year: T$highestTier (HQ: T$houseTier) | $mStr | Fame: $fame | Fans: $fanStr | Divs: $divisionsCount | OVR: ${avgOvr.toStringAsFixed(1)}';
  }
}

class SimResult {
  final List<SimYearRecord> yearRecords;
  final List<String> yearReports;
  final bool bankrupt;
  final int finalMoney;
  final int finalFame;
  final int finalFans;
  final int durationMs;
  final FinalEvaluation evaluation;

  SimResult({
    required this.yearRecords,
    required this.yearReports,
    required this.bankrupt,
    required this.finalMoney,
    required this.finalFame,
    required this.finalFans,
    required this.durationMs,
    required this.evaluation,
  });
}

class SimService {
  static final Random _rng = Random(42);

  /// Headless 10-year simulation with a sensible bot
  static SimResult runTenYearSimulation({String difficulty = 'normal'}) {
    final stopwatch = Stopwatch()..start();
    final state = GameState.initial(
      teamName: 'Bot Dynasty',
      ownerName: 'Sim Manager',
      primaryColorHex: '#1B2A49',
      secondaryColorHex: '#F5B700',
      emblemSymbol: 'lightning',
      emblemLetters: 'BD',
      difficulty: difficulty,
    );

    // Initial squad fill to 5 starters
    if (state.players.length < 5) {
      state.players.add(Player(
        id: 'p_bot_tank',
        gamerTag: 'Goliath',
        realName: 'Juan Goliath',
        age: 18,
        role: PlayerRole.tank,
        aim: 38,
        reaction: 36,
        gameSense: 40,
        teamwork: 42,
        mental: 44,
        stamina: 50,
        isStarter: true,
        potentialStars: 4,
      ));
      state.players.add(Player(
        id: 'p_bot_supp',
        gamerTag: 'Oracle',
        realName: 'Pedro Oracle',
        age: 17,
        role: PlayerRole.support,
        aim: 35,
        reaction: 38,
        gameSense: 44,
        teamwork: 46,
        mental: 42,
        stamina: 48,
        isStarter: true,
        potentialStars: 4,
      ));
    }

    final yearRecords = <SimYearRecord>[];
    final yearReports = <String>[];
    bool bankrupt = false;
    int currentCircuitTier = 1;

    // 10 years = 480 weeks
    for (int week = 1; week <= 480; week++) {
      state.totalWeeksPassed = week;
      state.week = ((week - 1) % 4) + 1;
      state.month = (((week - 1) ~/ 4) % 12) + 1;
      state.year = ((week - 1) ~/ 48) + 1;

      // 1. Team Training & Conditioning
      for (final p in state.players) {
        if (p.fatigue > 55) {
          p.fatigue = max(0, p.fatigue - 25);
          p.morale = min(100, p.morale + 5);
        } else {
          // Train role primary stats
          final gain = 1 + (_rng.nextDouble() < (0.35 + state.houseTier * 0.1) ? 1 : 0);
          p.aim = min(99, p.aim + gain);
          p.reaction = min(99, p.reaction + gain);
          p.gameSense = min(99, p.gameSense + gain);
          p.teamwork = min(99, p.teamwork + gain);
          p.mental = min(99, p.mental + gain);
          p.stamina = min(99, p.stamina + gain);
          p.fatigue += 10;
        }
      }

      // 2. Tournament Circuit Progression
      final avgOvr = state.starters.isEmpty
          ? 35.0
          : state.starters.map((p) => p.ovr).reduce((a, b) => a + b) / state.starters.length;

      // Determine highest eligible tier
      if (avgOvr >= 80 && state.fame >= 4500) {
        currentCircuitTier = 7; // World Championship
      } else if (avgOvr >= 72 && state.fame >= 2800) {
        currentCircuitTier = 6; // APAC Masters
      } else if (avgOvr >= 62 && state.fame >= 1500) {
        currentCircuitTier = 5; // National Pro League
      } else if (avgOvr >= 52 && state.fame >= 600) {
        currentCircuitTier = 4; // Regional
      } else if (avgOvr >= 44 && state.fame >= 200) {
        currentCircuitTier = 3; // Provincial
      } else if (avgOvr >= 38 && state.fame >= 50) {
        currentCircuitTier = 2; // Town League
      } else {
        currentCircuitTier = 1; // Community
      }

      // Weekly match participation & performance
      final tierWinPrize = [3000, 15000, 50000, 180000, 600000, 2000000, 8000000][currentCircuitTier - 1];
      final tierFameGain = [5, 15, 40, 100, 250, 600, 1500][currentCircuitTier - 1];
      final tierFanGain = [40, 150, 500, 1500, 5000, 18000, 60000][currentCircuitTier - 1];
      final winChance = (0.55 + ((avgOvr - (currentCircuitTier * 11)) * 0.02)).clamp(0.40, 0.90);

      if (_rng.nextDouble() < winChance) {
        state.money += (tierWinPrize * state.incomeDifficultyMultiplier).round();
        state.fame += tierFameGain;
        state.fans += tierFanGain;
        if (_rng.nextDouble() < 0.20) {
          state.trophies.add('Trophy_T$currentCircuitTier');
        }
      }

      // 3. Economy: Weekly Sponsors & Streaming
      final sponsorCount = (1 + (state.fame ~/ 800)).clamp(1, 6);
      final sponsorPerSlot = [2000, 6000, 18000, 50000, 140000, 400000, 1200000][currentCircuitTier - 1];
      final weeklySponsorIncome = sponsorCount * sponsorPerSlot;
      final weeklyStreamIncome = (state.fans * 0.08).round() + 500;
      state.money += ((weeklySponsorIncome + weeklyStreamIncome) * state.incomeDifficultyMultiplier).round();

      // Expenses: Salaries & Rent
      final playerSalaries = state.players.map((p) => p.weeklySalary).fold(0, (a, b) => a + b);
      final staffSalaries = state.staff.map((s) => s.salary).fold(0, (a, b) => a + b);
      final weeklyRent = [500, 2000, 7500, 37500, 200000][state.houseTier];
      state.money -= (playerSalaries + staffSalaries + weeklyRent);

      // 4. House & Base Infrastructure Upgrades
      if (state.houseTier < 4) {
        final houseCosts = [80000, 400000, 3000000, 20000000];
        final fameReqs = [100, 500, 2500, 9000];
        final tierReqs = [2, 3, 5, 6];
        final cost = houseCosts[state.houseTier];
        final reqFame = fameReqs[state.houseTier];
        final reqTier = tierReqs[state.houseTier];

        if (state.money > cost * 2.0 && state.fame >= reqFame && currentCircuitTier >= reqTier) {
          state.money -= cost;
          state.houseTier++;
        }
      }

      // 5. Staff Recruitment
      if (state.staff.length < state.maxStaffSlots) {
        if (state.staff.isEmpty && state.money > 20000) {
          state.staff.add(StaffMember(id: 'coach', name: 'Coach Al', role: StaffRole.coach, level: 1, salary: 500));
        } else if (state.staff.length == 1 && state.money > 60000) {
          state.staff.add(StaffMember(id: 'analyst', name: 'Analyst Rex', role: StaffRole.analyst, level: 1, salary: 600));
        } else if (state.staff.length == 2 && state.money > 150000) {
          state.staff.add(StaffMember(id: 'manager', name: 'Manager Liza', role: StaffRole.manager, level: 1, salary: 700));
        }
      }

      // Multi-Division Expansion (Phase 8)
      if (state.fame >= 200 && !state.isDivisionUnlocked('strike_zone')) {
        state.unlockDivision('strike_zone');
      }
      if (state.fame >= 500 && !state.isDivisionUnlocked('last_island')) {
        state.unlockDivision('last_island');
      }

      // 6. Bankruptcy Check
      if (state.money < -50000) {
        bankrupt = true;
        yearReports.add('Bankrupt at Week $week!');
        break;
      }

      // End of Year (every 48 weeks)
      if (week % 48 == 0) {
        final y = week ~/ 48;
        final record = SimYearRecord(
          year: y,
          money: state.money,
          fame: state.fame,
          fans: state.fans,
          houseTier: state.houseTier,
          highestTier: currentCircuitTier,
          avgOvr: avgOvr,
          rosterSize: state.players.length,
          divisionsCount: state.unlockedDivisions.length,
        );
        yearRecords.add(record);
        yearReports.add(record.formattedLine);
      }
    }

    stopwatch.stop();

    // Final Year 10 Evaluation
    final evaluation = LegacyService().evaluateYear10(state);

    return SimResult(
      yearRecords: yearRecords,
      yearReports: yearReports,
      bankrupt: bankrupt,
      finalMoney: state.money,
      finalFame: state.fame,
      finalFans: state.fans,
      durationMs: stopwatch.elapsedMilliseconds,
      evaluation: evaluation,
    );
  }
}
