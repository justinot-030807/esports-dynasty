import 'package:flutter/material.dart';
import '../../core/constants.dart';
import '../../models/game_state.dart';
import '../../models/tournament.dart';
import '../../models/ai_team.dart';
import '../../models/division.dart';
import '../../services/sim_service.dart';
import '../../services/data_service.dart';
import '../../services/tournament_service.dart';
import '../../services/legacy_service.dart';
import '../../services/audio_manager.dart';
import '../../services/division_service.dart';
import '../widgets/pixel_panel.dart';
import '../widgets/pixel_button.dart';
import '../screens/broadcast_match_screen.dart';
import 'event_dialog.dart';
import 'final_evaluation_dialog.dart';

class DebugMenuDialog extends StatefulWidget {
  final GameState state;
  final VoidCallback onStateUpdated;

  const DebugMenuDialog({
    super.key,
    required this.state,
    required this.onStateUpdated,
  });

  @override
  State<DebugMenuDialog> createState() => _DebugMenuDialogState();
}

class _DebugMenuDialogState extends State<DebugMenuDialog> {
  String _statusMessage = 'Hidden Debug Menu (7 Taps)';
  SimResult? _simResult;

  void _skipWeek() {
    setState(() {
      for (int i = 0; i < 7; i++) {
        widget.state.advanceDay();
      }
      TournamentService.processWeeklyTournaments(widget.state);
      widget.state.addNotification('+1 Week', '#3DBE5A', 0.5, 0.4);
      _statusMessage = 'Advanced to ${widget.state.dateString}';
    });
    widget.onStateUpdated();
  }

  void _addMoney() {
    setState(() {
      widget.state.money += 50000;
      widget.state.addNotification('+P50,000', '#F5B700', 0.5, 0.4);
      _statusMessage = 'Added P50,000 cash';
    });
    widget.onStateUpdated();
  }

  void _addFame() {
    setState(() {
      widget.state.fame += 500;
      widget.state.fans += 1000;
      widget.state.addNotification('+500 Fame!', '#9B5DE5', 0.5, 0.4);
      _statusMessage = 'Added 500 Fame & 1,000 Fans';
    });
    widget.onStateUpdated();
  }

  void _unlockAllTiers() {
    setState(() {
      widget.state.fame = max(widget.state.fame, 12000);
      widget.state.houseTier = 4;
      widget.state.addNotification('All Tiers Unlocked!', '#F5B700', 0.5, 0.4);
      _statusMessage = 'All 7 tiers & House Tier 5 unlocked!';
    });
    widget.onStateUpdated();
  }

  void _unlockAllFurniture() {
    setState(() {
      widget.state.money += 1000000;
      widget.state.addNotification('All Furniture Available!', '#3DBE5A', 0.5, 0.4);
      _statusMessage = 'All furniture items accessible!';
    });
    widget.onStateUpdated();
  }

  void _forceEvent() {
    final events = DataService().narrativeEvents;
    if (events.isNotEmpty) {
      final evt = events.first;
      Navigator.pop(context);
      showDialog(
        context: context,
        builder: (_) => EventDialog(
          state: widget.state,
          event: evt,
          onDismissed: () {
            widget.onStateUpdated();
          },
        ),
      );
    }
  }

  void _jumpToNextMatchDay() {
    setState(() {
      while (widget.state.day != 5) {
        widget.state.advanceDay();
      }
      TournamentService.processWeeklyTournaments(widget.state);
      final match = TournamentService.getScheduledUserMatch(widget.state);
      if (match != null) {
        widget.state.addNotification('MATCH DAY: ${match.roundName}', '#E5484D', 0.5, 0.4);
        _statusMessage = 'Match Day ready: vs ${match.slotA.teamId == "user_team" ? match.slotB.teamName : match.slotA.teamName}';
      } else {
        widget.state.addNotification('Day 5 (No Match)', '#E5484D', 0.5, 0.4);
        _statusMessage = 'Jumped to Day 5 (No user match scheduled)';
      }
    });
    widget.onStateUpdated();
  }

  void _jumpToAwardsNight() {
    setState(() {
      widget.state.month = 12;
      widget.state.week = 4;
      widget.state.day = 7;
      _statusMessage = 'Jumped to W48 Day 7 (Awards Night)!';
      widget.state.addNotification('W48 D7: Awards Night', '#F5B700', 0.5, 0.4);
    });
    widget.onStateUpdated();
  }

  void _setDifficulty(String mode) {
    setState(() {
      widget.state.difficulty = mode;
      _statusMessage = 'Difficulty set to: ${mode.toUpperCase()}';
    });
    widget.onStateUpdated();
  }

  void _runHeadlessSimulation() {
    setState(() {
      _statusMessage = 'Running 10-year headless simulation...';
    });

    final res = SimService.runTenYearSimulation(difficulty: widget.state.difficulty);
    setState(() {
      _simResult = res;
      _statusMessage = '10-Year Sim finished in ${res.durationMs}ms! Rank: ${res.evaluation.rankTitle}';
    });
  }

  void _triggerYear10Evaluation() {
    final eval = LegacyService().evaluateYear10(widget.state);
    Navigator.pop(context);
    showDialog(
      context: context,
      builder: (_) => FinalEvaluationDialog(
        state: widget.state,
        evaluation: eval,
        onContinueEndless: () {
          widget.state.isEndlessMode = true;
          widget.onStateUpdated();
        },
      ),
    );
  }

  void _addLegacyPoints() {
    setState(() {
      LegacyService().globalLegacy.totalLegacyPoints += 10;
      LegacyService().saveLegacy();
      _statusMessage = 'Added +10 Legacy Points (Total: ${LegacyService().globalLegacy.totalLegacyPoints})';
    });
  }

  void _testAudioSfx() {
    AudioManager().playSfx(AudioSfx.coin);
    AudioManager().playSfx(AudioSfx.promotion);
    setState(() {
      _statusMessage = 'Played Coin & Promotion SFX!';
    });
  }

  void _unlockAllDivisions() {
    setState(() {
      for (final div in EsportsDivision.all) {
        widget.state.unlockDivision(div.id);
        DivisionService.autoSignStarterRosterIfEmpty(widget.state, div.id);
      }
      _statusMessage = 'Unlocked All Divisions (SZ + LI)!';
    });
    widget.onStateUpdated();
  }

  void _cycleDivision() {
    setState(() {
      final all = EsportsDivision.all.map((d) => d.id).toList();
      final idx = all.indexOf(widget.state.activeDivisionId);
      final next = all[(idx + 1) % all.length];
      widget.state.unlockDivision(next);
      DivisionService.autoSignStarterRosterIfEmpty(widget.state, next);
      widget.state.setActiveDivision(next);
      _statusMessage = 'Active: ${widget.state.activeDivision.name} (${widget.state.activeDivision.shortCode})';
    });
    widget.onStateUpdated();
  }

  void _launchMatchScreen({bool isTest = false}) {
    Navigator.of(context).pop();
    final opp = DataService().flagshipRivals.firstOrNull ??
        DataService().allTeams.firstOrNull ??
        AiTeam(id: 'kidlat', name: 'Kidlat Esports', tier: 1, region: 'NCR', colors: ['#1B2A49', '#F5B700'], rating: 40, captain: 'Thunder');

    final tourney = DataService().tournaments.firstOrNull ??
        TournamentDef.fromJson({
          'id': 'T1-ICC1', 'name': 'Internet Cafe Cup', 'tier': 1, 'division': widget.state.activeDivisionId,
          'weeks': [5, 7], 'registration': {'opens': -4, 'closes': -1}, 'fame': {'min': 0, 'max': 999},
          'entry_fee': 0, 'travel_cost': 0, 'slots': 8,
          'stages': [{'type': 'single_elim', 'teams': 8, 'bo': 3, 'grand_final_bo': 3}],
          'rewards': {'champion_prize': 10000, 'fame': 50, 'fans': 500, 'circuit_points': 100, 'trophy': 'trophy_t1'},
          'banner': 'banner_t1',
        });

    final dummyMatch = MatchNode(
      id: isTest ? 'presentation_showcase' : 'quick_match_test', tournamentId: tourney.id,
      stageIndex: 0, round: 1, roundName: isTest ? 'Match Presentation Test' : 'Exhibition Quick Match',
      week: widget.state.weekOfYear, bestOf: 3,
      slotA: MatchSlot(teamId: 'user_team', teamName: widget.state.teamName, seed: 1),
      slotB: MatchSlot(teamId: opp.id, teamName: opp.name, seed: 2));

    if (!widget.state.tournamentInstances.any((t) => t.tournamentId == tourney.id)) {
      widget.state.tournamentInstances.add(TournamentInstance(
        tournamentId: tourney.id, name: tourney.name, tier: tourney.tier,
        banner: tourney.banner, division: tourney.division));
    }

    Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => BroadcastMatchScreen(
        state: widget.state, opponent: opp, match: dummyMatch, tournament: tourney,
        initialStrategy: 'Rush', isCoachMode: true, isScriptedPresentationTest: isTest,
        onMatchCompleted: widget.onStateUpdated)));
  }

  int max(int a, int b) => a > b ? a : b;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: PixelPanel(
        title: 'DEBUG MENU',
        width: 330,
        onClose: () => Navigator.of(context).pop(),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                color: AppConstants.darkNavy,
                child: Text(
                  _statusMessage,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontFamily: AppConstants.pixelFont,
                    color: AppConstants.moneyGold,
                    fontSize: 12,
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // Difficulty Mode
              Row(
                children: [
                  const Text('Mode: ', style: TextStyle(fontFamily: AppConstants.pixelFont, fontSize: 11, fontWeight: FontWeight.bold)),
                  for (final d in ['easy', 'normal', 'hard'])
                    Padding(
                      padding: const EdgeInsets.only(right: 6.0),
                      child: InkWell(
                        onTap: () => _setDifficulty(d),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: widget.state.difficulty == d ? AppConstants.moneyGold : Colors.white,
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(color: AppConstants.darkNavy, width: 1.5),
                          ),
                          child: Text(
                            d.toUpperCase(),
                            style: TextStyle(
                              fontFamily: AppConstants.pixelFont,
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                              color: widget.state.difficulty == d ? Colors.black : AppConstants.darkNavy,
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 10),

              // Action buttons
              for (final btn in [
                ('⚡ Quick Match (Current Roster)', () => _launchMatchScreen(isTest: false), PixelButtonColor.red),
                ('🎬 Match Presentation Test', () => _launchMatchScreen(isTest: true), PixelButtonColor.yellow),
                ('Skip 1 Week', _skipWeek, PixelButtonColor.yellow),
                ('Add P50,000 Cash', _addMoney, PixelButtonColor.green),
                ('Add 500 Fame & 1K Fans', _addFame, PixelButtonColor.yellow),
                ('Unlock All Tiers & HQ', _unlockAllTiers, PixelButtonColor.green),
                ('Unlock All Furniture', _unlockAllFurniture, PixelButtonColor.neutral),
                ('Force Random Event Dialog', _forceEvent, PixelButtonColor.yellow),
                ('Jump to Match Day (D5)', _jumpToNextMatchDay, PixelButtonColor.red),
                ('Jump to Awards Night (W48)', _jumpToAwardsNight, PixelButtonColor.yellow),
                ('Jump to Year 10 Evaluation', _triggerYear10Evaluation, PixelButtonColor.yellow),
                ('Add +10 Legacy Points', _addLegacyPoints, PixelButtonColor.green),
                ('Test Audio SFX (Coin, Promo)', _testAudioSfx, PixelButtonColor.neutral),
                ('Unlock All Divisions (SZ + LI)', _unlockAllDivisions, PixelButtonColor.green),
                ('Cycle Active Division', _cycleDivision, PixelButtonColor.yellow),
                ('Run 10-Year Headless Sim', _runHeadlessSimulation, PixelButtonColor.green),
              ])
                Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: _buildDebugButton(btn.$1, btn.$2, btn.$3),
                ),

              // Simulation report
              if (_simResult != null) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF131D33),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Simulation Report (${_simResult!.durationMs} ms):',
                        style: const TextStyle(
                          fontFamily: AppConstants.pixelFont,
                          color: AppConstants.positiveGreen,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 4),
                      for (final rep in _simResult!.yearReports)
                        Text(
                          rep,
                          style: const TextStyle(
                            fontFamily: AppConstants.pixelFont,
                            color: Colors.white,
                            fontSize: 10,
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDebugButton(String label, VoidCallback onPressed, PixelButtonColor color) {
    return SizedBox(
      height: 38,
      child: PixelButton(
        label: label,
        onPressed: onPressed,
        color: color,
        height: 36,
      ),
    );
  }
}
