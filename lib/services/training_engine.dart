import '../models/game_state.dart';
import '../models/player.dart';
import '../models/weekly_plan.dart';
import '../models/staff.dart';

class TrainingResult {
  final Map<String, int> statIncreases; // playerId -> amount
  final Map<String, int> fatigueChanges;
  final Map<String, int> moraleChanges;
  final List<String> logMessages;

  TrainingResult({
    required this.statIncreases,
    required this.fatigueChanges,
    required this.moraleChanges,
    required this.logMessages,
  });
}

class TrainingEngine {
  static TrainingResult processWeek(GameState state) {
    final statIncreases = <String, int>{};
    final fatigueChanges = <String, int>{};
    final moraleChanges = <String, int>{};
    final logMessages = <String>[];

    // 1. Staff bonuses
    final coach = state.staff.where((s) => s.role == StaffRole.coach).firstOrNull;
    final coachMult = coach != null ? 1.0 + (coach.level * 0.06) : 1.0;

    final cook = state.staff.where((s) => s.role == StaffRole.cook).firstOrNull;
    final cookFatigueRecoveryMult = cook != null ? 1.0 + (cook.level * 0.08) : 1.0;

    // 2. Station capacity checks
    final pcCount = state.pcDeskCapacity;
    int pcUsers = 0;

    // Best desk multiplier
    double bestDeskMult = 1.0;
    if (state.furniture.any((f) => f.itemId == 'elite_desk')) {
      bestDeskMult = 1.5;
    } else if (state.furniture.any((f) => f.itemId == 'pro_desk')) {
      bestDeskMult = 1.25;
    }

    // Chair fatigue discount
    double chairFatigueMult = 1.0;
    if (state.furniture.any((f) => f.itemId == 'ergo_chair')) {
      chairFatigueMult = 0.80;
    } else if (state.furniture.any((f) => f.itemId == 'gaming_chair')) {
      chairFatigueMult = 0.90;
    }

    // Kitchen & Comfort morale bonuses
    int mealMoraleBonus = 0;
    if (state.kitchenCount > 0) {
      mealMoraleBonus = 4;
      if (state.hasKainanCombo) mealMoraleBonus += 3; // COMBO Kainan
      if (cook != null) mealMoraleBonus += cook.level;
    }

    // Process each player
    for (final p in state.players) {
      final act = state.currentPlan.playerActivities[p.id] ?? PlayerActivity.trainAim;

      // Check station bottleneck
      final reqStation = WeeklyPlan.requiredStation(act);
      double stationMult = 1.0;
      if (reqStation == 'pc') {
        pcUsers++;
        if (pcUsers > pcCount) {
          stationMult = 0.70; // -30% penalty if queued
          logMessages.add('${p.gamerTag} queued for PC Desk (-30% gain).');
        }
      }

      // Trait multipliers
      double traitMult = 1.0;
      double traitFatigueMult = 1.0;
      if (p.traits.contains('Workaholic')) {
        traitMult *= 1.20;
        traitFatigueMult *= 1.20;
      }
      if (p.traits.contains('Lazy Genius')) {
        traitMult *= 0.80;
      }
      if (p.traits.contains('Prodigy') && p.age <= 20) {
        traitMult *= 1.10;
      }
      if (p.age < 20) {
        traitMult *= 1.20; // Under 20 trains +20% faster
      }

      // Condition multiplier
      double condMult = 1.0;
      switch (p.condition) {
        case PlayerCondition.great: condMult = 1.25; break;
        case PlayerCondition.good: condMult = 1.10; break;
        case PlayerCondition.normal: condMult = 1.00; break;
        case PlayerCondition.tired: condMult = 0.75; break;
        case PlayerCondition.exhausted: condMult = 0.40; break;
      }

      // Team focus multiplier
      double focusTrainMult = 1.0;
      double focusFatigueMult = 1.0;
      switch (state.currentPlan.focus) {
        case TeamFocus.bootcamp:
          focusTrainMult = 1.50;
          focusFatigueMult = 1.60;
          break;
        case TeamFocus.restWeek:
          focusTrainMult = 0.0;
          focusFatigueMult = 0.50;
          break;
        default:
          break;
      }

      // Calculate Training Gain
      String? trainedStatKey;
      switch (act) {
        case PlayerActivity.trainAim: trainedStatKey = 'aim'; break;
        case PlayerActivity.trainReaction: trainedStatKey = 'reaction'; break;
        case PlayerActivity.trainGameSense: trainedStatKey = 'gameSense'; break;
        case PlayerActivity.trainTeamwork: trainedStatKey = 'teamwork'; break;
        case PlayerActivity.trainMental: trainedStatKey = 'mental'; break;
        case PlayerActivity.trainStamina: trainedStatKey = 'stamina'; break;
        default: trainedStatKey = null; break;
      }

      if (trainedStatKey != null && focusTrainMult > 0) {
        final currentStat = _getStatValue(p, trainedStatKey);
        final cap = p.getStatCap(trainedStatKey);

        if (currentStat < cap) {
          // Formula: 2.0 x coach x desk x trait x (0.5 + 0.5 x (1 - stat/cap)) x condition
          final capDiminishing = 0.5 + (0.5 * (1.0 - (currentStat / cap.toDouble())));
          final totalGain = 2.0 * coachMult * bestDeskMult * traitMult * capDiminishing * condMult * stationMult * focusTrainMult;

          // Fraction carry-over
          final oldCarry = p.trainingCarry[trainedStatKey] ?? 0.0;
          final sum = oldCarry + totalGain;
          final intGain = sum.floor();
          p.trainingCarry[trainedStatKey] = sum - intGain;

          _addStatValue(p, trainedStatKey, intGain, cap);
          statIncreases[p.id] = intGain;
        }
      }

      // Scrim role mastery gain (Combo bonus: Scrim Room gives +1 extra mastery)
      if (act == PlayerActivity.scrim || act == PlayerActivity.studyRole) {
        final currentMastery = p.roleMastery[p.role.name] ?? 50;
        final gain = state.hasScrimRoomCombo ? 3 : 2;
        if (currentMastery < 100) {
          p.roleMastery[p.role.name] = (currentMastery + gain).clamp(0, 100);
        }
      }

      // Fatigue calculation
      int baseFatigue = WeeklyPlan.baseFatigueChange(act);
      int fatigueDelta;
      if (baseFatigue > 0) {
        fatigueDelta = (baseFatigue * traitFatigueMult * chairFatigueMult * focusFatigueMult).round();
      } else {
        fatigueDelta = (baseFatigue * cookFatigueRecoveryMult).round();
      }
      p.fatigue = (p.fatigue + fatigueDelta).clamp(0, 100);
      fatigueChanges[p.id] = fatigueDelta;

      // Morale calculation (Comfort rating + Psychologist bonus)
      int moraleDelta = mealMoraleBonus + (state.comfortRating - 1);
      if (state.psychologist != null) {
        moraleDelta += state.psychologist!.level;
      }
      if (act == PlayerActivity.rest || act == PlayerActivity.freeTime) {
        moraleDelta += 3;
      }
      if (p.fatigue >= 70) {
        moraleDelta -= 5; // Overwork penalty
      }
      p.morale = (p.morale + moraleDelta).clamp(0, 100);
      moraleChanges[p.id] = moraleDelta;
    }

    return TrainingResult(
      statIncreases: statIncreases,
      fatigueChanges: fatigueChanges,
      moraleChanges: moraleChanges,
      logMessages: logMessages,
    );
  }

  static int _getStatValue(Player p, String key) {
    switch (key) {
      case 'aim': return p.aim;
      case 'reaction': return p.reaction;
      case 'gameSense': return p.gameSense;
      case 'teamwork': return p.teamwork;
      case 'mental': return p.mental;
      case 'stamina': return p.stamina;
      default: return 0;
    }
  }

  static void _addStatValue(Player p, String key, int add, int cap) {
    switch (key) {
      case 'aim': p.aim = (p.aim + add).clamp(0, cap); break;
      case 'reaction': p.reaction = (p.reaction + add).clamp(0, cap); break;
      case 'gameSense': p.gameSense = (p.gameSense + add).clamp(0, cap); break;
      case 'teamwork': p.teamwork = (p.teamwork + add).clamp(0, cap); break;
      case 'mental': p.mental = (p.mental + add).clamp(0, cap); break;
      case 'stamina': p.stamina = (p.stamina + add).clamp(0, cap); break;
    }
  }
}
