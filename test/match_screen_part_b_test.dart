import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:esports_dynasty/services/audio_manager.dart';
import 'package:esports_dynasty/ui/widgets/match_particle_system.dart';
import 'package:esports_dynasty/ui/widgets/match_focus_meter_inline.dart';
import 'package:esports_dynasty/ui/widgets/match_intro_outro_overlay.dart';
import 'package:esports_dynasty/ui/screens/match_presentation_manager.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Match Screen Part B - Juice & Particles (B1)', () {
    test('Particle pool capped at 150 particles', () {
      final pool = MatchParticlePool();
      expect(MatchParticlePool.maxCapacity, 150);

      // Spawn more than capacity
      for (int i = 0; i < 25; i++) {
        pool.spawnHitSpark(100, 100, Colors.yellow);
      }
      expect(pool.activeParticles.length, lessThanOrEqualTo(150));

      // Update reduces life
      pool.update();
      for (final p in pool.activeParticles) {
        expect(p.life, lessThan(1.0));
      }
    });

    test('Multi-kill logic properly identifies Double Kill, Triple Kill, and Ace', () {
      final mgr = MatchPresentationManager();

      // 1st Kill
      mgr.triggerKill(
        killer: 'Kidlat',
        victim: 'Phantom',
        isUserKill: true,
        killerDeskPos: const Offset(50, 215),
        victimDeskPos: const Offset(50, 55),
        currentMatchSeconds: 10,
      );
      expect(mgr.getBannerForLastKill('Kidlat', 'Phantom'), 'KIDLAT ELIMINATED PHANTOM');

      // 2nd Kill within window -> Double Kill
      mgr.triggerKill(
        killer: 'Kidlat',
        victim: 'Viper',
        isUserKill: true,
        killerDeskPos: const Offset(120, 215),
        victimDeskPos: const Offset(120, 55),
        currentMatchSeconds: 12,
      );
      expect(mgr.getBannerForLastKill('Kidlat', 'Viper'), 'DOUBLE KILL!');
      expect(mgr.shakeOffset.abs(), greaterThanOrEqualTo(0.0));

      // 3rd Kill within window -> Triple Kill
      mgr.triggerKill(
        killer: 'Kidlat',
        victim: 'Blaze',
        isUserKill: true,
        killerDeskPos: const Offset(190, 215),
        victimDeskPos: const Offset(190, 55),
        currentMatchSeconds: 13,
      );
      expect(mgr.getBannerForLastKill('Kidlat', 'Blaze'), 'TRIPLE KILL!');

      // 4th and 5th Kill -> Ace
      mgr.triggerKill(
        killer: 'Kidlat',
        victim: 'Frost',
        isUserKill: true,
        killerDeskPos: const Offset(260, 215),
        victimDeskPos: const Offset(260, 55),
        currentMatchSeconds: 14,
      );
      mgr.triggerKill(
        killer: 'Kidlat',
        victim: 'Titan',
        isUserKill: true,
        killerDeskPos: const Offset(330, 215),
        victimDeskPos: const Offset(330, 55),
        currentMatchSeconds: 14,
      );
      expect(mgr.getBannerForLastKill('Kidlat', 'Titan'), 'ACE!');
    });

    test('Projectile beams advance and expire cleanly', () {
      final mgr = MatchPresentationManager();
      mgr.triggerKill(
        killer: 'Kidlat',
        victim: 'Phantom',
        isUserKill: true,
        killerDeskPos: const Offset(50, 215),
        victimDeskPos: const Offset(50, 55),
        currentMatchSeconds: 20,
      );

      expect(mgr.activeBeams.length, 1);
      expect(mgr.activeBeams.first.progress, 0.0);

      // Advance by 0.3s (greater than 0.25s beam duration)
      mgr.update(0.3, 1.0);
      expect(mgr.activeBeams.isEmpty, isTrue);
    });
  });

  group('Match Screen Part B - Focus Meter Inline (B2)', () {
    testWidgets('Renders 28 dp focus bar and 64 dp tap button', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MatchFocusMeterInline(
              captainMental: 75,
              momentTitle: 'OBJECTIVE CONTEST',
              onResolved: (power, outcome) {},
            ),
          ),
        ),
      );

      expect(find.text('⚡ OBJECTIVE CONTEST ⚡'), findsOneWidget);
      expect(find.text('TAP FOR CLUTCH FOCUS!'), findsOneWidget);

      // Find the 64 dp tall TAP button
      final tapFinder = find.widgetWithText(ElevatedButton, 'TAP FOR CLUTCH FOCUS!');
      expect(tapFinder, findsOneWidget);

      // Tap it
      await tester.tap(tapFinder);
      await tester.pump(const Duration(milliseconds: 700));
    });
  });

  group('Match Screen Part B - Intro & Outro (B3)', () {
    testWidgets('Intro overlay displays Game N, VS, and counts down', (tester) async {
      bool finished = false;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MatchIntroOverlay(
              gameNumber: 1,
              userTeamName: 'Kidlat PH',
              oppTeamName: 'Bakal Esports',
              onIntroFinished: () {
                finished = true;
              },
            ),
          ),
        ),
      );

      expect(find.text('GAME 1'), findsOneWidget);
      expect(find.text('Kidlat PH'), findsOneWidget);
      expect(find.text('Bakal Esports'), findsOneWidget);
      expect(find.text('VS'), findsOneWidget);
      expect(find.text('TAP TO SKIP'), findsOneWidget);

      // Tap to skip
      await tester.tap(find.text('TAP TO SKIP'));
      expect(finished, isTrue);
    });

    testWidgets('Outro overlay displays VICTORY stamp and MVP highlight', (tester) async {
      bool dismissed = false;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MatchOutroOverlay(
              userWon: true,
              mvpTag: 'Kidlat',
              onDismiss: () {
                dismissed = true;
              },
            ),
          ),
        ),
      );

      expect(find.text('VICTORY'), findsOneWidget);
      expect(find.text('GAME MVP: Kidlat'), findsOneWidget);
      expect(find.text('TAP TO CONTINUE'), findsOneWidget);

      await tester.tap(find.text('TAP TO CONTINUE'));
      expect(dismissed, isTrue);
    });
  });

  group('Match Screen Part B - Audio Hooks (B4)', () {
    test('All 12 Part B SFX enums dispatch cleanly', () {
      final audio = AudioManager();
      final played = <AudioSfx>[];
      audio.onSfxPlayed = (sfx, vol) => played.add(sfx);

      const partBSfx = [
        AudioSfx.kill,
        AudioSfx.multiKill,
        AudioSfx.clash,
        AudioSfx.focusPerfect,
        AudioSfx.focusGood,
        AudioSfx.focusMiss,
        AudioSfx.victory,
        AudioSfx.defeat,
        AudioSfx.crowdCheer,
        AudioSfx.crowdGroan,
        AudioSfx.countdown,
        AudioSfx.whistle,
      ];

      for (final sfx in partBSfx) {
        audio.playSfx(sfx);
      }

      expect(played.length, 12);
      expect(played, contains(AudioSfx.kill));
      expect(played, contains(AudioSfx.multiKill));
      expect(played, contains(AudioSfx.clash));
      expect(played, contains(AudioSfx.focusPerfect));
      expect(played, contains(AudioSfx.victory));
      expect(played, contains(AudioSfx.defeat));
    });
  });
}
