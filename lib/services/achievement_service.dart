import '../models/game_state.dart';
import '../models/achievement.dart';
import 'data_service.dart';

/// Evaluates and tracks player achievements
class AchievementService {
  static final AchievementService _instance = AchievementService._internal();
  factory AchievementService() => _instance;
  AchievementService._internal();

  List<AchievementDef> checkMilestones(GameState state) {
    final defs = DataService().achievements.isNotEmpty
        ? DataService().achievements
        : _fallbackDefs;
    final newlyUnlocked = <AchievementDef>[];

    for (final ach in defs) {
      if (state.unlockedAchievements.contains(ach.id)) continue;

      if (_isAchieved(ach.id, state)) {
        state.unlockedAchievements.add(ach.id);
        newlyUnlocked.add(ach);
        state.addNotification('Trophy Unlocked: ${ach.title}!', '#F5B700', 0.5, 0.4);
      }
    }

    return newlyUnlocked;
  }

  bool _isAchieved(String id, GameState state) {
    switch (id) {
      case 'first_win':
        return state.tournamentInstances.any((t) =>
            t.matches.any((m) => m.isPlayed && m.winnerId == 'user_team'));
      case 't1_champion':
        return state.trophies.any((t) => t.contains('t1'));
      case 't2_champion':
        return state.trophies.any((t) => t.contains('t2'));
      case 't3_champion':
        return state.trophies.any((t) => t.contains('t3'));
      case 't4_champion':
        return state.trophies.any((t) => t.contains('t4'));
      case 't5_champion':
        return state.trophies.any((t) => t.contains('t5'));
      case 't6_champion':
        return state.trophies.any((t) => t.contains('t6'));
      case 't7_champion':
        return state.trophies.any((t) => t.contains('t7'));
      case 'flawless_sweep':
        return state.tournamentInstances.any((t) => t.matches.any(
            (m) => m.isPlayed && m.winnerId == 'user_team' && m.loserScore == 0 && m.winnerScore >= 2));
      case 'rival_slayer':
        return state.tournamentInstances.any((t) => t.matches.any((m) =>
            m.isPlayed && m.winnerId == 'user_team' && (m.teamAId.startsWith('RIV_') || m.teamBId.startsWith('RIV_'))));
      case 'house_apartment':
        return state.houseTier >= 1;
      case 'house_small_house':
        return state.houseTier >= 2;
      case 'house_pro_mansion':
        return state.houseTier >= 3;
      case 'house_esports_hq':
        return state.houseTier >= 4;
      case 'combo_scrim_room':
        return state.hasScrimRoomCombo;
      case 'combo_kainan':
        return state.hasKainanCombo;
      case 'comfort_5_stars':
        return state.comfortRating >= 5;
      case 'generator_installed':
        return state.hasGenerator;
      case 'scout_prodigy':
        return state.players.any((p) => p.potentialStars >= 5);
      case 'roster_full_five':
        return state.starters.length >= 5;
      case 'legend_developed':
        return state.players.any((p) => p.ovr >= 92);
      case 'academy_graduate':
        return state.subs.isNotEmpty;
      case 'chemistry_max':
        return state.chemistry >= 85;
      case 'perfect_chemistry':
        return state.chemistry >= 90;
      case 'season_awards_mvp':
        return state.trophies.any((t) => t.toLowerCase().contains('mvp')) ||
            state.hallOfFame.any((h) => h.category.toLowerCase().contains('mvp'));
      case 'season_awards_toty':
        return state.trophies.any((t) => t.toLowerCase().contains('team of the year') || t.contains('toty'));
      case 'transfer_poach':
        return state.storyFlags['poached_player'] == true;
      case 'retirement_ceremony':
        return state.storyFlags['retired_legend'] == true ||
            state.hallOfFame.any((h) => h.category == 'Retired Legend');
      case 'coach_transition':
        return state.storyFlags['converted_coach'] == true ||
            state.staff.any((s) => s.id.contains('retire'));
      case 'bailout_survivor':
        return state.storyFlags['survived_bankruptcy'] == true;
      case 'multi_division_champ':
        return state.unlockedDivisions.length >= 2 && state.trophies.length >= 2;
      case 'streak_5':
        return state.consecutiveWins >= 5;
      case 'streak_10':
        return state.consecutiveWins >= 10;
      case 'millionaire_club':
        return state.money >= 5000000;
      case 'fanatic_army':
        return state.fans >= 50000;
      case 'super_house':
        return state.houseTier >= 4;
      case 'scrim_master':
        return state.hasScrimRoomCombo && state.totalWeeksPassed >= 20;
      case 'combo_chill_lounge':
        return state.hasChillLoungeCombo;
      case 'fans_500':
        return state.fans >= 500;
      case 'fans_2500':
        return state.fans >= 2500;
      case 'fans_10000':
        return state.fans >= 10000;
      case 'fans_100000':
        return state.fans >= 100000;
      case 'money_100k':
        return state.money >= 100000;
      case 'money_1m':
        return state.money >= 1000000;
      case 'money_10m':
        return state.money >= 10000000;
      case 'sponsor_signed':
        return state.activeSponsors.isNotEmpty;
      case 'sponsor_goal_met':
        return state.activeSponsors.any((s) => s.isCompleted);
      case 'staff_level_5':
        return state.staff.any((s) => s.level >= 5);
      case 'hall_of_fame_entry':
        return state.hallOfFame.isNotEmpty;
      case 'decade_dynasty':
        return state.totalWeeksPassed >= 480;
      default:
        return false;
    }
  }

  bool claimReward(AchievementDef def, GameState state) {
    if (state.claimedAchievements.contains(def.id)) return false;
    if (!state.unlockedAchievements.contains(def.id)) return false;

    state.claimedAchievements.add(def.id);

    if (def.rewardMoney > 0) {
      final m = (def.rewardMoney * state.incomeDifficultyMultiplier).round();
      state.money += m;
      state.monthIncome += m;
    }
    if (def.rewardFame > 0) {
      state.fame += def.rewardFame;
    }
    if (def.rewardFans > 0) {
      state.fans += def.rewardFans;
    }

    state.addNotification('Claimed: ${def.title}', '#3DBE5A', 0.5, 0.4);
    return true;
  }

  static const List<AchievementDef> _fallbackDefs = [
    AchievementDef(id: 'roster_full_five', title: 'Full Roster', desc: '5 starters', rewardMoney: 5000),
    AchievementDef(id: 'money_100k', title: '100k', desc: 'P100k bank', rewardMoney: 10000),
    AchievementDef(id: 'fans_500', title: '500 Fans', desc: '500 fans', rewardMoney: 8000),
    AchievementDef(id: 'sponsor_signed', title: 'Sponsor Signed', desc: 'Signed deal', rewardMoney: 5000),
    AchievementDef(id: 'sponsor_goal_met', title: 'Goal Met', desc: 'Completed goal', rewardMoney: 15000),
  ];
}
