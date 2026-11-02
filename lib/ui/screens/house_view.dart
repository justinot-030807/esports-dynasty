import 'dart:math';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import '../../core/constants.dart';
import '../../models/game_state.dart';
import '../../models/player.dart';
import '../widgets/house_painter.dart';

class HouseView extends StatefulWidget {
  final GameState state;
  final ui.Image? charIdle;
  final ui.Image? charStep1;
  final ui.Image? charStep2;
  final ui.Image? deskImage;
  final ui.Image? bedImage;
  final ui.Image? kitchenImage;
  final ui.Image? shelfImage;
  final ui.Image? roomBg;

  const HouseView({
    super.key,
    required this.state,
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
  State<HouseView> createState() => _HouseViewState();
}

class _HouseViewState extends State<HouseView> with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  final Random _rng = Random(42);
  double _elapsedSeconds = 0;
  double _walkTimer = 0;

  // Pan and integer zoom
  Offset _panOffset = Offset.zero;
  double _zoomLevel = 1.0;

  @override
  void initState() {
    super.initState();
    // Normalize any legacy save player positions to isometric floor tile grid
    for (final p in widget.state.players) {
      if (p.posX < 1.0) p.posX = 1.5 + (p.posX * 3.5);
      if (p.posY < 1.0) p.posY = 1.5 + (p.posY * 3.5);
      p.targetX = p.posX;
      p.targetY = p.posY;
    }

    _animController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat();

    _animController.addListener(_onTick);
  }

  @override
  void dispose() {
    _animController.removeListener(_onTick);
    _animController.dispose();
    super.dispose();
  }

  void _onTick() {
    final speed = widget.state.speedMultiplier == 0 ? 1.0 : widget.state.speedMultiplier.toDouble();
    final dt = 0.016 * speed;

    _elapsedSeconds += dt;
    _walkTimer += dt;

    // Advance walking frames (~8 fps)
    if (_walkTimer >= 0.12) {
      _walkTimer = 0;
      for (final p in widget.state.players) {
        if (p.isWalking) {
          p.walkFrame = (p.walkFrame + 1) % 4;
        } else {
          p.walkFrame = 0;
        }
      }
    }

    // Move players toward target stations on floor grid
    for (final p in widget.state.players) {
      final dx = p.targetX - p.posX;
      final dy = p.targetY - p.posY;
      final dist = sqrt(dx * dx + dy * dy);

      if (dist > 0.05) {
        p.isWalking = true;
        final step = 1.2 * dt;
        p.posX += (dx / dist) * min(dist, step);
        p.posY += (dy / dist) * min(dist, step);
      } else {
        p.posX = p.targetX;
        p.posY = p.targetY;
        p.isWalking = false;

        // Autonomous AI behavior: pick a new station after staying a bit
        if (_rng.nextDouble() < 0.005) {
          _pickNewStation(p);
        }
      }
    }

    // Update floating notifications
    for (int i = widget.state.activeNotifications.length - 1; i >= 0; i--) {
      final notif = widget.state.activeNotifications[i];
      notif.posY -= 0.03 * dt;
      notif.lifeTime -= 0.5 * dt;
      if (notif.lifeTime <= 0) {
        widget.state.activeNotifications.removeAt(i);
      }
    }

    if (mounted) setState(() {});
  }

  void _pickNewStation(Player p) {
    if (widget.state.furniture.isEmpty) return;
    final choices = ['pc', 'kitchen', 'bed'];
    final nextStation = choices[_rng.nextInt(choices.length)];
    p.currentStation = nextStation;

    // Find furniture matching station
    final matches = widget.state.furniture.where((f) => f.station == nextStation).toList();
    if (matches.isNotEmpty) {
      final targetFurn = matches[_rng.nextInt(matches.length)];
      // Stand right in front of the station on the floor
      p.targetX = (targetFurn.tileX + 0.3).clamp(1.0, 5.5);
      p.targetY = (targetFurn.tileY + 0.7).clamp(1.0, 5.5);
    } else {
      p.targetX = 1.5 + _rng.nextDouble() * 3.5;
      p.targetY = 1.5 + _rng.nextDouble() * 3.5;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onScaleUpdate: (details) {
        setState(() {
          _panOffset += details.focalPointDelta;
          if (details.scale != 1.0) {
            _zoomLevel = (_zoomLevel * details.scale).clamp(1.0, 3.0);
          }
        });
      },
      child: ClipRect(
        child: Container(
          color: AppConstants.bgDark,
          child: CustomPaint(
            size: Size.infinite,
            painter: HousePainter(
              state: widget.state,
              elapsedSeconds: _elapsedSeconds,
              zoomLevel: _zoomLevel,
              panOffset: _panOffset,
              charIdle: widget.charIdle,
              charStep1: widget.charStep1,
              charStep2: widget.charStep2,
              deskImage: widget.deskImage,
              bedImage: widget.bedImage,
              kitchenImage: widget.kitchenImage,
              shelfImage: widget.shelfImage,
              roomBg: widget.roomBg,
            ),
          ),
        ),
      ),
    );
  }
}
