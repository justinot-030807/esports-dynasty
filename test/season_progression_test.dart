import 'package:flutter_test/flutter_test.dart';
import 'package:esports_dynasty/models/game_state.dart';
import 'package:esports_dynasty/services/data_service.dart';
import 'package:esports_dynasty/services/tournament_service.dart';
import 'package:esports_dynasty/services/finance_service.dart';
import 'package:esports_dynasty/services/training_engine.dart';
import 'package:esports_dynasty/services/transfer_service.dart';
import 'package:esports_dynasty/services/event_service.dart';
import 'package:esports_dynasty/services/achievement_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('Simulate 52 weeks day by day and catch freeze or error', () async {
    await DataService().loadAllData();
    final state = GameState.initial(
      teamName: 'Test Squad',
      ownerName: 'Boss',
      primaryColorHex: '#000000',
      secondaryColorHex: '#FFFFFF',
      emblemSymbol: 'lightning',
      emblemLetters: 'TS',
    );
    TournamentService.initializeTournaments(state);

    for (int dayIndex = 1; dayIndex <= 52 * 7; dayIndex++) {
      final oldWeek = state.week;
      final oldMonth = state.month;
      state.advanceDay();

      // Day 2
      if (state.day == 2) {
        EventService().checkForWeeklyEvent(state);
      }
      // Day 3
      if (state.day == 3 && state.isTransferWindowOpen) {
        TransferService().checkForAiPoachOffer(state);
      }
      // Day 5
      if (state.day == 5) {
        final match = TournamentService.getScheduledUserMatch(state);
        if (match != null && !match.isPlayed) {
          // auto play user match if any
          match.isPlayed = true;
          match.winnerId = match.slotA.teamId;
        }
      }

      if (state.week != oldWeek) {
        TrainingEngine.processWeek(state);
        FinanceService.processWeeklyFinances(state);
        TournamentService.processWeeklyTournaments(state);
        TransferService().tickWeeklyContracts(state);
        EventService().tickWeeklyCooldowns(state);
        AchievementService().checkMilestones(state);
      }

      if (state.month != oldMonth) {
        // Month end
      }
    }
  });
}
