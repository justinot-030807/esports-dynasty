import '../models/game_state.dart';
import '../models/finance_record.dart';
import 'sponsor_service.dart';

class FinanceService {
  static void processWeeklyFinances(GameState state) {
    // 1. Player salaries
    int totalPlayerSalary = 0;
    for (final p in state.players) {
      totalPlayerSalary += p.weeklySalary;
    }

    // 2. Staff salaries
    int totalStaffSalary = 0;
    for (final s in state.staff) {
      totalStaffSalary += s.salary;
    }

    // 3. Streaming income (P150 + Fans x 0.08 per streamer per week)
    int streamIncome = 0;
    final streamers = state.players.where(
      (p) => state.currentPlan.playerActivities[p.id] != null &&
          state.currentPlan.playerActivities[p.id].toString().contains('stream'),
    ).length;
    if (streamers > 0) {
      final perStreamer = 150 + (state.fans * 0.08).round();
      final producerBonus = 1.0 + ((state.streamProducer?.level ?? 0) * 0.10);
      streamIncome = (perStreamer * streamers * producerBonus * state.incomeDifficultyMultiplier).round();
    }

    // 4. Sponsor income
    int sponsorIncome = 0;
    if (state.activeSponsors.isNotEmpty) {
      SponsorService().tickWeeklySponsors(state);
    } else {
      sponsorIncome = (2000 + (state.fame * 1.5).round());
      sponsorIncome = (sponsorIncome * state.incomeDifficultyMultiplier).round();
      state.money += sponsorIncome;
      state.monthIncome += sponsorIncome;
    }

    // Tally weekly
    final weeklyExpenses = totalPlayerSalary + totalStaffSalary;
    final weeklyIncome = streamIncome;

    state.money += (weeklyIncome - weeklyExpenses);
    state.monthIncome += weeklyIncome;
    state.monthExpenses += weeklyExpenses;
    state.monthPlayerSalaries += totalPlayerSalary;
    state.monthStaffSalaries += totalStaffSalary;

    // 5. Bankruptcy tracking (Phase 6)
    if (state.money < 0) {
      state.consecutiveNegativeWeeks++;
    } else {
      if (state.consecutiveNegativeWeeks >= 4 && state.storyFlags['received_bailout'] == true) {
        state.storyFlags['survived_bankruptcy'] = true;
      }
      state.consecutiveNegativeWeeks = 0;
    }
  }

  static MonthlyFinanceReport generateMonthlyReport(GameState state) {
    // Apply monthly rent (Kuya Kuryente power gives 30% discount if active)
    int rent = state.monthlyRent;
    if (state.activeSponsors.any((s) => s.id == 'kuya_kuryente')) {
      rent = (rent * 0.70).round();
    }
    state.money -= rent;
    state.monthExpenses += rent;
    state.monthRent = rent;

    final netProfit = state.monthIncome - state.monthExpenses;

    final tips = [
      'Magtabi ng pondo para sa tournament entry fee sa darating na linggo!',
      'Maganda ang fan growth natin Boss! Palakasin pa ang streaming ng squad.',
      'Bawasan ang fatigue bago ang tournament para hindi mapagod ang ating carry.',
      'Sulit ang bagong gaming desk, mabilis ang pag-angat ng Aim ng squad!'
    ];
    final mikaTip = tips[(state.month - 1) % tips.length];

    final report = MonthlyFinanceReport(
      year: state.year,
      month: state.month,
      totalIncome: state.monthIncome,
      totalExpenses: state.monthExpenses,
      netProfit: netProfit,
      playerSalariesPaid: state.monthPlayerSalaries,
      staffSalariesPaid: state.monthStaffSalaries,
      rentPaid: state.monthRent,
      sponsorIncome: (state.monthIncome * 0.7).round(),
      streamIncome: (state.monthIncome * 0.3).round(),
      prizeIncome: 0,
      fansGained: 20 + (state.fame ~/ 10),
      fameGained: 4,
      mikaTip: mikaTip,
    );

    // Reset monthly trackers
    state.monthIncome = 0;
    state.monthExpenses = 0;
    state.monthPlayerSalaries = 0;
    state.monthStaffSalaries = 0;
    state.monthRent = 0;
    state.lastMonthlyReport = report;

    return report;
  }
}
