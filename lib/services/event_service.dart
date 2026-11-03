import 'dart:math';
import '../models/game_state.dart';
import '../models/game_event.dart';
import 'data_service.dart';

/// Handles 40+ random and narrative events
class EventService {
  static final EventService _instance = EventService._internal();
  factory EventService() => _instance;
  EventService._internal();

  final Random _rng = Random();

  NarrativeEvent? checkForWeeklyEvent(GameState state) {
    // Only check once per week (e.g. Day 2)
    if (state.day != 2) return null;

    // Grace period: No disruptive random events during Month 1 (Weeks 1 to 4) onboarding
    if (state.weekOfYear <= 4) return null;

    // Global cooldown: Ensure at least 4 weeks breathing room between narrative events
    final lastWeek = state.storyFlags['last_event_week'] as int? ?? -99;
    if (state.weekOfYear - lastWeek < 4) return null;

    // 20% chance of an event per eligible week (~once every 5-8 weeks)
    if (_rng.nextDouble() > 0.20) return null;

    final events = DataService().narrativeEvents;
    if (events.isEmpty) return null;

    final eligible = events.where((evt) => _isEventEligible(evt, state)).toList();
    if (eligible.isEmpty) return null;

    eligible.shuffle(_rng);
    return eligible.first;
  }

  bool _isEventEligible(NarrativeEvent evt, GameState state) {
    // Check cooldown
    final cd = state.eventCooldowns[evt.id] ?? 0;
    if (cd > 0) return false;

    // Check event-level condition
    if (evt.condition != null) {
      if (!_evaluateCondition(evt.condition!, state)) return false;
    }

    return true;
  }

  bool _evaluateCondition(String cond, GameState state) {
    if (cond.startsWith('flag:')) {
      final flagKey = cond.substring(5);
      return state.storyFlags[flagKey] == true;
    }
    switch (cond) {
      case 'has_generator':
        return state.hasGenerator;
      case 'has_router':
        return state.hasRouter;
      case 'has_aircon':
        return state.hasAircon;
      case 'has_cook':
        return state.hasCook;
      case 'has_psychologist':
        return state.hasPsychologist;
      case 'has_manager':
        return state.hasManager;
      case 'has_analyst':
        return state.hasAnalyst;
      case 'has_coach':
        return state.hasHeadCoach;
      default:
        return true;
    }
  }

  bool isChoiceAvailable(EventChoice choice, GameState state) {
    if (choice.cost > 0 && state.money < choice.cost) return false;
    if (choice.condition != null) {
      return _evaluateCondition(choice.condition!, state);
    }
    return true;
  }

  String applyEventChoice(NarrativeEvent event, EventChoice choice, GameState state) {
    // Record event occurrence week for global cooldown pacing
    state.storyFlags['last_event_week'] = state.weekOfYear;

    // Set 12-week cooldown on event
    state.eventCooldowns[event.id] = 12;

    // Deduct cost
    if (choice.cost > 0) {
      state.money = max(0, state.money - choice.cost);
      state.monthExpenses += choice.cost;
    }

    final out = choice.outcome;
    if (out.money > 0) {
      final finalMoney = (out.money * state.incomeDifficultyMultiplier).round();
      state.money += finalMoney;
      state.monthIncome += finalMoney;
      state.addNotification('+P$finalMoney', '#3DBE5A', 0.5, 0.4);
    }

    if (out.fame != 0) {
      state.fame = max(0, state.fame + out.fame);
      state.addNotification('${out.fame > 0 ? "+" : ""}${out.fame} Fame', '#9B5DE5', 0.5, 0.45);
    }

    if (out.fans != 0) {
      state.fans = max(0, state.fans + out.fans);
      state.progressSponsors('gain_fans', out.fans > 0 ? out.fans : 0);
      state.addNotification('${out.fans > 0 ? "+" : ""}${out.fans} Fans', '#FF6FA5', 0.5, 0.5);
    }

    // Apply player morale / fatigue
    for (final p in state.players) {
      if (out.morale != 0) {
        p.morale = (p.morale + out.morale).clamp(0, 100);
      }
      if (out.fatigue != 0) {
        p.fatigue = (p.fatigue + out.fatigue).clamp(0, 100);
      }
    }

    if (out.flag != null) {
      state.storyFlags[out.flag!] = true;
    }

    return out.text.isNotEmpty ? out.text : 'Naganap ang desisyon!';
  }

  void tickWeeklyCooldowns(GameState state) {
    final keys = state.eventCooldowns.keys.toList();
    for (final k in keys) {
      final cur = state.eventCooldowns[k] ?? 0;
      if (cur <= 1) {
        state.eventCooldowns.remove(k);
      } else {
        state.eventCooldowns[k] = cur - 1;
      }
    }
  }
}
