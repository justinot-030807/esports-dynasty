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
import '../../widgets/emblem_widget.dart';

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
        state: widget.state, def: def,
        onStateUpdated: () { setState(() {}); widget.onStateUpdated(); },
      ),
    );
  }

  void _openMatchPrep(MatchNode match) {
    showDialog(
      context: context,
      builder: (ctx) => MatchPrepDialog(
        state: widget.state, match: match,
        onMatchCompleted: () { setState(() {}); widget.onStateUpdated(); },
      ),
    );
  }

  void _openHallOfFame() {
    showDialog(context: context, builder: (_) => HallOfFameDialog(state: widget.state));
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
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: const BoxDecoration(
              color: Color(0xFFF8FAFC),
              border: Border(bottom: BorderSide(color: Color(0xFFCBD5E1), width: 1.5)),
            ),
            child: Row(
              children: [
                _buildNavBtn('CALENDAR', 0),
                const SizedBox(width: 6),
                _buildNavBtn('RANKINGS', 1),
                const SizedBox(width: 6),
                _buildNavBtn('MATCHES', 2),
                const SizedBox(width: 6),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppConstants.moneyGold,
                    padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
                  ),
                  onPressed: _openHallOfFame,
                  child: const Text(
                    'HOF',
                    style: TextStyle(
                      fontFamily: AppConstants.pixelFont,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: AppConstants.darkNavy,
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
          backgroundColor: isSel ? const Color(0xFF0284C7) : const Color(0xFFE2E8F0),
          padding: const EdgeInsets.symmetric(vertical: 8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(5),
            side: BorderSide(color: isSel ? AppConstants.moneyGold : const Color(0xFFCBD5E1), width: 1.5),
          ),
        ),
        onPressed: () => setState(() => _viewMode = mode),
        child: Text(
          title,
          style: TextStyle(
            fontFamily: AppConstants.pixelFont,
            fontSize: 12,
            fontWeight: isSel ? FontWeight.bold : FontWeight.w600,
            color: isSel ? Colors.white : const Color(0xFF334155),
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
          height: 38,
          padding: const EdgeInsets.symmetric(horizontal: 8),
          color: const Color(0xFFF1F5F9),
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [0, 1, 2, 3, 4, 5, 6, 7].map((t) {
              final isSel = _tierFilter == t;
              return Padding(
                padding: const EdgeInsets.only(right: 6, top: 4, bottom: 4),
                child: ChoiceChip(
                  label: Text(
                    t == 0 ? 'ALL' : 'T$t',
                    style: TextStyle(
                      fontFamily: AppConstants.pixelFont,
                      fontSize: 11,
                      fontWeight: isSel ? FontWeight.bold : FontWeight.normal,
                      color: isSel ? Colors.white : const Color(0xFF334155),
                    ),
                  ),
                  selected: isSel,
                  selectedColor: const Color(0xFF0284C7),
                  backgroundColor: const Color(0xFFE2E8F0),
                  onSelected: (_) => setState(() => _tierFilter = t),
                ),
              );
            }).toList(),
          ),
        ),

        // Rankings Table
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(10),
            itemCount: filtered.length,
            itemBuilder: (context, idx) {
              final t = filtered[idx];
              final isUser = t.id == 'user_team';

              return Container(
                margin: const EdgeInsets.only(bottom: 6),
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                decoration: BoxDecoration(
                  color: isUser ? const Color(0xFFEFF6FF) : Colors.white,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color: isUser ? const Color(0xFFD97706) : const Color(0xFFCBD5E1),
                    width: isUser ? 2.0 : 1.0,
                  ),
                  boxShadow: const [
                    BoxShadow(color: Color(0x0A000000), offset: Offset(0, 1), blurRadius: 3),
                  ],
                ),
                child: Row(
                  children: [
                    SizedBox(
                      width: 28,
                      child: Text(
                        '#${idx + 1}',
                        style: TextStyle(
                          fontFamily: AppConstants.pixelFont,
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: isUser ? const Color(0xFFD97706) : const Color(0xFF64748B),
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(color: const Color(0xFFCBD5E1)),
                      ),
                      child: Text(
                        'T${t.tier}',
                        style: const TextStyle(fontFamily: AppConstants.pixelFont, fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF334155)),
                      ),
                    ),
                    const SizedBox(width: 8),
                    EmblemWidget(
                      size: 20,
                      teamId: isUser ? null : t.id,
                      symbol: isUser ? widget.state.emblemSymbol : 'lightning',
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        t.name,
                        style: TextStyle(
                          fontFamily: AppConstants.pixelFont,
                          fontSize: 14,
                          fontWeight: isUser || t.isFlagship ? FontWeight.bold : FontWeight.w500,
                          color: isUser ? const Color(0xFFD97706) : (t.isFlagship ? const Color(0xFFDB2777) : const Color(0xFF0F172A)),
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Text(
                      'Rating: ${t.rating}',
                      style: const TextStyle(
                        fontFamily: AppConstants.bodyFont,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF64748B),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      '${t.circuitPoints} pts',
                      style: const TextStyle(
                        fontFamily: AppConstants.pixelFont,
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF0284C7),
                      ),
                    ),
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
          style: TextStyle(fontFamily: AppConstants.pixelFont, color: Color(0xFF64748B), fontSize: 14),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(10),
      itemCount: myMatches.length,
      itemBuilder: (context, idx) {
        final m = myMatches[idx];
        final isToday = m.week == curWeek && m.day == widget.state.day && !m.isPlayed;

        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: isToday ? const Color(0xFFEFF6FF) : Colors.white,
            borderRadius: BorderRadius.circular(6),
            border: Border.all(
              color: isToday ? const Color(0xFFD97706) : const Color(0xFFCBD5E1),
              width: isToday ? 2.0 : 1.0,
            ),
            boxShadow: const [
              BoxShadow(color: Color(0x0A000000), offset: Offset(0, 1), blurRadius: 3),
            ],
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Week ${m.week} Day 5 | ${m.roundName}',
                      style: const TextStyle(fontFamily: AppConstants.pixelFont, fontSize: 11, color: Color(0xFF64748B)),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${m.slotA.teamName} vs ${m.slotB.teamName}',
                      style: const TextStyle(fontFamily: AppConstants.pixelFont, fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                    ),
                  ],
                ),
              ),
              if (isToday)
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppConstants.positiveGreen,
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
                  ),
                  onPressed: () => _openMatchPrep(m),
                  child: const Text('PLAY NOW', style: TextStyle(fontFamily: AppConstants.pixelFont, fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white)),
                )
              else
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: m.isPlayed ? AppConstants.positiveGreen : const Color(0xFF64748B),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    m.isPlayed ? '${m.slotA.score} - ${m.slotB.score}' : 'UPCOMING',
                    style: const TextStyle(fontFamily: AppConstants.pixelFont, fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}
