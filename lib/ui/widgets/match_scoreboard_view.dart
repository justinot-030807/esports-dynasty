import 'package:flutter/material.dart';
import '../../core/constants.dart';
import '../../models/patch_data.dart';
import '../text_styles.dart';

class MatchScoreboardView extends StatelessWidget {
  final String tournamentName;
  final String roundName;
  final int bestOf;
  final String userTeamName;
  final String oppTeamName;
  final int userWins;
  final int oppWins;
  final int targetWins;
  final int userKills;
  final int oppKills;
  final String formattedTime;
  final PatchDef patch;
  final String currentStrategy;
  final double scorePopScale;
  final Color? scorePopColor;
  final bool isLateGame;
  final double animPhase;
  final VoidCallback? onPatchTapped;
  final VoidCallback? onStrategyTapped;

  const MatchScoreboardView({
    super.key,
    required this.tournamentName,
    required this.roundName,
    required this.bestOf,
    required this.userTeamName,
    required this.oppTeamName,
    required this.userWins,
    required this.oppWins,
    required this.targetWins,
    required this.userKills,
    required this.oppKills,
    required this.formattedTime,
    required this.patch,
    required this.currentStrategy,
    this.scorePopScale = 1.0,
    this.scorePopColor,
    this.isLateGame = false,
    this.animPhase = 0.0,
    this.onPatchTapped,
    this.onStrategyTapped,
  });

  Widget _buildStarPips(int wins) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(targetWins, (i) {
        final won = i < wins;
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 2),
          child: Image.asset(
            won ? 'assets/images/ui/star_full.png' : 'assets/images/ui/star_empty.png',
            width: 14,
            height: 14,
            fit: BoxFit.contain,
            errorBuilder: (_, _, _) => Icon(
              won ? Icons.star : Icons.star_border,
              color: won ? AppConstants.moneyGold : Colors.white38,
              size: 15,
            ),
          ),
        );
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1B2A49),
        border: const Border(
          bottom: BorderSide(color: Color(0xFF2C4373), width: 2),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.35),
            offset: const Offset(0, 2),
            blurRadius: 4,
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 1. Event & Round (12 dp, ellipsis)
          Text(
            '${tournamentName.toUpperCase()} • ${roundName.toUpperCase()} (BO$bestOf)',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.caption12.copyWith(color: AppConstants.moneyGold),
          ),
          const SizedBox(height: 2),

          // 2. Main Row: User Team (Left) | Big Score & Timer (Center) | Opponent (Right)
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // User Team
              Expanded(
                child: Row(
                  children: [
                    Container(
                      width: 14,
                      height: 14,
                      decoration: const BoxDecoration(
                        color: AppConstants.energyBlue,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        userTeamName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.teamName,
                      ),
                    ),
                    _buildStarPips(userWins),
                  ],
                ),
              ),

              // Center Scoreboard Box (32 dp numbers + KILLS label + timer)
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 6),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFF0F1826),
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(
                    color: scorePopColor ?? const Color(0xFF32486E),
                    width: scorePopScale > 1.0 ? 2.5 : 1.5,
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('KILLS', style: AppTextStyles.caption12),
                    Transform.scale(
                      scale: scorePopScale,
                      child: Text(
                        '$userKills - $oppKills',
                        style: AppTextStyles.scoreboardNumber.copyWith(
                          color: scorePopColor ?? AppConstants.moneyGold,
                        ),
                      ),
                    ),
                    Text(
                      formattedTime,
                      style: AppTextStyles.label14.copyWith(
                        color: isLateGame && (animPhase * 5).toInt() % 2 == 0
                            ? AppConstants.negativeRed
                            : Colors.white,
                      ),
                    ),
                  ],
                ),
              ),

              // Opponent Team
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    _buildStarPips(oppWins),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        oppTeamName,
                        textAlign: TextAlign.right,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.teamName,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Container(
                      width: 14,
                      height: 14,
                      decoration: const BoxDecoration(
                        color: AppConstants.negativeRed,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 3),

          // 3. Tappable chips for patch and tactic
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              InkWell(
                onTap: onPatchTapped,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: const Color(0xFF131D33),
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: AppConstants.moneyGold.withValues(alpha: 0.6)),
                  ),
                  child: Text(
                    'PATCH ${patch.version}: ${patch.favoredStrategy.toUpperCase()} +3',
                    style: AppTextStyles.caption12.copyWith(color: AppConstants.moneyGold),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              InkWell(
                onTap: onStrategyTapped,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: const Color(0xFF131D33),
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: AppConstants.energyBlue.withValues(alpha: 0.6)),
                  ),
                  child: Text(
                    'TACTIC: ${currentStrategy.toUpperCase()}',
                    style: AppTextStyles.caption12.copyWith(color: AppConstants.energyBlue),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
