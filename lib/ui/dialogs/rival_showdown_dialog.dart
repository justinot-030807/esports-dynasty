import 'package:flutter/material.dart';
import '../../core/constants.dart';
import '../../models/ai_team.dart';

class RivalShowdownDialog extends StatelessWidget {
  final AiTeam opponent;
  final String userTeamName;
  final String userCaptainName;
  final VoidCallback onProceed;

  const RivalShowdownDialog({
    super.key,
    required this.opponent,
    required this.userTeamName,
    required this.userCaptainName,
    required this.onProceed,
  });

  Color _parseColor(String? hex, Color fallback) {
    if (hex == null || hex.isEmpty) return fallback;
    final clean = hex.replaceAll('#', '');
    if (clean.length == 6) {
      return Color(int.parse('0xFF$clean'));
    }
    return fallback;
  }

  @override
  Widget build(BuildContext context) {
    final oppColor = opponent.colors.isNotEmpty
        ? _parseColor(opponent.colors.first, const Color(0xFFE5484D))
        : const Color(0xFFE5484D);

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: Container(
        decoration: BoxDecoration(
          color: AppConstants.bgDark,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: oppColor, width: 2.5),
          boxShadow: [
            BoxShadow(
              color: oppColor.withValues(alpha: 0.35),
              blurRadius: 16,
              spreadRadius: 2,
            ),
          ],
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Banner Badge
            Container(
              padding: const EdgeInsets.symmetric(vertical: 6),
              decoration: BoxDecoration(
                color: oppColor,
                borderRadius: BorderRadius.circular(4),
              ),
              alignment: Alignment.center,
              child: const Text(
                'FLAGSHIP RIVAL SHOWDOWN!',
                style: TextStyle(
                  fontFamily: AppConstants.pixelFont,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: 1.5,
                ),
              ),
            ),
            const SizedBox(height: 14),

            // Opponent Trash Talk Box
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF1E1528),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: oppColor.withValues(alpha: 0.5)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          color: oppColor,
                          shape: BoxShape.circle,
                        ),
                        child: const Center(
                          child: Icon(Icons.flash_on, color: Colors.white, size: 16),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              opponent.captain ?? 'Rival Captain',
                              style: TextStyle(
                                fontFamily: AppConstants.pixelFont,
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: oppColor,
                              ),
                            ),
                            Text(
                              opponent.name,
                              style: const TextStyle(
                                fontFamily: AppConstants.pixelFont,
                                fontSize: 8,
                                color: Colors.white70,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '"${opponent.catchphrase ?? 'Wala kayong laban sa amin!'}"',
                    style: const TextStyle(
                      fontFamily: AppConstants.pixelFont,
                      fontSize: 10,
                      fontStyle: FontStyle.italic,
                      color: Colors.white,
                      height: 1.3,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),

            // VS Divider
            const Center(
              child: Text(
                '--- VS ---',
                style: TextStyle(
                  fontFamily: AppConstants.pixelFont,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: AppConstants.moneyGold,
                ),
              ),
            ),
            const SizedBox(height: 10),

            // User Captain Counter Talk Box
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF14243B),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: AppConstants.energyBlue.withValues(alpha: 0.5)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 28,
                        height: 28,
                        decoration: const BoxDecoration(
                          color: AppConstants.energyBlue,
                          shape: BoxShape.circle,
                        ),
                        child: const Center(
                          child: Icon(Icons.shield, color: Colors.black, size: 16),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              userCaptainName,
                              style: const TextStyle(
                                fontFamily: AppConstants.pixelFont,
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: AppConstants.energyBlue,
                              ),
                            ),
                            Text(
                              userTeamName,
                              style: const TextStyle(
                                fontFamily: AppConstants.pixelFont,
                                fontSize: 8,
                                color: Colors.white70,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    '"Hindi kami uurong! Papakita namin kung paano maglaro ang tunay na kampeon!"',
                    style: TextStyle(
                      fontFamily: AppConstants.pixelFont,
                      fontSize: 10,
                      fontStyle: FontStyle.italic,
                      color: Colors.white,
                      height: 1.3,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),

            // Action Button
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppConstants.moneyGold,
                foregroundColor: AppConstants.bgDark,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
              ),
              onPressed: () {
                Navigator.of(context).pop();
                onProceed();
              },
              child: const Text(
                'ENTER THE ARENA!',
                style: TextStyle(
                  fontFamily: AppConstants.pixelFont,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
