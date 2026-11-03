import 'dart:math';
import 'package:flutter/material.dart';
import '../../core/constants.dart';
import '../text_styles.dart';

enum ParticleType { hitSpark, floatingText, confetti, shockwave }

class MatchParticle {
  bool active = false;
  ParticleType type = ParticleType.hitSpark;
  double x = 0.0;
  double y = 0.0;
  double vx = 0.0;
  double vy = 0.0;
  double life = 0.0; // 1.0 down to 0.0
  double decay = 0.05;
  double size = 4.0;
  Color color = AppConstants.moneyGold;
  String text = '+1';

  void reset() {
    active = false;
    x = 0;
    y = 0;
    vx = 0;
    vy = 0;
    life = 0;
  }
}

class MatchParticlePool {
  static const int maxCapacity = 150;
  final List<MatchParticle> _pool = List.generate(maxCapacity, (_) => MatchParticle());

  void spawnHitSpark(double x, double y, Color color) {
    final rng = Random();
    for (int i = 0; i < 8; i++) {
      final p = _getAvailable();
      if (p == null) break;
      final angle = rng.nextDouble() * 2 * pi;
      final speed = 1.5 + rng.nextDouble() * 3.5;
      p.active = true;
      p.type = ParticleType.hitSpark;
      p.x = x;
      p.y = y;
      p.vx = cos(angle) * speed;
      p.vy = sin(angle) * speed;
      p.life = 1.0;
      p.decay = 0.05 + rng.nextDouble() * 0.04;
      p.size = 3.0 + rng.nextDouble() * 3.0;
      p.color = rng.nextBool() ? Colors.white : color;
    }
  }

  void spawnFloatingScore(double x, double y, {String text = '+1', Color color = AppConstants.moneyGold}) {
    final p = _getAvailable();
    if (p == null) return;
    p.active = true;
    p.type = ParticleType.floatingText;
    p.x = x;
    p.y = y;
    p.vx = 0.0;
    p.vy = -1.5;
    p.life = 1.0;
    p.decay = 0.025;
    p.size = 14.0;
    p.color = color;
    p.text = text;
  }

  void spawnConfetti(double width) {
    final rng = Random();
    const colors = [
      AppConstants.moneyGold,
      AppConstants.energyBlue,
      AppConstants.positiveGreen,
      AppConstants.negativeRed,
      Colors.white,
      Colors.purpleAccent,
    ];
    for (int i = 0; i < 35; i++) {
      final p = _getAvailable();
      if (p == null) break;
      p.active = true;
      p.type = ParticleType.confetti;
      p.x = rng.nextDouble() * width;
      p.y = -10.0 - (rng.nextDouble() * 30.0);
      p.vx = (rng.nextDouble() - 0.5) * 2.0;
      p.vy = 2.0 + rng.nextDouble() * 4.0;
      p.life = 1.0;
      p.decay = 0.015;
      p.size = 5.0 + rng.nextDouble() * 3.0;
      p.color = colors[rng.nextInt(colors.length)];
    }
  }

  void spawnShockwave(double x, double y) {
    final p = _getAvailable();
    if (p == null) return;
    p.active = true;
    p.type = ParticleType.shockwave;
    p.x = x;
    p.y = y;
    p.vx = 0;
    p.vy = 0;
    p.life = 1.0;
    p.decay = 0.04;
    p.size = 10.0;
    p.color = Colors.white;
  }

  void update() {
    for (final p in _pool) {
      if (!p.active) continue;
      p.x += p.vx;
      p.y += p.vy;
      p.life -= p.decay;
      if (p.type == ParticleType.shockwave) {
        p.size += 4.5;
      }
      if (p.life <= 0.0) {
        p.active = false;
      }
    }
  }

  MatchParticle? _getAvailable() {
    for (final p in _pool) {
      if (!p.active) return p;
    }
    return null;
  }

  List<MatchParticle> get activeParticles => _pool.where((p) => p.active).toList();
}

class MatchParticleOverlay extends StatelessWidget {
  final MatchParticlePool pool;

  const MatchParticleOverlay({super.key, required this.pool});

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: CustomPaint(
        painter: _ParticlePainter(particles: pool.activeParticles),
        child: const SizedBox.expand(),
      ),
    );
  }
}

class _ParticlePainter extends CustomPainter {
  final List<MatchParticle> particles;

  _ParticlePainter({required this.particles});

  @override
  void paint(Canvas canvas, Size size) {
    final sparkPaint = Paint()..style = PaintingStyle.fill;
    final wavePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5;

    for (final p in particles) {
      final alpha = (p.life.clamp(0.0, 1.0) * 255).toInt();
      if (alpha <= 0) continue;

      if (p.type == ParticleType.hitSpark || p.type == ParticleType.confetti) {
        sparkPaint.color = p.color.withAlpha(alpha);
        canvas.drawRect(
          Rect.fromCenter(center: Offset(p.x, p.y), width: p.size, height: p.size),
          sparkPaint,
        );
      } else if (p.type == ParticleType.shockwave) {
        wavePaint.color = p.color.withAlpha(alpha);
        canvas.drawCircle(Offset(p.x, p.y), p.size, wavePaint);
      } else if (p.type == ParticleType.floatingText) {
        final tp = TextPainter(
          text: TextSpan(
            text: p.text,
            style: AppTextStyles.label14.copyWith(
              color: p.color.withAlpha(alpha),
              shadows: AppTextStyles.navyOutline,
            ),
          ),
          textDirection: TextDirection.ltr,
        )..layout();
        tp.paint(canvas, Offset(p.x - (tp.width / 2), p.y));
      }
    }
  }

  @override
  bool shouldRepaint(covariant _ParticlePainter oldDelegate) => true;
}
