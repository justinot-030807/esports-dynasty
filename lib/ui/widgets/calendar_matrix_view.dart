import 'package:flutter/material.dart';
import '../../core/constants.dart';
import '../../models/game_state.dart';
import '../../models/tournament.dart';
import '../../services/data_service.dart';

class CalendarMatrixView extends StatelessWidget {
  final GameState state;
  final Function(TournamentDef) onSelectTournament;

  const CalendarMatrixView({
    super.key,
    required this.state,
    required this.onSelectTournament,
  });

  @override
  Widget build(BuildContext context) {
    final allDefs = DataService().tournaments;
    final tourDefs = allDefs.where((t) => t.division == state.activeDivisionId).toList();
    final displayDefs = tourDefs.isNotEmpty ? tourDefs : allDefs;
    final curWeek = state.weekOfYear;

    return ListView(
      padding: const EdgeInsets.all(10),
      children: [
        // Current status banner
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: const Color(0xFF1B2A49),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'YEAR ${state.year} CIRCUIT (48 WEEKS)',
                style: const TextStyle(
                  fontFamily: AppConstants.pixelFont,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: AppConstants.moneyGold,
                ),
              ),
              Text(
                'WEEK $curWeek (M${state.month} W${state.week})',
                style: const TextStyle(
                  fontFamily: AppConstants.pixelFont,
                  fontSize: 9,
                  color: Colors.white70,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),

        Text(
          '${state.activeDivision.name.toUpperCase()} CIRCUIT (T1 - T7)',
          style: const TextStyle(
            fontFamily: AppConstants.pixelFont,
            fontSize: 10,
            fontWeight: FontWeight.bold,
            color: Colors.white60,
          ),
        ),
        const SizedBox(height: 4),

        for (final def in displayDefs) ...[
          _buildTournamentCard(def, curWeek),
          const SizedBox(height: 6),
        ],
      ],
    );
  }

  Widget _buildTournamentCard(TournamentDef def, int curWeek) {
    final inst = state.tournamentInstances.firstWhere(
      (t) => t.tournamentId == def.id,
      orElse: () => TournamentInstance(
        tournamentId: def.id,
        name: def.name,
        tier: def.tier,
        banner: def.banner,
      ),
    );

    final isRegOpen = curWeek >= def.startWeek + def.regOpenOffset &&
        curWeek <= def.startWeek + def.regCloseOffset;
    final isRegistered = inst.isUserRegistered;
    final isInProgress = curWeek >= def.startWeek && curWeek <= def.endWeek;

    Color badgeColor = const Color(0xFF4A5568);
    if (def.tier == 2) badgeColor = AppConstants.energyBlue;
    if (def.tier == 3) badgeColor = AppConstants.famePurple;
    if (def.tier == 4) badgeColor = const Color(0xFF00B4D8);
    if (def.tier == 5) badgeColor = AppConstants.moneyGold;
    if (def.tier == 6) badgeColor = AppConstants.fansPink;
    if (def.tier == 7) badgeColor = AppConstants.negativeRed;

    return InkWell(
      onTap: () => onSelectTournament(def),
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: isRegistered ? const Color(0xFF233458) : const Color(0xFF142036),
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
            color: isRegistered ? AppConstants.moneyGold : AppConstants.darkNavy,
            width: isRegistered ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
              decoration: BoxDecoration(color: badgeColor, borderRadius: BorderRadius.circular(4)),
              child: Text(
                'T${def.tier}',
                style: const TextStyle(
                  fontFamily: AppConstants.pixelFont,
                  fontSize: 10,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          def.name,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontFamily: AppConstants.pixelFont,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      if (isRegistered) ...[
                        const SizedBox(width: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                          decoration: BoxDecoration(color: AppConstants.moneyGold, borderRadius: BorderRadius.circular(2)),
                          child: const Text('JOINED', style: TextStyle(fontFamily: AppConstants.pixelFont, fontSize: 7, fontWeight: FontWeight.bold, color: AppConstants.bgDark)),
                        ),
                      ],
                    ],
                  ),
                  Text(
                    'W${def.startWeek}-W${def.endWeek} | Entry P${def.entryFee} | Champ P${def.championPrize}',
                    style: const TextStyle(fontFamily: AppConstants.pixelFont, fontSize: 8, color: Colors.white60),
                  ),
                ],
              ),
            ),
            if (isInProgress)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(color: AppConstants.positiveGreen, borderRadius: BorderRadius.circular(3)),
                child: const Text('LIVE', style: TextStyle(fontFamily: AppConstants.pixelFont, fontSize: 8, color: Colors.white, fontWeight: FontWeight.bold)),
              )
            else if (isRegOpen)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(color: AppConstants.fansPink, borderRadius: BorderRadius.circular(3)),
                child: const Text('REG OPEN', style: TextStyle(fontFamily: AppConstants.pixelFont, fontSize: 8, color: Colors.white, fontWeight: FontWeight.bold)),
              ),
          ],
        ),
      ),
    );
  }
}
