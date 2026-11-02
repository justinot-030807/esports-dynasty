import 'package:flutter/material.dart';
import '../../core/constants.dart';

class BroadcastScoreboard extends StatelessWidget {
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

  const BroadcastScoreboard({
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
  });

  Widget _buildSeriesPips(int wins) {
    return Row(
      children: List.generate(targetWins, (i) {
        final won = i < wins;
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 2),
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: won ? AppConstants.moneyGold : Colors.transparent,
            border: Border.all(color: AppConstants.moneyGold, width: 1.5),
            shape: BoxShape.circle,
          ),
        );
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: const BoxDecoration(
        color: Color(0xFF1B2A49),
        border: Border(bottom: BorderSide(color: Color(0xFF2B3E68), width: 1.5)),
      ),
      child: Column(
        children: [
          Text(
            '${tournamentName.toUpperCase()} - ${roundName.toUpperCase()} (BO$bestOf)',
            style: const TextStyle(
              fontFamily: AppConstants.pixelFont,
              fontSize: 8,
              color: Colors.white70,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Team User
              Expanded(
                child: Row(
                  children: [
                    Container(width: 12, height: 12, decoration: const BoxDecoration(color: AppConstants.energyBlue, shape: BoxShape.circle)),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        userTeamName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontFamily: AppConstants.pixelFont, fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                    ),
                    _buildSeriesPips(userWins),
                  ],
                ),
              ),

              // Center Clock & Kills
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(color: const Color(0xFF0F1826), borderRadius: BorderRadius.circular(4)),
                child: Column(
                  children: [
                    Text(
                      '$userKills - $oppKills',
                      style: const TextStyle(fontFamily: AppConstants.pixelFont, fontSize: 13, fontWeight: FontWeight.bold, color: AppConstants.moneyGold),
                    ),
                    Text(
                      formattedTime,
                      style: const TextStyle(fontFamily: AppConstants.pixelFont, fontSize: 8, color: Colors.white70),
                    ),
                  ],
                ),
              ),

              // Team Opponent
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    _buildSeriesPips(oppWins),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        oppTeamName,
                        textAlign: TextAlign.right,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontFamily: AppConstants.pixelFont, fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Container(width: 12, height: 12, decoration: const BoxDecoration(color: Color(0xFFE5484D), shape: BoxShape.circle)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
