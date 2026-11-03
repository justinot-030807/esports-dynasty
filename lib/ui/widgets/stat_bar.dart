import 'package:flutter/material.dart';
import '../../core/constants.dart';

class StatBar extends StatelessWidget {
  final String label;
  final int value; // 0 to 100
  final double width;

  const StatBar({
    super.key,
    required this.label,
    required this.value,
    this.width = 120,
  });

  Color _getColor(int val) {
    if (val < 30) return const Color(0xFF718096); // Grey
    if (val < 50) return AppConstants.positiveGreen; // Green
    if (val < 70) return AppConstants.energyBlue; // Blue
    if (val < 85) return AppConstants.moneyGold; // Yellow
    return const Color(0xFFED8936); // Orange with sparkle
  }

  String? _getStatIcon(String label) {
    final l = label.toLowerCase();
    if (l.contains('aim')) return 'assets/images/icons/stat_aim.png';
    if (l.contains('react')) return 'assets/images/icons/stat_reaction.png';
    if (l.contains('sense')) return 'assets/images/icons/stat_sense.png';
    if (l.contains('team')) return 'assets/images/icons/stat_teamwork.png';
    if (l.contains('mental')) return 'assets/images/icons/stat_mental.png';
    if (l.contains('stamina')) return 'assets/images/icons/stat_stamina.png';
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final clamped = value.clamp(0, 100);
    final barColor = _getColor(clamped);
    final iconPath = _getStatIcon(label);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (iconPath != null) ...[
            Image.asset(
              iconPath,
              width: 14,
              height: 14,
              fit: BoxFit.contain,
              filterQuality: FilterQuality.none,
              errorBuilder: (_, _, _) => const SizedBox(),
            ),
            const SizedBox(width: 4),
          ],
          SizedBox(
            width: iconPath != null ? 70 : 75,
            child: Text(
              label,
              style: const TextStyle(
                fontFamily: AppConstants.pixelFont,
                fontSize: 10,
                color: AppConstants.darkNavy,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Container(
            width: width,
            height: 8,
            decoration: BoxDecoration(
              color: const Color(0xFFE2E8F0),
              borderRadius: BorderRadius.circular(2),
              border: Border.all(color: AppConstants.darkNavy, width: 1.0),
            ),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: (clamped / 100.0).clamp(0.02, 1.0),
              child: Container(
                decoration: BoxDecoration(
                  color: barColor,
                  borderRadius: BorderRadius.circular(1),
                ),
              ),
            ),
          ),
          const SizedBox(width: 6),
          SizedBox(
            width: 22,
            child: Text(
              '$clamped',
              textAlign: TextAlign.right,
              style: TextStyle(
                fontFamily: AppConstants.pixelFont,
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: barColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
