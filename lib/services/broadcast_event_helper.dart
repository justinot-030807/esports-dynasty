import 'dart:math';
import '../models/player.dart';
import 'data_service.dart';

class BroadcastEvent {
  final bool hasKill;
  final bool isUserKill;
  final String? popupText;
  final String? popupTarget;
  final String? commentary;

  const BroadcastEvent({
    this.hasKill = false,
    this.isUserKill = false,
    this.popupText,
    this.popupTarget,
    this.commentary,
  });
}

class BroadcastEventHelper {
  static final Random _rng = Random();

  static BroadcastEvent? rollTickEvent({
    required String timeStr,
    required String userTeamName,
    required String oppTeamName,
    required String oppCaptain,
    required List<Player> starters,
    String divisionId = 'arena_clash',
  }) {
    // 1. Roll for kill event
    if (_rng.nextDouble() < 0.22 && starters.isNotEmpty) {
      final isUserKill = _rng.nextDouble() < 0.52;
      if (isUserKill) {
        final p = starters[_rng.nextInt(starters.length)];
        final killLabel = divisionId == 'strike_zone'
            ? 'HEADSHOT! ${p.gamerTag}'
            : (divisionId == 'last_island' ? 'KNOCK! ${p.gamerTag}' : 'KILL! ${p.gamerTag}');
        final killCommentary = divisionId == 'strike_zone'
            ? '[$timeStr] Solid na headshot flick ang pinakawalan ni ${p.gamerTag}!'
            : (divisionId == 'last_island'
                ? '[$timeStr] Na-knock ni ${p.gamerTag} ang kalaban mula sa ridge!'
                : '[$timeStr] Pinatumba ni ${p.gamerTag} ang kalaban!');

        return BroadcastEvent(
          hasKill: true,
          isUserKill: true,
          popupText: killLabel,
          popupTarget: 'user',
          commentary: killCommentary,
        );
      } else {
        final oppLabel = divisionId == 'strike_zone'
            ? 'HEADSHOT! $oppCaptain'
            : (divisionId == 'last_island' ? 'KNOCK! $oppCaptain' : 'KILL! $oppCaptain');
        final oppCommentary = divisionId == 'strike_zone'
            ? '[$timeStr] Na-crossfire ni $oppCaptain ang ating depensa!'
            : (divisionId == 'last_island'
                ? '[$timeStr] Na-ambush ni $oppCaptain ang ating pambato sa edge ng circle!'
                : '[$timeStr] Pinaslang ni $oppCaptain ang isa sa ating mga pambato!');

        return BroadcastEvent(
          hasKill: true,
          isUserKill: false,
          popupText: oppLabel,
          popupTarget: 'opp',
          commentary: oppCommentary,
        );
      }
    }

    // 2. Roll for general Taglish caster commentary
    if (_rng.nextDouble() < 0.12 && DataService().matchCommentary.isNotEmpty && starters.isNotEmpty) {
      final raw = DataService().matchCommentary[_rng.nextInt(DataService().matchCommentary.length)];
      final p = starters[_rng.nextInt(starters.length)];
      final line = raw
          .replaceAll('{player}', p.gamerTag)
          .replaceAll('{team}', userTeamName);
      return BroadcastEvent(
        commentary: '[$timeStr] $line',
      );
    }

    return null;
  }
}
