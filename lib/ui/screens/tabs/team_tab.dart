import 'dart:math';
import 'package:flutter/material.dart';
import '../../../core/constants.dart';
import '../../../models/game_state.dart';
import '../../../models/player.dart';
import '../../../models/division.dart';
import '../../dialogs/player_detail_dialog.dart';
import '../../dialogs/scouting_dialog.dart';
import '../../dialogs/staff_dialog.dart';
import '../../dialogs/divisions_dialog.dart';

class TeamTab extends StatefulWidget {
  final GameState state;
  final VoidCallback onStateUpdated;

  const TeamTab({
    super.key,
    required this.state,
    required this.onStateUpdated,
  });

  @override
  State<TeamTab> createState() => _TeamTabState();
}

class _TeamTabState extends State<TeamTab> {
  String _divisionFilter = 'ALL';

  Color _conditionColor(PlayerCondition c) {
    switch (c) {
      case PlayerCondition.great: return AppConstants.positiveGreen;
      case PlayerCondition.good: return AppConstants.energyBlue;
      case PlayerCondition.normal: return Colors.grey;
      case PlayerCondition.tired: return AppConstants.moneyGold;
      case PlayerCondition.exhausted: return AppConstants.negativeRed;
    }
  }

  void _openPlayerDetail(Player p) {
    showDialog(
      context: context,
      builder: (_) => PlayerDetailDialog(
        player: p,
        state: widget.state,
        onStateUpdated: widget.onStateUpdated,
        onToggleStarter: () {
          setState(() {
            p.isStarter = !p.isStarter;
          });
          widget.onStateUpdated();
        },
        onRelease: () {
          setState(() {
            widget.state.players.remove(p);
            widget.state.currentPlan.playerActivities.remove(p.id);
          });
          widget.onStateUpdated();
        },
      ),
    );
  }

  void _openScouting() {
    showDialog(
      context: context,
      builder: (_) => ScoutingDialog(
        state: widget.state,
        onRosterUpdated: () {
          setState(() {});
          widget.onStateUpdated();
        },
      ),
    );
  }

  void _openStaff() {
    showDialog(
      context: context,
      builder: (_) => StaffDialog(
        state: widget.state,
        onUpdated: () {
          setState(() {});
          widget.onStateUpdated();
        },
      ),
    );
  }

  void _openDivisions() {
    showDialog(
      context: context,
      builder: (_) => DivisionsDialog(
        state: widget.state,
        onStateUpdated: () {
          setState(() {});
          widget.onStateUpdated();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final filteredPlayers = _divisionFilter == 'ALL'
        ? widget.state.players
        : widget.state.players.where((p) => p.divisionId == _divisionFilter).toList();

    return Container(
      color: AppConstants.bgDark,
      child: Column(
        children: [
          // Sub-header with Scouting, Staff, and Divisions buttons
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            color: const Color(0xFF1B2A49),
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppConstants.moneyGold,
                      padding: const EdgeInsets.symmetric(vertical: 4),
                    ),
                    icon: const Icon(Icons.person_search, size: 13, color: AppConstants.darkNavy),
                    label: const Text(
                      'SCOUT',
                      style: TextStyle(fontFamily: AppConstants.pixelFont, fontSize: 9, fontWeight: FontWeight.bold, color: AppConstants.darkNavy),
                    ),
                    onPressed: _openScouting,
                  ),
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppConstants.energyBlue,
                      padding: const EdgeInsets.symmetric(vertical: 4),
                    ),
                    icon: const Icon(Icons.badge, size: 13, color: Colors.white),
                    label: const Text(
                      'STAFF',
                      style: TextStyle(fontFamily: AppConstants.pixelFont, fontSize: 9, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                    onPressed: _openStaff,
                  ),
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF9B5DE5),
                      padding: const EdgeInsets.symmetric(vertical: 4),
                    ),
                    icon: const Icon(Icons.hub, size: 13, color: Colors.white),
                    label: const Text(
                      'CLUB',
                      style: TextStyle(fontFamily: AppConstants.pixelFont, fontSize: 9, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                    onPressed: _openDivisions,
                  ),
                ),
              ],
            ),
          ),

          // Division filter chips
          Container(
            height: 32,
            padding: const EdgeInsets.symmetric(horizontal: 8),
            color: const Color(0xFF142036),
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                _buildFilterChip('ALL', 'ALL (${widget.state.players.length})'),
                ...EsportsDivision.all.map((d) {
                  final count = widget.state.getPlayersForDivision(d.id).length;
                  return _buildFilterChip(d.id, '${d.shortCode} ($count)');
                }),
              ],
            ),
          ),

          // Player Roster List
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(10),
              itemCount: filteredPlayers.length,
              itemBuilder: (context, idx) {
                final p = filteredPlayers[idx];
                final condColor = _conditionColor(p.condition);

                return GestureDetector(
                  onTap: () => _openPlayerDetail(p),
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color(0xFF233458),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                        color: p.isStarter ? AppConstants.moneyGold : AppConstants.darkNavy,
                        width: 2.0,
                      ),
                    ),
                    child: Row(
                      children: [
                        // Role Icon Box
                        Container(
                          width: 38,
                          height: 38,
                          decoration: BoxDecoration(
                            color: AppConstants.darkNavy,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Center(
                            child: Text(
                              p.role.name.substring(0, min(2, p.role.name.length)).toUpperCase(),
                              style: const TextStyle(
                                fontFamily: AppConstants.pixelFont,
                                color: AppConstants.moneyGold,
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),

                        // Name, OVR, Rank
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    p.gamerTag,
                                    style: const TextStyle(
                                      fontFamily: AppConstants.pixelFont,
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                                    decoration: BoxDecoration(
                                      color: p.isStarter ? AppConstants.positiveGreen : Colors.grey.shade700,
                                      borderRadius: BorderRadius.circular(3),
                                    ),
                                    child: Text(
                                      p.isStarter ? 'STARTER' : 'BENCH',
                                      style: const TextStyle(fontFamily: AppConstants.pixelFont, fontSize: 8, color: Colors.white),
                                    ),
                                  ),
                                ],
                              ),
                              Text(
                                '${p.realName} | [${p.divisionId.split('_').map((w) => w[0]).join().toUpperCase()}] ${p.roleDisplayName.toUpperCase()} | OVR ${p.ovr} (${p.rankTitle})',
                                style: const TextStyle(
                                  fontFamily: AppConstants.pixelFont,
                                  color: Colors.white70,
                                  fontSize: 10,
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Condition & Salary chip
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                              decoration: BoxDecoration(
                                color: condColor,
                                borderRadius: BorderRadius.circular(3),
                              ),
                              child: Text(
                                p.condition.name.toUpperCase(),
                                style: const TextStyle(
                                  fontFamily: AppConstants.pixelFont,
                                  fontSize: 9,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              'P${p.weeklySalary}/wk',
                              style: const TextStyle(
                                fontFamily: AppConstants.pixelFont,
                                color: AppConstants.moneyGold,
                                fontSize: 10,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String filterKey, String label) {
    final isSel = _divisionFilter == filterKey;
    return Padding(
      padding: const EdgeInsets.only(right: 6, top: 4, bottom: 4),
      child: ChoiceChip(
        label: Text(
          label,
          style: TextStyle(
            fontFamily: AppConstants.pixelFont,
            fontSize: 8,
            color: isSel ? Colors.white : Colors.white70,
            fontWeight: isSel ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        selected: isSel,
        selectedColor: AppConstants.energyBlue,
        backgroundColor: const Color(0xFF233458),
        onSelected: (_) => setState(() => _divisionFilter = filterKey),
      ),
    );
  }
}
