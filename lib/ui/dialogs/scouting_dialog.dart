import 'dart:math';
import 'package:flutter/material.dart';
import '../../core/constants.dart';
import '../../models/game_state.dart';
import '../../models/player.dart';
import '../../services/scouting_service.dart';
import '../widgets/pixel_panel.dart';

class ScoutingDialog extends StatefulWidget {
  final GameState state;
  final VoidCallback onRosterUpdated;

  const ScoutingDialog({
    super.key,
    required this.state,
    required this.onRosterUpdated,
  });

  @override
  State<ScoutingDialog> createState() => _ScoutingDialogState();
}

class _ScoutingDialogState extends State<ScoutingDialog> {
  @override
  void initState() {
    super.initState();
    if (widget.state.freeAgents.isEmpty) {
      widget.state.freeAgents = ScoutingService.generateFreeAgents(widget.state);
    }
  }

  void _signPlayer(Player candidate) {
    if (widget.state.players.length >= widget.state.maxRosterCap) {
      _showMessage('Puno na ang Roster! (Cap: ${widget.state.maxRosterCap})');
      return;
    }

    setState(() {
      widget.state.freeAgents.remove(candidate);
      widget.state.players.add(candidate);
      widget.state.addNotification('+1 Recruit!', '#3DBE5A', 0.5, 0.4);

      // Tutorial progression (Step 1 recruit)
      if (widget.state.tutorial.step == 1 && widget.state.players.length >= 4) {
        widget.state.tutorial.step = 2;
      }
    });
    widget.onRosterUpdated();
    _showMessage('Na-sign si ${candidate.gamerTag} sa koponan!');
  }

  void _runOpenTryouts() {
    const tryoutCost = 5000;
    if (widget.state.money < tryoutCost) {
      _showMessage('Kulang ang pera para sa Open Tryouts (P5,000)!');
      return;
    }

    setState(() {
      widget.state.money -= tryoutCost;
      widget.state.freeAgents = ScoutingService.generateFreeAgents(widget.state, count: 10);
      widget.state.addNotification('Open Tryouts!', '#F5B700', 0.5, 0.4);
    });
    widget.onRosterUpdated();
    _showMessage('10 bagong kandidato ang dumating sa tryouts!');
  }

  void _showMessage(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg, style: const TextStyle(fontFamily: AppConstants.pixelFont)),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 20),
      child: PixelPanel(
        title: 'SCOUTING (${widget.state.activeDivision.shortCode})',
        width: 330,
        height: 480,
        onClose: () => Navigator.of(context).pop(),
        child: Column(
          children: [
            // Header buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Roster: ${widget.state.players.length}/${widget.state.maxRosterCap}',
                  style: const TextStyle(fontFamily: AppConstants.pixelFont, fontSize: 11, fontWeight: FontWeight.bold, color: AppConstants.darkNavy),
                ),
                GestureDetector(
                  onTap: _runOpenTryouts,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppConstants.moneyGold,
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(color: AppConstants.darkNavy, width: 1.5),
                    ),
                    child: const Text(
                      'OPEN TRYOUTS (P5K)',
                      style: TextStyle(fontFamily: AppConstants.pixelFont, fontSize: 9, fontWeight: FontWeight.bold, color: AppConstants.darkNavy),
                    ),
                  ),
                ),
              ],
            ),
            const Divider(color: Color(0xFFCBD5E0), height: 12),

            // Free agents candidate list
            Expanded(
              child: widget.state.freeAgents.isEmpty
                  ? const Center(
                      child: Text('Walang available na scouts ngayon.', style: TextStyle(fontFamily: AppConstants.pixelFont, color: Colors.black54)),
                    )
                  : ListView.builder(
                      itemCount: widget.state.freeAgents.length,
                      itemBuilder: (context, idx) {
                        final p = widget.state.freeAgents[idx];
                        return Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: AppConstants.darkNavy, width: 1.5),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 34,
                                height: 34,
                                decoration: BoxDecoration(
                                  color: AppConstants.darkNavy,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Center(
                                  child: Text(
                                    p.role.name.substring(0, min(2, p.role.name.length)).toUpperCase(),
                                    style: const TextStyle(fontFamily: AppConstants.pixelFont, color: AppConstants.moneyGold, fontSize: 13, fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      '${p.gamerTag} (OVR ${p.ovr})',
                                      style: const TextStyle(fontFamily: AppConstants.pixelFont, fontSize: 12, fontWeight: FontWeight.bold, color: AppConstants.darkNavy),
                                    ),
                                    Text(
                                      '${p.roleDisplayName} | Trait: ${p.traits.first}',
                                      style: const TextStyle(fontFamily: AppConstants.pixelFont, fontSize: 9, color: Colors.black54),
                                    ),
                                  ],
                                ),
                              ),
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppConstants.positiveGreen,
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  minimumSize: const Size(54, 28),
                                ),
                                onPressed: () => _signPlayer(p),
                                child: const Text('RECRUIT', style: TextStyle(fontFamily: AppConstants.pixelFont, fontSize: 9, color: Colors.white)),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
