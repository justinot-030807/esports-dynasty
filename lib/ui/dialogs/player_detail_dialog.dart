import 'package:flutter/material.dart';
import '../../core/constants.dart';
import '../../models/player.dart';
import '../../models/game_state.dart';
import '../../models/staff.dart';
import '../../services/transfer_service.dart';
import '../widgets/pixel_panel.dart';
import '../widgets/stat_bar.dart';

class PlayerDetailDialog extends StatelessWidget {
  final Player player;
  final GameState? state;
  final VoidCallback onToggleStarter;
  final VoidCallback onRelease;
  final VoidCallback? onStateUpdated;

  const PlayerDetailDialog({
    super.key,
    required this.player,
    this.state,
    required this.onToggleStarter,
    required this.onRelease,
    this.onStateUpdated,
  });

  String _conditionText(PlayerCondition c) {
    switch (c) {
      case PlayerCondition.great: return 'GREAT (x1.25)';
      case PlayerCondition.good: return 'GOOD (x1.10)';
      case PlayerCondition.normal: return 'NORMAL (x1.00)';
      case PlayerCondition.tired: return 'TIRED (x0.75)';
      case PlayerCondition.exhausted: return 'EXHAUSTED (x0.40)';
    }
  }

  Color _conditionColor(PlayerCondition c) {
    switch (c) {
      case PlayerCondition.great: return AppConstants.positiveGreen;
      case PlayerCondition.good: return AppConstants.energyBlue;
      case PlayerCondition.normal: return AppConstants.darkNavy;
      case PlayerCondition.tired: return AppConstants.moneyGold;
      case PlayerCondition.exhausted: return AppConstants.negativeRed;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: PixelPanel(
        title: '${player.gamerTag.toUpperCase()} (OVR ${player.ovr})',
        width: 320,
        onClose: () => Navigator.of(context).pop(),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Player Basic Info
              Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: AppConstants.darkNavy,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: AppConstants.moneyGold, width: 2),
                    ),
                    child: Image.asset(
                      player.facePath,
                      fit: BoxFit.contain,
                      filterQuality: FilterQuality.none,
                      errorBuilder: (_, _, _) => Image.asset(
                        player.avatarPath,
                        fit: BoxFit.contain,
                        filterQuality: FilterQuality.none,
                        errorBuilder: (_, _, _) => Center(
                          child: Text(
                            player.role.name.substring(0, player.role.name.length >= 2 ? 2 : 1).toUpperCase(),
                            style: const TextStyle(
                              fontFamily: AppConstants.pixelFont,
                              color: AppConstants.moneyGold,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          player.realName,
                          style: const TextStyle(
                            fontFamily: AppConstants.pixelFont,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: AppConstants.darkNavy,
                          ),
                        ),
                        Text(
                          '${player.roleDisplayName} [${player.divisionId.toUpperCase()}] | Age: ${player.age}',
                          style: const TextStyle(
                            fontFamily: AppConstants.pixelFont,
                            fontSize: 10,
                            color: Colors.black54,
                          ),
                        ),
                        Row(
                          children: [
                            Image.asset(
                              'assets/images/icons/rank_${player.rankTitle.toLowerCase().replaceAll('-', '')}.png',
                              width: 12,
                              height: 12,
                              fit: BoxFit.contain,
                              filterQuality: FilterQuality.none,
                              errorBuilder: (_, _, _) => const SizedBox(),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'Rank: ${player.rankTitle} | Salary: P${player.weeklySalary}/wk',
                              style: const TextStyle(
                                fontFamily: AppConstants.pixelFont,
                                fontSize: 10,
                                color: AppConstants.famePurple,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        Text(
                          'Contract: ${player.contractWeeksLeft} wks left',
                          style: TextStyle(
                            fontFamily: AppConstants.pixelFont,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: player.contractWeeksLeft <= 8
                                ? AppConstants.negativeRed
                                : AppConstants.positiveGreen,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const Divider(color: Color(0xFFCBD5E0), height: 16),

              // Condition & Potential
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Text(
                        'Condition: ',
                        style: TextStyle(fontFamily: AppConstants.pixelFont, fontSize: 10, fontWeight: FontWeight.bold, color: AppConstants.darkNavy),
                      ),
                      Image.asset(
                        'assets/images/icons/face_${player.condition.name}.png',
                        width: 14,
                        height: 14,
                        fit: BoxFit.contain,
                        filterQuality: FilterQuality.none,
                        errorBuilder: (_, _, _) => const SizedBox(),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        _conditionText(player.condition),
                        style: TextStyle(fontFamily: AppConstants.pixelFont, fontSize: 10, fontWeight: FontWeight.bold, color: _conditionColor(player.condition)),
                      ),
                    ],
                  ),
                  Text(
                    'Stars: ${player.isPotentialRevealed ? "${player.potentialStars}★" : "?"}',
                    style: const TextStyle(fontFamily: AppConstants.pixelFont, fontSize: 11, fontWeight: FontWeight.bold, color: AppConstants.moneyGold),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // Stats Bars (0 - 100)
              StatBar(label: 'Aim', value: player.aim),
              StatBar(label: 'Reaction', value: player.reaction),
              StatBar(label: 'Game Sense', value: player.gameSense),
              StatBar(label: 'Teamwork', value: player.teamwork),
              StatBar(label: 'Mental', value: player.mental),
              StatBar(label: 'Stamina', value: player.stamina),

              const Divider(color: Color(0xFFCBD5E0), height: 16),

              // Traits
              Wrap(
                spacing: 6,
                runSpacing: 4,
                children: player.traits.map((t) {
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppConstants.darkNavy,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      'Trait: $t',
                      style: const TextStyle(
                        fontFamily: AppConstants.pixelFont,
                        fontSize: 9,
                        color: AppConstants.moneyGold,
                      ),
                    ),
                  );
                }).toList(),
              ),

              const SizedBox(height: 14),

              // Action Buttons: Starter toggle & Release
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: player.isStarter ? AppConstants.energyBlue : AppConstants.darkNavy,
                        padding: const EdgeInsets.symmetric(vertical: 8),
                      ),
                      onPressed: () {
                        onToggleStarter();
                        Navigator.of(context).pop();
                      },
                      child: Text(
                        player.isStarter ? 'BENCH' : 'SET STARTER',
                        style: const TextStyle(fontFamily: AppConstants.pixelFont, fontSize: 11, color: Colors.white),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppConstants.negativeRed,
                        padding: const EdgeInsets.symmetric(vertical: 8),
                      ),
                      onPressed: () {
                        onRelease();
                        Navigator.of(context).pop();
                      },
                      child: const Text(
                        'RELEASE',
                        style: TextStyle(fontFamily: AppConstants.pixelFont, fontSize: 11, color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
              if (state != null) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    if (player.contractWeeksLeft <= 24)
                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppConstants.positiveGreen,
                            padding: const EdgeInsets.symmetric(vertical: 8),
                          ),
                          onPressed: () => _renewContract(context),
                          child: const Text(
                            'RENEW (48 WKS)',
                            style: TextStyle(fontFamily: AppConstants.pixelFont, fontSize: 10, color: Colors.white),
                          ),
                        ),
                      ),
                    if (player.contractWeeksLeft <= 24 && (player.age >= 28 || player.ovr >= 70))
                      const SizedBox(width: 8),
                    if (player.age >= 28 || player.ovr >= 70)
                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppConstants.moneyGold,
                            padding: const EdgeInsets.symmetric(vertical: 8),
                          ),
                          onPressed: () => _showRetirementDialog(context),
                          child: const Text(
                            'RETIRE / CEREMONY',
                            style: TextStyle(fontFamily: AppConstants.pixelFont, fontSize: 10, color: AppConstants.darkNavy, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  void _renewContract(BuildContext context) {
    if (state == null) return;
    TransferService().renewContract(player, 48, state!);
    onStateUpdated?.call();
    Navigator.of(context).pop();
  }

  void _showRetirementDialog(BuildContext context) {
    if (state == null) return;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppConstants.panelLight,
        title: Text(
          'RETIREMENT: ${player.gamerTag.toUpperCase()}',
          style: const TextStyle(fontFamily: AppConstants.pixelFont, fontSize: 13, color: AppConstants.darkNavy),
        ),
        content: Text(
          'Gusto mo bang magdaos ng marangal na retirement ceremony para kay ${player.gamerTag} (Age ${player.age}, OVR ${player.ovr})?',
          style: const TextStyle(fontFamily: AppConstants.pixelFont, fontSize: 11, color: Colors.black87),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('CANCEL', style: TextStyle(fontFamily: AppConstants.pixelFont, fontSize: 10)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppConstants.famePurple),
            onPressed: () {
              Navigator.pop(ctx);
              Navigator.pop(context);
              TransferService().retirePlayer(player, state!);
              onStateUpdated?.call();
            },
            child: const Text('ISABIT ANG JERSEY', style: TextStyle(fontFamily: AppConstants.pixelFont, fontSize: 10, color: Colors.white)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppConstants.positiveGreen),
            onPressed: () {
              Navigator.pop(ctx);
              Navigator.pop(context);
              TransferService().retireAndConvertToStaff(player, StaffRole.coach, state!);
              onStateUpdated?.call();
            },
            child: const Text('MAGING HEAD COACH', style: TextStyle(fontFamily: AppConstants.pixelFont, fontSize: 10, color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
