import 'dart:math';
import 'package:flutter/material.dart';
import '../../core/constants.dart';
import '../../models/player.dart';
import '../../models/ai_team.dart';

class ArenaStageView extends StatelessWidget {
  final List<Player> userStarters;
  final AiTeam opponent;
  final String? activePopupText;
  final String? activePopupTarget; // 'user' or 'opp'
  final int gameMinutes;

  const ArenaStageView({
    super.key,
    required this.userStarters,
    required this.opponent,
    this.activePopupText,
    this.activePopupTarget,
    required this.gameMinutes,
  });

  Color _getPressureColor(double pressure) {
    if (pressure > 70) return AppConstants.negativeRed;
    if (pressure > 40) return AppConstants.moneyGold;
    return AppConstants.positiveGreen;
  }

  String _getRivalSprite(String oppId, int index) {
    final clean = oppId.toLowerCase().replaceAll('team_', '').replaceAll('rival_', '');
    final flagshipRivals = ['kidlat', 'bakal', 'dagat', 'mayon', 'tarsier', 'pawikan', 'agila', 'banaue', 'siargao'];
    if (index == 0 && flagshipRivals.contains(clean)) {
      return 'assets/images/characters/rival_$clean/rival_${clean}_front_idle.png';
    }
    final num = ((index + 2) % 9) + 2;
    final padded = num.toString().padLeft(2, '0');
    return 'assets/images/characters/gamer_m$padded/gamer_m${padded}_front_idle.png';
  }

  Widget _buildCrowdStrip() {
    const crowd = ['fan_kid', 'fan_teen', 'fan_student', 'fan_cosplayer', 'fan_mascot', 'fan_vlogger', 'fan_kagawad'];
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: crowd.map((f) {
        return Image.asset(
          'assets/images/characters/$f/${f}_front_idle.png',
          width: 22,
          height: 22,
          fit: BoxFit.contain,
          filterQuality: FilterQuality.none,
          errorBuilder: (_, _, _) => const SizedBox(),
        );
      }).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Calculated dynamic in-game pressure based on game duration and player mental
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: const Color(0xFF0F1826),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFF233758), width: 1.5),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Opponent Team Row (Facing down)
          _buildTeamRow(
            isUser: false,
            teamName: opponent.name,
            teamColor: const Color(0xFFE5484D),
            players: List.generate(5, (i) {
              final roles = ['Carry', 'Mid', 'Offlane', 'Roam', 'Support'];
              return _ArenaPlayerDisplay(
                tag: i == 0 ? (opponent.captain ?? 'Ace') : 'Player ${i + 1}',
                role: roles[i],
                mental: 45 + (i * 3),
                avatarPath: _getRivalSprite(opponent.id, i),
              );
            }),
          ),

          // Cheering fan crowd in arena stands
          _buildCrowdStrip(),

          // Center Highlight Arena Banner / Popup
          Container(
            height: 38,
            alignment: Alignment.center,
            child: activePopupText != null
                ? Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                    decoration: BoxDecoration(
                      color: activePopupTarget == 'user'
                          ? const Color(0xFF1B4E3B)
                          : const Color(0xFF4A1A22),
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(
                        color: activePopupTarget == 'user'
                            ? AppConstants.positiveGreen
                            : AppConstants.negativeRed,
                        width: 1.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: (activePopupTarget == 'user'
                                  ? AppConstants.positiveGreen
                                  : AppConstants.negativeRed)
                              .withValues(alpha: 0.4),
                          blurRadius: 8,
                        ),
                      ],
                    ),
                    child: Text(
                      activePopupText!,
                      style: const TextStyle(
                        fontFamily: AppConstants.pixelFont,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: 1.2,
                      ),
                    ),
                  )
                : const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.sports_esports, color: Colors.white24, size: 14),
                      SizedBox(width: 6),
                      Text(
                        'MAIN STAGE LAN ARENA',
                        style: TextStyle(
                          fontFamily: AppConstants.pixelFont,
                          fontSize: 8,
                          color: Colors.white24,
                          letterSpacing: 1.5,
                        ),
                      ),
                    ],
                  ),
          ),

          // User Team Row (Facing up)
          _buildTeamRow(
            isUser: true,
            teamName: 'YOUR TEAM',
            teamColor: AppConstants.energyBlue,
            players: userStarters.take(5).map((p) {
              return _ArenaPlayerDisplay(
                tag: p.gamerTag,
                role: p.role.name.toUpperCase(),
                mental: p.mental,
                avatarPath: p.avatarPath,
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildTeamRow({
    required bool isUser,
    required String teamName,
    required Color teamColor,
    required List<_ArenaPlayerDisplay> players,
  }) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              teamName.toUpperCase(),
              style: TextStyle(
                fontFamily: AppConstants.pixelFont,
                fontSize: 8,
                fontWeight: FontWeight.bold,
                color: teamColor,
                letterSpacing: 1.2,
              ),
            ),
            const Text(
              'PRESSURE / TILT',
              style: TextStyle(
                fontFamily: AppConstants.pixelFont,
                fontSize: 7,
                color: Colors.white38,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: players.map((p) {
            // Pressure accumulates over match duration dampened by mental stat
            final basePressure = min(100.0, (gameMinutes * 3.2) - (p.mental * 0.35));
            final pressure = max(10.0, basePressure);
            final barColor = _getPressureColor(pressure);

            return Column(
              children: [
                // Gaming Desk / Chibi Monitor
                Container(
                  width: 52,
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFF142036),
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: teamColor.withValues(alpha: 0.6)),
                  ),
                  child: Column(
                    children: [
                      Image.asset(
                        p.avatarPath,
                        width: 28,
                        height: 28,
                        fit: BoxFit.contain,
                        filterQuality: FilterQuality.none,
                        errorBuilder: (_, _, _) => Icon(
                          isUser ? Icons.person : Icons.person_outline,
                          color: teamColor,
                          size: 16,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        p.tag,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontFamily: AppConstants.pixelFont,
                          fontSize: 7,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        p.role,
                        style: const TextStyle(
                          fontFamily: AppConstants.pixelFont,
                          fontSize: 6,
                          color: Colors.white60,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 3),
                // Pressure bar
                Container(
                  width: 48,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.white12,
                    borderRadius: BorderRadius.circular(2),
                  ),
                  child: FractionallySizedBox(
                    alignment: Alignment.centerLeft,
                    widthFactor: min(1.0, pressure / 100.0),
                    child: Container(
                      decoration: BoxDecoration(
                        color: barColor,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                ),
              ],
            );
          }).toList(),
        ),
      ],
    );
  }
}

class _ArenaPlayerDisplay {
  final String tag;
  final String role;
  final int mental;
  final String avatarPath;

  _ArenaPlayerDisplay({
    required this.tag,
    required this.role,
    required this.mental,
    required this.avatarPath,
  });
}
