import 'package:flutter/material.dart';
import '../../core/constants.dart';
import '../../models/game_state.dart';
import '../../models/hall_of_fame.dart';
import '../../services/season_service.dart';
import '../widgets/pixel_panel.dart';
import '../widgets/pixel_button.dart';
import 'annual_report_dialog.dart';

class AwardsNightDialog extends StatefulWidget {
  final GameState state;

  const AwardsNightDialog({super.key, required this.state});

  @override
  State<AwardsNightDialog> createState() => _AwardsNightDialogState();
}

class _AwardsNightDialogState extends State<AwardsNightDialog> {
  late final List<SeasonAward> _awards;
  int _currentAwardIndex = 0;
  bool _claimed = false;

  static void _ignoreError(Object e, StackTrace? s) {}

  String _getAwardSprite(String title) {
    final lower = title.toLowerCase();
    if (lower.contains('mvp')) return 'assets/images/trophies/award_mvp.png';
    if (lower.contains('rookie')) return 'assets/images/trophies/award_rookie.png';
    if (lower.contains('stream')) return 'assets/images/trophies/award_streamer.png';
    if (lower.contains('team')) return 'assets/images/trophies/award_team.png';
    if (lower.contains('play')) return 'assets/images/trophies/award_play.png';
    return 'assets/images/trophies/trophy_t3.png';
  }

  @override
  void initState() {
    super.initState();
    _awards = SeasonService.computeSeasonAwards(widget.state);
  }

  void _onClaimAndProceed() {
    if (!_claimed) {
      SeasonService.applyAwards(widget.state, _awards);
      setState(() => _claimed = true);
    }

    Navigator.of(context).pop();
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AnnualReportDialog(state: widget.state),
    );
  }

  @override
  Widget build(BuildContext context) {
    final award = _awards[_currentAwardIndex];
    final isLast = _currentAwardIndex == _awards.length - 1;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: PixelPanel(
        title: 'AWARDS NIGHT',
        width: 330,
        child: Padding(
          padding: const EdgeInsets.all(4),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Container(
                padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
                decoration: BoxDecoration(
                  color: AppConstants.moneyGold.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: AppConstants.moneyGold, width: 1.5),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.emoji_events, color: AppConstants.moneyGold, size: 18),
                    const SizedBox(width: 8),
                    Text(
                      'YEAR ${widget.state.year} AWARDS NIGHT',
                      style: const TextStyle(
                        fontFamily: AppConstants.pixelFont,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: AppConstants.moneyGold,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Icon(Icons.star, color: AppConstants.moneyGold, size: 16),
                  ],
                ),
              ),
              const SizedBox(height: 12),

              // Award Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF1B2A49),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color: award.isUserWinner ? AppConstants.positiveGreen : const Color(0xFF2E4068),
                    width: award.isUserWinner ? 2 : 1,
                  ),
                  image: const DecorationImage(
                    image: AssetImage('assets/images/backgrounds/awards_stage.png'),
                    fit: BoxFit.cover,
                    filterQuality: FilterQuality.medium,
                    colorFilter: ColorFilter.mode(Color(0xBB0F172A), BlendMode.darken),
                    onError: _ignoreError,
                  ),
                ),
                child: Column(
                  children: [
                    Image.asset(
                      _getAwardSprite(award.title),
                      width: 54,
                      height: 54,
                      fit: BoxFit.contain,
                      filterQuality: FilterQuality.none,
                      errorBuilder: (_, _, _) => const Icon(Icons.emoji_events, color: AppConstants.moneyGold, size: 40),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      award.title.toUpperCase(),
                      style: const TextStyle(
                        fontFamily: AppConstants.pixelFont,
                        fontSize: 10,
                        color: Colors.white70,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      award.winnerName,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: AppConstants.pixelFont,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: award.isUserWinner ? AppConstants.moneyGold : Colors.white,
                      ),
                    ),
                    Text(
                      award.teamName,
                      style: const TextStyle(
                        fontFamily: AppConstants.pixelFont,
                        fontSize: 10,
                        color: AppConstants.energyBlue,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      award.description,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontFamily: AppConstants.pixelFont,
                        fontSize: 9,
                        color: Colors.white60,
                      ),
                    ),
                    if (award.isUserWinner) ...[
                      const SizedBox(height: 10),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppConstants.positiveGreen.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(color: AppConstants.positiveGreen),
                        ),
                        child: Text(
                          'PANALO! +P${award.rewardMoney} | +${award.rewardFame} Fame | +${award.rewardFans} Fans',
                          style: const TextStyle(
                            fontFamily: AppConstants.pixelFont,
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                            color: AppConstants.positiveGreen,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 12),

              // Step indicator
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(_awards.length, (idx) {
                  final active = idx == _currentAwardIndex;
                  return Container(
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    width: active ? 14 : 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: active ? AppConstants.moneyGold : Colors.white30,
                      borderRadius: BorderRadius.circular(3),
                    ),
                  );
                }),
              ),
              const SizedBox(height: 12),

              // Controls
              Row(
                children: [
                  if (_currentAwardIndex > 0)
                    Expanded(
                      child: PixelButton(
                        label: 'PREV',
                        color: PixelButtonColor.neutral,
                        onPressed: () => setState(() => _currentAwardIndex--),
                      ),
                    ),
                  if (_currentAwardIndex > 0) const SizedBox(width: 8),
                  Expanded(
                    child: PixelButton(
                      label: isLast ? 'CLAIM AWARDS' : 'NEXT AWARD',
                      color: isLast ? PixelButtonColor.yellow : PixelButtonColor.green,
                      onPressed: () {
                        if (isLast) {
                          _onClaimAndProceed();
                        } else {
                          setState(() => _currentAwardIndex++);
                        }
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
