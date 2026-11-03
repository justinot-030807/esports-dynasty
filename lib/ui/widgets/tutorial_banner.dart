import 'package:flutter/material.dart';
import '../../core/constants.dart';
import '../../models/tutorial_state.dart';

class TutorialBanner extends StatelessWidget {
  final TutorialState tutorial;
  final VoidCallback onDismiss;
  final VoidCallback onSkip;

  const TutorialBanner({
    super.key,
    required this.tutorial,
    required this.onDismiss,
    required this.onSkip,
  });

  @override
  Widget build(BuildContext context) {
    if (tutorial.isCompleted || tutorial.isSkipped || tutorial.currentPrompt.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: AppConstants.moneyGold, width: 2.0),
        boxShadow: const [
          BoxShadow(color: Colors.black45, offset: Offset(0, 2), blurRadius: 2),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 34,
            height: 34,
            padding: const EdgeInsets.all(2),
            decoration: BoxDecoration(
              color: AppConstants.famePurple.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: AppConstants.moneyGold, width: 1.5),
            ),
            child: Image.asset(
              'assets/images/characters/staff_mika/staff_mika_front_idle.png',
              fit: BoxFit.contain,
              filterQuality: FilterQuality.none,
              errorBuilder: (_, _, _) => const Icon(Icons.support_agent, size: 24, color: AppConstants.darkNavy),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                  decoration: BoxDecoration(
                    color: AppConstants.famePurple,
                    borderRadius: BorderRadius.circular(3),
                  ),
                  child: const Text(
                    'MANANG MIKA (ASSISTANT)',
                    style: TextStyle(
                      fontFamily: AppConstants.pixelFont,
                      fontSize: 8,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  tutorial.currentPrompt,
                  style: const TextStyle(
                    fontFamily: AppConstants.pixelFont,
                    fontSize: 10,
                    color: AppConstants.textNavy,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 6),
          GestureDetector(
            onTap: onSkip,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.grey.shade400,
                borderRadius: BorderRadius.circular(3),
              ),
              child: const Text(
                'SKIP',
                style: TextStyle(fontFamily: AppConstants.pixelFont, fontSize: 8, color: Colors.black87),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
