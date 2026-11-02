import 'package:flutter/material.dart';
import '../../core/constants.dart';
import '../../models/game_state.dart';
import '../../models/tournament.dart';
import '../../services/tournament_service.dart';
import '../widgets/tournament_overview_view.dart';

class TournamentHubDialog extends StatefulWidget {
  final GameState state;
  final TournamentDef def;
  final VoidCallback onStateUpdated;

  const TournamentHubDialog({
    super.key,
    required this.state,
    required this.def,
    required this.onStateUpdated,
  });

  @override
  State<TournamentHubDialog> createState() => _TournamentHubDialogState();
}

class _TournamentHubDialogState extends State<TournamentHubDialog> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  TournamentInstance get _instance {
    return widget.state.tournamentInstances.firstWhere(
      (t) => t.tournamentId == widget.def.id,
      orElse: () {
        final inst = TournamentInstance(
          tournamentId: widget.def.id,
          name: widget.def.name,
          tier: widget.def.tier,
          banner: widget.def.banner,
        );
        widget.state.tournamentInstances.add(inst);
        return inst;
      },
    );
  }

  void _handleRegister() {
    final error = TournamentService.checkRegistrationEligibility(widget.state, widget.def);
    if (error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error, style: const TextStyle(fontFamily: AppConstants.pixelFont)),
          backgroundColor: AppConstants.negativeRed,
        ),
      );
      return;
    }

    setState(() {
      TournamentService.registerUser(widget.state, widget.def);
    });
    widget.onStateUpdated();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Matagumpay na nagparehistro sa ${widget.def.name}!', style: const TextStyle(fontFamily: AppConstants.pixelFont)),
        backgroundColor: AppConstants.positiveGreen,
      ),
    );
  }

  void _handleWithdraw() {
    setState(() {
      TournamentService.withdrawUser(widget.state, widget.def);
    });
    widget.onStateUpdated();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Nag-withdraw sa event. Na-refund ang 50%!', style: TextStyle(fontFamily: AppConstants.pixelFont)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final inst = _instance;

    return Dialog(
      backgroundColor: AppConstants.bgDark,
      insetPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: AppConstants.darkNavy, width: 2),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          children: [
            // Header with Tier Banner
            Container(
              padding: const EdgeInsets.all(10),
              color: const Color(0xFF1B2A49),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: widget.def.tier == 1 ? const Color(0xFF4A5568) : AppConstants.energyBlue,
                      borderRadius: BorderRadius.circular(3),
                    ),
                    child: Text('T${widget.def.tier}', style: const TextStyle(fontFamily: AppConstants.pixelFont, fontSize: 10, color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      widget.def.name,
                      style: const TextStyle(fontFamily: AppConstants.pixelFont, fontSize: 13, fontWeight: FontWeight.bold, color: Colors.white),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white70, size: 18),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),

            // Tab Navigation
            TabBar(
              controller: _tabController,
              labelColor: AppConstants.moneyGold,
              unselectedLabelColor: Colors.white60,
              indicatorColor: AppConstants.moneyGold,
              labelStyle: const TextStyle(fontFamily: AppConstants.pixelFont, fontSize: 10, fontWeight: FontWeight.bold),
              tabs: const [
                Tab(text: 'OVERVIEW'),
                Tab(text: 'BRACKET'),
                Tab(text: 'SCHEDULE'),
                Tab(text: 'STANDINGS'),
              ],
            ),

            // Tab Content
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  // 1. OVERVIEW
                  TournamentOverviewView(
                    state: widget.state,
                    def: widget.def,
                    instance: inst,
                    onRegister: _handleRegister,
                    onWithdraw: _handleWithdraw,
                  ),
                  // 2. BRACKET
                  _buildBracketTab(inst),
                  // 3. SCHEDULE
                  _buildScheduleTab(inst),
                  // 4. STANDINGS
                  _buildStandingsTab(inst),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBracketTab(TournamentInstance inst) {
    if (inst.matches.isEmpty) {
      return Center(
        child: Text('Mag-uumpisa ang bracket sa Week ${widget.def.startWeek}.', style: const TextStyle(fontFamily: AppConstants.pixelFont, color: Colors.white54, fontSize: 10)),
      );
    }

    final rounds = <int, List<MatchNode>>{};
    for (final m in inst.matches) {
      rounds.putIfAbsent(m.round, () => []).add(m);
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.all(10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: rounds.entries.map((entry) {
          final mList = entry.value;

          return Container(
            width: 130,
            margin: const EdgeInsets.only(right: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  color: const Color(0xFF1B2A49),
                  child: Text(
                    mList.first.roundName.toUpperCase(),
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontFamily: AppConstants.pixelFont, fontSize: 9, fontWeight: FontWeight.bold, color: AppConstants.moneyGold),
                  ),
                ),
                const SizedBox(height: 8),
                for (final match in mList) ...[
                  _buildMatchBox(match),
                  const SizedBox(height: 10),
                ],
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildMatchBox(MatchNode match) {
    final hasUser = match.hasUser;
    final isPlayed = match.isPlayed;

    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: const Color(0xFF142036),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(
          color: hasUser ? AppConstants.moneyGold : (isPlayed ? AppConstants.darkNavy : AppConstants.energyBlue),
          width: hasUser ? 1.5 : 1,
        ),
      ),
      child: Column(
        children: [
          _buildSlotRow(match.slotA, match.winnerId == match.slotA.teamId),
          const Divider(height: 6, color: Colors.white12),
          _buildSlotRow(match.slotB, match.winnerId == match.slotB.teamId),
          const SizedBox(height: 4),
          Text(
            isPlayed ? 'FINAL (Bo${match.bestOf})' : 'W${match.week} D5 (Bo${match.bestOf})',
            style: const TextStyle(fontFamily: AppConstants.pixelFont, fontSize: 7, color: Colors.white38),
          ),
        ],
      ),
    );
  }

  Widget _buildSlotRow(MatchSlot slot, bool isWinner) {
    final isUser = slot.teamId == 'user_team';
    return Row(
      children: [
        Expanded(
          child: Text(
            slot.teamName,
            style: TextStyle(
              fontFamily: AppConstants.pixelFont,
              fontSize: 9,
              fontWeight: isWinner || isUser ? FontWeight.bold : FontWeight.normal,
              color: isWinner ? AppConstants.positiveGreen : (isUser ? AppConstants.moneyGold : Colors.white70),
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        Text(
          '${slot.score}',
          style: TextStyle(
            fontFamily: AppConstants.pixelFont,
            fontSize: 9,
            fontWeight: FontWeight.bold,
            color: isWinner ? AppConstants.positiveGreen : Colors.white60,
          ),
        ),
      ],
    );
  }

  Widget _buildScheduleTab(TournamentInstance inst) {
    final curWeek = widget.state.weekOfYear;
    if (inst.matches.isEmpty) {
      return const Center(child: Text('Walang schedule.', style: TextStyle(fontFamily: AppConstants.pixelFont, color: Colors.white54, fontSize: 10)));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(8),
      itemCount: inst.matches.length,
      itemBuilder: (context, idx) {
        final m = inst.matches[idx];
        final isUser = m.hasUser;

        return Container(
          margin: const EdgeInsets.only(bottom: 6),
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: isUser ? const Color(0xFF233458) : const Color(0xFF142036),
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: isUser ? AppConstants.moneyGold : AppConstants.darkNavy),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Week ${m.week} Day 5 | ${m.roundName}', style: const TextStyle(fontFamily: AppConstants.pixelFont, fontSize: 8, color: Colors.white54)),
                  Text('${m.slotA.teamName} vs ${m.slotB.teamName}', style: const TextStyle(fontFamily: AppConstants.pixelFont, fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white)),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: m.isPlayed ? AppConstants.positiveGreen : (m.week == curWeek ? AppConstants.negativeRed : AppConstants.energyBlue),
                  borderRadius: BorderRadius.circular(3),
                ),
                child: Text(
                  m.isPlayed ? '${m.slotA.score} - ${m.slotB.score}' : (m.week == curWeek ? 'TODAY' : 'UPCOMING'),
                  style: const TextStyle(fontFamily: AppConstants.pixelFont, fontSize: 8, fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStandingsTab(TournamentInstance inst) {
    if (inst.standings.isEmpty) {
      return const Center(child: Text('Walang standings para sa format na ito.', style: TextStyle(fontFamily: AppConstants.pixelFont, color: Colors.white54, fontSize: 10)));
    }

    final sorted = List<RoundRobinTeamStat>.from(inst.standings);
    sorted.sort((a, b) {
      final pDiff = b.points.compareTo(a.points);
      if (pDiff != 0) return pDiff;
      return b.gameDiff.compareTo(a.gameDiff);
    });

    return ListView.builder(
      padding: const EdgeInsets.all(8),
      itemCount: sorted.length,
      itemBuilder: (context, idx) {
        final s = sorted[idx];
        final isUser = s.teamId == 'user_team';

        return Container(
          margin: const EdgeInsets.only(bottom: 4),
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          decoration: BoxDecoration(
            color: isUser ? const Color(0xFF233458) : const Color(0xFF142036),
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: isUser ? AppConstants.moneyGold : AppConstants.darkNavy),
          ),
          child: Row(
            children: [
              SizedBox(width: 20, child: Text('${idx + 1}', style: const TextStyle(fontFamily: AppConstants.pixelFont, fontSize: 9, color: Colors.white70))),
              Expanded(child: Text(s.teamName, style: TextStyle(fontFamily: AppConstants.pixelFont, fontSize: 10, fontWeight: isUser ? FontWeight.bold : FontWeight.normal, color: isUser ? AppConstants.moneyGold : Colors.white))),
              Text('${s.wins}W - ${s.losses}L', style: const TextStyle(fontFamily: AppConstants.pixelFont, fontSize: 9, color: Colors.white70)),
              const SizedBox(width: 10),
              Text('${s.points} pts', style: const TextStyle(fontFamily: AppConstants.pixelFont, fontSize: 9, fontWeight: FontWeight.bold, color: AppConstants.moneyGold)),
            ],
          ),
        );
      },
    );
  }
}
