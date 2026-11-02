import 'package:flutter_test/flutter_test.dart';
import 'package:esports_dynasty/models/game_state.dart';
import 'package:esports_dynasty/models/legacy_state.dart';
import 'package:esports_dynasty/services/sim_service.dart';
import 'package:esports_dynasty/services/legacy_service.dart';
import 'package:esports_dynasty/services/audio_manager.dart';
import 'package:esports_dynasty/services/settings_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Phase 7: 10-Year Headless Bot Simulation & Balance', () {
    test('10-year headless simulation runs under 60 seconds without crashes and avoids bankruptcy', () {
      final result = SimService.runTenYearSimulation(difficulty: 'normal');

      expect(result.durationMs, lessThan(60000), reason: 'Simulation must complete in < 60s');
      expect(result.bankrupt, isFalse, reason: 'Sensible bot on Normal difficulty must avoid bankruptcy');
      expect(result.yearRecords.length, equals(10), reason: 'Must produce 10 annual reports');

      // Verify milestones: T3 by Year 3, T5 by Year 6
      final y3 = result.yearRecords.firstWhere((r) => r.year == 3);
      expect(y3.highestTier, greaterThanOrEqualTo(3), reason: 'Target on Normal: reach T3 by Year 3');

      final y6 = result.yearRecords.firstWhere((r) => r.year == 6);
      expect(y6.highestTier, greaterThanOrEqualTo(5), reason: 'Target on Normal: reach T5 by Year 6');

      // Check final evaluation score
      expect(result.evaluation.score, greaterThan(0));
      expect(result.evaluation.legacyPointsEarned, greaterThan(0));
    });

    test('Simulation difficulty scaling affects cash and progression', () {
      final easy = SimService.runTenYearSimulation(difficulty: 'easy');
      final hard = SimService.runTenYearSimulation(difficulty: 'hard');

      expect(easy.bankrupt, isFalse);
      expect(easy.finalMoney, greaterThan(hard.finalMoney));
    });
  });

  group('Phase 7: Final Evaluation & Dynasty Ranks', () {
    test('Calculates correct dynasty rank title based on score thresholds', () {
      final state = GameState.initial(
        teamName: 'Agila Legends',
        ownerName: 'Boss Juan',
        primaryColorHex: '#1B2A49',
        secondaryColorHex: '#F5B700',
        emblemSymbol: 'crown',
        emblemLetters: 'AL',
      );

      // Low score -> Local Hero / Garage Owner
      state.fame = 100;
      state.fans = 200;
      final evalLow = LegacyService().evaluateYear10(state);
      expect(evalLow.rankTitle, anyOf('Garage Owner', 'Local Hero'));

      // High dynasty score -> World Dynasty
      state.fame = 12000;
      state.fans = 300000;
      state.money = 25000000;
      state.houseTier = 4;
      state.trophies = ['Trophy1', 'Trophy2', 'Trophy3', 'Trophy4', 'Trophy5'];
      final evalHigh = LegacyService().evaluateYear10(state);
      expect(evalHigh.score, greaterThanOrEqualTo(15000));
      expect(evalHigh.rankTitle, equals('World Dynasty'));
      expect(evalHigh.legacyPointsEarned, greaterThanOrEqualTo(30));
    });
  });

  group('Phase 7: Legacy Perks (New Game+)', () {
    test('Applies starting bonus cash, upgraded furniture, and legend coach', () {
      final state = GameState.initial(
        teamName: 'Perk Squad',
        ownerName: 'Juan',
        primaryColorHex: '#1B2A49',
        secondaryColorHex: '#F5B700',
        emblemSymbol: 'lightning',
        emblemLetters: 'PS',
        difficulty: 'normal',
        activeLegacyPerks: ['extra_cash_1', 'comfy_bed', 'pro_desk', 'legend_coach', 'dynasty_emblem'],
      );

      // P50,000 normal base + P25,000 bonus
      expect(state.money, equals(75000));
      // Comfy bed replaced bunk bed
      expect(state.furniture.any((f) => f.itemId == 'comfy_bed'), isTrue);
      // Desks upgraded to pro desks
      expect(state.furniture.any((f) => f.itemId == 'pro_desk'), isTrue);
      // Starter level 3 legend coach
      expect(state.staff.any((s) => s.id == 'coach' && s.level == 3), isTrue);
      // Dynasty emblem and starting Fame
      expect(state.emblemSymbol, equals('crown'));
      expect(state.fame, equals(100));
    });

    test('LegacyState serializes and deserializes correctly', () {
      final legacy = LegacyState(
        totalLegacyPoints: 15,
        activePerkIds: ['extra_cash_1', 'pro_desk'],
        isEndlessMode: true,
      );

      final json = legacy.toJson();
      final restored = LegacyState.fromJson(json);

      expect(restored.totalLegacyPoints, equals(15));
      expect(restored.activePerkIds, contains('extra_cash_1'));
      expect(restored.isEndlessMode, isTrue);
    });
  });

  group('Phase 7: AudioManager & Settings', () {
    test('AudioManager plays named SFX and controls BGM channels', () {
      final audio = AudioManager();
      audio.resetDiagnostics();
      audio.setSfxEnabled(true);
      audio.setSfxVolume(0.8);

      audio.playSfx(AudioSfx.coin);
      expect(audio.sfxPlayCount, equals(1));
      expect(audio.lastSfxPlayed, equals(AudioSfx.coin));

      audio.playSfx(AudioSfx.promotion);
      expect(audio.sfxPlayCount, equals(2));
      expect(audio.lastSfxPlayed, equals(AudioSfx.promotion));

      // BGM channel switching
      audio.setMusicEnabled(true);
      audio.playBgm(AudioBgm.house);
      expect(audio.currentBgm, equals(AudioBgm.house));

      audio.stopBgm();
      expect(audio.currentBgm, equals(AudioBgm.none));

      // Mute disables playback
      audio.setSfxEnabled(false);
      audio.playSfx(AudioSfx.win);
      expect(audio.sfxPlayCount, equals(2)); // Didn't increment
    });

    test('GameSettings serializes correctly with low power mode and auto-pause', () {
      final settings = GameSettings(
        sfxEnabled: true,
        musicEnabled: false,
        sfxVolume: 0.9,
        musicVolume: 0.5,
        lowPowerMode: true,
        pauseOnMatchDay: true,
        pauseOnEvents: false,
        showFps: true,
      );

      final json = settings.toJson();
      final restored = GameSettings.fromJson(json);

      expect(restored.sfxEnabled, isTrue);
      expect(restored.musicEnabled, isFalse);
      expect(restored.sfxVolume, equals(0.9));
      expect(restored.lowPowerMode, isTrue);
      expect(restored.pauseOnMatchDay, isTrue);
      expect(restored.pauseOnEvents, isFalse);
      expect(restored.showFps, isTrue);
    });
  });
}
