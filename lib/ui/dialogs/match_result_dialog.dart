import 'package:flutter/material.dart';
import '../../core/constants.dart';
import '../../models/match_result.dart';

class MatchResultDialog extends StatelessWidget {
  final MatchSeriesResult result;
  final VoidCallback onClose;

  const MatchResultDialog({
    super.key,
    required this.result,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    final won = result.isUserVictory;

    return Dialog(
      backgroundColor: AppConstants.bgDark,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          border: Border.all(color: won ? AppConstants.positiveGreen : AppConstants.negativeRed, width: 2),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Banner (VICTORY / DEFEAT)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                color: won ? AppConstants.positiveGreen : AppConstants.negativeRed,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                won ? 'VICTORY!' : 'DEFEAT',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontFamily: AppConstants.pixelFont,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: 2,
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Tournament & Round
            Text(
              '${result.tournamentName} - ${result.roundName}',
              style: const TextStyle(fontFamily: AppConstants.pixelFont, fontSize: 10, color: Colors.white60),
            ),
            const SizedBox(height: 6),

            // Score Row
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                  child: Text(
                    result.teamAName,
                    textAlign: TextAlign.right,
                    style: TextStyle(
                      fontFamily: AppConstants.pixelFont,
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: won ? AppConstants.positiveGreen : Colors.white,
                    ),
                  ),
                ),
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 12),
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFF142036),
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: AppConstants.darkNavy),
                  ),
                  child: Text(
                    '${result.scoreA} - ${result.scoreB}',
                    style: const TextStyle(fontFamily: AppConstants.pixelFont, fontSize: 16, fontWeight: FontWeight.bold, color: AppConstants.moneyGold),
                  ),
                ),
                Expanded(
                  child: Text(
                    result.teamBName,
                    textAlign: TextAlign.left,
                    style: TextStyle(
                      fontFamily: AppConstants.pixelFont,
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: !won ? AppConstants.negativeRed : Colors.white70,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Game Breakdown
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(color: const Color(0xFF142036), borderRadius: BorderRadius.circular(6)),
              child: Column(
                children: [
                  for (final g in result.games)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 2),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Game ${g.gameNumber} (${g.durationMinutes}m)', style: const TextStyle(fontFamily: AppConstants.pixelFont, fontSize: 9, color: Colors.white60)),
                          Text('${g.teamAScore} - ${g.teamBScore}', style: const TextStyle(fontFamily: AppConstants.pixelFont, fontSize: 9, fontWeight: FontWeight.bold, color: Colors.white)),
                          Text(
                            g.winnerTeamId == 'user_team' ? 'WIN' : 'LOSS',
                            style: TextStyle(fontFamily: AppConstants.pixelFont, fontSize: 8, fontWeight: FontWeight.bold, color: g.winnerTeamId == 'user_team' ? AppConstants.positiveGreen : AppConstants.negativeRed),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 10),

            // MVP & News
            Text('MVP: ${result.mvpName}', style: const TextStyle(fontFamily: AppConstants.pixelFont, fontSize: 10, color: AppConstants.moneyGold, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text(
              result.newsHeadline,
              textAlign: TextAlign.center,
              style: const TextStyle(fontFamily: AppConstants.pixelFont, fontSize: 9, color: Colors.white70, fontStyle: FontStyle.italic),
            ),
            const SizedBox(height: 12),

            // Rewards Bar (if user won series)
            if (won)
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(color: const Color(0xFF1B2A49), borderRadius: BorderRadius.circular(4)),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    if (result.prizeMoney > 0)
                      Text('+P${result.prizeMoney}', style: const TextStyle(fontFamily: AppConstants.pixelFont, fontSize: 10, color: AppConstants.moneyGold, fontWeight: FontWeight.bold)),
                    Text('+${result.fameChange} Fame', style: const TextStyle(fontFamily: AppConstants.pixelFont, fontSize: 9, color: AppConstants.famePurple)),
                    Text('+${result.fansChange} Fans', style: const TextStyle(fontFamily: AppConstants.pixelFont, fontSize: 9, color: AppConstants.fansPink)),
                    Text('+${result.circuitPoints} Pts', style: const TextStyle(fontFamily: AppConstants.pixelFont, fontSize: 9, color: AppConstants.energyBlue)),
                  ],
                ),
              ),
            const SizedBox(height: 14),

            // Close Button
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppConstants.energyBlue,
                minimumSize: const Size(140, 34),
              ),
              onPressed: () {
                Navigator.of(context).pop();
                onClose();
              },
              child: const Text('CONTINUE', style: TextStyle(fontFamily: AppConstants.pixelFont, fontSize: 10, color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }
}
