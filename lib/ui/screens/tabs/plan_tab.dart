import 'package:flutter/material.dart';
import '../../../core/constants.dart';
import '../../../models/game_state.dart';
import '../../../models/player.dart';
import '../../../models/weekly_plan.dart';

class PlanTab extends StatefulWidget {
  final GameState state;
  final VoidCallback onPlanUpdated;

  const PlanTab({
    super.key,
    required this.state,
    required this.onPlanUpdated,
  });

  @override
  State<PlanTab> createState() => _PlanTabState();
}

class _PlanTabState extends State<PlanTab> {
  void _setTeamFocus(TeamFocus focus) {
    setState(() {
      widget.state.currentPlan.focus = focus;
    });
    widget.onPlanUpdated();
  }

  void _setPlayerActivity(String playerId, PlayerActivity act) {
    setState(() {
      widget.state.currentPlan.playerActivities[playerId] = act;
    });
    widget.onPlanUpdated();
  }

  void _autoPlan() {
    setState(() {
      for (final p in widget.state.players) {
        if (p.fatigue >= 60) {
          widget.state.currentPlan.playerActivities[p.id] = PlayerActivity.rest;
        } else {
          // Train role's primary stat
          switch (p.role) {
            case PlayerRole.carry:
            case PlayerRole.entry:
            case PlayerRole.assault:
              widget.state.currentPlan.playerActivities[p.id] = PlayerActivity.trainAim;
              break;
            case PlayerRole.mid:
            case PlayerRole.igl:
            case PlayerRole.lurker:
            case PlayerRole.caller:
              widget.state.currentPlan.playerActivities[p.id] = PlayerActivity.trainGameSense;
              break;
            case PlayerRole.sniper:
            case PlayerRole.scout:
              widget.state.currentPlan.playerActivities[p.id] = PlayerActivity.trainReaction;
              break;
            case PlayerRole.tank:
            case PlayerRole.anchor:
              widget.state.currentPlan.playerActivities[p.id] = PlayerActivity.trainMental;
              break;
            case PlayerRole.roamer:
            case PlayerRole.support:
            case PlayerRole.medic:
              widget.state.currentPlan.playerActivities[p.id] = PlayerActivity.trainTeamwork;
              break;
          }
        }
      }
    });
    widget.onPlanUpdated();
  }

  void _repeatLastWeek() {
    setState(() {
      // Re-apply existing activities
    });
    widget.onPlanUpdated();
  }

  @override
  Widget build(BuildContext context) {
    final pcCount = widget.state.pcDeskCapacity;
    final pcUsers = widget.state.players.where((p) {
      final act = widget.state.currentPlan.playerActivities[p.id] ?? PlayerActivity.trainAim;
      return WeeklyPlan.requiredStation(act) == 'pc';
    }).length;
    final hasStationBottleneck = pcUsers > pcCount;

    return Container(
      color: AppConstants.bgDark,
      child: Column(
        children: [
          // Team Focus selector
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            color: const Color(0xFF1B2A49),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'TEAM FOCUS:',
                      style: TextStyle(fontFamily: AppConstants.pixelFont, fontSize: 11, fontWeight: FontWeight.bold, color: AppConstants.moneyGold),
                    ),
                    DropdownButton<TeamFocus>(
                      value: widget.state.currentPlan.focus,
                      dropdownColor: const Color(0xFF1B2A49),
                      isDense: true,
                      underline: const SizedBox.shrink(),
                      style: const TextStyle(fontFamily: AppConstants.pixelFont, fontSize: 12, color: Colors.white),
                      items: TeamFocus.values.map((f) {
                        return DropdownMenuItem(
                          value: f,
                          child: Text(f.name.toUpperCase()),
                        );
                      }).toList(),
                      onChanged: (val) {
                        if (val != null) _setTeamFocus(val);
                      },
                    ),
                  ],
                ),
                Text(
                  widget.state.currentPlan.focusDescription,
                  style: const TextStyle(fontFamily: AppConstants.pixelFont, fontSize: 9, color: Colors.white70),
                ),
              ],
            ),
          ),

          // Station Warning Bar if bottlenecked
          if (hasStationBottleneck)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              color: AppConstants.negativeRed,
              child: Row(
                children: [
                  const Icon(Icons.warning, size: 14, color: Colors.white),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      'Kulang sa PC Desk! ($pcUsers gumagamit vs $pcCount pwesto) -30% effectiveness.',
                      style: const TextStyle(fontFamily: AppConstants.pixelFont, fontSize: 9, color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),

          // Quick Action Buttons: Auto Plan, Repeat Last Week
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            color: const Color(0xFF233458),
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppConstants.positiveGreen,
                      padding: const EdgeInsets.symmetric(vertical: 6),
                    ),
                    onPressed: _autoPlan,
                    child: const Text('AUTO PLAN', style: TextStyle(fontFamily: AppConstants.pixelFont, fontSize: 10, color: Colors.white)),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppConstants.energyBlue,
                      padding: const EdgeInsets.symmetric(vertical: 6),
                    ),
                    onPressed: _repeatLastWeek,
                    child: const Text('REPEAT LAST WEEK', style: TextStyle(fontFamily: AppConstants.pixelFont, fontSize: 10, color: Colors.white)),
                  ),
                ),
              ],
            ),
          ),

          // Player Plan List
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(10),
              itemCount: widget.state.players.length,
              itemBuilder: (context, idx) {
                final p = widget.state.players[idx];
                final act = widget.state.currentPlan.playerActivities[p.id] ?? PlayerActivity.trainAim;
                final fatigueDelta = WeeklyPlan.baseFatigueChange(act);
                final predictedFatigue = (p.fatigue + fatigueDelta).clamp(0, 100);

                return Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF233458),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: AppConstants.darkNavy, width: 1.5),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: AppConstants.darkNavy,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Center(
                          child: Text(
                            p.role.name.substring(0, 1).toUpperCase(),
                            style: const TextStyle(fontFamily: AppConstants.pixelFont, color: AppConstants.moneyGold, fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),

                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${p.gamerTag} (${p.condition.name.toUpperCase()})',
                              style: const TextStyle(fontFamily: AppConstants.pixelFont, fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
                            ),
                            Text(
                              'Fatigue: ${p.fatigue} -> $predictedFatigue',
                              style: TextStyle(
                                fontFamily: AppConstants.pixelFont,
                                fontSize: 9,
                                color: predictedFatigue >= 60 ? AppConstants.negativeRed : AppConstants.positiveGreen,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Activity Dropdown
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6),
                        decoration: BoxDecoration(
                          color: AppConstants.darkNavy,
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(color: AppConstants.moneyGold, width: 1),
                        ),
                        child: DropdownButton<PlayerActivity>(
                          value: act,
                          dropdownColor: AppConstants.darkNavy,
                          isDense: true,
                          underline: const SizedBox.shrink(),
                          style: const TextStyle(fontFamily: AppConstants.pixelFont, fontSize: 10, color: Colors.white),
                          items: PlayerActivity.values.map((a) {
                            return DropdownMenuItem(
                              value: a,
                              child: Text(WeeklyPlan.activityTitle(a)),
                            );
                          }).toList(),
                          onChanged: (val) {
                            if (val != null) _setPlayerActivity(p.id, val);
                          },
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
