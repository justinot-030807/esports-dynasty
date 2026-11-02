import 'package:shared_preferences/shared_preferences.dart';
import 'audio_manager.dart';

class GameSettings {
  bool sfxEnabled;
  bool musicEnabled;
  double sfxVolume;
  double musicVolume;
  bool lowPowerMode;
  bool pauseOnMatchDay;
  bool pauseOnEvents;
  bool showFps;

  GameSettings({
    this.sfxEnabled = true,
    this.musicEnabled = true,
    this.sfxVolume = 0.8,
    this.musicVolume = 0.7,
    this.lowPowerMode = false,
    this.pauseOnMatchDay = true,
    this.pauseOnEvents = true,
    this.showFps = false,
  });

  Map<String, dynamic> toJson() => {
        'sfx_enabled': sfxEnabled,
        'music_enabled': musicEnabled,
        'sfx_volume': sfxVolume,
        'music_volume': musicVolume,
        'low_power_mode': lowPowerMode,
        'pause_on_match_day': pauseOnMatchDay,
        'pause_on_events': pauseOnEvents,
        'show_fps': showFps,
      };

  factory GameSettings.fromJson(Map<String, dynamic> json) => GameSettings(
        sfxEnabled: json['sfx_enabled'] as bool? ?? true,
        musicEnabled: json['music_enabled'] as bool? ?? true,
        sfxVolume: (json['sfx_volume'] as num?)?.toDouble() ?? 0.8,
        musicVolume: (json['music_volume'] as num?)?.toDouble() ?? 0.7,
        lowPowerMode: json['low_power_mode'] as bool? ?? false,
        pauseOnMatchDay: json['pause_on_match_day'] as bool? ?? true,
        pauseOnEvents: json['pause_on_events'] as bool? ?? true,
        showFps: json['show_fps'] as bool? ?? false,
      );
}

class SettingsService {
  static final SettingsService _instance = SettingsService._internal();
  factory SettingsService() => _instance;
  SettingsService._internal();

  GameSettings current = GameSettings();
  bool _initialized = false;

  Future<void> init() async {
    if (_initialized) return;
    try {
      final prefs = await SharedPreferences.getInstance();
      current.sfxEnabled = prefs.getBool('setting_sfx_enabled') ?? true;
      current.musicEnabled = prefs.getBool('setting_music_enabled') ?? true;
      current.sfxVolume = prefs.getDouble('setting_sfx_volume') ?? 0.8;
      current.musicVolume = prefs.getDouble('setting_music_volume') ?? 0.7;
      current.lowPowerMode = prefs.getBool('setting_low_power_mode') ?? false;
      current.pauseOnMatchDay = prefs.getBool('setting_pause_match_day') ?? true;
      current.pauseOnEvents = prefs.getBool('setting_pause_events') ?? true;
      current.showFps = prefs.getBool('setting_show_fps') ?? false;

      // Sync with AudioManager
      final audio = AudioManager();
      audio.setSfxEnabled(current.sfxEnabled);
      audio.setMusicEnabled(current.musicEnabled);
      audio.setSfxVolume(current.sfxVolume);
      audio.setMusicVolume(current.musicVolume);

      _initialized = true;
    } catch (_) {
      // In tests or headless environments, keep in-memory defaults
      _initialized = true;
    }
  }

  Future<void> saveSettings() async {
    // Sync audio manager
    final audio = AudioManager();
    audio.setSfxEnabled(current.sfxEnabled);
    audio.setMusicEnabled(current.musicEnabled);
    audio.setSfxVolume(current.sfxVolume);
    audio.setMusicVolume(current.musicVolume);

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('setting_sfx_enabled', current.sfxEnabled);
      await prefs.setBool('setting_music_enabled', current.musicEnabled);
      await prefs.setDouble('setting_sfx_volume', current.sfxVolume);
      await prefs.setDouble('setting_music_volume', current.musicVolume);
      await prefs.setBool('setting_low_power_mode', current.lowPowerMode);
      await prefs.setBool('setting_pause_match_day', current.pauseOnMatchDay);
      await prefs.setBool('setting_pause_events', current.pauseOnEvents);
      await prefs.setBool('setting_show_fps', current.showFps);
    } catch (_) {}
  }
}
