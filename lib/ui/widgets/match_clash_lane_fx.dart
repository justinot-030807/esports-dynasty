import 'dart:math';
import 'package:flutter/material.dart';
import '../../core/constants.dart';
import '../text_styles.dart';

class KillFeedEntry {
  final String killer;
  final String victim;
  final bool isUserKill;
  final String timestamp;

  const KillFeedEntry({
    required this.killer,
    required this.victim,
    required this.isUserKill,
    required this.timestamp,
  });
}

class ProjectileBeam {
  final Offset start;
  final Offset end;
  final Color color;
  double progress; // 0.0 to 1.0

  ProjectileBeam({
    required this.start,
    required this.end,
    required this.color,
    this.progress = 0.0,
  });
}

class MatchClashLaneFx extends StatelessWidget {
  final List<KillFeedEntry> killFeed;
  final List<ProjectileBeam> activeBeams;
  final bool isTeamfightActive;
  final double animPhase;

  const MatchClashLaneFx({
    super.key,
    required this.killFeed,
    required this.activeBeams,
    required this.isTeamfightActive,
    required this.animPhase,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // 1. Projectile Beams Painter
        if (activeBeams.isNotEmpty)
          Positioned.fill(
            child: IgnorePointer(
              child: CustomPaint(
                painter: _BeamPainter(beams: activeBeams),
              ),
            ),
          ),

        // 2. Teamfight Crossed Swords & Shockwaves in Clash Lane
        if (isTeamfightActive)
          Positioned.fill(
            child: IgnorePointer(
              child: Center(
                child: Transform.rotate(
                  angle: sin(animPhase * 3) * 0.15,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Transform(
                        alignment: Alignment.center,
                        transform: Matrix4.rotationY(pi),
                        child: const Icon(
                          Icons.sports_kabaddi,
                          size: 32,
                          color: AppConstants.moneyGold,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1B2A49).withValues(alpha: 0.9),
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(color: AppConstants.moneyGold, width: 2),
                        ),
                        child: const Text('⚔️ 5v5 TEAMFIGHT ⚔️', style: AppTextStyles.label14),
                      ),
                      const SizedBox(width: 8),
                      const Icon(
                        Icons.sports_kabaddi,
                        size: 32,
                        color: AppConstants.moneyGold,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

        // 3. Kill Feed (Top Right, Max 3 entries with icons)
        Positioned(
          top: 4,
          right: 8,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisSize: MainAxisSize.min,
            children: killFeed.take(3).map((k) {
              return Container(
                margin: const EdgeInsets.only(bottom: 2),
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.75),
                  borderRadius: BorderRadius.circular(3),
                  border: Border.all(
                    color: k.isUserKill ? AppConstants.energyBlue : AppConstants.negativeRed,
                    width: 1,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      k.killer,
                      style: AppTextStyles.caption12.copyWith(
                        color: k.isUserKill ? AppConstants.energyBlue : AppConstants.negativeRed,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: Image.asset(
                        'assets/images/effects/icon_skull.png',
                        width: 13,
                        height: 13,
                        fit: BoxFit.contain,
                        filterQuality: FilterQuality.none,
                        errorBuilder: (_, _, _) => const Icon(Icons.flash_on, size: 11, color: AppConstants.moneyGold),
                      ),
                    ),
                    Text(
                      k.victim,
                      style: AppTextStyles.caption12.copyWith(
                        color: k.isUserKill ? AppConstants.negativeRed : AppConstants.energyBlue,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}

class _BeamPainter extends CustomPainter {
  final List<ProjectileBeam> beams;

  _BeamPainter({required this.beams});

  @override
  void paint(Canvas canvas, Size size) {
    for (final b in beams) {
      final currentPos = Offset.lerp(b.start, b.end, b.progress.clamp(0.0, 1.0))!;
      final tailPos = Offset.lerp(b.start, b.end, (b.progress - 0.25).clamp(0.0, 1.0))!;

      final beamPaint = Paint()
        ..color = b.color
        ..strokeWidth = 3.5
        ..strokeCap = StrokeCap.round;

      final glowPaint = Paint()
        ..color = b.color.withValues(alpha: 0.4)
        ..strokeWidth = 8.0
        ..strokeCap = StrokeCap.round;

      canvas.drawLine(tailPos, currentPos, glowPaint);
      canvas.drawLine(tailPos, currentPos, beamPaint);
      canvas.drawCircle(currentPos, 4.0, Paint()..color = Colors.white);
    }
  }

  @override
  bool shouldRepaint(covariant _BeamPainter oldDelegate) => true;
}
