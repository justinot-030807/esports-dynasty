import 'dart:math';
import '../models/game_state.dart';
import '../models/player.dart';
import '../models/division.dart';

class DivisionService {
  static final Random _rng = Random();

  /// Check if user can unlock a division
  static bool canUnlockDivision(GameState state, EsportsDivision division) {
    if (state.isDivisionUnlocked(division.id)) return false;
    return state.fame >= division.minFame && state.money >= division.unlockCost;
  }

  /// Unlock a division, deduct fees, and initialize starter roster
  static bool unlockDivision(GameState state, String divisionId) {
    final div = EsportsDivision.getById(divisionId);
    if (!canUnlockDivision(state, div)) return false;

    state.money -= div.unlockCost;
    state.monthExpenses += div.unlockCost;
    state.unlockDivision(divisionId);
    state.setActiveDivision(divisionId);

    // Auto-sign starter squad
    autoSignStarterRosterIfEmpty(state, divisionId);

    state.addNotification('EXPANSION: ${div.name.toUpperCase()} SQUAD FORMED!', '#3DBE5A', 0.5, 0.4);
    return true;
  }

  /// Generate starter roster for a new division
  static List<Player> generateStarterRoster(GameState state, String divisionId) {
    final div = EsportsDivision.getById(divisionId);
    final starters = <Player>[];

    final szTags = ['Asintado', 'Bala', 'Puntirya', 'Silip', 'Kuta'];
    final szNames = [
      'Mark Reyes', 'Paolo Santos', 'Carlo Bautista', 'Neil Mendoza', 'Dexter Aquino'
    ];

    final liTags = ['Parakayod', 'Bumagsak', 'Pulo', 'Gamot'];
    final liNames = [
      'Joshua Castillo', 'Angelo Navarro', 'Tristan Perez', 'Kiko Salazar'
    ];

    for (int i = 0; i < div.roles.length; i++) {
      final role = div.roles[i];
      final tag = divisionId == 'strike_zone'
          ? (i < szTags.length ? szTags[i] : 'Fragger$i')
          : (i < liTags.length ? liTags[i] : 'Survivor$i');
      final realName = divisionId == 'strike_zone'
          ? (i < szNames.length ? szNames[i] : 'Juan Dela Cruz')
          : (i < liNames.length ? liNames[i] : 'Pedro Penduko');

      final baseStat = 32 + _rng.nextInt(12);

      starters.add(Player(
        id: 'p_${divisionId}_${DateTime.now().microsecondsSinceEpoch}_$i',
        realName: realName,
        gamerTag: tag,
        role: role,
        divisionId: divisionId,
        age: 17 + _rng.nextInt(4),
        aim: (baseStat + _rng.nextInt(8) - 4).clamp(25, 60),
        reaction: (baseStat + _rng.nextInt(8) - 4).clamp(25, 60),
        gameSense: (baseStat + _rng.nextInt(8) - 4).clamp(25, 60),
        teamwork: (baseStat + _rng.nextInt(8) - 4).clamp(25, 60),
        mental: (baseStat + _rng.nextInt(8) - 4).clamp(25, 60),
        stamina: (baseStat + _rng.nextInt(8) - 4).clamp(25, 60),
        fatigue: 10,
        morale: 75,
        potentialStars: 2 + _rng.nextInt(3),
        isStarter: true,
        jerseyColorHex: state.primaryColorHex,
        hairColorHex: ['#1B2A49', '#4A3728', '#0F172A'][_rng.nextInt(3)],
        skinColorHex: ['#E0AC69', '#C68642', '#8D5524'][_rng.nextInt(3)],
      ));
    }

    return starters;
  }

  /// Automatically sign starting players if division has no roster
  static void autoSignStarterRosterIfEmpty(GameState state, String divisionId) {
    final existing = state.getPlayersForDivision(divisionId);
    if (existing.isEmpty) {
      final newRoster = generateStarterRoster(state, divisionId);
      state.players.addAll(newRoster);
    }
  }

  /// Get summary stats for a division
  static Map<String, dynamic> getDivisionStats(GameState state, String divisionId) {
    final players = state.getPlayersForDivision(divisionId);
    final starters = state.getStartersForDivision(divisionId);
    final avgOvr = starters.isNotEmpty
        ? (starters.map((p) => p.ovr).reduce((a, b) => a + b) ~/ starters.length)
        : (players.isNotEmpty ? (players.map((p) => p.ovr).reduce((a, b) => a + b) ~/ players.length) : 0);

    final titles = state.tournamentInstances
        .where((t) => t.division == divisionId && t.championId == 'user_team')
        .length;

    return {
      'totalPlayers': players.length,
      'startersCount': starters.length,
      'avgOvr': avgOvr,
      'circuitPoints': state.getDivisionCircuitPoints(divisionId),
      'titlesWon': titles,
    };
  }
}
