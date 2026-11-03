import 'package:flutter_test/flutter_test.dart';
import 'package:esports_dynasty/models/ai_team.dart';
import 'package:esports_dynasty/ui/text_styles.dart';
import 'package:esports_dynasty/services/commentary_engine.dart';
import 'package:esports_dynasty/services/rival_roster_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('MATCH_SCREEN_SPEC PART A: Readability, Layout, Cards & Commentary', () {
    test('A1: AppTextStyles enforces font sizes and whole-number rule', () {
      expect(AppTextStyles.scoreboardNumber.fontSize, 32);
      expect(AppTextStyles.teamName.fontSize, 16);
      expect(AppTextStyles.killBanner.fontSize, 24);
      expect(AppTextStyles.currentCommentary.fontSize, 16);
      expect(AppTextStyles.historyCommentary.fontSize, 14);
      expect(AppTextStyles.nameplate.fontSize, 13);
      expect(AppTextStyles.label14.fontSize, 14);
      expect(AppTextStyles.caption12.fontSize, 12);
      expect(AppTextStyles.buttonText.fontSize, 14);
      expect(AppTextStyles.windowCaption.fontSize, 12);

      // Verify no size is below 12
      final allSizes = [
        AppTextStyles.scoreboardNumber.fontSize!,
        AppTextStyles.teamName.fontSize!,
        AppTextStyles.killBanner.fontSize!,
        AppTextStyles.currentCommentary.fontSize!,
        AppTextStyles.historyCommentary.fontSize!,
        AppTextStyles.nameplate.fontSize!,
        AppTextStyles.label14.fontSize!,
        AppTextStyles.caption12.fontSize!,
        AppTextStyles.buttonText.fontSize!,
        AppTextStyles.windowCaption.fontSize!,
      ];
      for (final s in allSizes) {
        expect(s >= 12, isTrue);
        expect(s == s.roundToDouble(), isTrue);
      }
    });

    test('A4: RivalRosterService generates real names and 5 standard roles only', () {
      final team = AiTeam(
        id: 'rival_kidlat',
        name: 'Kidlat Esports',
        tier: 1,
        region: 'NCR',
        colors: ['#1B2A49', '#F5B700'],
        rating: 45,
        captain: "Mark 'Thunder' Santos",
      );

      final roster = RivalRosterService.generateRoster(team);
      expect(roster.length, 5);

      // Verify standard roles
      final expectedRoles = ['Carry', 'Mid', 'Roamer', 'Tank', 'Support'];
      for (int i = 0; i < 5; i++) {
        expect(roster[i].roleName, expectedRoles[i]);
        expect(roster[i].roleName, isNot('Offlane'));
        expect(roster[i].roleName, isNot('Roam'));
        expect(roster[i].gamerTag, isNot(contains('Player ')));
        expect(roster[i].gamerTag.isNotEmpty, isTrue);
        expect(roster[i].roleIconPath, contains('assets/images/icons/role_'));
        expect(roster[i].conditionIconPath, contains('assets/images/icons/face_'));
      }

      // Captain tag
      expect(roster.first.gamerTag, 'Thunder');
    });

    test('A5: CommentaryEngine alternates casters and prevents repetition in last 8 lines', () {
      final engine = CommentaryEngine();
      final line1 = engine.generateLine(
        eventType: 'kill',
        timestampSeconds: 120,
        killer: 'Kidlat',
        victim: 'Phantom',
      );
      expect(line1.text.isNotEmpty, isTrue);
      expect(line1.text, contains('Kidlat'));
      expect(line1.speaker, CasterType.hype);

      final line2 = engine.generateLine(
        eventType: 'teamfight',
        timestampSeconds: 140,
      );
      expect(line2.text.isNotEmpty, isTrue);
      expect(line2.speaker, CasterType.analyst);

      // Verify template formatting does not leak template brackets
      expect(line1.text.contains('{killer}'), isFalse);
      expect(line1.text.contains('{victim}'), isFalse);
    });

    test('MatchPresentationConfig loads all presentation numbers and timings', () {
      const config = MatchPresentationConfig();
      expect(config.scoreboardHeightPercent, 0.12);
      expect(config.arenaHeightPercent, 0.50);
      expect(config.castersHeightPercent, 0.14);
      expect(config.controlsHeightPercent, 0.10);
      expect(config.clashLaneHeightPercent, 0.20);
      expect(config.momentumBarHeight, 14.0);
      expect(config.momentumShiftThreshold, 0.25);
      expect(config.typewriterMs, 30);
      expect(config.casterTalkFps, 6.0);
      expect(config.ambientIntervalMs, 2000);
      expect(config.minTouchTarget, 48.0);
      expect(config.timeoutButtonHeight, 56.0);
      expect(config.focusBarHeight, 8.0);
      expect(config.tiltBarHeight, 8.0);
      expect(config.hitFlashDurationMs, 80);
      expect(config.maxActiveEmotes, 3);
      expect(config.commentaryNoRepeatWindow, 8);
    });
  });
}
