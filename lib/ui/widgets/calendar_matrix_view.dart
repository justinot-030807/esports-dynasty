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

  String _getVenueIcon(int tier, String id) {
    switch (tier) {
      case 1:
        if (id.contains('cafe')) return 'assets/images/venues/venue_internet_cafe.png';
        if (id.contains('school') || id.contains('gym')) return 'assets/images/venues/venue_school_gym.png';
        return 'assets/images/venues/venue_barangay_court.png';
      case 2: return 'assets/images/venues/venue_town_arena.png';
      case 3: return 'assets/images/venues/venue_provincial_hall.png';
      case 4: return 'assets/images/venues/venue_regional_arena.png';
      case 5: return 'assets/images/venues/venue_national_stadium.png';
      case 6: return 'assets/images/venues/venue_apac_arena.png';
      default: return 'assets/images/venues/venue_world_stadium.png';
    }
  }

  bool _isTierUnlocked(int tier) {
    if (tier <= 1) return true;
    switch (tier) {
      case 2: return state.fame >= 100 || state.trophies.any((t) => t.contains('t1'));
      case 3: return state.fame >= 300 || state.trophies.any((t) => t.contains('t2'));
      case 4: return state.fame >= 600 || state.trophies.any((t) => t.contains('t3'));
      case 5: return state.fame >= 1000 || state.trophies.any((t) => t.contains('t4'));
      case 6: return state.fame >= 1500 || state.trophies.any((t) => t.contains('t5'));
      case 7: return state.fame >= 2000 || state.trophies.any((t) => t.contains('t6'));
      default: return false;
    }
  }

  String _getTierLockReason(int tier) {
    switch (tier) {
      case 2: return '100 Fame o T1 Champion';
      case 3: return '300 Fame o T2 Champion';
      case 4: return '600 Fame o T3 Champion';
      case 5: return '1,000 Fame o T4 Champion';
      case 6: return '1,500 Fame o T5 Champion';
      case 7: return '2,000 Fame o T6 Champion';
      default: return 'Naka-lock';
    }
  }

  Widget _buildTournamentCard(TournamentDef def, int curWeek) {
    final unlocked = _isTierUnlocked(def.tier);
    final inst = state.tournamentInstances.firstWhere(
      (t) => t.tournamentId == def.id,
      orElse: () => TournamentInstance(
        tournamentId: def.id,
        name: def.name,
        tier: def.tier,
        banner: def.banner,
      ),
    );

    final isRegOpen = unlocked && curWeek >= def.startWeek + def.regOpenOffset &&
        curWeek <= def.startWeek + def.regCloseOffset;
    final isRegistered = inst.isUserRegistered;
    final isInProgress = unlocked && curWeek >= def.startWeek && curWeek <= def.endWeek;

    Color badgeColor = const Color(0xFF64748B);
    if (unlocked) {
      if (def.tier == 2) badgeColor = AppConstants.energyBlue;
      if (def.tier == 3) badgeColor = AppConstants.famePurple;
      if (def.tier == 4) badgeColor = const Color(0xFF00B4D8);
      if (def.tier == 5) badgeColor = AppConstants.moneyGold;
      if (def.tier == 6) badgeColor = AppConstants.fansPink;
      if (def.tier == 7) badgeColor = AppConstants.negativeRed;
    }

    return InkWell(
      onTap: () {
        if (!unlocked) {
          return;
        }
        onSelectTournament(def);
      },
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: !unlocked
              ? const Color(0xFF0F172A).withValues(alpha: 0.6)
              : (isRegistered ? const Color(0xFF233458) : const Color(0xFF142036)),
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
            color: !unlocked
                ? const Color(0xFF334155)
                : (isRegistered ? AppConstants.moneyGold : AppConstants.darkNavy),
            width: isRegistered ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(3),
              child: Opacity(
                opacity: unlocked ? 1.0 : 0.4,
                child: Image.asset(
                  _getVenueIcon(def.tier, def.id),
                  width: 32,
                  height: 24,
                  fit: BoxFit.cover,
                  filterQuality: FilterQuality.none,
                  errorBuilder: (_, _, _) => const SizedBox(),
                ),
              ),
            ),
            const SizedBox(width: 6),
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
                          style: TextStyle(
                            fontFamily: AppConstants.pixelFont,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: unlocked ? Colors.white : Colors.white54,
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
                    unlocked
                        ? 'W${def.startWeek}-W${def.endWeek} | Entry P${def.entryFee} | Champ P${def.championPrize}'
                        : 'LOCKED • Kailangan: ${_getTierLockReason(def.tier)}',
                    style: TextStyle(
                      fontFamily: AppConstants.pixelFont,
                      fontSize: 8,
                      color: unlocked ? Colors.white60 : const Color(0xFFF87171),
                    ),
                  ),
                ],
              ),
            ),
            if (!unlocked)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(color: const Color(0xFF475569), borderRadius: BorderRadius.circular(3)),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.lock, size: 9, color: Colors.white70),
                    SizedBox(width: 2),
                    Text('LOCKED', style: TextStyle(fontFamily: AppConstants.pixelFont, fontSize: 8, color: Colors.white70, fontWeight: FontWeight.bold)),
                  ],
                ),
              )
            else if (isInProgress)
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
