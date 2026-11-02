import 'package:flutter/material.dart';
import '../../core/constants.dart';
import '../../models/game_state.dart';
import '../../models/legacy_state.dart';
import '../../services/audio_manager.dart';
import '../widgets/pixel_panel.dart';
import '../widgets/pixel_button.dart';
import 'legacy_shop_dialog.dart';

class FinalEvaluationDialog extends StatelessWidget {
  final GameState state;
  final FinalEvaluation evaluation;
  final VoidCallback onContinueEndless;

  const FinalEvaluationDialog({
    super.key,
    required this.state,
    required this.evaluation,
    required this.onContinueEndless,
  });

  @override
  Widget build(BuildContext context) {
    AudioManager().playSfx(AudioSfx.promotion);

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: PixelPanel(
        title: 'YEAR 10 EVALUATION',
        width: 330,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Rank Banner
              Container(
                padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
                decoration: BoxDecoration(
                  color: AppConstants.darkNavy,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: AppConstants.moneyGold, width: 2),
                ),
                child: Column(
                  children: [
                    const Text(
                      'DYNASTY RANK ATTAINED',
                      style: TextStyle(
                        fontFamily: AppConstants.pixelFont,
                        fontSize: 9,
                        color: Colors.white70,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      evaluation.rankTitle.toUpperCase(),
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontFamily: AppConstants.pixelFont,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppConstants.moneyGold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Final Score: ${evaluation.score} pts',
                      style: const TextStyle(
                        fontFamily: AppConstants.pixelFont,
                        fontSize: 11,
                        color: AppConstants.positiveGreen,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),

              // Metrics Breakdown Card
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: const Color(0xFFD0D7DE), width: 1.5),
                ),
                child: Column(
                  children: [
                    _buildMetricRow('Trophies Won', '${evaluation.trophiesCount} Trophies', AppConstants.moneyGold),
                    _buildMetricRow('Legends Developed', '${evaluation.legendsDeveloped} Legends', AppConstants.famePurple),
                    _buildMetricRow('Peak Fame', '${evaluation.peakFame} Fame', AppConstants.famePurple),
                    _buildMetricRow('Active Fans', '${evaluation.peakFans} Fans', AppConstants.fansPink),
                    _buildMetricRow('Dynasty Wealth', 'P${(state.money / 1000).toStringAsFixed(1)}K', AppConstants.positiveGreen),
                  ],
                ),
              ),
              const SizedBox(height: 10),

              // Legacy Points Banner
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppConstants.positiveGreen.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: AppConstants.positiveGreen, width: 1.5),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.star, color: AppConstants.moneyGold, size: 20),
                    const SizedBox(width: 6),
                    Text(
                      '+${evaluation.legacyPointsEarned} LEGACY POINTS AWARDED!',
                      style: const TextStyle(
                        fontFamily: AppConstants.pixelFont,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: AppConstants.darkNavy,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),

              // Action Buttons
              PixelButton(
                label: 'MAGPATULOY SA ENDLESS MODE',
                color: PixelButtonColor.green,
                fontSize: 10,
                height: 34,
                onPressed: () {
                  Navigator.pop(context);
                  onContinueEndless();
                },
              ),
              const SizedBox(height: 8),
              PixelButton(
                label: 'BUKSAN ANG LEGACY SHOP (NG+)',
                color: PixelButtonColor.yellow,
                fontSize: 10,
                height: 34,
                onPressed: () {
                  Navigator.pop(context);
                  showDialog(
                    context: context,
                    builder: (_) => const LegacyShopDialog(),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMetricRow(String label, String value, Color valueColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontFamily: AppConstants.pixelFont,
              fontSize: 10,
              color: Colors.black87,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontFamily: AppConstants.pixelFont,
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: valueColor,
            ),
          ),
        ],
      ),
    );
  }
}
