import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import '../../core/constants.dart';
import '../../models/game_state.dart';
import '../../models/ai_team.dart';
import '../../models/tournament.dart';
import '../../models/match_result.dart';
import '../../models/patch_data.dart';
import '../../services/data_service.dart';
import '../../services/match_sim_engine.dart';
import '../../services/bracket_engine.dart';
import '../../services/broadcast_event_helper.dart';
import '../dialogs/match_result_dialog.dart';
import '../dialogs/timeout_dialog.dart';
import '../widgets/focus_meter.dart';
import '../widgets/arena_stage_view.dart';
import '../widgets/broadcast_scoreboard.dart';
import '../widgets/broadcast_controls.dart';
import '../widgets/broadcast_commentary_box.dart';

class BroadcastMatchScreen extends StatefulWidget {
  final GameState state;
  final AiTeam opponent;
  final MatchNode match;
  final TournamentDef tournament;
  final String initialStrategy;
  final bool isCoachMode;
  final VoidCallback onMatchCompleted;

  const BroadcastMatchScreen({
    super.key,
    required this.state,
    required this.opponent,
    required this.match,
    required this.tournament,
    required this.initialStrategy,
    required this.isCoachMode,
    required this.onMatchCompleted,
  });

  @override
  State<BroadcastMatchScreen> createState() => _BroadcastMatchScreenState();
}

class _BroadcastMatchScreenState extends State<BroadcastMatchScreen> {
  Timer? _ticker;

  int _speedMultiplier = 1;
  bool _isPaused = false;
  bool _isIntermission = false;
  bool _isSeriesOver = false;

  int _userWins = 0;
  int _oppWins = 0;
  int _currentGameNumber = 1;
  int _timeoutsRemaining = 2;
  late String _currentStrategy;

  int _gameMinutes = 0;
  int _gameSeconds = 0;
  int _userKills = 0;
  int _oppKills = 0;
  double _focusBonusAccumulated = 0.0;
  int _momentsTriggered = 0;
  double _momentumUser = 0.0;
  double _momentumOpponent = 0.0;

  String? _activePopupText;
  String? _activePopupTarget;
  final List<GameResult> _playedGames = [];
  final List<String> _commentaryFeed = [];
  late PatchDef _activePatch;

  int get _targetWins => (widget.match.bestOf / 2).ceil();

  @override
  void initState() {
    super.initState();
    _currentStrategy = widget.initialStrategy;
    _activePatch = DataService().getPatchForWeek(widget.match.week);
    _addCommentary('Nagsisimula na ang laban sa pagitan ng ${widget.state.teamName} at ${widget.opponent.name}!');
    _startClock();
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }

  void _addCommentary(String line) {
    setState(() {
      _commentaryFeed.insert(0, line);
      if (_commentaryFeed.length > 20) _commentaryFeed.removeLast();
    });
  }

  void _startClock() {
    _ticker?.cancel();
    if (_isPaused || _isIntermission || _isSeriesOver) return;

    final tickMs = _speedMultiplier == 1 ? 160 : 80;
    _ticker = Timer.periodic(Duration(milliseconds: tickMs), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      _onTick();
    });
  }

  void _onTick() {
    setState(() {
      _gameSeconds += 20;
      if (_gameSeconds >= 60) {
        _gameMinutes += _gameSeconds ~/ 60;
        _gameSeconds = _gameSeconds % 60;
      }

      final evt = BroadcastEventHelper.rollTickEvent(
        timeStr: _formatTime(),
        userTeamName: widget.state.teamName,
        oppTeamName: widget.opponent.name,
        oppCaptain: widget.opponent.captain ?? 'Opponent Ace',
        starters: widget.state.getStartersForDivision(widget.tournament.division),
        divisionId: widget.tournament.division,
      );

      if (evt != null) {
        if (evt.hasKill) {
          if (evt.isUserKill) {
            _userKills++;
          } else {
            _oppKills++;
          }
          _activePopupText = evt.popupText;
          _activePopupTarget = evt.popupTarget;
        }
        if (evt.commentary != null) {
          _addCommentary(evt.commentary!);
        }
      }

      if (_gameMinutes >= 10 && _momentsTriggered == 0) {
        _momentsTriggered = 1;
        _handleKeyMoment('FIRST OBJECTIVE CLASH');
        return;
      }
      if (_gameMinutes >= 20 && _momentsTriggered == 1) {
        _momentsTriggered = 2;
        _handleKeyMoment('BASE SIEGE CONTEST');
        return;
      }
      if (_gameMinutes >= 24) _resolveCurrentGame();
    });
  }

  void _handleKeyMoment(String title) {
    if (!widget.isCoachMode) {
      _focusBonusAccumulated += 1.0;
      _addCommentary('[${_formatTime()}] AUTO FOCUS: +1.0 Power applied!');
      return;
    }
    _ticker?.cancel();
    final mental = widget.state.starters.firstOrNull?.mental ?? 50;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => FocusMeterDialog(
        captainMental: mental,
        momentTitle: title,
        onResult: (bonus, outcome) {
          Navigator.of(ctx).pop();
          setState(() {
            _focusBonusAccumulated += bonus;
            _activePopupText = outcome;
            _activePopupTarget = bonus > 0 ? 'user' : 'opp';
            _addCommentary('[${_formatTime()}] COACH FOCUS: $outcome');
          });
          _startClock();
        },
      ),
    );
  }

  void _resolveCurrentGame() {
    _ticker?.cancel();
    final game = MatchSimEngine.simulateSingleGame(
      state: widget.state,
      opponent: widget.opponent,
      userStrategy: _currentStrategy,
      focusBonus: _focusBonusAccumulated,
      momentumUser: _momentumUser,
      momentumOpponent: _momentumOpponent,
      gameNumber: _currentGameNumber,
      isPlayoff: widget.match.roundName.contains('Final') || widget.match.roundName.contains('Semi'),
      isLAN: widget.tournament.tier >= 4,
      patch: _activePatch,
    );

    _userKills = max(_userKills, game.teamAScore);
    _oppKills = max(_oppKills, game.teamBScore);
    _playedGames.add(game);

    final userWon = game.winnerTeamId == 'user_team';
    if (userWon) {
      _userWins++;
      _momentumUser = 1.0;
      _momentumOpponent = 0.0;
      _addCommentary('PANALO ANG GAME $_currentGameNumber! Malupet na tagumpay para sa ${widget.state.teamName}!');
    } else {
      _oppWins++;
      _momentumOpponent = 1.0;
      _momentumUser = 0.0;
      _addCommentary('TALO ANG GAME $_currentGameNumber! Bumabawi ang ${widget.opponent.name}!');
    }

    if (_userWins >= _targetWins || _oppWins >= _targetWins) {
      _finalizeSeries();
    } else {
      setState(() => _isIntermission = true);
    }
  }

  void _startNextGame() {
    setState(() {
      _currentGameNumber++;
      _gameMinutes = 0;
      _gameSeconds = 0;
      _userKills = 0;
      _oppKills = 0;
      _momentsTriggered = 0;
      _focusBonusAccumulated = 0.0;
      _activePopupText = null;
      _isIntermission = false;
    });
    _addCommentary('Nagsisimula na ang Game $_currentGameNumber!');
    _startClock();
  }

  void _finalizeSeries() {
    setState(() => _isSeriesOver = true);
    final result = MatchSimEngine.finalizeUserSeriesResult(
      state: widget.state,
      opponent: widget.opponent,
      match: widget.match,
      tournament: widget.tournament,
      games: _playedGames,
    );
    final inst = widget.state.tournamentInstances.firstWhere((t) => t.tournamentId == widget.tournament.id);
    BracketEngine.recordMatchOutcome(instance: inst, tournament: widget.tournament, match: widget.match, result: result);
    if (result.isUserVictory && widget.match.roundName == 'Grand Final' && !widget.state.trophies.contains(widget.tournament.trophy)) {
      widget.state.trophies.add(widget.tournament.trophy);
      widget.state.addNotification('CHAMPION TROPHY UNLOCKED!', '#F5B700', 0.5, 0.3);
    }
  }

  void _skipToEnd() {
    _ticker?.cancel();
    while (_userWins < _targetWins && _oppWins < _targetWins) {
      final game = MatchSimEngine.simulateSingleGame(
        state: widget.state,
        opponent: widget.opponent,
        userStrategy: _currentStrategy,
        focusBonus: 1.0,
        momentumUser: _momentumUser,
        momentumOpponent: _momentumOpponent,
        gameNumber: _currentGameNumber++,
        patch: _activePatch,
      );
      _playedGames.add(game);
      final userWon = game.winnerTeamId == 'user_team';
      if (userWon) {
        _userWins++;
        _momentumUser = 1.0;
        _momentumOpponent = 0.0;
      } else {
        _oppWins++;
        _momentumOpponent = 1.0;
        _momentumUser = 0.0;
      }
    }
    _finalizeSeries();
    _openResultScreen();
  }

  void _openResultScreen() {
    final result = MatchSimEngine.finalizeUserSeriesResult(
      state: widget.state,
      opponent: widget.opponent,
      match: widget.match,
      tournament: widget.tournament,
      games: _playedGames,
    );
    Navigator.of(context).pop();
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => MatchResultDialog(result: result, onClose: widget.onMatchCompleted),
    );
  }

  void _openTimeoutDialog() {
    _ticker?.cancel();
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => TimeoutDialog(
        state: widget.state,
        timeoutsRemaining: _timeoutsRemaining,
        currentStrategy: _currentStrategy,
        onPepTalkApplied: (msg) => _applyTimeout(msg),
        onStrategyChanged: (strat, msg) { _currentStrategy = strat; _applyTimeout(msg); },
        onSubstituted: (outP, inP) => _applyTimeout('Substitution: ${outP.gamerTag} -> ${inP.gamerTag}!'),
      ),
    ).then((_) {
      if (!_isIntermission && !_isSeriesOver) _startClock();
    });
  }

  void _applyTimeout(String msg) {
    setState(() {
      _timeoutsRemaining--;
      _addCommentary('[TIMEOUT] $msg');
    });
    _startClock();
  }

  String _formatTime() {
    final m = _gameMinutes.toString().padLeft(2, '0');
    final s = _gameSeconds.toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppConstants.bgDark,
      body: SafeArea(
        child: Column(
          children: [
            BroadcastScoreboard(
              tournamentName: widget.tournament.name,
              roundName: widget.match.roundName,
              bestOf: widget.match.bestOf,
              userTeamName: widget.state.teamName,
              oppTeamName: widget.opponent.name,
              userWins: _userWins,
              oppWins: _oppWins,
              targetWins: _targetWins,
              userKills: _userKills,
              oppKills: _oppKills,
              formattedTime: _formatTime(),
            ),
            BroadcastMetaStrip(patch: _activePatch, currentStrategy: _currentStrategy),
            Expanded(
              flex: 4,
              child: ArenaStageView(
                userStarters: widget.state.starters,
                opponent: widget.opponent,
                activePopupText: _activePopupText,
                activePopupTarget: _activePopupTarget,
                gameMinutes: _gameMinutes,
              ),
            ),
            Expanded(
              flex: 2,
              child: BroadcastCommentaryBox(commentaryFeed: _commentaryFeed),
            ),
            BroadcastControls(
              isSeriesOver: _isSeriesOver,
              userWon: _userWins > _oppWins,
              userWins: _userWins,
              oppWins: _oppWins,
              onOpenResults: _openResultScreen,
              isIntermission: _isIntermission,
              currentGameNumber: _currentGameNumber,
              timeoutsRemaining: _timeoutsRemaining,
              onOpenTimeout: _openTimeoutDialog,
              onStartNextGame: _startNextGame,
              speedMultiplier: _speedMultiplier,
              isPaused: _isPaused,
              onSpeedChanged: (s) { setState(() => _speedMultiplier = s); _startClock(); },
              onTogglePause: () => setState(() { _isPaused = !_isPaused; _isPaused ? _ticker?.cancel() : _startClock(); }),
              onSkip: _skipToEnd,
            ),
          ],
        ),
      ),
    );
  }
}
