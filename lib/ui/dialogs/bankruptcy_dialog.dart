import 'package:flutter/material.dart';
import '../../core/constants.dart';
import '../../models/game_state.dart';
import '../../models/sponsor.dart';
import '../../services/data_service.dart';
import '../../services/audio_manager.dart';
import '../widgets/pixel_panel.dart';
import '../widgets/pixel_button.dart';

class BankruptcyDialog extends StatelessWidget {
  final GameState state;
  final VoidCallback onStateUpdated;
  final VoidCallback onOpenBuildMode;
  final VoidCallback onOpenTransfers;
  final VoidCallback onReloadSave;

  const BankruptcyDialog({
    super.key,
    required this.state,
    required this.onStateUpdated,
    required this.onOpenBuildMode,
    required this.onOpenTransfers,
    required this.onReloadSave,
  });

  bool get isGameOver => state.consecutiveNegativeWeeks >= 6;

  void _acceptBailout(BuildContext context) {
    AudioManager().playSfx(AudioSfx.coin);
    // Find bailout fund from sponsors
    final def = DataService().sponsors.firstWhere(
      (s) => s.id == 'bailout_fund',
      orElse: () => const SponsorDef(
        id: 'bailout_fund',
        name: 'Emergency Bailout Fund',
        tier: 1,
        weeklyPay: 15000,
        bonusPay: 0,
        minFame: 0,
        durationWeeks: 12,
        goalType: 'win_matches',
        goalTarget: 2,
        desc: 'Tulong pinansyal kapag delikadong ma-bankrupt ang team.',
      ),
    );

    // Give emergency cash injection + sign sponsor
    state.money += 25000;
    state.activeSponsors.removeWhere((s) => s.id == 'bailout_fund');
    state.activeSponsors.add(ActiveSponsor(
      id: def.id,
      name: def.name,
      tier: def.tier,
      weeklyPay: def.weeklyPay,
      bonusPay: def.bonusPay,
      durationWeeks: def.durationWeeks,
      weeksRemaining: def.durationWeeks,
      goalType: def.goalType,
      goalTarget: def.goalTarget,
    ));

    state.storyFlags['received_bailout'] = true;
    state.consecutiveNegativeWeeks = 0;
    state.addNotification('Bailout Granted: +P25,000!', '#3DBE5A', 0.5, 0.4);

    onStateUpdated();
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    if (isGameOver) {
      return Dialog(
        backgroundColor: Colors.transparent,
        child: PixelPanel(
          title: 'GAME OVER: BANGKAROTE',
          width: 320,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.warning, color: AppConstants.negativeRed, size: 48),
              const SizedBox(height: 10),
              Text(
                'Naubos ang pondo ng ${state.teamName}! 6 na linggo nang negatibo ang inyong kaban (P${state.money}). Hindi na kayang pasahurin ang squad at magbayad ng upa.',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontFamily: AppConstants.pixelFont,
                  fontSize: 11,
                  color: AppConstants.darkNavy,
                ),
              ),
              const SizedBox(height: 14),
              PixelButton(
                label: 'RETRY FROM LAST SAVE',
                color: PixelButtonColor.green,
                onPressed: () {
                  Navigator.of(context).pop();
                  onReloadSave();
                },
              ),
            ],
          ),
        ),
      );
    }

    return Dialog(
      backgroundColor: Colors.transparent,
      child: PixelPanel(
        title: 'BABALA: BAON SA UTANG!',
        width: 330,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.red.shade100,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: AppConstants.negativeRed, width: 2),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.error, color: AppConstants.negativeRed, size: 32),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Boss Juan, 4 na linggo nang negatibo ang kaban natin (P${state.money})! May 2 linggo na lang bago magsara ang team.',
                        style: const TextStyle(
                          fontFamily: AppConstants.pixelFont,
                          fontSize: 10,
                          color: AppConstants.negativeRed,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Pumili ng paraan upang maiwasan ang Game Over:',
                style: TextStyle(
                  fontFamily: AppConstants.pixelFont,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: AppConstants.darkNavy,
                ),
              ),
              const SizedBox(height: 8),

              // Option 1: Bailout sponsor
              PixelButton(
                label: 'TANGGAPIN ANG BAILOUT (+P25K)',
                color: PixelButtonColor.yellow,
                height: 34,
                fontSize: 9,
                onPressed: () => _acceptBailout(context),
              ),
              const SizedBox(height: 6),

              // Option 2: Sell furniture
              PixelButton(
                label: 'MAGBENTA NG FURNITURE (BUILD)',
                color: PixelButtonColor.neutral,
                height: 32,
                fontSize: 9,
                onPressed: () {
                  Navigator.of(context).pop();
                  onOpenBuildMode();
                },
              ),
              const SizedBox(height: 6),

              // Option 3: Release players
              PixelButton(
                label: 'MAG-RELEASE NG PLAYERS (TEAM)',
                color: PixelButtonColor.red,
                height: 32,
                fontSize: 9,
                onPressed: () {
                  Navigator.of(context).pop();
                  onOpenTransfers();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
