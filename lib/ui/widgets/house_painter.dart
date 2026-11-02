import 'dart:math';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import '../../core/constants.dart';
import '../../models/game_state.dart';
import '../../models/player.dart';
import '../../models/placed_furniture.dart';

class HousePainter extends CustomPainter {
  final GameState state;
  final double elapsedSeconds;
  final double zoomLevel;
  final Offset panOffset;
  final ui.Image? charIdle;
  final ui.Image? charStep1;
  final ui.Image? charStep2;
  final ui.Image? deskImage;
  final ui.Image? bedImage;
  final ui.Image? kitchenImage;
  final ui.Image? shelfImage;
  final ui.Image? roomBg;

  HousePainter({
    required this.state,
    required this.elapsedSeconds,
    required this.zoomLevel,
    required this.panOffset,
    this.charIdle,
    this.charStep1,
    this.charStep2,
    this.deskImage,
    this.bedImage,
    this.kitchenImage,
    this.shelfImage,
    this.roomBg,
  });

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.translate(panOffset.dx, panOffset.dy);
    canvas.scale(zoomLevel, zoomLevel);

    // 1. Draw Room Background / Floor & Walls
    final roomRect = Rect.fromLTWH(0, 0, size.width, size.height);
    if (roomBg != null) {
      final src = Rect.fromLTWH(0, 0, roomBg!.width.toDouble(), roomBg!.height.toDouble());
      canvas.drawImageRect(roomBg!, src, roomRect, Paint()..filterQuality = FilterQuality.none);
    } else {
      _drawProceduralRoom(canvas, size);
    }

    // 2. Day / Night ambient tint
    _drawDayNightTint(canvas, size);

    // 3. Depth Sorting: collect all entities (furniture + players) and sort by Y
    final renderables = <_RenderItem>[];

    for (final f in state.furniture) {
      final screenX = (f.tileX * 36.0) + 15.0;
      final screenY = (f.tileY * 36.0) + 40.0;
      renderables.add(_RenderItem(
        y: screenY + (f.sizeY * 30.0),
        draw: (c) => _drawFurniture(c, f, screenX, screenY),
      ));
    }

    for (int i = 0; i < state.players.length; i++) {
      final p = state.players[i];
      final px = p.posX * size.width;
      final py = p.posY * size.height;
      renderables.add(_RenderItem(
        y: py,
        draw: (c) => _drawPlayer(c, p, px, py, i),
      ));
    }

    renderables.sort((a, b) => a.y.compareTo(b.y));

    for (final item in renderables) {
      item.draw(canvas);
    }

    // 4. Floating Text Notifications
    _drawNotifications(canvas, size);

    canvas.restore();
  }

  void _drawProceduralRoom(Canvas canvas, Size size) {
    final wallPaint = Paint()..color = const Color(0xFF2A3B5C);
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height * 0.4), wallPaint);

    final floorPaint = Paint()..color = const Color(0xFFC49A6C);
    canvas.drawRect(Rect.fromLTWH(0, size.height * 0.4, size.width, size.height * 0.6), floorPaint);

    final linePaint = Paint()
      ..color = const Color(0x331B2A49)
      ..strokeWidth = 1.0;
    for (double x = 0; x < size.width; x += 32) {
      canvas.drawLine(Offset(x, size.height * 0.4), Offset(x, size.height), linePaint);
    }
    for (double y = size.height * 0.4; y < size.height; y += 32) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), linePaint);
    }
  }

  void _drawDayNightTint(Canvas canvas, Size size) {
    final dayPhase = (state.day - 1) / 7.0;
    Color tintColor;
    if (dayPhase < 0.5) {
      tintColor = Colors.transparent;
    } else if (dayPhase < 0.75) {
      tintColor = const Color(0x18F5B700);
    } else {
      tintColor = const Color(0x281B2A49);
    }

    if (tintColor != Colors.transparent) {
      canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), Paint()..color = tintColor);
    }
  }

  void _drawFurniture(Canvas canvas, PlacedFurniture f, double x, double y) {
    ui.Image? img;
    switch (f.station) {
      case 'pc': img = deskImage; break;
      case 'bed': img = bedImage; break;
      case 'kitchen': img = kitchenImage; break;
      case 'shelf': img = shelfImage; break;
    }

    final fw = f.sizeX * 42.0;
    final fh = f.sizeY * 46.0;

    if (img != null) {
      final src = Rect.fromLTWH(0, 0, img.width.toDouble(), img.height.toDouble());
      final dst = Rect.fromLTWH(x, y, fw, fh);
      canvas.drawImageRect(img, src, dst, Paint()..filterQuality = FilterQuality.none);
    } else {
      final boxPaint = Paint()..color = AppConstants.darkNavy;
      canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(x, y, fw, fh), const Radius.circular(4)), boxPaint);
    }
  }

  void _drawPlayer(Canvas canvas, Player p, double x, double y, int index) {
    canvas.save();

    final shadowPaint = Paint()..color = const Color(0x550F172A);
    canvas.drawOval(Rect.fromCenter(center: Offset(x, y + 2), width: 22, height: 8), shadowPaint);

    final breathCycle = (elapsedSeconds + (index * 0.9) + p.breathPhase) / 2.8 * 2 * pi;
    final scaleY = p.isWalking ? (1.0 + (p.walkFrame % 2 == 1 ? 0.05 : 0.0)) : 1.0 + (sin(breathCycle) * 0.015 + 0.015);
    final scaleX = p.isWalking ? 1.0 : 1.0 - (sin(breathCycle) * 0.005);

    canvas.translate(x, y);
    canvas.scale(scaleX, scaleY);

    final facingLeft = p.targetX < p.posX;
    if (facingLeft) {
      canvas.scale(-1.0, 1.0);
    }

    ui.Image? sprite = charIdle;
    if (p.isWalking) {
      if (p.walkFrame == 1) sprite = charStep1 ?? charIdle;
      if (p.walkFrame == 3) sprite = charStep2 ?? charIdle;
    }

    const cw = 32.0;
    const ch = 48.0;

    if (sprite != null) {
      final src = Rect.fromLTWH(0, 0, sprite.width.toDouble(), sprite.height.toDouble());
      final dst = Rect.fromLTWH(-cw / 2, -ch, cw, ch);

      final jerseyColor = _parseColor(p.jerseyColorHex, AppConstants.energyBlue);
      final paint = Paint()
        ..filterQuality = FilterQuality.none
        ..colorFilter = ColorFilter.mode(jerseyColor.withValues(alpha: 0.18), BlendMode.srcATop);

      canvas.drawImageRect(sprite, src, dst, paint);
    } else {
      final charPaint = Paint()..color = _parseColor(p.jerseyColorHex, AppConstants.energyBlue);
      canvas.drawRect(Rect.fromLTWH(-12, -40, 24, 40), charPaint);
    }

    if (!p.isWalking) {
      if (p.currentStation == 'bed') {
        _drawEmote(canvas, 'Zzz', 0, -ch - 8, AppConstants.energyBlue);
      } else if (p.currentStation == 'pc') {
        _drawEmote(canvas, 'PLAY', 0, -ch - 8, AppConstants.positiveGreen);
      } else if (p.currentStation == 'kitchen') {
        _drawEmote(canvas, 'EAT', 0, -ch - 8, AppConstants.moneyGold);
      }
    }

    final nameSpan = TextSpan(
      text: p.gamerTag,
      style: const TextStyle(
        fontFamily: AppConstants.pixelFont,
        color: Colors.white,
        fontSize: 9,
        fontWeight: FontWeight.bold,
        shadows: [Shadow(color: AppConstants.darkNavy, offset: Offset(1, 1), blurRadius: 0)],
      ),
    );
    final namePainter = TextPainter(text: nameSpan, textDirection: TextDirection.ltr)..layout();
    namePainter.paint(canvas, Offset(-namePainter.width / 2, -ch - 18));

    canvas.restore();
  }

  void _drawEmote(Canvas canvas, String text, double x, double y, Color color) {
    final bgPaint = Paint()..color = AppConstants.darkNavy;
    final rrect = RRect.fromRectAndRadius(Rect.fromCenter(center: Offset(x, y), width: 34, height: 14), const Radius.circular(3));
    canvas.drawRRect(rrect, bgPaint);

    final borderPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;
    canvas.drawRRect(rrect, borderPaint);

    final span = TextSpan(
      text: text,
      style: TextStyle(fontFamily: AppConstants.pixelFont, color: color, fontSize: 8, fontWeight: FontWeight.bold),
    );
    final painter = TextPainter(text: span, textDirection: TextDirection.ltr)..layout();
    painter.paint(canvas, Offset(x - painter.width / 2, y - painter.height / 2));
  }

  void _drawNotifications(Canvas canvas, Size size) {
    for (final n in state.activeNotifications) {
      final nx = n.posX * size.width;
      final ny = n.posY * size.height;
      final opacity = n.lifeTime.clamp(0.0, 1.0);
      final color = _parseColor(n.colorHex, AppConstants.moneyGold).withValues(alpha: opacity);

      final span = TextSpan(
        text: n.text,
        style: TextStyle(
          fontFamily: AppConstants.pixelFont,
          color: color,
          fontSize: 14,
          fontWeight: FontWeight.bold,
          shadows: [
            Shadow(color: AppConstants.darkNavy.withValues(alpha: opacity), offset: const Offset(1, 1), blurRadius: 0),
          ],
        ),
      );
      final painter = TextPainter(text: span, textDirection: TextDirection.ltr)..layout();
      painter.paint(canvas, Offset(nx - painter.width / 2, ny));
    }
  }

  Color _parseColor(String hex, Color fallback) {
    try {
      final clean = hex.replaceAll('#', '');
      return Color(int.parse('FF$clean', radix: 16));
    } catch (_) {
      return fallback;
    }
  }

  @override
  bool shouldRepaint(covariant HousePainter oldDelegate) => true;
}

class _RenderItem {
  final double y;
  final void Function(Canvas c) draw;
  _RenderItem({required this.y, required this.draw});
}
