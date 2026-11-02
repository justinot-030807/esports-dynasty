import 'package:flutter/material.dart';
import '../../core/constants.dart';
import '../../models/game_state.dart';
import '../../models/division.dart';

class DivisionSwitcherBar extends StatelessWidget {
  final GameState state;
  final VoidCallback onDivisionChanged;
  final VoidCallback onOpenManageDivisions;

  const DivisionSwitcherBar({
    super.key,
    required this.state,
    required this.onDivisionChanged,
    required this.onOpenManageDivisions,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFF142036),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Row(
        children: [
          // Division Chips
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: EsportsDivision.all.map((div) {
                  final isUnlocked = state.isDivisionUnlocked(div.id);
                  final isSelected = state.activeDivisionId == div.id;
                  final squad = state.getPlayersForDivision(div.id);

                  return Padding(
                    padding: const EdgeInsets.only(right: 6),
                    child: InkWell(
                      onTap: () {
                        if (isUnlocked) {
                          state.setActiveDivision(div.id);
                          onDivisionChanged();
                        } else {
                          onOpenManageDivisions();
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppConstants.energyBlue
                              : (isUnlocked ? const Color(0xFF233458) : const Color(0xFF1B2A49)),
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(
                            color: isSelected ? AppConstants.moneyGold : Colors.transparent,
                            width: 1.5,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (!isUnlocked) ...[
                              const Icon(Icons.lock, size: 10, color: Colors.white54),
                              const SizedBox(width: 3),
                            ],
                            Text(
                              div.shortCode,
                              style: TextStyle(
                                fontFamily: AppConstants.pixelFont,
                                fontSize: 9,
                                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                color: isUnlocked ? Colors.white : Colors.white54,
                              ),
                            ),
                            if (isUnlocked) ...[
                              const SizedBox(width: 4),
                              Text(
                                '${squad.length}',
                                style: TextStyle(
                                  fontFamily: AppConstants.pixelFont,
                                  fontSize: 8,
                                  fontWeight: FontWeight.bold,
                                  color: isSelected ? AppConstants.moneyGold : AppConstants.positiveGreen,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),

          // Manage / Expand Button
          InkWell(
            onTap: onOpenManageDivisions,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppConstants.moneyGold,
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.add_business, size: 11, color: AppConstants.bgDark),
                  SizedBox(width: 3),
                  Text(
                    'CLUB',
                    style: TextStyle(
                      fontFamily: AppConstants.pixelFont,
                      fontSize: 8,
                      fontWeight: FontWeight.bold,
                      color: AppConstants.bgDark,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
