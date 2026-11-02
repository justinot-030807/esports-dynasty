import 'package:flutter/material.dart';
import '../../core/constants.dart';
import '../../services/settings_service.dart';
import '../../services/audio_manager.dart';
import '../../services/save_service.dart';
import '../widgets/pixel_panel.dart';
import '../widgets/pixel_button.dart';
import 'credits_dialog.dart';
import 'legacy_shop_dialog.dart';

class SettingsDialog extends StatefulWidget {
  final VoidCallback? onSettingsChanged;

  const SettingsDialog({
    super.key,
    this.onSettingsChanged,
  });

  @override
  State<SettingsDialog> createState() => _SettingsDialogState();
}

class _SettingsDialogState extends State<SettingsDialog> {
  final _settings = SettingsService().current;

  void _onChanged() {
    setState(() {});
    SettingsService().saveSettings();
    widget.onSettingsChanged?.call();
  }

  void _confirmResetData() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppConstants.panelLight,
        title: const Text(
          'BURAHIN ANG SAVE DATA?',
          style: TextStyle(fontFamily: AppConstants.pixelFont, fontSize: 13, fontWeight: FontWeight.bold, color: AppConstants.negativeRed),
        ),
        content: const Text(
          'Sigurado ka ba? Mabubura ang lahat ng kasalukuyang laro at progreso.',
          style: TextStyle(fontFamily: AppConstants.pixelFont, fontSize: 10, color: Colors.black87),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('HINDI', style: TextStyle(fontFamily: AppConstants.pixelFont, color: Colors.black54)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              SaveService.deleteSave();
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Nabura ang save data. Muling buksan ang laro.', style: TextStyle(fontFamily: AppConstants.pixelFont))),
              );
            },
            child: const Text('OO, BURAHIN', style: TextStyle(fontFamily: AppConstants.pixelFont, color: AppConstants.negativeRed, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 20),
      child: PixelPanel(
        title: 'MGA SETTING',
        width: 330,
        onClose: () => Navigator.pop(context),
        child: SizedBox(
          height: 480,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: ListView(
                  children: [
                    _buildSectionHeader('TUNOG AT MUSIKA'),
                    SwitchListTile(
                      title: const Text('Sound Effects (SFX)', style: TextStyle(fontFamily: AppConstants.pixelFont, fontSize: 11, fontWeight: FontWeight.bold)),
                      subtitle: const Text('Tunog ng mga click, barya, at panalo', style: TextStyle(fontFamily: AppConstants.pixelFont, fontSize: 8.5)),
                      value: _settings.sfxEnabled,
                      activeTrackColor: AppConstants.positiveGreen,
                      onChanged: (val) {
                        _settings.sfxEnabled = val;
                        AudioManager().playSfx(AudioSfx.tap);
                        _onChanged();
                      },
                    ),
                    if (_settings.sfxEnabled)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: Row(
                          children: [
                            const Text('Lakas: ', style: TextStyle(fontFamily: AppConstants.pixelFont, fontSize: 9)),
                            Expanded(
                              child: Slider(
                                value: _settings.sfxVolume,
                                activeColor: AppConstants.moneyGold,
                                onChanged: (val) {
                                  _settings.sfxVolume = val;
                                  _onChanged();
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    SwitchListTile(
                      title: const Text('Musika (BGM)', style: TextStyle(fontFamily: AppConstants.pixelFont, fontSize: 11, fontWeight: FontWeight.bold)),
                      subtitle: const Text('Chiptune soundtrack sa bahay at arena', style: TextStyle(fontFamily: AppConstants.pixelFont, fontSize: 8.5)),
                      value: _settings.musicEnabled,
                      activeTrackColor: AppConstants.positiveGreen,
                      onChanged: (val) {
                        _settings.musicEnabled = val;
                        _onChanged();
                      },
                    ),

                    const SizedBox(height: 8),
                    _buildSectionHeader('PERFORMANCE & DISPLAY'),
                    SwitchListTile(
                      title: const Text('Low Power Mode (30 FPS)', style: TextStyle(fontFamily: AppConstants.pixelFont, fontSize: 11, fontWeight: FontWeight.bold)),
                      subtitle: const Text('Inirerekomenda para sa 4GB RAM phones upang makatipid sa baterya', style: TextStyle(fontFamily: AppConstants.pixelFont, fontSize: 8.5)),
                      value: _settings.lowPowerMode,
                      activeTrackColor: AppConstants.positiveGreen,
                      onChanged: (val) {
                        _settings.lowPowerMode = val;
                        _onChanged();
                      },
                    ),

                    const SizedBox(height: 8),
                    _buildSectionHeader('AUTO-PAUSE MGA OPSYON'),
                    SwitchListTile(
                      title: const Text('Pause sa Match Day (Day 5)', style: TextStyle(fontFamily: AppConstants.pixelFont, fontSize: 11)),
                      value: _settings.pauseOnMatchDay,
                      activeTrackColor: AppConstants.positiveGreen,
                      onChanged: (val) {
                        _settings.pauseOnMatchDay = val;
                        _onChanged();
                      },
                    ),
                    SwitchListTile(
                      title: const Text('Pause sa mga Random Event', style: TextStyle(fontFamily: AppConstants.pixelFont, fontSize: 11)),
                      value: _settings.pauseOnEvents,
                      activeTrackColor: AppConstants.positiveGreen,
                      onChanged: (val) {
                        _settings.pauseOnEvents = val;
                        _onChanged();
                      },
                    ),

                    const SizedBox(height: 12),
                    PixelButton(
                      label: 'BUKSAN ANG LEGACY SHOP (NG+)',
                      color: PixelButtonColor.yellow,
                      fontSize: 10,
                      height: 32,
                      onPressed: () {
                        showDialog(context: context, builder: (_) => const LegacyShopDialog());
                      },
                    ),
                    const SizedBox(height: 8),
                    PixelButton(
                      label: 'TINGNAN ANG MGA KREDITO',
                      color: PixelButtonColor.neutral,
                      fontSize: 10,
                      height: 32,
                      onPressed: () {
                        showDialog(context: context, builder: (_) => const CreditsDialog());
                      },
                    ),
                    const SizedBox(height: 8),
                    PixelButton(
                      label: 'BURAHIN ANG SAVE DATA (RESET)',
                      color: PixelButtonColor.red,
                      fontSize: 10,
                      height: 32,
                      onPressed: _confirmResetData,
                    ),
                    const SizedBox(height: 8),
                  ],
                ),
              ),
              PixelButton(
                label: 'ISARA AT I-SAVE',
                color: PixelButtonColor.green,
                fontSize: 10,
                height: 32,
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Container(
      margin: const EdgeInsets.only(top: 6, bottom: 4),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      color: AppConstants.darkNavy,
      child: Text(
        title,
        style: const TextStyle(
          fontFamily: AppConstants.pixelFont,
          fontSize: 9,
          fontWeight: FontWeight.bold,
          color: AppConstants.moneyGold,
        ),
      ),
    );
  }
}
