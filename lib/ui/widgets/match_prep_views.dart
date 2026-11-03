import 'package:flutter/material.dart';
import '../../core/constants.dart';
import '../../models/ai_team.dart';
import '../../models/staff.dart';

class MatchPrepVersusHeader extends StatelessWidget {
  final String userTeamName;
  final int startersCount;
  final int squadSize;
  final AiTeam opponent;

  const MatchPrepVersusHeader({
    super.key,
    required this.userTeamName,
    required this.startersCount,
    this.squadSize = 5,
    required this.opponent,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: const Color(0xFF142036), borderRadius: BorderRadius.circular(6)),
            child: Column(
              children: [
                Text(userTeamName, textAlign: TextAlign.center, style: const TextStyle(fontFamily: AppConstants.pixelFont, fontSize: 11, fontWeight: FontWeight.bold, color: AppConstants.moneyGold)),
                const SizedBox(height: 2),
                Text('Starters: $startersCount/$squadSize', style: const TextStyle(fontFamily: AppConstants.pixelFont, fontSize: 8, color: Colors.white60)),
              ],
            ),
          ),
        ),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 6),
          child: Text('VS', style: TextStyle(fontFamily: AppConstants.pixelFont, fontSize: 14, fontWeight: FontWeight.bold, color: AppConstants.negativeRed)),
        ),
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: const Color(0xFF142036), borderRadius: BorderRadius.circular(6)),
            child: Column(
              children: [
                Text(opponent.name, textAlign: TextAlign.center, style: const TextStyle(fontFamily: AppConstants.pixelFont, fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white)),
                const SizedBox(height: 2),
                Text('Rating: ${opponent.rating} OVR', style: const TextStyle(fontFamily: AppConstants.pixelFont, fontSize: 8, color: Colors.white60)),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class MatchPrepAnalystReport extends StatelessWidget {
  final StaffMember? analyst;
  final String opponentStyle;

  const MatchPrepAnalystReport({
    super.key,
    required this.analyst,
    required this.opponentStyle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(color: const Color(0xFF172641), borderRadius: BorderRadius.circular(6)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Image.asset(
                'assets/images/characters/staff_analyst/staff_analyst_front_idle.png',
                width: 18,
                height: 18,
                fit: BoxFit.contain,
                filterQuality: FilterQuality.none,
                errorBuilder: (_, _, _) => const Icon(Icons.psychology, color: AppConstants.energyBlue, size: 14),
              ),
              const SizedBox(width: 6),
              Text(
                analyst != null ? 'Analyst Report (Level ${analyst!.level})' : 'Analyst Report (Walang Analyst)',
                style: const TextStyle(fontFamily: AppConstants.pixelFont, fontSize: 9, fontWeight: FontWeight.bold, color: AppConstants.energyBlue),
              ),
            ],
          ),
          const SizedBox(height: 2),
          Text(
            analyst != null
                ? 'Style ng kalaban: $opponentStyle. Mag-set ng counter strategy para sa +4 Power!'
                : 'Hire ng Analyst para makita ang playstyle ng kalaban.',
            style: const TextStyle(fontFamily: AppConstants.pixelFont, fontSize: 8, color: Colors.white70),
          ),
        ],
      ),
    );
  }
}

class MatchPrepStrategySelector extends StatelessWidget {
  final String selectedStrategy;
  final List<String> strategies;
  final Function(String) onStrategySelected;

  const MatchPrepStrategySelector({
    super.key,
    required this.selectedStrategy,
    this.strategies = const ['Rush', 'Teamfight', 'Scale', 'Split'],
    required this.onStrategySelected,
  });

  String _getStratIcon(String s) {
    final l = s.toLowerCase();
    if (l.contains('rush')) return 'assets/images/icons/strat_rush.png';
    if (l.contains('fight') || l.contains('retake')) return 'assets/images/icons/strat_teamfight.png';
    if (l.contains('scale') || l.contains('default')) return 'assets/images/icons/strat_scale.png';
    return 'assets/images/icons/strat_split.png';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(color: const Color(0xFF142036), borderRadius: BorderRadius.circular(6)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('TEAM STRATEGY:', style: TextStyle(fontFamily: AppConstants.pixelFont, fontSize: 9, fontWeight: FontWeight.bold, color: Colors.white70)),
          const SizedBox(height: 4),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: strategies.map((strat) {
                final isSel = selectedStrategy == strat;
                final iconPath = _getStratIcon(strat);
                return Padding(
                  padding: const EdgeInsets.only(right: 6),
                  child: InkWell(
                    onTap: () => onStrategySelected(strat),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: isSel ? AppConstants.moneyGold : const Color(0xFF233458),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Image.asset(
                            iconPath,
                            width: 14,
                            height: 14,
                            fit: BoxFit.contain,
                            filterQuality: FilterQuality.none,
                            errorBuilder: (_, _, _) => const SizedBox(),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            strat,
                            style: TextStyle(
                              fontFamily: AppConstants.pixelFont,
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                              color: isSel ? AppConstants.bgDark : Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}
