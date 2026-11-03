import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import '../../core/constants.dart';
import '../../services/audio_manager.dart';
import '../widgets/match_particle_system.dart';
import '../widgets/match_clash_lane_fx.dart';

class MatchPresentationManager extends ChangeNotifier {
  final MatchParticlePool particlePool = MatchParticlePool();
  final List<ProjectileBeam> activeBeams = [];
  final List<KillFeedEntry> killFeed = [];
  final Map<String, String> playerStates = {};

  double shakeOffset = 0.0;
  double _shakeMagnitude = 0.0;
  double _shakeDuration = 0.0;

  double cameraZoom = 1.0;
  double _targetZoom = 1.0;

  bool isDesaturated = false;
  double scorePopScale = 1.0;
  Color? scorePopColor;

  bool isTeamfightActive = false;
  bool isFocusMeterActive = false;
  String focusMomentTitle = 'OBJECTIVE CONTEST';

  bool isIntroActive = true;
  bool isOutroActive = false;
  bool userWonOutro = true;
  String mvpTag = 'Kidlat';

  // Multi-kill tracking (window: 5000ms per B1)
  int _lastKillMs = 0;
  int _consecutiveKills = 0;
  String? _lastKillerTeam;
  final Map<String, int> _playerKills = {};

  void update(double dt, double animPhase) {
    // 1. Update pooled particles
    particlePool.update();

    // 2. Update projectile beams (0.25s flight duration)
    for (int i = activeBeams.length - 1; i >= 0; i--) {
      final b = activeBeams[i];
      b.progress += dt / 0.25;
      if (b.progress >= 1.0) {
        particlePool.spawnHitSpark(b.end.dx, b.end.dy, b.color);
        activeBeams.removeAt(i);
      }
    }

    // 3. Screen shake decay
    if (_shakeDuration > 0.0) {
      _shakeDuration -= dt;
      shakeOffset = sin(animPhase * 35) * _shakeMagnitude;
    } else {
      shakeOffset = 0.0;
      _shakeMagnitude = 0.0;
    }

    // 4. Camera zoom easing
    if ((cameraZoom - _targetZoom).abs() > 0.005) {
      cameraZoom += (_targetZoom - cameraZoom) * (dt * 8.0);
    } else {
      cameraZoom = _targetZoom;
    }

    // 5. Score pop decay (1.4 -> 1.0)
    if (scorePopScale > 1.0) {
      scorePopScale = max(1.0, scorePopScale - (dt * 1.8));
      if (scorePopScale <= 1.02) {
        scorePopScale = 1.0;
        scorePopColor = null;
      }
    }

    notifyListeners();
  }

  void triggerScreenShake(double magnitudePx, double durationSeconds) {
    _shakeMagnitude = magnitudePx;
    _shakeDuration = durationSeconds;
    notifyListeners();
  }

  void triggerCameraZoomPulse(double zoom, {int durationMs = 700}) {
    _targetZoom = zoom;
    notifyListeners();
    Future.delayed(Duration(milliseconds: durationMs), () {
      _targetZoom = 1.0;
      notifyListeners();
    });
  }

  void triggerKill({
    required String killer,
    required String victim,
    required bool isUserKill,
    required Offset killerDeskPos,
    required Offset victimDeskPos,
    required int currentMatchSeconds,
  }) {
    final nowMs = DateTime.now().millisecondsSinceEpoch;
    final teamKey = isUserKill ? 'user' : 'opp';
    final teamColor = isUserKill ? AppConstants.energyBlue : AppConstants.negativeRed;

    // Multi-kill window check (5 seconds)
    if (_lastKillerTeam == teamKey && (nowMs - _lastKillMs) <= 5000) {
      _consecutiveKills++;
    } else {
      _consecutiveKills = 1;
      _lastKillerTeam = teamKey;
    }
    _lastKillMs = nowMs;

    // Hot streak tracking (3 kills)
    _playerKills[killer] = (_playerKills[killer] ?? 0) + 1;
    if ((_playerKills[killer] ?? 0) >= 3) {
      playerStates[killer] = 'hot_streak';
    }

    // 1. Projectile beam streak (0.25s)
    activeBeams.add(
      ProjectileBeam(
        start: killerDeskPos,
        end: victimDeskPos,
        color: teamColor,
      ),
    );

    // 2. Floating +1 score particle
    particlePool.spawnFloatingScore(
      victimDeskPos.dx,
      victimDeskPos.dy - 10,
      text: '+1',
      color: isUserKill ? AppConstants.moneyGold : Colors.white,
    );

    // 3. Score pop (1.0 to 1.4 with team color flash)
    scorePopScale = 1.4;
    scorePopColor = teamColor;

    // 4. Victim states: hit flash then slump/dead
    playerStates[victim] = 'hit';
    Future.delayed(const Duration(milliseconds: 150), () {
      playerStates[victim] = 'dead';
      notifyListeners();
    });
    Future.delayed(const Duration(seconds: 6), () {
      if (playerStates[victim] == 'dead') {
        playerStates[victim] = 'idle';
        notifyListeners();
      }
    });

    // 5. Kill feed entry (max 3)
    final m = (currentMatchSeconds ~/ 60).toString().padLeft(2, '0');
    final s = (currentMatchSeconds % 60).toString().padLeft(2, '0');
    killFeed.insert(
      0,
      KillFeedEntry(
        killer: killer,
        victim: victim,
        isUserKill: isUserKill,
        timestamp: '$m:$s',
      ),
    );
    if (killFeed.length > 3) killFeed.removeLast();

    // 6. Sound & Multikill banner/shake logic
    if (_consecutiveKills == 2) {
      triggerScreenShake(2.0, 0.20);
      AudioManager().playSfx(AudioSfx.multiKill);
    } else if (_consecutiveKills == 3) {
      triggerScreenShake(3.0, 0.25);
      AudioManager().playSfx(AudioSfx.multiKill);
    } else if (_consecutiveKills >= 5) {
      triggerScreenShake(6.0, 0.35);
      AudioManager().playSfx(AudioSfx.multiKill);
      particlePool.spawnConfetti(360.0);
    } else {
      AudioManager().playSfx(AudioSfx.kill);
    }

    // Crowd audio
    if (isUserKill) {
      AudioManager().playSfx(AudioSfx.crowdCheer);
    } else {
      AudioManager().playSfx(AudioSfx.crowdGroan);
    }

    notifyListeners();
  }

  void triggerTeamfight({required String momentTitle, required bool isCoachMode}) {
    isTeamfightActive = true;
    focusMomentTitle = momentTitle;
    triggerScreenShake(3.0, 0.35);
    triggerCameraZoomPulse(1.05, durationMs: 2500);
    AudioManager().playSfx(AudioSfx.clash);

    if (isCoachMode) {
      isFocusMeterActive = true;
    }

    Future.delayed(const Duration(milliseconds: 2800), () {
      isTeamfightActive = false;
      notifyListeners();
    });
    notifyListeners();
  }

  void resolveFocusMeter() {
    isFocusMeterActive = false;
    notifyListeners();
  }

  void triggerGameEnd({required bool userWon, required String mvp}) {
    mvpTag = mvp;
    userWonOutro = userWon;

    if (userWon) {
      triggerCameraZoomPulse(1.10, durationMs: 1200);
      AudioManager().playSfx(AudioSfx.victory);
      particlePool.spawnConfetti(360.0);
      playerStates['__user__'] = 'cheer';
      playerStates['__opp__'] = 'slump';
    } else {
      isDesaturated = true;
      AudioManager().playSfx(AudioSfx.defeat);
      playerStates['__user__'] = 'slump';
      playerStates['__opp__'] = 'cheer';
    }

    Future.delayed(const Duration(milliseconds: 1000), () {
      isOutroActive = true;
      notifyListeners();
    });
    notifyListeners();
  }

  void dismissOutro() {
    isOutroActive = false;
    isDesaturated = false;
    playerStates.remove('__user__');
    playerStates.remove('__opp__');
    notifyListeners();
  }

  void finishIntro() {
    isIntroActive = false;
    notifyListeners();
  }

  String getBannerForLastKill(String killer, String victim) {
    if (_consecutiveKills >= 5) return 'ACE!';
    if (_consecutiveKills == 3) return 'TRIPLE KILL!';
    if (_consecutiveKills == 2) return 'DOUBLE KILL!';
    return '${killer.toUpperCase()} ELIMINATED ${victim.toUpperCase()}';
  }

  Future<void> runScriptedShowcase({
    required Function(String killer, String victim, bool isUserKill) onKill,
    required Function(String title) onTeamfight,
    required Function(double momentumDelta) onMomentumShift,
    required Function(bool won, String mvp) onGameWin,
  }) async {
    finishIntro();
    await Future.delayed(const Duration(milliseconds: 600));
    onKill('Kidlat', 'Phantom', true);
    await Future.delayed(const Duration(milliseconds: 1800));
    onKill('Kidlat', 'Viper', true);
    await Future.delayed(const Duration(milliseconds: 2000));
    onKill('Kidlat', 'Blaze', true);
    await Future.delayed(const Duration(milliseconds: 2400));
    onTeamfight('FIRST OBJECTIVE CLASH');
    await Future.delayed(const Duration(milliseconds: 3200));
    onMomentumShift(0.35);
    await Future.delayed(const Duration(milliseconds: 2200));
    onGameWin(true, 'Kidlat');
  }
}
