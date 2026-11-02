import 'package:flutter/material.dart';
import '../../../core/constants.dart';
import '../../../models/game_state.dart';
import '../../../models/tournament.dart';
import '../../../models/ai_team.dart';
import '../../../services/data_service.dart';
import '../../../services/tournament_service.dart';
import '../../dialogs/tournament_hub_dialog.dart';
import '../../dialogs/match_prep_dialog.dart';
import '../../dialogs/hall_of_fame_dialog.dart';
import '../../widgets/calendar_matrix_view.dart';

class CompeteTab extends StatefulWidget {
  final GameState state;
  final VoidCallback onStateUpdated;

  const CompeteTab({
    super.key,
    required this.state,
    required this.onStateUpdated,
  });

  @override
  State<CompeteTab> createState() => _CompeteTabState();
}

class _CompeteTabState extends State<CompeteTab> {
  int _viewMode = 0; // 0 = Calendar, 1 = Rankings, 2 = My Matches
  int _tierFilter = 0; // 0 = All

  void _openTournamentHub(TournamentDef def) {
    showDialog(
      context: context,
      builder: (ctx) => TournamentHubDialog(
        state: widget.state,
        def: def,
        onStateUpdated: () {
          setState(() {});
          widget.onStateUpdated();
        },
      ),
    );
  }

  void _openMatchPrep(MatchNode match) {
    showDialog(
      context: context,
      builder: (ctx) => MatchPrepDialog(
        state: widget.state,
        match: match,
        onMatchCompleted: () {
          setState(() {});
          widget.onStateUpdated();
        },
      ),
    );
  }

  void _openHallOfFame() {
    showDialog(
      context: context,
      builder: (_) => HallOfFameDialog(state: widget.state),
    );
  }

  @override
  Widget build(BuildContext context) {
    TournamentService.initializeTournaments(widget.state);

    return Container(
      color: AppConstants.bgDark,
      child: Column(
        children: [
          // Sub-navigation bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            color: const Color(0xFF142036),
            child: Row(
              children: [
                _buildNavBtn('CALENDAR', 0),
                const SizedBox(width: 4),
                _buildNavBtn('RANKINGS', 1),
                const SizedBox(width: 4),
                _buildNavBtn('MATCHES', 2),
                const SizedBox(width: 4),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppConstants.moneyGold,
                    padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                    minimumSize: const Size(40, 28),
                  ),
                  onPressed: _openHallOfFame,
                  child: const Text(
                    'HOF',
                    style: TextStyle(
                      fontFamily: AppConstants.pixelFont,
                      fontSize: 8,
                      fontWeight: FontWeight.bold,
                      color: AppConstants.bgDark,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Content
          Expanded(
            child: _viewMode == 0
                ? CalendarMatrixView(
                    state: widget.state,
                    onSelectTournament: _openTournamentHub,
                  )
                : (_viewMode == 1 ? _buildRankingsView() : _buildMyMatchesView()),
          ),
        ],
      ),
    );
  }

  Widget _buildNavBtn(String title, int mode) {
    final isSel = _viewMode == mode;
    return Expanded(
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: isSel ? AppConstants.energyBlue : const Color(0xFF233458),
          padding: const EdgeInsets.symmetric(vertical: 4),
          minimumSize: const Size(50, 28),
        ),
        onPressed: () => setState(() => _viewMode = mode),
        child: Text(
          title,
          style: TextStyle(
            fontFamily: AppConstants.pixelFont,
            fontSize: 8,
            fontWeight: isSel ? FontWeight.bold : FontWeight.normal,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  // CIRCUIT RANKINGS VIEW
  Widget _buildRankingsView() {
    final allAi = DataService().allTeams;
    final allLadder = <AiTeam>[
      AiTeam(
        id: 'user_team',
        name: widget.state.teamName,
        tier: 1 + (widget.state.fame ~/ 300).clamp(0, 6),
        region: 'NCR',
        colors: [widget.state.primaryColorHex, widget.state.secondaryColorHex],
        rating: widget.state.starters.isNotEmpty
            ? (widget.state.starters.map((p) => p.ovr).reduce((a, b) => a + b) ~/ widget.state.starters.length)
            : 35,
        circuitPoints: widget.state.circuitPoints,
        fans: widget.state.fans,
        fame: widget.state.fame,
      ),
      ...allAi,
    ];

    final filtered = _tierFilter == 0
        ? allLadder
        : allLadder.where((t) => t.tier == _tierFilter).toList();

    filtered.sort((a, b) {
      final pDiff = b.circuitPoints.compareTo(a.circuitPoints);
      if (pDiff != 0) return pDiff;
      return b.rating.compareTo(a.rating);
    });

    return Column(
      children: [
        // Tier Filters
        Container(
          height: 32,
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [0, 1, 2, 3, 4, 5, 6, 7].map((t) {
              final isSel = _tierFilter == t;
              return Padding(
                padding: const EdgeInsets.only(right: 4, top: 4, bottom: 4),
                child: ChoiceChip(
                  label: Text(t == 0 ? 'ALL' : 'T$t', style: const TextStyle(fontFamily: AppConstants.pixelFont, fontSize: 8, color: Colors.white)),
                  selected: isSel,
                  selectedColor: AppConstants.energyBlue,
                  backgroundColor: const Color(0xFF233458),
                  onSelected: (_) => setState(() => _tierFilter = t),
                ),
              );
            }).toList(),
          ),
        ),

        // Rankings Table
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(8),
            itemCount: filtered.length,
            itemBuilder: (context, idx) {
              final t = filtered[idx];
              final isUser = t.id == 'user_team';

              return Container(
                margin: const EdgeInsets.only(bottom: 4),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                decoration: BoxDecoration(
                  color: isUser ? const Color(0xFF233458) : const Color(0xFF142036),
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: isUser ? AppConstants.moneyGold : AppConstants.darkNavy, width: isUser ? 1.5 : 1),
                ),
                child: Row(
                  children: [
                    SizedBox(
                      width: 24,
                      child: Text(
                        '#${idx + 1}',
                        style: TextStyle(fontFamily: AppConstants.pixelFont, fontSize: 9, fontWeight: FontWeight.bold, color: isUser ? AppConstants.moneyGold : Colors.white60),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                      decoration: BoxDecoration(color: const Color(0xFF1B2A49), borderRadius: BorderRadius.circular(2)),
                      child: Text('T${t.tier}', style: const TextStyle(fontFamily: AppConstants.pixelFont, fontSize: 7, color: Colors.white70)),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        t.name,
                        style: TextStyle(
                          fontFamily: AppConstants.pixelFont,
                          fontSize: 10,
                          fontWeight: isUser || t.isFlagship ? FontWeight.bold : FontWeight.normal,
                          color: isUser ? AppConstants.moneyGold : (t.isFlagship ? AppConstants.fansPink : Colors.white),
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Text('Rating: ${t.rating}', style: const TextStyle(fontFamily: AppConstants.pixelFont, fontSize: 8, color: Colors.white54)),
                    const SizedBox(width: 10),
                    Text('${t.circuitPoints} pts', style: const TextStyle(fontFamily: AppConstants.pixelFont, fontSize: 9, fontWeight: FontWeight.bold, color: AppConstants.energyBlue)),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  // MY MATCHES VIEW
  Widget _buildMyMatchesView() {
    final curWeek = widget.state.weekOfYear;
    final myMatches = <MatchNode>[];
    for (final inst in widget.state.tournamentInstances) {
      for (final m in inst.matches) {
        if (m.hasUser) myMatches.add(m);
      }
    }

    if (myMatches.isEmpty) {
      return const Center(
        child: Text(
          'Walang nakatakdang matches.\nMag-register sa darating na event!',
          textAlign: TextAlign.center,
          style: TextStyle(fontFamily: AppConstants.pixelFont, color: Colors.white54, fontSize: 10),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(8),
      itemCount: myMatches.length,
      itemBuilder: (context, idx) {
        final m = myMatches[idx];
        final isToday = m.week == curWeek && m.day == widget.state.day && !m.isPlayed;

        return Container(
          margin: const EdgeInsets.only(bottom: 6),
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: isToday ? const Color(0xFF2A1C3C) : const Color(0xFF142036),
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: isToday ? AppConstants.moneyGold : AppConstants.darkNavy),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Week ${m.week} Day 5 | ${m.roundName}', style: const TextStyle(fontFamily: AppConstants.pixelFont, fontSize: 8, color: Colors.white54)),
                    Text('${m.slotA.teamName} vs ${m.slotB.teamName}', style: const TextStyle(fontFamily: AppConstants.pixelFont, fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white)),
                  ],
                ),
              ),
              if (isToday)
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: AppConstants.positiveGreen, padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4)),
                  onPressed: () => _openMatchPrep(m),
                  child: const Text('PLAY NOW', style: TextStyle(fontFamily: AppConstants.pixelFont, fontSize: 8, color: Colors.white)),
                )
              else
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: m.isPlayed ? AppConstants.positiveGreen : const Color(0xFF233458),
                    borderRadius: BorderRadius.circular(3),
                  ),
                  child: Text(
                    m.isPlayed ? '${m.slotA.score} - ${m.slotB.score}' : 'UPCOMING',
                    style: const TextStyle(fontFamily: AppConstants.pixelFont, fontSize: 8, color: Colors.white),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}
