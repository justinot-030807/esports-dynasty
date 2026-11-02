import 'package:flutter/material.dart';
import '../../core/constants.dart';
import '../../models/game_state.dart';
import '../../models/division.dart';
import '../../services/division_service.dart';
import '../../services/audio_manager.dart';
import '../widgets/pixel_panel.dart';
import '../widgets/pixel_button.dart';

class DivisionsDialog extends StatefulWidget {
  final GameState state;
  final VoidCallback onStateUpdated;

  const DivisionsDialog({
    super.key,
    required this.state,
    required this.onStateUpdated,
  });

  @override
  State<DivisionsDialog> createState() => _DivisionsDialogState();
}

class _DivisionsDialogState extends State<DivisionsDialog> {
  void _unlockDivision(EsportsDivision div) {
    AudioManager().playSfx(AudioSfx.coin);
    final success = DivisionService.unlockDivision(widget.state, div.id);
    if (success) {
      AudioManager().playSfx(AudioSfx.promotion);
      setState(() {});
      widget.onStateUpdated();
    }
  }

  void _selectDivision(EsportsDivision div) {
    AudioManager().playSfx(AudioSfx.tap);
    setState(() {
      widget.state.setActiveDivision(div.id);
    });
    widget.onStateUpdated();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: PixelPanel(
        title: 'CLUB DIVISIONS',
        width: 330,
        height: 520,
        onClose: () => Navigator.of(context).pop(),
        child: Column(
          children: [
            // Header info
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              margin: const EdgeInsets.only(bottom: 8),
              decoration: BoxDecoration(
                color: const Color(0xFF1B2A49),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'CLUB: ${widget.state.teamName.toUpperCase()}',
                    style: const TextStyle(
                      fontFamily: AppConstants.pixelFont,
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                      color: AppConstants.moneyGold,
                    ),
                  ),
                  Text(
                    'FAME: ${widget.state.fame}',
                    style: const TextStyle(
                      fontFamily: AppConstants.pixelFont,
                      fontSize: 9,
                      color: AppConstants.famePurple,
                    ),
                  ),
                ],
              ),
            ),

            // Divisions list
            Expanded(
              child: ListView.builder(
                itemCount: EsportsDivision.all.length,
                itemBuilder: (context, idx) {
                  final div = EsportsDivision.all[idx];
                  final isUnlocked = widget.state.isDivisionUnlocked(div.id);
                  final isActive = widget.state.activeDivisionId == div.id;
                  final canUnlock = DivisionService.canUnlockDivision(widget.state, div);
                  final stats = DivisionService.getDivisionStats(widget.state, div.id);

                  return Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: isActive
                          ? const Color(0xFF233E6E)
                          : (isUnlocked ? const Color(0xFF1E2D48) : const Color(0xFF142036)),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                        color: isActive
                            ? AppConstants.moneyGold
                            : (isUnlocked ? AppConstants.energyBlue : Colors.white24),
                        width: isActive ? 2.0 : 1.0,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Title row
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: isActive ? AppConstants.moneyGold : AppConstants.energyBlue,
                                borderRadius: BorderRadius.circular(3),
                              ),
                              child: Text(
                                div.shortCode,
                                style: const TextStyle(
                                  fontFamily: AppConstants.pixelFont,
                                  fontSize: 8,
                                  fontWeight: FontWeight.bold,
                                  color: AppConstants.bgDark,
                                ),
                              ),
                            ),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    div.name,
                                    style: const TextStyle(
                                      fontFamily: AppConstants.pixelFont,
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                  Text(
                                    '${div.genre} - ${div.squadSize} Players',
                                    style: const TextStyle(
                                      fontFamily: AppConstants.pixelFont,
                                      fontSize: 8,
                                      color: Colors.white70,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            if (isActive)
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: AppConstants.positiveGreen,
                                  borderRadius: BorderRadius.circular(3),
                                ),
                                child: const Text(
                                  'ACTIVE',
                                  style: TextStyle(
                                    fontFamily: AppConstants.pixelFont,
                                    fontSize: 8,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 6),

                        // Tagline
                        Text(
                          div.tagline,
                          style: const TextStyle(
                            fontFamily: AppConstants.pixelFont,
                            fontSize: 8,
                            fontStyle: FontStyle.italic,
                            color: Colors.white60,
                          ),
                        ),
                        const SizedBox(height: 6),

                        // Stats or unlock card
                        if (isUnlocked) ...[
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                            decoration: BoxDecoration(
                              color: const Color(0xFF16233B),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                _buildMiniStat('ROSTER', '${stats['totalPlayers']}/${div.squadSize}'),
                                _buildMiniStat('AVG OVR', '${stats['avgOvr']}'),
                                _buildMiniStat('POINTS', '${stats['circuitPoints']}'),
                                _buildMiniStat('TITLES', '${stats['titlesWon']}'),
                              ],
                            ),
                          ),
                          const SizedBox(height: 6),
                          if (!isActive)
                            SizedBox(
                              width: double.infinity,
                              child: PixelButton(
                                label: 'SWITCH TO THIS SQUAD',
                                height: 26,
                                fontSize: 8,
                                color: PixelButtonColor.neutral,
                                onPressed: () => _selectDivision(div),
                              ),
                            ),
                        ] else ...[
                          Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: const Color(0xFF16233B),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'REQ: ${div.minFame} FAME | P${div.unlockCost}',
                                  style: const TextStyle(
                                    fontFamily: AppConstants.pixelFont,
                                    fontSize: 8,
                                    color: AppConstants.moneyGold,
                                  ),
                                ),
                                Text(
                                  widget.state.fame >= div.minFame ? 'ELIGIBLE' : 'LOCKED',
                                  style: TextStyle(
                                    fontFamily: AppConstants.pixelFont,
                                    fontSize: 8,
                                    fontWeight: FontWeight.bold,
                                    color: widget.state.fame >= div.minFame
                                        ? AppConstants.positiveGreen
                                        : AppConstants.negativeRed,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 6),
                          SizedBox(
                            width: double.infinity,
                            child: PixelButton(
                              label: 'EXPAND FRANCHISE (P${div.unlockCost})',
                              height: 26,
                              fontSize: 8,
                              color: canUnlock ? PixelButtonColor.green : PixelButtonColor.neutral,
                              onPressed: canUnlock ? () => _unlockDivision(div) : null,
                            ),
                          ),
                        ],
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

  Widget _buildMiniStat(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontFamily: AppConstants.pixelFont,
            fontSize: 9,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            fontFamily: AppConstants.pixelFont,
            fontSize: 7,
            color: Colors.white54,
          ),
        ),
      ],
    );
  }
}
