import 'package:flutter/foundation.dart';

/// Sound effect event identifiers per Style Bible Section 3
enum AudioSfx {
  tap,
  confirm,
  cancel,
  coin,
  promotion,
  win,
  lose,
  popup,
  hit,
  weekTick,
}

/// Background music loop channels per Style Bible Section 3
enum AudioBgm {
  title,
  house,
  match,
  finals,
  none,
}

class AudioManager {
  static final AudioManager _instance = AudioManager._internal();
  factory AudioManager() => _instance;
  AudioManager._internal();

  bool _sfxEnabled = true;
  bool _musicEnabled = true;
  double _sfxVolume = 0.8;
  double _musicVolume = 0.7;
  AudioBgm _currentBgm = AudioBgm.none;

  // Diagnostics and testing hooks
  int sfxPlayCount = 0;
  AudioSfx? lastSfxPlayed;
  void Function(AudioSfx sfx, double volume)? onSfxPlayed;
  void Function(AudioBgm bgm, double volume)? onBgmChanged;

  bool get sfxEnabled => _sfxEnabled;
  bool get musicEnabled => _musicEnabled;
  double get sfxVolume => _sfxVolume;
  double get musicVolume => _musicVolume;
  AudioBgm get currentBgm => _currentBgm;

  void setSfxEnabled(bool enabled) {
    _sfxEnabled = enabled;
  }

  void setMusicEnabled(bool enabled) {
    _musicEnabled = enabled;
    if (!enabled && _currentBgm != AudioBgm.none) {
      stopBgm();
    }
  }

  void setSfxVolume(double volume) {
    _sfxVolume = volume.clamp(0.0, 1.0);
  }

  void setMusicVolume(double volume) {
    _musicVolume = volume.clamp(0.0, 1.0);
    if (_musicEnabled && _currentBgm != AudioBgm.none) {
      onBgmChanged?.call(_currentBgm, _musicVolume);
    }
  }

  /// Play a named one-shot sound effect
  void playSfx(AudioSfx sfx) {
    if (!_sfxEnabled || _sfxVolume <= 0.0) return;

    sfxPlayCount++;
    lastSfxPlayed = sfx;
    onSfxPlayed?.call(sfx, _sfxVolume);

    if (kDebugMode) {
      // In debug mode, log SFX dispatch without crashing
      // debugPrint('[SFX] ${sfx.name} @ volume ${_sfxVolume.toStringAsFixed(2)}');
    }
  }

  /// Start or transition to a background music channel
  void playBgm(AudioBgm bgm) {
    if (_currentBgm == bgm) return;
    _currentBgm = bgm;

    if (!_musicEnabled || _musicVolume <= 0.0 || bgm == AudioBgm.none) {
      return;
    }

    onBgmChanged?.call(bgm, _musicVolume);

    if (kDebugMode) {
      // debugPrint('[BGM] Started track: ${bgm.name} @ volume ${_musicVolume.toStringAsFixed(2)}');
    }
  }

  /// Stop current background music
  void stopBgm() {
    _currentBgm = AudioBgm.none;
    onBgmChanged?.call(AudioBgm.none, 0.0);
  }

  /// Reset testing counters
  void resetDiagnostics() {
    sfxPlayCount = 0;
    lastSfxPlayed = null;
  }
}
