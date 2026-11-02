import 'dart:math';
import '../models/game_state.dart';
import '../models/player.dart';
import 'scouting_service.dart';

/// Academy engine producing young prospects every 12 weeks for tier 3+ houses
class AcademyService {
  static final AcademyService _instance = AcademyService._internal();
  factory AcademyService() => _instance;
  AcademyService._internal();

  final Random _rng = Random();

  Player? checkAcademyProspect(GameState state) {
    if (!state.isAcademyUnlocked) return null;

    // Check if 12 weeks have passed since last prospect (or first time)
    if (state.lastAcademyWeek > 0 && state.totalWeeksPassed - state.lastAcademyWeek < 12) return null;

    state.lastAcademyWeek = state.totalWeeksPassed;

    // Generate 16-17 year old rookie prodigy
    final p = ScoutingService().generateCandidate(minOvr: 38, maxOvr: 55);
    p.age = 16 + _rng.nextInt(2);
    p.potentialStars = 3 + _rng.nextInt(3); // 3 to 5 stars
    p.isPotentialRevealed = true;
    p.isStarter = false;

    if (!p.traits.contains('Prodigy') && p.potentialStars >= 4 && _rng.nextBool()) {
      p.traits.add('Prodigy');
    }

    state.addNotification('Academy Prospect Ready: ${p.gamerTag}!', '#3DBE5A', 0.5, 0.4);
    return p;
  }

  bool enrollProspect(Player p, GameState state) {
    if (state.players.length >= state.maxRosterCap) return false;
    p.isStarter = false;
    state.players.add(p);
    state.addNotification('Enrolled ${p.gamerTag} into Roster!', '#3DBE5A', 0.5, 0.4);
    return true;
  }
}
