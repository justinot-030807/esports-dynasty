import 'package:flutter/material.dart';
import '../../core/constants.dart';

class EmblemWidget extends StatelessWidget {
  final double size;
  final Color primaryColor;
  final Color secondaryColor;
  final String symbol; // 'lightning', 'dragon', etc., or 'my_01'..'my_12', or 'rival_*'
  final String letters;
  final String? teamId;

  const EmblemWidget({
    super.key,
    this.size = 40.0,
    this.primaryColor = AppConstants.energyBlue,
    this.secondaryColor = AppConstants.moneyGold,
    this.symbol = 'lightning',
    this.letters = '',
    this.teamId,
  });

  static const Set<String> _rivalKeys = {
    'kidlat', 'bakal', 'dagat', 'mayon', 'tarsier',
    'pawikan', 'agila', 'banaue', 'siargao',
  };

  String? _resolveAssetPath() {
    final tid = teamId?.toLowerCase() ?? '';
    final sym = symbol.toLowerCase();
    final cleanTid = tid.replaceFirst('team_', '').replaceFirst('rival_', '');

    if (_rivalKeys.contains(cleanTid)) {
      return 'assets/images/emblems/rival_$cleanTid.png';
    }
    if (_rivalKeys.contains(sym.replaceFirst('rival_', ''))) {
      final r = sym.replaceFirst('rival_', '');
      return 'assets/images/emblems/rival_$r.png';
    }
    if (sym.startsWith('my_')) {
      return 'assets/images/emblems/$sym.png';
    }
    if (sym.startsWith('sponsor_')) {
      return 'assets/images/emblems/$sym.png';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final assetPath = _resolveAssetPath();
    final fallbackPainter = CustomPaint(
      size: Size(size, size),
      painter: _EmblemPainter(
        primaryColor: primaryColor,
        secondaryColor: secondaryColor,
        symbol: symbol,
        letters: letters,
      ),
    );

    if (assetPath != null) {
      return SizedBox(
        width: size,
        height: size,
        child: Image.asset(
          assetPath,
          fit: BoxFit.contain,
          filterQuality: FilterQuality.none,
          errorBuilder: (_, _, _) => fallbackPainter,
        ),
      );
    }

    return fallbackPainter;
  }
}

class _EmblemPainter extends CustomPainter {
  final Color primaryColor;
  final Color secondaryColor;
  final String symbol;
  final String letters;

  _EmblemPainter({
    required this.primaryColor,
    required this.secondaryColor,
    required this.symbol,
    required this.letters,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Shield path
    final path = Path()
      ..moveTo(w * 0.1, h * 0.1)
      ..lineTo(w * 0.9, h * 0.1)
      ..lineTo(w * 0.9, h * 0.6)
      ..quadraticBezierTo(w * 0.9, h * 0.95, w * 0.5, h * 1.0)
      ..quadraticBezierTo(w * 0.1, h * 0.95, w * 0.1, h * 0.6)
      ..close();

    // Fill primary
    final fillPaint = Paint()..color = primaryColor;
    canvas.drawPath(path, fillPaint);

    // Inner shield or stripe (secondary)
    final innerPath = Path()
      ..moveTo(w * 0.5, h * 0.1)
      ..lineTo(w * 0.9, h * 0.1)
      ..lineTo(w * 0.9, h * 0.6)
      ..quadraticBezierTo(w * 0.9, h * 0.95, w * 0.5, h * 1.0)
      ..close();
    final secPaint = Paint()..color = secondaryColor;
    canvas.drawPath(innerPath, secPaint);

    // Dark navy outline
    final strokePaint = Paint()
      ..color = AppConstants.darkNavy
      ..style = PaintingStyle.stroke
      ..strokeWidth = (w * 0.08).clamp(1.5, 4.0);
    canvas.drawPath(path, strokePaint);

    // Draw symbol or letters
    if (letters.isNotEmpty) {
      final textSpan = TextSpan(
        text: letters,
        style: TextStyle(
          color: Colors.white,
          fontSize: w * 0.38,
          fontWeight: FontWeight.bold,
          fontFamily: AppConstants.pixelFont,
          shadows: [
            Shadow(color: AppConstants.darkNavy, offset: const Offset(1, 1), blurRadius: 0),
            Shadow(color: AppConstants.darkNavy, offset: const Offset(-1, 1), blurRadius: 0),
          ],
        ),
      );
      final textPainter = TextPainter(
        text: textSpan,
        textDirection: TextDirection.ltr,
        textAlign: TextAlign.center,
      )..layout();
      textPainter.paint(
        canvas,
        Offset((w - textPainter.width) / 2, (h - textPainter.height) / 2 - h * 0.05),
      );
    } else {
      // Draw lightning bolt symbol
      final boltPath = Path()
        ..moveTo(w * 0.55, h * 0.22)
        ..lineTo(w * 0.35, h * 0.52)
        ..lineTo(w * 0.52, h * 0.52)
        ..lineTo(w * 0.45, h * 0.82)
        ..lineTo(w * 0.68, h * 0.45)
        ..lineTo(w * 0.52, h * 0.45)
        ..close();
      final boltPaint = Paint()..color = Colors.white;
      canvas.drawPath(boltPath, boltPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _EmblemPainter oldDelegate) => true;
}
