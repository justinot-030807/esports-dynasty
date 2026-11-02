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

  @override
  Widget build(BuildContext context) {
    final clamped = value.clamp(0, 100);
    final barColor = _getColor(clamped);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 75,
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
