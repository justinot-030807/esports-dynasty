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
      decoration: const BoxDecoration(
        color: Color(0xFFF8FAFC),
        border: Border(
          bottom: BorderSide(color: Color(0xFFE2E8F0), width: 1.5),
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
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
                    padding: const EdgeInsets.only(right: 8),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(5),
                      onTap: () {
                        if (isUnlocked) {
                          state.setActiveDivision(div.id);
                          onDivisionChanged();
                        } else {
                          onOpenManageDivisions();
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? const Color(0xFF0284C7)
                              : (isUnlocked ? const Color(0xFFE2E8F0) : const Color(0xFFF1F5F9)),
                          borderRadius: BorderRadius.circular(5),
                          border: Border.all(
                            color: isSelected ? AppConstants.moneyGold : const Color(0xFFCBD5E1),
                            width: 1.5,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (!isUnlocked) ...[
                              const Icon(Icons.lock, size: 12, color: Color(0xFF94A3B8)),
                              const SizedBox(width: 4),
                            ],
                            Text(
                              div.shortCode,
                              style: TextStyle(
                                fontFamily: AppConstants.pixelFont,
                                fontSize: 12,
                                fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                                color: isSelected ? Colors.white : (isUnlocked ? const Color(0xFF1E293B) : const Color(0xFF94A3B8)),
                              ),
                            ),
                            if (isUnlocked) ...[
                              const SizedBox(width: 5),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                                decoration: BoxDecoration(
                                  color: isSelected ? AppConstants.moneyGold : const Color(0xFF16A34A),
                                  borderRadius: BorderRadius.circular(3),
                                ),
                                child: Text(
                                  '${squad.length}',
                                  style: TextStyle(
                                    fontFamily: AppConstants.pixelFont,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: isSelected ? AppConstants.darkNavy : Colors.white,
                                  ),
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
            borderRadius: BorderRadius.circular(5),
            onTap: onOpenManageDivisions,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: AppConstants.moneyGold,
                borderRadius: BorderRadius.circular(5),
                border: Border.all(color: const Color(0xFFB45309), width: 1.5),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.add_business, size: 14, color: Color(0xFF1B2A49)),
                  SizedBox(width: 4),
                  Text(
                    'CLUB',
                    style: TextStyle(
                      fontFamily: AppConstants.pixelFont,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1B2A49),
                      letterSpacing: 0.5,
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
