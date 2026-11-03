import 'package:flutter/material.dart';
import '../../core/constants.dart';
import '../text_styles.dart';

class MatchControlBar extends StatelessWidget {
  final bool isSeriesOver;
  final bool userWon;
  final int userWins;
  final int oppWins;
  final VoidCallback onOpenResults;

  final bool isIntermission;
  final int currentGameNumber;
  final int timeoutsRemaining;
  final VoidCallback onOpenTimeout;
  final VoidCallback onStartNextGame;

  final int speedMultiplier;
  final bool isPaused;
  final Function(int speed) onSpeedChanged;
  final VoidCallback onTogglePause;
  final VoidCallback onSkip;

  const MatchControlBar({
    super.key,
    required this.isSeriesOver,
    required this.userWon,
    required this.userWins,
    required this.oppWins,
    required this.onOpenResults,
    required this.isIntermission,
    required this.currentGameNumber,
    required this.timeoutsRemaining,
    required this.onOpenTimeout,
    required this.onStartNextGame,
    required this.speedMultiplier,
    required this.isPaused,
    required this.onSpeedChanged,
    required this.onTogglePause,
    required this.onSkip,
  });

  Widget _buildSpeedButton(int speed) {
    final isSelected = speedMultiplier == speed;
    return InkWell(
      onTap: () => onSpeedChanged(speed),
      child: Container(
        width: 48,
        height: 48,
        alignment: Alignment.center,
        margin: const EdgeInsets.symmetric(horizontal: 2),
        decoration: BoxDecoration(
          color: isSelected ? AppConstants.moneyGold : const Color(0xFF1B2A49),
          borderRadius: BorderRadius.circular(4),
          border: Border.all(
            color: isSelected ? Colors.white : const Color(0xFF2C3E60),
            width: 1.5,
          ),
          boxShadow: const [
            BoxShadow(color: Color(0xFF0F1826), offset: Offset(1, 1)),
          ],
        ),
        child: Text(
          '${speed}X',
          style: AppTextStyles.buttonText.copyWith(
            color: isSelected ? Colors.black : Colors.white,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isSeriesOver) {
      return Container(
        height: 64,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        color: userWon ? const Color(0xFF1B4E3B) : const Color(0xFF4A1A22),
        child: Row(
          children: [
            Expanded(
              child: Text(
                userWon ? 'SERIES VICTORY! ($userWins-$oppWins)' : 'SERIES DEFEAT! ($userWins-$oppWins)',
                style: AppTextStyles.killBanner,
              ),
            ),
            SizedBox(
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppConstants.moneyGold,
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(horizontal: 18),
                ),
                onPressed: onOpenResults,
                child: const Text('VIEW RESULTS', style: AppTextStyles.buttonText),
              ),
            ),
          ],
        ),
      );
    }

    if (isIntermission) {
      return Container(
        height: 64,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        color: const Color(0xFF1B2A49),
        child: Row(
          children: [
            Expanded(
              child: Text(
                'GAME $currentGameNumber FINISHED',
                style: AppTextStyles.label14.copyWith(color: AppConstants.moneyGold),
              ),
            ),
            SizedBox(
              height: 48,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: timeoutsRemaining > 0 ? AppConstants.energyBlue : Colors.grey[800],
                  foregroundColor: Colors.black,
                ),
                onPressed: timeoutsRemaining > 0 ? onOpenTimeout : null,
                child: Text('TIMEOUT ($timeoutsRemaining)', style: AppTextStyles.buttonText),
              ),
            ),
            const SizedBox(width: 8),
            SizedBox(
              height: 48,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppConstants.positiveGreen,
                  foregroundColor: Colors.white,
                ),
                onPressed: onStartNextGame,
                child: Text('START GAME ${currentGameNumber + 1}', style: AppTextStyles.buttonText),
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      height: 68,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: const BoxDecoration(
        color: Color(0xFF142036),
        border: Border(top: BorderSide(color: Color(0xFF2B3E68), width: 1.5)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // 1. Speeds & Pause (All >= 48x48)
          Row(
            children: [
              _buildSpeedButton(1),
              _buildSpeedButton(2),
              InkWell(
                onTap: onTogglePause,
                child: Container(
                  width: 48,
                  height: 48,
                  alignment: Alignment.center,
                  margin: const EdgeInsets.symmetric(horizontal: 2),
                  decoration: BoxDecoration(
                    color: isPaused ? AppConstants.negativeRed : const Color(0xFF1B2A49),
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: const Color(0xFF2C3E60), width: 1.5),
                  ),
                  child: Icon(
                    isPaused ? Icons.play_arrow : Icons.pause,
                    size: 22,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),

          // 2. Big TIMEOUT Button (at least 56 dp tall)
          SizedBox(
            height: 56,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: timeoutsRemaining > 0 ? AppConstants.energyBlue : Colors.grey[800],
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                side: const BorderSide(color: Color(0xFF1B2A49), width: 2),
              ),
              icon: const Icon(Icons.timer, size: 20),
              label: Text(
                'TIMEOUT ($timeoutsRemaining)',
                style: AppTextStyles.buttonText.copyWith(color: Colors.black),
              ),
              onPressed: timeoutsRemaining > 0 ? onOpenTimeout : null,
            ),
          ),

          // 3. Skip Button (Touch target >= 48x48)
          InkWell(
            onTap: onSkip,
            child: Container(
              height: 48,
              padding: const EdgeInsets.symmetric(horizontal: 8),
              alignment: Alignment.center,
              child: Row(
                children: [
                  const Icon(Icons.fast_forward, size: 20, color: Colors.white70),
                  const SizedBox(width: 4),
                  Text('SKIP', style: AppTextStyles.buttonText.copyWith(color: Colors.white70)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
