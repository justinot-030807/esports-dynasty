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
  final ui.Image? charIdle, charStep1, charStep2;
  final ui.Image? deskImage, bedImage, kitchenImage, shelfImage, roomBg;

  static const double halfTileW = 24.0;
  static const double halfTileH = 12.0;
  static const int gridSize = 7;
  static const double wallHeight = 110.0;

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

    final originX = size.width / 2;
    final totalFloorH = (gridSize * 2) * halfTileH;
    final originY = ((size.height - totalFloorH) / 2 + 25.0).clamp(60.0, 160.0);

    // 1. Cozy Ambient Room Backdrop
    _drawAmbientBackdrop(canvas, size, originX, originY);
    // 2. Procedural Pixel-Art Walls
    _drawPixelWalls(canvas, originX, originY);
    // 3. Procedural Pixel Parquet Floor
    _drawPixelFloor(canvas, originX, originY);
    // 4. Day / Night ambient tint
    _drawDayNightTint(canvas, size);

    // 5. Depth-Sorted Entities
    final renderables = <_RenderItem>[];

    for (final f in state.furniture) {
      final col = f.tileX.toDouble().clamp(0.0, 6.0);
      final row = f.tileY.toDouble().clamp(0.0, 6.0);
      final cx = originX + (col - row) * halfTileW;
      final cy = originY + (col + row + 1) * halfTileH;
      final baseY = cy + halfTileH;

      renderables.add(_RenderItem(y: baseY, draw: (c) => _drawFurniture(c, f, cx, baseY)));
    }

    for (int i = 0; i < state.players.length; i++) {
      final p = state.players[i];
      final gx = p.posX > 1.0 ? p.posX.clamp(0.5, 6.0) : (1.0 + p.posX * 4.5);
      final gy = p.posY > 1.0 ? p.posY.clamp(0.5, 6.0) : (1.0 + p.posY * 4.5);
      final px = originX + (gx - gy) * halfTileW;
      final py = originY + (gx + gy + 1) * halfTileH + halfTileH;

      renderables.add(_RenderItem(y: py, draw: (c) => _drawPlayer(c, p, px, py, i)));
    }

    renderables.sort((a, b) => a.y.compareTo(b.y));
    for (final item in renderables) {
      item.draw(canvas);
    }

    // 6. Floating Text Notifications
    _drawNotifications(canvas, size);
    canvas.restore();
  }

  void _drawAmbientBackdrop(Canvas canvas, Size size, double ox, double oy) {
    final bgRect = Rect.fromLTWH(0, 0, size.width, size.height);
    final paint = Paint()
      ..shader = RadialGradient(
        center: Alignment((ox / size.width) * 2 - 1, ((oy + 60) / size.height) * 2 - 1),
        radius: 1.1,
        colors: const [Color(0xFF283955), Color(0xFF1A2740), Color(0xFF0F172A)],
      ).createShader(bgRect);
    canvas.drawRect(bgRect, paint);
  }

  void _drawPixelWalls(Canvas canvas, double ox, double oy) {
    final leftX = ox - (gridSize * halfTileW);
    final midY = oy + (gridSize * halfTileH);
    final rightX = ox + (gridSize * halfTileW);

    // Left Wall
    final leftWall = Path()
      ..moveTo(ox, oy)..lineTo(leftX, midY)
      ..lineTo(leftX, midY - wallHeight)..lineTo(ox, oy - wallHeight)..close();
    canvas.drawPath(leftWall, Paint()..color = const Color(0xFFE2E8F0));

    final linePaint = Paint()..color = const Color(0x3394A3B8)..strokeWidth = 1.0;
    for (int i = 1; i < gridSize; i++) {
      final wx = ox - (i * halfTileW);
      final wy = oy + (i * halfTileH);
      canvas.drawLine(Offset(wx, wy), Offset(wx, wy - wallHeight), linePaint);
    }

    // Top Neon LED (Cyan) & Baseboard
    canvas.drawLine(Offset(leftX, midY - wallHeight), Offset(ox, oy - wallHeight), Paint()..color = const Color(0xFF00E5FF)..strokeWidth = 3.0);
    canvas.drawLine(Offset(leftX, midY), Offset(ox, oy), Paint()..color = const Color(0xFF1E293B)..strokeWidth = 6.0);

    // Left Wall Window
    _drawPixelWindow(canvas, ox - (3.5 * halfTileW), oy + (3.5 * halfTileH) - (wallHeight * 0.72));

    // Right Wall (Shaded for 3D depth)
    final rightWall = Path()
      ..moveTo(ox, oy)..lineTo(rightX, midY)
      ..lineTo(rightX, midY - wallHeight)..lineTo(ox, oy - wallHeight)..close();
    canvas.drawPath(rightWall, Paint()..color = const Color(0xFF94A3B8));

    for (int i = 1; i < gridSize; i++) {
      final wx = ox + (i * halfTileW);
      final wy = oy + (i * halfTileH);
      canvas.drawLine(Offset(wx, wy), Offset(wx, wy - wallHeight), linePaint);
    }

    // Right Top Neon (Gold) & Baseboard
    canvas.drawLine(Offset(ox, oy - wallHeight), Offset(rightX, midY - wallHeight), Paint()..color = AppConstants.moneyGold..strokeWidth = 3.0);
    canvas.drawLine(Offset(ox, oy), Offset(rightX, midY), Paint()..color = const Color(0xFF0F172A)..strokeWidth = 6.0);

    // Esports Banner on Right Wall
    _drawEsportsBanner(canvas, ox + (2.5 * halfTileW), oy + (2.5 * halfTileH) - (wallHeight * 0.65));
  }

  void _drawPixelWindow(Canvas canvas, double x, double y) {
    final r = Rect.fromCenter(center: Offset(x, y), width: 40.0, height: 46.0);
    canvas.drawRect(r, Paint()..color = const Color(0xFF38BDF8));
    final frame = Paint()..color = const Color(0xFF1E293B)..style = PaintingStyle.stroke..strokeWidth = 2.5;
    canvas.drawRect(r, frame);
    canvas.drawLine(Offset(r.left, r.center.dy), Offset(r.right, r.center.dy), frame);
    canvas.drawLine(Offset(r.center.dx, r.top), Offset(r.center.dx, r.bottom), frame);
  }

  void _drawEsportsBanner(Canvas canvas, double x, double y) {
    final pColor = _parseColor(state.primaryColorHex, const Color(0xFF1E3A8A));
    final r = Rect.fromCenter(center: Offset(x, y), width: 32.0, height: 42.0);
    final bannerPath = Path()
      ..moveTo(r.left, r.top)..lineTo(r.right, r.top)
      ..lineTo(r.right, r.bottom - 8)..lineTo(r.center.dx, r.bottom)
      ..lineTo(r.left, r.bottom - 8)..close();
    canvas.drawPath(bannerPath, Paint()..color = pColor);
    canvas.drawPath(bannerPath, Paint()..color = AppConstants.moneyGold..style = PaintingStyle.stroke..strokeWidth = 1.5);
  }

  void _drawPixelFloor(Canvas canvas, double ox, double oy) {
    final border = Paint()..color = const Color(0xFF885427)..style = PaintingStyle.stroke..strokeWidth = 1.0;
    final paintA = Paint()..color = const Color(0xFFD79A63);
    final paintB = Paint()..color = const Color(0xFFC78850);

    for (int col = 0; col < gridSize; col++) {
      for (int row = 0; row < gridSize; row++) {
        final cx = ox + (col - row) * halfTileW;
        final cy = oy + (col + row + 1) * halfTileH;
        final path = Path()
          ..moveTo(cx, cy - halfTileH)..lineTo(cx + halfTileW, cy)
          ..lineTo(cx, cy + halfTileH)..lineTo(cx - halfTileW, cy)..close();
        canvas.drawPath(path, (col + row) % 2 == 0 ? paintA : paintB);
        canvas.drawPath(path, border);
      }
    }

    // 3D Platform Base Edges
    final leftX = ox - (gridSize * halfTileW);
    final midY = oy + (gridSize * halfTileH);
    final rightX = ox + (gridSize * halfTileW);
    final botY = oy + (gridSize * 2 * halfTileH);
    const depth = 8.0;

    final leftSkirt = Path()
      ..moveTo(leftX, midY)..lineTo(ox, botY)..lineTo(ox, botY + depth)..lineTo(leftX, midY + depth)..close();
    canvas.drawPath(leftSkirt, Paint()..color = const Color(0xFF543216));

    final rightSkirt = Path()
      ..moveTo(ox, botY)..lineTo(rightX, midY)..lineTo(rightX, midY + depth)..lineTo(ox, botY + depth)..close();
    canvas.drawPath(rightSkirt, Paint()..color = const Color(0xFF381E08));
  }

  void _drawDayNightTint(Canvas canvas, Size size) {
    final dayPhase = (state.day - 1) / 7.0;
    final tint = dayPhase < 0.5 ? Colors.transparent : (dayPhase < 0.75 ? const Color(0x18F5B700) : const Color(0x281B2A49));
    if (tint != Colors.transparent) canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), Paint()..color = tint);
  }

  void _drawFurniture(Canvas canvas, PlacedFurniture f, double cx, double baseY) {
    ui.Image? img;
    switch (f.station) {
      case 'pc': img = deskImage; break;
      case 'bed': img = bedImage; break;
      case 'kitchen': img = kitchenImage; break;
      case 'shelf': img = shelfImage; break;
    }

    final fw = f.sizeX * 38.0;
    final fh = f.sizeY * 42.0;
    canvas.drawOval(Rect.fromCenter(center: Offset(cx, baseY - 2), width: fw * 0.85, height: 12), Paint()..color = const Color(0x44000000));

    if (img != null) {
      final src = Rect.fromLTWH(0, 0, img.width.toDouble(), img.height.toDouble());
      canvas.drawImageRect(img, src, Rect.fromLTWH(cx - fw / 2, baseY - fh, fw, fh), Paint()..filterQuality = FilterQuality.none);
    } else {
      canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(cx - fw / 2, baseY - fh, fw, fh), const Radius.circular(4)), Paint()..color = AppConstants.darkNavy);
    }
  }

  void _drawPlayer(Canvas canvas, Player p, double px, double py, int index) {
    canvas.save();
    canvas.drawOval(Rect.fromCenter(center: Offset(px, py - 2), width: 24, height: 9), Paint()..color = const Color(0x55000000));

    final breath = (elapsedSeconds + (index * 0.9) + p.breathPhase) / 2.8 * 2 * pi;
    final scaleY = p.isWalking ? (1.0 + (p.walkFrame % 2 == 1 ? 0.05 : 0.0)) : 1.0 + (sin(breath) * 0.015);
    final scaleX = p.isWalking ? 1.0 : 1.0 - (sin(breath) * 0.005);

    canvas.translate(px, py);
    canvas.scale(scaleX, scaleY);
    if (p.targetX < p.posX) canvas.scale(-1.0, 1.0);

    ui.Image? sprite = charIdle;
    if (p.isWalking) {
      if (p.walkFrame == 1) sprite = charStep1 ?? charIdle;
      if (p.walkFrame == 3) sprite = charStep2 ?? charIdle;
    }

    const cw = 32.0;
    const ch = 48.0;
    if (sprite != null) {
      final src = Rect.fromLTWH(0, 0, sprite.width.toDouble(), sprite.height.toDouble());
      final jColor = _parseColor(p.jerseyColorHex, AppConstants.energyBlue);
      canvas.drawImageRect(sprite, src, Rect.fromLTWH(-cw / 2, -ch, cw, ch), Paint()..filterQuality = FilterQuality.none..colorFilter = ColorFilter.mode(jColor.withValues(alpha: 0.18), BlendMode.srcATop));
    } else {
      canvas.drawRect(Rect.fromLTWH(-12, -40, 24, 40), Paint()..color = AppConstants.energyBlue);
    }

    if (!p.isWalking) {
      if (p.currentStation == 'bed') _drawEmote(canvas, 'Zzz', 0, -ch - 8, AppConstants.energyBlue);
      if (p.currentStation == 'pc') _drawEmote(canvas, 'PLAY', 0, -ch - 8, AppConstants.positiveGreen);
      if (p.currentStation == 'kitchen') _drawEmote(canvas, 'EAT', 0, -ch - 8, AppConstants.moneyGold);
    }

    final nameSpan = TextSpan(
      text: p.gamerTag,
      style: const TextStyle(
        fontFamily: AppConstants.pixelFont, color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold,
        shadows: [Shadow(color: Color(0xFF0F172A), offset: Offset(1.5, 1.5)), Shadow(color: Color(0xFF0F172A), offset: Offset(-1.0, -1.0))],
      ),
    );
    final namePainter = TextPainter(text: nameSpan, textDirection: TextDirection.ltr)..layout();
    namePainter.paint(canvas, Offset(-namePainter.width / 2, -ch - 20));
    canvas.restore();
  }

  void _drawEmote(Canvas canvas, String text, double x, double y, Color color) {
    final rrect = RRect.fromRectAndRadius(Rect.fromCenter(center: Offset(x, y), width: 38, height: 16), const Radius.circular(3));
    canvas.drawRRect(rrect, Paint()..color = const Color(0xFF0F172A));
    canvas.drawRRect(rrect, Paint()..color = color..style = PaintingStyle.stroke..strokeWidth = 1.4);
    final span = TextSpan(text: text, style: TextStyle(fontFamily: AppConstants.pixelFont, color: color, fontSize: 9, fontWeight: FontWeight.bold));
    final painter = TextPainter(text: span, textDirection: TextDirection.ltr)..layout();
    painter.paint(canvas, Offset(x - painter.width / 2, y - painter.height / 2));
  }

  void _drawNotifications(Canvas canvas, Size size) {
    for (final n in state.activeNotifications) {
      final nx = n.posX * size.width;
      final ny = n.posY * size.height;
      final color = _parseColor(n.colorHex, AppConstants.moneyGold).withValues(alpha: n.lifeTime.clamp(0.0, 1.0));
      final span = TextSpan(
        text: n.text,
        style: TextStyle(
          fontFamily: AppConstants.pixelFont, color: color, fontSize: 16, fontWeight: FontWeight.bold,
          shadows: [Shadow(color: const Color(0xFF0F172A).withValues(alpha: n.lifeTime.clamp(0.0, 1.0)), offset: const Offset(1.5, 1.5))],
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
