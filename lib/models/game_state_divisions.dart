import 'game_state.dart';
import 'player.dart';
import 'division.dart';

extension GameStateDivisions on GameState {
  /// Currently selected division model
  EsportsDivision get activeDivision => EsportsDivision.getById(activeDivisionId);

  /// All players belonging to the currently active division
  List<Player> get activeDivisionPlayers => getPlayersForDivision(activeDivisionId);

  /// All active starters for the currently active division
  List<Player> get activeDivisionStarters => getStartersForDivision(activeDivisionId);

  /// Get players by division ID
  List<Player> getPlayersForDivision(String divId) {
    return players.where((p) => p.divisionId == divId).toList();
  }

  /// Get active starters by division ID
  List<Player> getStartersForDivision(String divId) {
    return players.where((p) => p.divisionId == divId && p.isStarter).toList();
  }

  /// Whether a division is unlocked
  bool isDivisionUnlocked(String divId) {
    if (divId == 'arena_clash') return true;
    return unlockedDivisions.contains(divId);
  }

  /// Unlock a division
  void unlockDivision(String divId) {
    if (!unlockedDivisions.contains(divId)) {
      unlockedDivisions.add(divId);
    }
  }

  /// Switch active division
  void setActiveDivision(String divId) {
    if (isDivisionUnlocked(divId)) {
      activeDivisionId = divId;
    }
  }

  /// Get circuit points for a specific division
  int getDivisionCircuitPoints(String divId) {
    return divisionCircuitPoints[divId] ?? (divId == 'arena_clash' ? circuitPoints : 0);
  }

  /// Award circuit points to a specific division
  void addDivisionCircuitPoints(String divId, int pts) {
    final current = getDivisionCircuitPoints(divId);
    divisionCircuitPoints[divId] = current + pts;
    if (divId == 'arena_clash') {
      circuitPoints += pts;
    }
  }
}
