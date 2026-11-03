import 'dart:math';
import 'package:flutter/material.dart';
import '../../core/constants.dart';
import '../../models/player.dart';
import '../text_styles.dart';
import '../../services/rival_roster_service.dart';
import 'match_player_card.dart';

class MatchArenaView extends StatelessWidget {
  final int tier;
  final bool isGrandFinal;
  final String userTeamName;
  final String oppTeamName;
  final List<Player> userStarters;
  final List<RivalPlayerDisplayData> rivalRoster;
  final double momentum; // -1.0 (Opponent ahead) to +1.0 (User ahead)
  final double winChancePercent; // e.g. 55.0
  final bool showMomentumShiftBanner;
  final String? activeKillBanner;
  final String? activeBannerTarget; // 'user' or 'opp'
  final double animPhase;
  final Map<String, String> activeEmotes;
  final Map<String, String> playerStates;
  final double cameraZoom;
  final double shakeOffset;
  final bool isDesaturated;
  final Widget? inlineFocusMeter;
  final Widget? clashFxOverlay;

  const MatchArenaView({
    super.key,
    required this.tier,
    required this.isGrandFinal,
    required this.userTeamName,
    required this.oppTeamName,
    required this.userStarters,
    required this.rivalRoster,
    required this.momentum,
    required this.winChancePercent,
    this.showMomentumShiftBanner = false,
    this.activeKillBanner,
    this.activeBannerTarget,
    required this.animPhase,
    this.activeEmotes = const {},
    this.playerStates = const {},
    this.cameraZoom = 1.0,
    this.shakeOffset = 0.0,
    this.isDesaturated = false,
    this.inlineFocusMeter,
    this.clashFxOverlay,
  });

  String _getStageBackground() {
    if (tier >= 7 || (tier == 6 && isGrandFinal)) {
      return 'assets/images/backgrounds/match_stage_world.png';
    } else if (tier >= 3) {
      return 'assets/images/backgrounds/match_stage_arena.png';
    }
    return 'assets/images/backgrounds/match_stage_community.png';
  }

  String _getKillBannerAsset(String text) {
    final upper = text.toUpperCase();
    if (upper.contains('ACE')) return 'assets/images/effects/banner_ace.png';
    if (upper.contains('CLUTCH')) return 'assets/images/effects/banner_clutch.png';
    if (upper.contains('MULTI') || upper.contains('DOUBLE') || upper.contains('TRIPLE') || upper.contains('RAMPAGE')) {
      return 'assets/images/effects/banner_multi.png';
    }
    return 'assets/images/effects/banner_kill.png';
  }

  Widget _buildCrowdStrip() {
    const crowd = [
      'fan_kid', 'fan_teen', 'fan_student', 'fan_cosplayer',
      'fan_mascot', 'fan_vlogger', 'fan_kagawad'
    ];
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: List.generate(crowd.length, (i) {
        final f = crowd[i];
        final waveY = sin(animPhase + (i * 0.8)) * 2.5;
        return Transform.translate(
          offset: Offset(0, waveY),
          child: Image.asset(
            'assets/images/characters/$f/${f}_front_idle.png',
            width: 24,
            height: 24,
            fit: BoxFit.contain,
            filterQuality: FilterQuality.none,
            errorBuilder: (_, _, _) => const SizedBox(),
          ),
        );
      }),
    );
  }

  Widget _buildClashLane() {
    if (inlineFocusMeter != null) {
      return inlineFocusMeter!;
    }
    // Momentum factor 0.0 to 1.0 (0.5 is even)
    final clampedFactor = ((momentum + 1.0) / 2.0).clamp(0.05, 0.95);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Kill Banner / Highlight Popups (22 to 28 dp)
          if (activeKillBanner != null)
            Container(
              margin: const EdgeInsets.only(bottom: 4),
              child: Image.asset(
                _getKillBannerAsset(activeKillBanner!),
                height: 28,
                fit: BoxFit.contain,
                filterQuality: FilterQuality.none,
                errorBuilder: (_, _, _) => Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  decoration: BoxDecoration(
                    color: activeBannerTarget == 'user' ? const Color(0xFF1B4E3B) : const Color(0xFF4A1A22),
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(
                      color: activeBannerTarget == 'user' ? AppConstants.positiveGreen : AppConstants.negativeRed,
                      width: 2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: (activeBannerTarget == 'user' ? AppConstants.positiveGreen : AppConstants.negativeRed).withValues(alpha: 0.5),
                        blurRadius: 8,
                      ),
                    ],
                  ),
                  child: Text(
                    activeKillBanner!,
                    style: AppTextStyles.killBanner.copyWith(
                      color: activeBannerTarget == 'user' ? AppConstants.moneyGold : Colors.white,
                    ),
                  ),
                ),
              ),
            )
          else if (showMomentumShiftBanner)
            Container(
              margin: const EdgeInsets.only(bottom: 4),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 3),
              decoration: BoxDecoration(
                color: const Color(0xFF1B2A49),
                borderRadius: BorderRadius.circular(4),
                border: Border.all(color: AppConstants.moneyGold, width: 2),
              ),
              child: const Text('⚡ MOMENTUM SHIFT! ⚡', style: AppTextStyles.killBanner),
            ),

          // Momentum Label & Win Chance (14 dp)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('${winChancePercent.toStringAsFixed(0)}% WIN CHANCE', style: AppTextStyles.label14),
              Text('${(100 - winChancePercent).toStringAsFixed(0)}% WIN CHANCE', style: AppTextStyles.label14),
            ],
          ),
          const SizedBox(height: 2),

          // 14 dp tall tug-of-war bar with glowing marker
          Container(
            height: 14,
            decoration: BoxDecoration(
              color: const Color(0xFF0F1826),
              borderRadius: BorderRadius.circular(3),
              border: Border.all(color: const Color(0xFF2C3E60), width: 1.5),
            ),
            child: Stack(
              alignment: Alignment.centerLeft,
              children: [
                // Split team colors
                Row(
                  children: [
                    Expanded(
                      flex: (clampedFactor * 100).toInt(),
                      child: Container(color: AppConstants.energyBlue),
                    ),
                    Expanded(
                      flex: ((1.0 - clampedFactor) * 100).toInt(),
                      child: Container(color: AppConstants.negativeRed),
                    ),
                  ],
                ),
                // Glowing Center Marker
                Positioned(
                  left: (clampedFactor * 300).clamp(0.0, 300.0),
                  child: Container(
                    width: 6,
                    height: 14,
                    decoration: BoxDecoration(
                      color: AppConstants.moneyGold,
                      borderRadius: BorderRadius.circular(2),
                      boxShadow: [
                        BoxShadow(
                          color: AppConstants.moneyGold.withValues(alpha: 0.8),
                          blurRadius: 4,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    Widget arenaColumn = Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // 1. Crowd in the arena stands
        _buildCrowdStrip(),

        // 2. Rival Team Row (Top, facing down)
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: rivalRoster.map((r) {
            return MatchPlayerCard(
              tag: r.gamerTag,
              roleName: r.roleName,
              roleIconPath: r.roleIconPath,
              conditionIconPath: r.conditionIconPath,
              avatarPath: r.avatarPath,
              teamColor: AppConstants.negativeRed,
              focus: r.focus,
              tilt: r.tilt,
              state: playerStates[r.gamerTag] ?? playerStates['__opp__'] ?? r.state,
              respawnSeconds: r.respawnSeconds,
              activeEmote: activeEmotes[r.gamerTag],
              animPhase: animPhase,
              isFacingDown: true,
            );
          }).toList(),
        ),

        // 3. Center Clash Lane (~20% of arena)
        _buildClashLane(),

        // 4. User Team Row (Bottom, facing up)
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: userStarters.take(5).map((p) {
            final roleName = _normalizeRole(p.role.name);
            final roleIcon = _getRoleIcon(roleName);
            final condIcon = _getConditionIcon(p.condition.name);

            return MatchPlayerCard(
              tag: p.gamerTag,
              roleName: roleName,
              roleIconPath: roleIcon,
              conditionIconPath: condIcon,
              avatarPath: p.avatarPath,
              teamColor: AppConstants.energyBlue,
              focus: p.morale.toDouble(),
              tilt: p.fatigue.toDouble().clamp(10.0, 90.0),
              state: playerStates[p.gamerTag] ?? playerStates['__user__'] ?? 'idle',
              activeEmote: activeEmotes[p.gamerTag],
              animPhase: animPhase,
              isFacingDown: false,
            );
          }).toList(),
        ),
        const SizedBox(height: 4),
      ],
    );

    Widget stack = Stack(
      children: [
        arenaColumn,
        if (clashFxOverlay != null) Positioned.fill(child: clashFxOverlay!),
      ],
    );

    if (shakeOffset != 0.0) {
      stack = Transform.translate(offset: Offset(shakeOffset, 0), child: stack);
    }
    if (cameraZoom != 1.0) {
      stack = Transform.scale(scale: cameraZoom, child: stack);
    }
    if (isDesaturated) {
      stack = ColorFiltered(
        colorFilter: const ColorFilter.mode(Colors.grey, BlendMode.saturation),
        child: stack,
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF0D1420),
        image: DecorationImage(
          image: AssetImage(_getStageBackground()),
          fit: BoxFit.cover,
          filterQuality: FilterQuality.medium,
          colorFilter: ColorFilter.mode(
            Colors.black.withValues(alpha: 0.65),
            BlendMode.darken,
          ),
          onError: (e, s) {},
        ),
      ),
      child: stack,
    );
  }

  String _normalizeRole(String raw) {
    final lower = raw.toLowerCase();
    if (lower.contains('carry') || lower.contains('entry') || lower.contains('scout')) return 'Carry';
    if (lower.contains('mid') || lower.contains('sniper') || lower.contains('assault')) return 'Mid';
    if (lower.contains('roam') || lower.contains('igl') || lower.contains('caller')) return 'Roamer';
    if (lower.contains('tank') || lower.contains('anchor') || lower.contains('offlane')) return 'Tank';
    return 'Support';
  }

  String _getRoleIcon(String role) {
    switch (role) {
      case 'Carry': return 'assets/images/icons/role_carry.png';
      case 'Mid': return 'assets/images/icons/role_mid.png';
      case 'Roamer': return 'assets/images/icons/role_roamer.png';
      case 'Tank': return 'assets/images/icons/role_tank.png';
      default: return 'assets/images/icons/role_support.png';
    }
  }

  String _getConditionIcon(String cond) {
    switch (cond.toLowerCase()) {
      case 'great': return 'assets/images/icons/face_great.png';
      case 'good': return 'assets/images/icons/face_good.png';
      case 'tired': return 'assets/images/icons/face_tired.png';
      case 'exhausted': return 'assets/images/icons/face_exhausted.png';
      default: return 'assets/images/icons/face_normal.png';
    }
  }
}
