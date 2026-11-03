import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import '../../models/game_state.dart';
import '../../models/ai_team.dart';
import '../../models/tournament.dart';
import '../../models/match_result.dart';
import '../../models/patch_data.dart';
import '../../services/data_service.dart';
import '../../services/match_sim_engine.dart';
import '../../services/bracket_engine.dart';
import '../../services/commentary_engine.dart';
import '../../services/rival_roster_service.dart';
import '../../services/audio_manager.dart';
import 'match_presentation_manager.dart';

class BroadcastMatchController extends ChangeNotifier {
  final GameState state;
  final AiTeam opponent;
  final MatchNode match;
  final TournamentDef tournament;
  final bool isCoachMode;
  final bool isScriptedPresentationTest;
  final VoidCallback onMatchCompleted;
  final MatchPresentationManager presentation = MatchPresentationManager();

  Timer? _ticker, _typewriterTimer, _ambientTimer;
  int speedMultiplier = 1;
  bool isPaused = false, isIntermission = false, isSeriesOver = false;
  int userWins = 0, oppWins = 0, currentGameNumber = 1, timeoutsRemaining = 2;
  late String currentStrategy;
  int gameMinutes = 0, gameSeconds = 0, userKills = 0, oppKills = 0, momentsTriggered = 0;
  double focusBonusAccumulated = 0.0, momentum = 0.0, _lastMomentum = 0.0;
  bool showMomentumShift = false, isTyping = false;
  String? activeKillBanner, activeBannerTarget;
  final List<GameResult> playedGames = [];
  late PatchDef activePatch;
  late List<RivalPlayerDisplayData> rivalRoster;
  final CommentaryEngine commentaryEngine = CommentaryEngine();
  CommentaryLine? currentCommentary;
  final List<CommentaryLine> commentaryHistory = [];
  String displayedCommentaryText = '';
  int _typewriterCharIndex = 0;
  double animPhase = 0.0;
  final Map<String, String> activeEmotes = {};

  int get targetWins => (match.bestOf / 2).ceil();

  BroadcastMatchController({
    required this.state,
    required this.opponent,
    required this.match,
    required this.tournament,
    required String initialStrategy,
    required this.isCoachMode,
    this.isScriptedPresentationTest = false,
    required this.onMatchCompleted,
  }) {
    currentStrategy = initialStrategy;
    activePatch = DataService().getPatchForWeek(match.week);
    rivalRoster = RivalRosterService.generateRoster(opponent);
  }

  Future<void> init() async {
    await commentaryEngine.initialize();
    _startAmbientLoop();
    if (isScriptedPresentationTest) {
      _runScriptedPresentationTest();
    } else {
      triggerCommentary('start');
      AudioManager().playBgm(
        tournament.tier >= 6 || match.roundName.contains('Final')
            ? AudioBgm.finals
            : AudioBgm.match,
      );
    }
  }

  void _startAmbientLoop() {
    _ambientTimer?.cancel();
    _ambientTimer = Timer.periodic(const Duration(milliseconds: 100), (_) {
      animPhase += 0.15;
      presentation.update(0.1, animPhase);
      notifyListeners();
    });
  }

  void triggerCommentary(String eventType, {String? killer, String? victim, String? name, String? team, String? oppTeam}) {
    final starters = state.getStartersForDivision(tournament.division);
    final userP = starters.isNotEmpty ? starters[Random().nextInt(starters.length)].gamerTag : 'Kidlat';
    final oppP = rivalRoster.isNotEmpty ? rivalRoster[Random().nextInt(rivalRoster.length)].gamerTag : 'Phantom';

    final line = commentaryEngine.generateLine(
      eventType: eventType, timestampSeconds: (gameMinutes * 60) + gameSeconds,
      killer: killer ?? userP, victim: victim ?? oppP, name: name ?? userP,
      team: team ?? state.teamName, oppTeam: oppTeam ?? opponent.name, n: currentGameNumber);

    if (currentCommentary != null) {
      commentaryHistory.insert(0, currentCommentary!);
      if (commentaryHistory.length > 5) commentaryHistory.removeLast();
    }

    currentCommentary = line;
    displayedCommentaryText = '';
    _typewriterCharIndex = 0;
    isTyping = true;
    _typewriterTimer?.cancel();
    final ms = commentaryEngine.config.typewriterMs;
    _typewriterTimer = Timer.periodic(Duration(milliseconds: ms), (t) {
      if (_typewriterCharIndex < line.text.length) {
        displayedCommentaryText = line.text.substring(0, ++_typewriterCharIndex);
      } else {
        t.cancel();
        isTyping = false;
      }
      notifyListeners();
    });
    notifyListeners();
  }

  void finishTypingInstantly() {
    if (currentCommentary == null) return;
    _typewriterTimer?.cancel();
    displayedCommentaryText = currentCommentary!.text;
    isTyping = false;
    notifyListeners();
  }

  void startClock() {
    _ticker?.cancel();
    if (isPaused || isIntermission || isSeriesOver || isScriptedPresentationTest) return;
    final baseTickMs = speedMultiplier == 1 ? 160 : 80;
    final tickMs = presentation.isFocusMeterActive ? (baseTickMs * 4) : baseTickMs;
    _ticker = Timer.periodic(Duration(milliseconds: tickMs), (_) => onTick());
  }

  void stopClock() => _ticker?.cancel();

  void setSpeed(int s) {
    speedMultiplier = s;
    startClock();
    notifyListeners();
  }

  void togglePause() {
    isPaused = !isPaused;
    isPaused ? stopClock() : startClock();
    notifyListeners();
  }

  void onTick() {
    gameSeconds += 20;
    if (gameSeconds >= 60) {
      gameMinutes += gameSeconds ~/ 60;
      gameSeconds = gameSeconds % 60;
    }

    if (gameMinutes >= 10 && momentsTriggered == 0) {
      momentsTriggered = 1;
      presentation.triggerTeamfight(momentTitle: 'OBJECTIVE CONTEST', isCoachMode: isCoachMode);
      triggerCommentary('teamfight');
      if (isCoachMode) startClock();
    } else if (gameMinutes >= 20 && momentsTriggered == 1) {
      momentsTriggered = 2;
      presentation.triggerTeamfight(momentTitle: 'BASE SIEGE CONTEST', isCoachMode: isCoachMode);
      triggerCommentary('teamfight');
      if (isCoachMode) startClock();
    }

    _rollMatchEvent();

    if (gameMinutes >= 24) {
      resolveCurrentGame();
    }
    notifyListeners();
  }

  void _rollMatchEvent() {
    final rng = Random();
    final starters = state.getStartersForDivision(tournament.division);

    if (rng.nextDouble() < 0.22 && starters.isNotEmpty && rivalRoster.isNotEmpty) {
      final isUserKill = rng.nextDouble() < 0.52;
      final killer = isUserKill
          ? starters[rng.nextInt(starters.length)].gamerTag
          : rivalRoster[rng.nextInt(rivalRoster.length)].gamerTag;
      final victim = isUserKill
          ? rivalRoster[rng.nextInt(rivalRoster.length)].gamerTag
          : starters[rng.nextInt(starters.length)].gamerTag;

      if (isUserKill) {
        userKills++;
        momentum = (momentum + 0.15).clamp(-1.0, 1.0);
      } else {
        oppKills++;
        momentum = (momentum - 0.15).clamp(-1.0, 1.0);
      }

      final killerX = 36.0 + rng.nextInt(5) * 65.0;
      final victimX = 36.0 + rng.nextInt(5) * 65.0;
      presentation.triggerKill(
        killer: killer,
        victim: victim,
        isUserKill: isUserKill,
        killerDeskPos: Offset(killerX, isUserKill ? 215.0 : 55.0),
        victimDeskPos: Offset(victimX, isUserKill ? 55.0 : 215.0),
        currentMatchSeconds: (gameMinutes * 60) + gameSeconds,
      );

      if ((momentum - _lastMomentum).abs() >= 0.25) {
        showMomentumShift = true;
        triggerCommentary('momentum', team: isUserKill ? state.teamName : opponent.name);
      } else {
        showMomentumShift = false;
        triggerCommentary('kill', killer: killer, victim: victim);
      }
      _lastMomentum = momentum;

      activeKillBanner = presentation.getBannerForLastKill(killer, victim);
      activeBannerTarget = isUserKill ? 'user' : 'opp';
      Timer(const Duration(milliseconds: 1200), () {
        if (activeKillBanner != null) {
          activeKillBanner = null;
          notifyListeners();
        }
      });

      activeEmotes[killer] = 'assets/images/effects/emote_sparkle.png';
      if (activeEmotes.length > 3) activeEmotes.remove(activeEmotes.keys.first);
    }
  }

  void onFocusMeterResolved(double powerBonus, String outcome) {
    focusBonusAccumulated += powerBonus;
    activeKillBanner = outcome;
    activeBannerTarget = powerBonus > 0 ? 'user' : 'opp';
    presentation.resolveFocusMeter();
    startClock();
    if (powerBonus >= 2.5) {
      triggerCommentary('perfect_focus', name: state.starters.firstOrNull?.gamerTag ?? 'Kidlat');
    } else {
      triggerCommentary('teamfight');
    }
    notifyListeners();
  }

  void resolveCurrentGame() {
    stopClock();
    final game = MatchSimEngine.simulateSingleGame(
      state: state,
      opponent: opponent,
      userStrategy: currentStrategy,
      focusBonus: focusBonusAccumulated,
      momentumUser: max(0.0, momentum),
      momentumOpponent: max(0.0, -momentum),
      gameNumber: currentGameNumber,
      isPlayoff: match.roundName.contains('Final') || match.roundName.contains('Semi'),
      isLAN: tournament.tier >= 4,
      patch: activePatch,
    );

    userKills = max(userKills, game.teamAScore);
    oppKills = max(oppKills, game.teamBScore);
    playedGames.add(game);

    final userWon = game.winnerTeamId == 'user_team';
    if (userWon) {
      userWins++;
      momentum = 0.5;
    } else {
      oppWins++;
      momentum = -0.5;
    }

    final starters = state.getStartersForDivision(tournament.division);
    final mvp = userWon
        ? (starters.isNotEmpty ? starters.first.gamerTag : 'Kidlat')
        : (rivalRoster.isNotEmpty ? rivalRoster.first.gamerTag : 'Phantom');
    presentation.triggerGameEnd(userWon: userWon, mvp: mvp);
    triggerCommentary('end');

    if (userWins >= targetWins || oppWins >= targetWins) {
      finalizeSeries();
    } else {
      isIntermission = true;
    }
    notifyListeners();
  }

  void startNextGame() {
    currentGameNumber++;
    gameMinutes = 0;
    gameSeconds = 0;
    userKills = 0;
    oppKills = 0;
    momentsTriggered = 0;
    focusBonusAccumulated = 0.0;
    activeKillBanner = null;
    isIntermission = false;
    triggerCommentary('start');
    startClock();
    notifyListeners();
  }

  void finalizeSeries() {
    isSeriesOver = true;
    final res = MatchSimEngine.finalizeUserSeriesResult(
      state: state, opponent: opponent, match: match, tournament: tournament, games: playedGames);
    final inst = state.tournamentInstances.firstWhere((t) => t.tournamentId == tournament.id);
    BracketEngine.recordMatchOutcome(instance: inst, tournament: tournament, match: match, result: res);
    if (res.isUserVictory && match.roundName == 'Grand Final' && !state.trophies.contains(tournament.trophy)) {
      state.trophies.add(tournament.trophy);
      state.addNotification('CHAMPION TROPHY UNLOCKED!', '#F5B700', 0.5, 0.3);
    }
    notifyListeners();
  }

  void skipToEnd() {
    stopClock();
    while (userWins < targetWins && oppWins < targetWins) {
      final g = MatchSimEngine.simulateSingleGame(
        state: state, opponent: opponent, userStrategy: currentStrategy,
        focusBonus: 1.0, momentumUser: max(0.0, momentum),
        momentumOpponent: max(0.0, -momentum),
        gameNumber: currentGameNumber++, patch: activePatch);
      playedGames.add(g);
      g.winnerTeamId == 'user_team' ? userWins++ : oppWins++;
    }
    finalizeSeries();
  }

  void _runScriptedPresentationTest() {
    presentation.runScriptedShowcase(
      onKill: (k, v, isUser) {
        isUser ? userKills++ : oppKills++;
        if (isUser) momentum = (momentum + 0.15).clamp(-1.0, 1.0);
        presentation.triggerKill(
          killer: k, victim: v, isUserKill: isUser,
          killerDeskPos: const Offset(100, 215), victimDeskPos: const Offset(100, 55),
          currentMatchSeconds: 120);
        activeKillBanner = presentation.getBannerForLastKill(k, v);
        activeBannerTarget = isUser ? 'user' : 'opp';
        triggerCommentary('kill', killer: k, victim: v);
        notifyListeners();
      },
      onTeamfight: (title) {
        presentation.triggerTeamfight(momentTitle: title, isCoachMode: isCoachMode);
        triggerCommentary('teamfight');
        notifyListeners();
      },
      onMomentumShift: (delta) {
        momentum = (momentum + delta).clamp(-1.0, 1.0);
        showMomentumShift = true;
        triggerCommentary('momentum', team: state.teamName);
        notifyListeners();
      },
      onGameWin: (won, mvp) {
        userWins++;
        presentation.triggerGameEnd(userWon: won, mvp: mvp);
        triggerCommentary('end');
        notifyListeners();
      },
    );
  }

  void applyTimeout(String msg) {
    timeoutsRemaining--;
    triggerCommentary('clutch', name: state.teamName);
    startClock();
    notifyListeners();
  }

  String formatTime() {
    final m = gameMinutes.toString().padLeft(2, '0');
    final s = gameSeconds.toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  void dispose() {
    _ticker?.cancel();
    _typewriterTimer?.cancel();
    _ambientTimer?.cancel();
    presentation.dispose();
    super.dispose();
  }
}
