import 'package:flutter/material.dart';
import '../../models/game_state.dart';
import '../../models/ai_team.dart';
import '../../models/tournament.dart';
import '../../services/match_sim_engine.dart';
import '../dialogs/match_result_dialog.dart';
import '../dialogs/timeout_dialog.dart';
import '../widgets/match_scoreboard_view.dart';
import '../widgets/match_arena_view.dart';
import '../widgets/match_casters_strip.dart';
import '../widgets/match_control_bar.dart';
import '../widgets/match_particle_system.dart';
import '../widgets/match_focus_meter_inline.dart';
import '../widgets/match_intro_outro_overlay.dart';
import '../widgets/match_clash_lane_fx.dart';
import 'broadcast_match_controller.dart';

class BroadcastMatchScreen extends StatefulWidget {
  final GameState state;
  final AiTeam opponent;
  final MatchNode match;
  final TournamentDef tournament;
  final String initialStrategy;
  final bool isCoachMode;
  final bool isScriptedPresentationTest;
  final VoidCallback onMatchCompleted;

  const BroadcastMatchScreen({
    super.key,
    required this.state,
    required this.opponent,
    required this.match,
    required this.tournament,
    required this.initialStrategy,
    required this.isCoachMode,
    this.isScriptedPresentationTest = false,
    required this.onMatchCompleted,
  });

  @override
  State<BroadcastMatchScreen> createState() => _BroadcastMatchScreenState();
}

class _BroadcastMatchScreenState extends State<BroadcastMatchScreen> {
  late final BroadcastMatchController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = BroadcastMatchController(
      state: widget.state,
      opponent: widget.opponent,
      match: widget.match,
      tournament: widget.tournament,
      initialStrategy: widget.initialStrategy,
      isCoachMode: widget.isCoachMode,
      isScriptedPresentationTest: widget.isScriptedPresentationTest,
      onMatchCompleted: widget.onMatchCompleted,
    );
    _ctrl.init();
    _ctrl.addListener(_handleStateChange);
  }

  void _handleStateChange() {
    if (!mounted) return;
    setState(() {});
  }

  void _openResultScreen() {
    final result = MatchSimEngine.finalizeUserSeriesResult(
      state: widget.state,
      opponent: widget.opponent,
      match: widget.match,
      tournament: widget.tournament,
      games: _ctrl.playedGames,
    );
    Navigator.of(context).pop();
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => MatchResultDialog(result: result, onClose: widget.onMatchCompleted),
    );
  }

  void _openTimeoutDialog() {
    _ctrl.stopClock();
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => TimeoutDialog(
        state: widget.state,
        timeoutsRemaining: _ctrl.timeoutsRemaining,
        currentStrategy: _ctrl.currentStrategy,
        onPepTalkApplied: (msg) => _ctrl.applyTimeout(msg),
        onStrategyChanged: (strat, msg) {
          _ctrl.currentStrategy = strat;
          _ctrl.applyTimeout(msg);
        },
        onSubstituted: (outP, inP) => _ctrl.applyTimeout('Substitution: ${outP.gamerTag} -> ${inP.gamerTag}!'),
      ),
    ).then((_) {
      if (!_ctrl.isIntermission && !_ctrl.isSeriesOver) _ctrl.startClock();
    });
  }

  @override
  void dispose() {
    _ctrl.removeListener(_handleStateChange);
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final winChance = (50.0 + (_ctrl.momentum * 25.0)).clamp(10.0, 90.0);

    return Scaffold(
      backgroundColor: const Color(0xFF0F1826),
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                // 1. Scoreboard (12%)
                MatchScoreboardView(
                  tournamentName: widget.tournament.name,
                  roundName: widget.match.roundName,
                  bestOf: widget.match.bestOf,
                  userTeamName: widget.state.teamName,
                  oppTeamName: widget.opponent.name,
                  userWins: _ctrl.userWins,
                  oppWins: _ctrl.oppWins,
                  targetWins: _ctrl.targetWins,
                  userKills: _ctrl.userKills,
                  oppKills: _ctrl.oppKills,
                  formattedTime: _ctrl.formatTime(),
                  patch: _ctrl.activePatch,
                  currentStrategy: _ctrl.currentStrategy,
                  scorePopScale: _ctrl.presentation.scorePopScale,
                  scorePopColor: _ctrl.presentation.scorePopColor,
                  isLateGame: _ctrl.gameMinutes >= 22,
                  animPhase: _ctrl.animPhase,
                ),

                // 2. Arena Stage (50%)
                Expanded(
                  flex: 5,
                  child: MatchArenaView(
                    tier: widget.tournament.tier,
                    isGrandFinal: widget.match.roundName.contains('Grand Final'),
                    userTeamName: widget.state.teamName,
                    oppTeamName: widget.opponent.name,
                    userStarters: widget.state.starters,
                    rivalRoster: _ctrl.rivalRoster,
                    momentum: _ctrl.momentum,
                    winChancePercent: winChance,
                    showMomentumShiftBanner: _ctrl.showMomentumShift,
                    activeKillBanner: _ctrl.activeKillBanner,
                    activeBannerTarget: _ctrl.activeBannerTarget,
                    animPhase: _ctrl.animPhase,
                    activeEmotes: _ctrl.activeEmotes,
                    playerStates: _ctrl.presentation.playerStates,
                    cameraZoom: _ctrl.presentation.cameraZoom,
                    shakeOffset: _ctrl.presentation.shakeOffset,
                    isDesaturated: _ctrl.presentation.isDesaturated,
                    clashFxOverlay: MatchClashLaneFx(
                      killFeed: _ctrl.presentation.killFeed,
                      activeBeams: _ctrl.presentation.activeBeams,
                      isTeamfightActive: _ctrl.presentation.isTeamfightActive,
                      animPhase: _ctrl.animPhase,
                    ),
                    inlineFocusMeter: _ctrl.presentation.isFocusMeterActive
                        ? MatchFocusMeterInline(
                            captainMental: widget.state.starters.firstOrNull?.mental ?? 50,
                            momentTitle: _ctrl.presentation.focusMomentTitle,
                            onResolved: (bonus, outcome) => _ctrl.onFocusMeterResolved(bonus, outcome),
                          )
                        : null,
                  ),
                ),

                // 3. Casters Strip (14%)
                MatchCastersStrip(
                  currentLine: _ctrl.currentCommentary,
                  historyLines: _ctrl.commentaryHistory,
                  isTyping: _ctrl.isTyping,
                  displayedText: _ctrl.displayedCommentaryText,
                  onFinishTyping: _ctrl.finishTypingInstantly,
                  animPhase: _ctrl.animPhase,
                ),

                // 4. Control Bar (10%)
                MatchControlBar(
                  isSeriesOver: _ctrl.isSeriesOver,
                  userWon: _ctrl.userWins > _ctrl.oppWins,
                  userWins: _ctrl.userWins,
                  oppWins: _ctrl.oppWins,
                  onOpenResults: _openResultScreen,
                  isIntermission: _ctrl.isIntermission,
                  currentGameNumber: _ctrl.currentGameNumber,
                  timeoutsRemaining: _ctrl.timeoutsRemaining,
                  onOpenTimeout: _openTimeoutDialog,
                  onStartNextGame: _ctrl.startNextGame,
                  speedMultiplier: _ctrl.speedMultiplier,
                  isPaused: _ctrl.isPaused,
                  onSpeedChanged: _ctrl.setSpeed,
                  onTogglePause: _ctrl.togglePause,
                  onSkip: () {
                    _ctrl.skipToEnd();
                    _openResultScreen();
                  },
                ),
              ],
            ),

            // Particle FX Overlay (Pooled, max 150 particles)
            MatchParticleOverlay(pool: _ctrl.presentation.particlePool),

            // Intro Overlay (Game N banner, Team vs Team, 3-2-1-FIGHT)
            if (_ctrl.presentation.isIntroActive)
              Positioned.fill(
                child: MatchIntroOverlay(
                  gameNumber: _ctrl.currentGameNumber,
                  userTeamName: widget.state.teamName,
                  oppTeamName: widget.opponent.name,
                  onIntroFinished: () {
                    _ctrl.presentation.finishIntro();
                    if (!_ctrl.isScriptedPresentationTest) _ctrl.startClock();
                  },
                ),
              ),

            // Outro Overlay (VICTORY/DEFEAT stamp, MVP highlight)
            if (_ctrl.presentation.isOutroActive)
              Positioned.fill(
                child: MatchOutroOverlay(
                  userWon: _ctrl.presentation.userWonOutro,
                  mvpTag: _ctrl.presentation.mvpTag,
                  onDismiss: () {
                    _ctrl.presentation.dismissOutro();
                    _openResultScreen();
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}
