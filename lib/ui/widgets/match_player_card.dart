import 'dart:math';
import 'package:flutter/material.dart';
import '../../core/constants.dart';
import '../text_styles.dart';

class MatchPlayerCard extends StatelessWidget {
  final String tag;
  final String roleName;
  final String roleIconPath;
  final String conditionIconPath;
  final String avatarPath;
  final Color teamColor;
  final double focus;
  final double tilt;
  final String state; // 'idle', 'attacking', 'hit', 'dead', 'hot_streak', 'tilted'
  final int respawnSeconds;
  final String? activeEmote;
  final double animPhase;
  final bool isFacingDown;

  const MatchPlayerCard({
    super.key,
    required this.tag,
    required this.roleName,
    required this.roleIconPath,
    required this.conditionIconPath,
    required this.avatarPath,
    required this.teamColor,
    required this.focus,
    required this.tilt,
    this.state = 'idle',
    this.respawnSeconds = 0,
    this.activeEmote,
    this.animPhase = 0.0,
    this.isFacingDown = false,
  });

  String _getSeatedSprite() {
    final prefix = isFacingDown ? 'red' : 'blue';
    if (state == 'cheer' || state == 'win') {
      return 'assets/images/characters/match/seated_${prefix}_cheer.png';
    }
    if (state == 'slump' || state == 'dead' || state == 'tilted' || tilt >= 70) {
      return 'assets/images/characters/match/seated_${prefix}_slump.png';
    }
    return 'assets/images/characters/match/seated_${prefix}_focus.png';
  }

  @override
  Widget build(BuildContext context) {
    final isDead = state == 'dead';
    final isHit = state == 'hit';
    final isAttacking = state == 'attacking';
    final isHot = state == 'hot_streak';
    final isTilted = state == 'tilted' || tilt >= 70;

    // Breathing & typing bob
    final bobY = isDead ? 4.0 : (isAttacking ? (isFacingDown ? 4.0 : -4.0) : sin(animPhase) * 1.5);
    final shakeX = isHit ? (sin(animPhase * 8) * 3.0) : 0.0;

    // Tilt bar color from orange to red
    final tiltColor = Color.lerp(
      const Color(0xFFFF9800),
      AppConstants.negativeRed,
      (tilt / 100.0).clamp(0.0, 1.0),
    )!;

    return Container(
      width: 58,
      margin: const EdgeInsets.symmetric(horizontal: 2),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 1. Emote Bubble if present
          SizedBox(
            height: 18,
            child: activeEmote != null
                ? Image.asset(
                    activeEmote!,
                    width: 16,
                    height: 16,
                    fit: BoxFit.contain,
                    filterQuality: FilterQuality.none,
                    errorBuilder: (_, _, _) => const Icon(Icons.mood, size: 14, color: AppConstants.moneyGold),
                  )
                : (isHot
                    ? const Icon(Icons.star, size: 16, color: AppConstants.moneyGold)
                    : (isTilted
                        ? Image.asset(
                            'assets/images/effects/emote_sweat.png',
                            width: 14,
                            height: 14,
                            filterQuality: FilterQuality.none,
                            errorBuilder: (_, _, _) => const SizedBox(),
                          )
                        : const SizedBox())),
          ),

          // 2. Chibi Avatar seated at desk
          Transform.translate(
            offset: Offset(shakeX, bobY),
            child: Stack(
              clipBehavior: Clip.none,
              alignment: Alignment.center,
              children: [
                // Desk background prop
                Image.asset(
                  'assets/images/furniture/pro_desk.png',
                  width: 52,
                  height: 32,
                  fit: BoxFit.contain,
                  filterQuality: FilterQuality.none,
                  errorBuilder: (_, _, _) => Container(
                    width: 52,
                    height: 28,
                    decoration: BoxDecoration(
                      color: const Color(0xFF1B2A49),
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(color: teamColor.withValues(alpha: 0.6)),
                    ),
                  ),
                ),

                // Seated Chibi Player Sprite
                Container(
                  foregroundDecoration: isHit
                      ? const BoxDecoration(color: Colors.white70)
                      : (isDead
                          ? const BoxDecoration(color: Colors.black54)
                          : (isTilted
                              ? BoxDecoration(color: Colors.red.withValues(alpha: 0.25))
                              : null)),
                  child: ColorFiltered(
                    colorFilter: isDead
                        ? const ColorFilter.mode(Colors.grey, BlendMode.saturation)
                        : const ColorFilter.mode(Colors.transparent, BlendMode.dst),
                    child: Image.asset(
                      _getSeatedSprite(),
                      width: 36,
                      height: 36,
                      fit: BoxFit.contain,
                      filterQuality: FilterQuality.none,
                      errorBuilder: (_, _, _) => Image.asset(
                        avatarPath,
                        width: 34,
                        height: 34,
                        fit: BoxFit.contain,
                        filterQuality: FilterQuality.none,
                        errorBuilder: (_, _, _) => Icon(
                          Icons.person,
                          size: 26,
                          color: isDead ? Colors.grey : teamColor,
                        ),
                      ),
                    ),
                  ),
                ),

                // Dead state: Skull + respawn timer
                if (isDead)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                    decoration: BoxDecoration(
                      color: Colors.black87,
                      borderRadius: BorderRadius.circular(3),
                    ),
                    child: Text(
                      '${respawnSeconds}s',
                      style: AppTextStyles.caption12.copyWith(color: AppConstants.negativeRed),
                    ),
                  ),
              ],
            ),
          ),

          const SizedBox(height: 2),

          // 3. Nameplate (13 dp bold)
          Text(
            tag,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.nameplate,
          ),

          // 4. Role Icon + Condition Face
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                roleIconPath,
                width: 14,
                height: 14,
                filterQuality: FilterQuality.none,
                errorBuilder: (_, _, _) => const Icon(Icons.flash_on, size: 12, color: AppConstants.moneyGold),
              ),
              const SizedBox(width: 4),
              Image.asset(
                conditionIconPath,
                width: 14,
                height: 14,
                filterQuality: FilterQuality.none,
                errorBuilder: (_, _, _) => const Icon(Icons.sentiment_satisfied, size: 12, color: Colors.green),
              ),
            ],
          ),

          const SizedBox(height: 3),

          // 5. Thick 8 dp FOCUS bar (Blue) with small lightning icon
          Row(
            children: [
              const Icon(Icons.bolt, size: 10, color: AppConstants.energyBlue),
              const SizedBox(width: 2),
              Expanded(
                child: Container(
                  height: 8,
                  decoration: BoxDecoration(
                    color: const Color(0xFF0D1626),
                    borderRadius: BorderRadius.circular(2),
                    border: Border.all(color: const Color(0xFF1F3559), width: 1),
                  ),
                  child: FractionallySizedBox(
                    alignment: Alignment.centerLeft,
                    widthFactor: (focus / 100.0).clamp(0.05, 1.0),
                    child: Container(
                      decoration: BoxDecoration(
                        color: AppConstants.energyBlue,
                        borderRadius: BorderRadius.circular(1.5),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 2),

          // 6. Thick 8 dp TILT bar (Orange to Red) with flame icon
          Row(
            children: [
              Icon(Icons.local_fire_department, size: 10, color: tiltColor),
              const SizedBox(width: 2),
              Expanded(
                child: Container(
                  height: 8,
                  decoration: BoxDecoration(
                    color: const Color(0xFF0D1626),
                    borderRadius: BorderRadius.circular(2),
                    border: Border.all(color: const Color(0xFF1F3559), width: 1),
                  ),
                  child: FractionallySizedBox(
                    alignment: Alignment.centerLeft,
                    widthFactor: (tilt / 100.0).clamp(0.05, 1.0),
                    child: Container(
                      decoration: BoxDecoration(
                        color: tiltColor,
                        borderRadius: BorderRadius.circular(1.5),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
