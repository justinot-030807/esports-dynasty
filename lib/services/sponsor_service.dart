import 'dart:math';
import '../models/game_state.dart';
import '../models/sponsor.dart';
import 'data_service.dart';

/// Manages sponsor contracts, weekly payouts, goals, and renewals
class SponsorService {
  static final SponsorService _instance = SponsorService._internal();
  factory SponsorService() => _instance;
  SponsorService._internal();

  List<SponsorDef> getAvailableOffers(GameState state) {
    final all = DataService().sponsors;
    final activeIds = state.activeSponsors.map((s) => s.id).toSet();

    // Filter by fame requirement and not currently active
    final eligible = all.where((s) {
      if (activeIds.contains(s.id)) return false;
      if (s.id == 'bailout_fund') return state.money < 0;
      return state.fame >= s.minFame;
    }).toList();

    eligible.sort((a, b) => b.tier.compareTo(a.tier));
    return eligible.take(4).toList();
  }

  bool signSponsor(SponsorDef def, GameState state) {
    if (state.activeSponsors.length >= state.maxSponsorSlots) return false;
    state.activeSponsors.add(ActiveSponsor.fromDef(def));
    state.addNotification('Signed: ${def.name}', '#3DBE5A', 0.5, 0.4);
    return true;
  }

  bool claimBonus(ActiveSponsor sp, GameState state) {
    if (!sp.isCompleted || sp.isBonusClaimed) return false;
    final bonus = (sp.bonusPay * state.incomeDifficultyMultiplier).round();
    state.money += bonus;
    state.monthIncome += bonus;
    sp.isBonusClaimed = true;
    state.addNotification('+P$bonus Bonus!', '#F5B700', 0.5, 0.4);
    return true;
  }

  void tickWeeklySponsors(GameState state) {
    final managerBonus = 1.0 + ((state.manager?.level ?? 0) * 0.08);
    int totalPayout = 0;

    final expired = <ActiveSponsor>[];

    for (final sp in state.activeSponsors) {
      final weekly = (sp.weeklyPay * managerBonus * state.incomeDifficultyMultiplier).round();
      totalPayout += weekly;

      final isDone = sp.tickWeek();
      if (isDone) {
        expired.add(sp);
      }
    }

    if (totalPayout > 0) {
      state.money += totalPayout;
      state.monthIncome += totalPayout;
      state.addNotification('+P$totalPayout Sponsors', '#3DBE5A', 0.5, 0.35);
    }

    // Process expired sponsors
    for (final exp in expired) {
      if (!exp.isCompleted) {
        state.fame = max(0, state.fame - 15);
        state.addNotification('Contract Ended: ${exp.name} (-15 Fame)', '#E5484D', 0.5, 0.45);
      } else {
        if (!exp.isBonusClaimed) {
          claimBonus(exp, state);
        }
        state.addNotification('Contract Completed: ${exp.name}!', '#3DBE5A', 0.5, 0.45);
      }
      state.activeSponsors.remove(exp);
    }
  }
}
