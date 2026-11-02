import 'package:flutter/material.dart';
import '../../core/constants.dart';

class BroadcastControls extends StatelessWidget {
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

  const BroadcastControls({
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

  Widget _buildSpeedBtn(int speed) {
    final isSel = speedMultiplier == speed;
    return InkWell(
      onTap: () => onSpeedChanged(speed),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: isSel ? AppConstants.moneyGold : const Color(0xFF1B2A49),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Text(
          '${speed}X',
          style: TextStyle(
            fontFamily: AppConstants.pixelFont,
            fontSize: 8,
            fontWeight: FontWeight.bold,
            color: isSel ? Colors.black : Colors.white,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isSeriesOver) {
      return Container(
        padding: const EdgeInsets.all(12),
        color: userWon ? const Color(0xFF1B4E3B) : const Color(0xFF4A1A22),
        child: Row(
          children: [
            Expanded(
              child: Text(
                userWon ? 'SERIES VICTORY! ($userWins-$oppWins)' : 'SERIES DEFEAT! ($userWins-$oppWins)',
                style: const TextStyle(fontFamily: AppConstants.pixelFont, fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: AppConstants.moneyGold, foregroundColor: Colors.black),
              onPressed: onOpenResults,
              child: const Text('VIEW RESULTS', style: TextStyle(fontFamily: AppConstants.pixelFont, fontSize: 9, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      );
    }

    if (isIntermission) {
      return Container(
        padding: const EdgeInsets.all(8),
        color: const Color(0xFF142036),
        child: Row(
          children: [
            Expanded(
              child: Text(
                'INTERMISSION: Game $currentGameNumber Finished',
                style: const TextStyle(fontFamily: AppConstants.pixelFont, fontSize: 9, color: Colors.white70),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: AppConstants.energyBlue, foregroundColor: Colors.black),
              onPressed: onOpenTimeout,
              child: Text('TIMEOUT ($timeoutsRemaining)', style: const TextStyle(fontFamily: AppConstants.pixelFont, fontSize: 8)),
            ),
            const SizedBox(width: 6),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: AppConstants.positiveGreen, foregroundColor: Colors.white),
              onPressed: onStartNextGame,
              child: Text('START GAME ${currentGameNumber + 1}', style: const TextStyle(fontFamily: AppConstants.pixelFont, fontSize: 8, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      color: const Color(0xFF142036),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Speed toggles & pause
          Row(
            children: [
              _buildSpeedBtn(1),
              const SizedBox(width: 4),
              _buildSpeedBtn(2),
              const SizedBox(width: 4),
              InkWell(
                onTap: onTogglePause,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                  decoration: BoxDecoration(
                    color: isPaused ? AppConstants.negativeRed : const Color(0xFF1B2A49),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Icon(isPaused ? Icons.play_arrow : Icons.pause, size: 12, color: Colors.white),
                ),
              ),
            ],
          ),

          // Timeout button
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: timeoutsRemaining > 0 ? AppConstants.energyBlue : Colors.grey[800],
              foregroundColor: Colors.black,
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            ),
            icon: const Icon(Icons.timer, size: 12),
            label: Text('TIMEOUT ($timeoutsRemaining)', style: const TextStyle(fontFamily: AppConstants.pixelFont, fontSize: 8, fontWeight: FontWeight.bold)),
            onPressed: timeoutsRemaining > 0 ? onOpenTimeout : null,
          ),

          // Skip button
          TextButton.icon(
            style: TextButton.styleFrom(foregroundColor: Colors.white70),
            icon: const Icon(Icons.fast_forward, size: 14),
            label: const Text('SKIP', style: TextStyle(fontFamily: AppConstants.pixelFont, fontSize: 8)),
            onPressed: onSkip,
          ),
        ],
      ),
    );
  }
}
