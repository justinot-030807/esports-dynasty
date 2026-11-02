import 'package:flutter/material.dart';
import '../../core/constants.dart';
import '../../models/legacy_state.dart';
import '../../services/legacy_service.dart';
import '../../services/audio_manager.dart';
import '../widgets/pixel_panel.dart';
import '../widgets/pixel_button.dart';

class LegacyShopDialog extends StatefulWidget {
  final VoidCallback? onPerksUpdated;

  const LegacyShopDialog({
    super.key,
    this.onPerksUpdated,
  });

  @override
  State<LegacyShopDialog> createState() => _LegacyShopDialogState();
}

class _LegacyShopDialogState extends State<LegacyShopDialog> {
  late List<String> _selectedPerks;

  @override
  void initState() {
    super.initState();
    _selectedPerks = List.from(LegacyService().globalLegacy.activePerkIds);
  }

  int get _usedPoints {
    int total = 0;
    for (final id in _selectedPerks) {
      final p = LegacyState.availablePerks.firstWhere((item) => item.id == id);
      total += p.pointCost;
    }
    return total;
  }

  int get _availablePoints => LegacyService().globalLegacy.totalLegacyPoints;

  void _togglePerk(LegacyPerkDef perk) {
    setState(() {
      if (_selectedPerks.contains(perk.id)) {
        _selectedPerks.remove(perk.id);
        AudioManager().playSfx(AudioSfx.cancel);
      } else {
        if (_usedPoints + perk.pointCost <= _availablePoints) {
          _selectedPerks.add(perk.id);
          AudioManager().playSfx(AudioSfx.coin);
        } else {
          AudioManager().playSfx(AudioSfx.hit);
        }
      }
    });
  }

  void _saveAndClose() {
    LegacyService().globalLegacy.activePerkIds = List.from(_selectedPerks);
    LegacyService().saveLegacy();
    widget.onPerksUpdated?.call();
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final remaining = _availablePoints - _usedPoints;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 20),
      child: PixelPanel(
        title: 'LEGACY VAULT (NEW GAME+)',
        width: 330,
        onClose: () => Navigator.pop(context),
        child: SizedBox(
          height: 480,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Budget Header
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppConstants.darkNavy,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'LEGACY POINTS:',
                      style: TextStyle(
                        fontFamily: AppConstants.pixelFont,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: Colors.white70,
                      ),
                    ),
                    Text(
                      '$remaining / $_availablePoints PTS',
                      style: const TextStyle(
                        fontFamily: AppConstants.pixelFont,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: AppConstants.moneyGold,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),

              const Text(
                'Pumili ng mga bonus perks para sa susunod mong New Game run:',
                style: TextStyle(
                  fontFamily: AppConstants.pixelFont,
                  fontSize: 9,
                  color: Colors.black54,
                ),
              ),
              const SizedBox(height: 8),

              // Perks List
              Expanded(
                child: ListView.builder(
                  itemCount: LegacyState.availablePerks.length,
                  itemBuilder: (context, index) {
                    final perk = LegacyState.availablePerks[index];
                    final isSelected = _selectedPerks.contains(perk.id);
                    final canAfford = remaining >= perk.pointCost || isSelected;

                    return Container(
                      margin: const EdgeInsets.only(bottom: 6),
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: isSelected ? AppConstants.positiveGreen.withValues(alpha: 0.15) : Colors.white,
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                          color: isSelected ? AppConstants.positiveGreen : const Color(0xFFD0D7DE),
                          width: isSelected ? 2 : 1.5,
                        ),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      perk.name,
                                      style: TextStyle(
                                        fontFamily: AppConstants.pixelFont,
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                        color: isSelected ? AppConstants.darkNavy : Colors.black87,
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                                      decoration: BoxDecoration(
                                        color: AppConstants.moneyGold.withValues(alpha: 0.2),
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Text(
                                        '${perk.pointCost} PTS',
                                        style: const TextStyle(
                                          fontFamily: AppConstants.pixelFont,
                                          fontSize: 8,
                                          fontWeight: FontWeight.bold,
                                          color: AppConstants.darkNavy,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  perk.description,
                                  style: const TextStyle(
                                    fontFamily: AppConstants.pixelFont,
                                    fontSize: 8.5,
                                    color: Colors.black54,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Checkbox(
                            value: isSelected,
                            activeColor: AppConstants.positiveGreen,
                            onChanged: canAfford ? (_) => _togglePerk(perk) : null,
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 8),

              // Save Button
              PixelButton(
                label: 'I-APPLY ANG MGA PERK',
                color: PixelButtonColor.green,
                fontSize: 10,
                height: 34,
                onPressed: _saveAndClose,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
