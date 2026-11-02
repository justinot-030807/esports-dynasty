import 'package:flutter/material.dart';
import '../../core/constants.dart';
import '../../models/game_state.dart';
import '../../services/season_service.dart';
import '../widgets/pixel_panel.dart';
import '../widgets/pixel_button.dart';

class AnnualReportDialog extends StatelessWidget {
  final GameState state;

  const AnnualReportDialog({super.key, required this.state});

  String _getSeasonGrade() {
    if (state.trophies.length >= 3 || state.fame >= 3000) return 'S';
    if (state.trophies.isNotEmpty || state.fame >= 1000) return 'A';
    if (state.circuitPoints >= 400 || state.fame >= 400) return 'B';
    if (state.money > 0) return 'C';
    return 'D';
  }

  String _getMikaComments(String grade) {
    switch (grade) {
      case 'S':
        return 'Boss! Walang kupas ang galing ng squad natin! Tinitingala na tayo sa buong Pilipinas!';
      case 'A':
        return 'Napakagandang taon para sa squad! Tuloy-tuloy lang ang sipag sa training para mas marami pang kampiyonato!';
      case 'B':
        return 'May mga panalo, may mga aral. Ayusin pa natin ang synergy at strategy para umangat sa susunod na taon.';
      case 'C':
        return 'Medyo kinapos tayo ngayong season, Boss. Pero buhay pa ang pangarap! Bawi tayo sa Season ${state.year + 1}!';
      default:
        return 'Muntik na tayong ma-bankrupt, Boss! Kailangan nating magtipid at mag-focus sa fundamentals sa susunod na taon.';
    }
  }

  @override
  Widget build(BuildContext context) {
    final grade = _getSeasonGrade();
    final comments = _getMikaComments(grade);

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: PixelPanel(
        title: 'YEAR ${state.year} REPORT',
        width: 330,
        child: Padding(
          padding: const EdgeInsets.all(4),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Container(
                padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 10),
                decoration: BoxDecoration(
                  color: const Color(0xFF1B2A49),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'YEAR ${state.year} ANNUAL REPORT',
                      style: const TextStyle(
                        fontFamily: AppConstants.pixelFont,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: AppConstants.moneyGold,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: grade == 'S' || grade == 'A' ? AppConstants.positiveGreen : AppConstants.energyBlue,
                        borderRadius: BorderRadius.circular(3),
                      ),
                      child: Text(
                        'GRADE: $grade',
                        style: const TextStyle(
                          fontFamily: AppConstants.pixelFont,
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),

              // Summary Grid
              Row(
                children: [
                  Expanded(child: _buildMetricCard('CASH RESERVE', 'P${state.money}', AppConstants.moneyGold)),
                  const SizedBox(width: 6),
                  Expanded(child: _buildMetricCard('FAME REACHED', '${state.fame}', AppConstants.famePurple)),
                ],
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  Expanded(child: _buildMetricCard('TOTAL FANS', '${state.fans}', AppConstants.fansPink)),
                  const SizedBox(width: 6),
                  Expanded(child: _buildMetricCard('TROPHIES WON', '${state.trophies.length}', AppConstants.positiveGreen)),
                ],
              ),
              const SizedBox(height: 10),

              // Manang Mika Speech Bubble
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF1B2A49),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: AppConstants.darkNavy),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: AppConstants.moneyGold,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Center(
                        child: Text(
                          'M',
                          style: TextStyle(fontFamily: AppConstants.pixelFont, fontSize: 14, fontWeight: FontWeight.bold, color: AppConstants.bgDark),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'MANANG MIKA (Assistant Manager):',
                            style: TextStyle(fontFamily: AppConstants.pixelFont, fontSize: 8, fontWeight: FontWeight.bold, color: AppConstants.moneyGold),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            comments,
                            style: const TextStyle(fontFamily: AppConstants.pixelFont, fontSize: 8, color: Colors.white70),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),

              // Proceed Button
              PixelButton(
                label: 'START YEAR ${state.year + 1} CIRCUIT',
                color: PixelButtonColor.green,
                onPressed: () {
                  SeasonService.performAnnualRollover(state);
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMetricCard(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF1B2A49),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontFamily: AppConstants.pixelFont, fontSize: 7, color: Colors.white60)),
          const SizedBox(height: 2),
          Text(value, style: TextStyle(fontFamily: AppConstants.pixelFont, fontSize: 12, fontWeight: FontWeight.bold, color: color)),
        ],
      ),
    );
  }
}
