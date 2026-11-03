import 'dart:convert';
import 'dart:math';
import 'package:flutter/services.dart';

enum CasterType { hype, analyst }

class CommentaryLine {
  final String text;
  final CasterType speaker;
  final String speakerName;
  final String speakerTitle;
  final int timestampSeconds;

  const CommentaryLine({
    required this.text,
    required this.speaker,
    required this.speakerName,
    required this.speakerTitle,
    required this.timestampSeconds,
  });
}

class MatchPresentationConfig {
  final double scoreboardHeightPercent;
  final double arenaHeightPercent;
  final double castersHeightPercent;
  final double controlsHeightPercent;
  final double clashLaneHeightPercent;
  final double momentumBarHeight;
  final double momentumShiftThreshold;
  final int typewriterMs;
  final double casterTalkFps;
  final int ambientIntervalMs;
  final double minTouchTarget;
  final double timeoutButtonHeight;
  final double focusBarHeight;
  final double tiltBarHeight;
  final int hitFlashDurationMs;
  final int maxActiveEmotes;
  final int commentaryNoRepeatWindow;
  final int killBeamDurationMs;
  final int killBannerDurationMs;
  final int multiKillWindowMs;
  final double screenShakeDoubleKill;
  final double screenShakeTripleKill;
  final double screenShakeAce;
  final int hitStopAceMs;
  final int maxParticles;
  final double focusMeterHeight;
  final double focusTapButtonHeight;
  final int introDurationMs;
  final double slowMotionFactor;
  final double cameraZoomPulse;
  final double winningZoomPulse;

  const MatchPresentationConfig({
    this.scoreboardHeightPercent = 0.12,
    this.arenaHeightPercent = 0.50,
    this.castersHeightPercent = 0.14,
    this.controlsHeightPercent = 0.10,
    this.clashLaneHeightPercent = 0.20,
    this.momentumBarHeight = 14.0,
    this.momentumShiftThreshold = 0.25,
    this.typewriterMs = 30,
    this.casterTalkFps = 6.0,
    this.ambientIntervalMs = 2000,
    this.minTouchTarget = 48.0,
    this.timeoutButtonHeight = 56.0,
    this.focusBarHeight = 8.0,
    this.tiltBarHeight = 8.0,
    this.hitFlashDurationMs = 80,
    this.maxActiveEmotes = 3,
    this.commentaryNoRepeatWindow = 8,
    this.killBeamDurationMs = 250,
    this.killBannerDurationMs = 1200,
    this.multiKillWindowMs = 5000,
    this.screenShakeDoubleKill = 2.0,
    this.screenShakeTripleKill = 3.0,
    this.screenShakeAce = 6.0,
    this.hitStopAceMs = 60,
    this.maxParticles = 150,
    this.focusMeterHeight = 28.0,
    this.focusTapButtonHeight = 64.0,
    this.introDurationMs = 2000,
    this.slowMotionFactor = 0.4,
    this.cameraZoomPulse = 1.05,
    this.winningZoomPulse = 1.10,
  });

  factory MatchPresentationConfig.fromJson(Map<String, dynamic> json) {
    return MatchPresentationConfig(
      scoreboardHeightPercent: (json['scoreboard_height_percent'] as num?)?.toDouble() ?? 0.12,
      arenaHeightPercent: (json['arena_height_percent'] as num?)?.toDouble() ?? 0.50,
      castersHeightPercent: (json['casters_height_percent'] as num?)?.toDouble() ?? 0.14,
      controlsHeightPercent: (json['controls_height_percent'] as num?)?.toDouble() ?? 0.10,
      clashLaneHeightPercent: (json['clash_lane_height_percent'] as num?)?.toDouble() ?? 0.20,
      momentumBarHeight: (json['momentum_bar_height_dp'] as num?)?.toDouble() ?? 14.0,
      momentumShiftThreshold: (json['momentum_shift_threshold'] as num?)?.toDouble() ?? 0.25,
      typewriterMs: (json['commentary_typewriter_ms_per_char'] as num?)?.toInt() ?? 30,
      casterTalkFps: (json['caster_talk_fps'] as num?)?.toDouble() ?? 6.0,
      ambientIntervalMs: (json['ambient_life_interval_ms'] as num?)?.toInt() ?? 2000,
      minTouchTarget: (json['min_touch_target_dp'] as num?)?.toDouble() ?? 48.0,
      timeoutButtonHeight: (json['timeout_button_height_dp'] as num?)?.toDouble() ?? 56.0,
      focusBarHeight: (json['focus_bar_height_dp'] as num?)?.toDouble() ?? 8.0,
      tiltBarHeight: (json['tilt_bar_height_dp'] as num?)?.toDouble() ?? 8.0,
      hitFlashDurationMs: (json['hit_flash_duration_ms'] as num?)?.toInt() ?? 80,
      maxActiveEmotes: (json['max_active_emotes'] as num?)?.toInt() ?? 3,
      commentaryNoRepeatWindow: (json['commentary_no_repeat_window'] as num?)?.toInt() ?? 8,
      killBeamDurationMs: (json['kill_beam_duration_ms'] as num?)?.toInt() ?? 250,
      killBannerDurationMs: (json['kill_banner_duration_ms'] as num?)?.toInt() ?? 1200,
      multiKillWindowMs: (json['multi_kill_window_ms'] as num?)?.toInt() ?? 5000,
      screenShakeDoubleKill: (json['screen_shake_double_kill_px'] as num?)?.toDouble() ?? 2.0,
      screenShakeTripleKill: (json['screen_shake_triple_kill_px'] as num?)?.toDouble() ?? 3.0,
      screenShakeAce: (json['screen_shake_ace_px'] as num?)?.toDouble() ?? 6.0,
      hitStopAceMs: (json['hit_stop_ace_ms'] as num?)?.toInt() ?? 60,
      maxParticles: (json['max_particles'] as num?)?.toInt() ?? 150,
      focusMeterHeight: (json['focus_meter_height_dp'] as num?)?.toDouble() ?? 28.0,
      focusTapButtonHeight: (json['focus_tap_button_height_dp'] as num?)?.toDouble() ?? 64.0,
      introDurationMs: (json['intro_duration_ms'] as num?)?.toInt() ?? 2000,
      slowMotionFactor: (json['slow_motion_factor'] as num?)?.toDouble() ?? 0.4,
      cameraZoomPulse: (json['camera_zoom_pulse'] as num?)?.toDouble() ?? 1.05,
      winningZoomPulse: (json['winning_zoom_pulse'] as num?)?.toDouble() ?? 1.10,
    );
  }
}

class CommentaryEngine {
  static final CommentaryEngine _instance = CommentaryEngine._internal();
  factory CommentaryEngine() => _instance;
  CommentaryEngine._internal();

  final Random _rng = Random();
  Map<String, List<String>> _templates = {
    'kill': [
      'Grabe! Pinabagsak ni {killer} si {victim}!',
      'Hala! Nahuli sa gitna si {victim} ni {killer}!',
      'Walang awa si {killer}! Agad pinatumba si {victim}!',
    ],
    'multi_kill': ['DOUBLE KILL para kay {killer}!', 'TRIPLE KILL para kay {killer}!'],
    'clutch': ['Clutch ni {name}! Sabi ko na eh!'],
    'teamfight': ['Nagsalpukan na ang dalawang koponan sa clash lane!'],
    'momentum': ['Lumilipat ang ihip ng hangin pabor sa {team}!'],
    'start': ['Nagsisimula na ang bakbakan sa pagitan ng {team} at {oppTeam}!'],
    'end': ['Tapos na ang Game {n}! Malupet na laban!'],
  };
  final List<String> _recentTemplates = [];
  MatchPresentationConfig config = const MatchPresentationConfig();
  bool _initialized = false;
  CasterType _lastSpeaker = CasterType.analyst;

  Future<void> initialize() async {
    if (_initialized) return;
    try {
      final specStr = await rootBundle.loadString('assets/data/match_presentation.json');
      config = MatchPresentationConfig.fromJson(jsonDecode(specStr) as Map<String, dynamic>);
    } catch (_) {}

    try {
      final commStr = await rootBundle.loadString('assets/data/commentary.json');
      final map = jsonDecode(commStr) as Map<String, dynamic>;
      _templates = map.map((k, v) => MapEntry(k, (v as List<dynamic>).map((e) => e.toString()).toList()));
    } catch (_) {}
    _initialized = true;
  }

  CommentaryLine generateLine({
    required String eventType,
    required int timestampSeconds,
    String killer = 'Kidlat',
    String victim = 'Phantom',
    String name = 'Kidlat',
    String team = 'Team Liquid PH',
    String oppTeam = 'Bakal Wolves',
    int n = 1,
    CasterType? forcedCaster,
  }) {
    final list = _templates[eventType] ?? [
      'Grabe ang laban sa pagitan ng $team at $oppTeam!'
    ];

    // Filter out templates used within last 8 lines
    final available = list.where((t) => !_recentTemplates.contains(t)).toList();
    final chosenTemplate = available.isNotEmpty
        ? available[_rng.nextInt(available.length)]
        : list[_rng.nextInt(list.length)];

    _recentTemplates.add(chosenTemplate);
    if (_recentTemplates.length > config.commentaryNoRepeatWindow) {
      _recentTemplates.removeAt(0);
    }

    final formatted = chosenTemplate
        .replaceAll('{killer}', killer)
        .replaceAll('{victim}', victim)
        .replaceAll('{name}', name)
        .replaceAll('{team}', team)
        .replaceAll('{oppTeam}', oppTeam)
        .replaceAll('{n}', n.toString());

    // Alternate casters or use strategic logic
    final speaker = forcedCaster ?? (_lastSpeaker == CasterType.hype ? CasterType.analyst : CasterType.hype);
    _lastSpeaker = speaker;

    return CommentaryLine(
      text: formatted,
      speaker: speaker,
      speakerName: speaker == CasterType.hype ? 'Kuya Chito' : 'Prof. Dan',
      speakerTitle: speaker == CasterType.hype ? 'HYPE CASTER' : 'TACTICAL ANALYST',
      timestampSeconds: timestampSeconds,
    );
  }
}
