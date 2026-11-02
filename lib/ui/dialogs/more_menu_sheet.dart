import 'package:flutter/material.dart';
import '../../core/constants.dart';
import '../../models/game_state.dart';
import '../../services/save_service.dart';
import 'monthly_report_dialog.dart';
import 'hall_of_fame_dialog.dart';
import 'debug_menu_dialog.dart';
import 'sponsors_dialog.dart';
import 'staff_dialog.dart';
import 'transfer_market_dialog.dart';
import 'achievements_dialog.dart';
import 'settings_dialog.dart';
import 'legacy_shop_dialog.dart';
import 'divisions_dialog.dart';

class MoreMenuSheet extends StatelessWidget {
  final GameState state;
  final VoidCallback onStateUpdated;

  const MoreMenuSheet({
    super.key,
    required this.state,
    required this.onStateUpdated,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppConstants.panelLight,
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'MORE OPTIONS',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: AppConstants.pixelFont,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppConstants.darkNavy,
                ),
              ),
              const Divider(color: Color(0xFF2B3A5E)),
              ListTile(
                leading: const Icon(Icons.hub, color: Color(0xFF9B5DE5)),
                title: const Text('Club Franchises (Divisions & Expansion)', style: TextStyle(fontFamily: AppConstants.pixelFont, color: AppConstants.textNavy, fontSize: 13)),
                onTap: () {
                  Navigator.pop(context);
                  showDialog(
                    context: context,
                    builder: (_) => DivisionsDialog(state: state, onStateUpdated: onStateUpdated),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.handshake, color: AppConstants.positiveGreen),
                title: const Text('Mga Sponsor (Contracts & Bonuses)', style: TextStyle(fontFamily: AppConstants.pixelFont, color: AppConstants.textNavy, fontSize: 13)),
                onTap: () {
                  Navigator.pop(context);
                  showDialog(
                    context: context,
                    builder: (_) => SponsorsDialog(state: state, onUpdated: onStateUpdated),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.people, color: AppConstants.energyBlue),
                title: const Text('Staff & Coaches (Mentors & Upgrades)', style: TextStyle(fontFamily: AppConstants.pixelFont, color: AppConstants.textNavy, fontSize: 13)),
                onTap: () {
                  Navigator.pop(context);
                  showDialog(
                    context: context,
                    builder: (_) => StaffDialog(state: state, onUpdated: onStateUpdated),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.swap_horiz, color: AppConstants.famePurple),
                title: const Text('Transfers & Academy (Contracts & Scouting)', style: TextStyle(fontFamily: AppConstants.pixelFont, color: AppConstants.textNavy, fontSize: 13)),
                onTap: () {
                  Navigator.pop(context);
                  showDialog(
                    context: context,
                    builder: (_) => TransferMarketDialog(state: state, onUpdated: onStateUpdated),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.emoji_events, color: AppConstants.moneyGold),
                title: const Text('Mga Parangal (Achievements & Milestones)', style: TextStyle(fontFamily: AppConstants.pixelFont, color: AppConstants.textNavy, fontSize: 13)),
                onTap: () {
                  Navigator.pop(context);
                  showDialog(
                    context: context,
                    builder: (_) => AchievementsDialog(state: state, onUpdated: onStateUpdated),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.military_tech, color: AppConstants.moneyGold),
                title: const Text('Hall of Fame', style: TextStyle(fontFamily: AppConstants.pixelFont, color: AppConstants.textNavy, fontSize: 13)),
                onTap: () {
                  Navigator.pop(context);
                  showDialog(context: context, builder: (_) => HallOfFameDialog(state: state));
                },
              ),
              ListTile(
                leading: const Icon(Icons.assessment, color: AppConstants.positiveGreen),
                title: const Text('Buwanang Ulat (Monthly Report)', style: TextStyle(fontFamily: AppConstants.pixelFont, color: AppConstants.textNavy, fontSize: 13)),
                onTap: () {
                  Navigator.pop(context);
                  if (state.lastMonthlyReport != null) {
                    showDialog(
                      context: context,
                      builder: (_) => MonthlyReportDialog(report: state.lastMonthlyReport!),
                    );
                  }
                },
              ),
              ListTile(
                leading: const Icon(Icons.settings, color: AppConstants.textNavy),
                title: const Text('Mga Setting (Audio & Display)', style: TextStyle(fontFamily: AppConstants.pixelFont, color: AppConstants.textNavy, fontSize: 13)),
                onTap: () {
                  Navigator.pop(context);
                  showDialog(context: context, builder: (_) => SettingsDialog(onSettingsChanged: onStateUpdated));
                },
              ),
              ListTile(
                leading: const Icon(Icons.vpn_key, color: AppConstants.moneyGold),
                title: const Text('Legacy Vault (New Game+ Perks)', style: TextStyle(fontFamily: AppConstants.pixelFont, color: AppConstants.textNavy, fontSize: 13)),
                onTap: () {
                  Navigator.pop(context);
                  showDialog(context: context, builder: (_) => LegacyShopDialog(onPerksUpdated: onStateUpdated));
                },
              ),
              ListTile(
                leading: const Icon(Icons.bug_report, color: AppConstants.negativeRed),
                title: const Text('Debug Menu', style: TextStyle(fontFamily: AppConstants.pixelFont, color: AppConstants.textNavy, fontSize: 13)),
                onTap: () {
                  Navigator.pop(context);
                  showDialog(
                    context: context,
                    builder: (_) => DebugMenuDialog(
                      state: state,
                      onStateUpdated: () {
                        onStateUpdated();
                        SaveService.saveGame(state);
                      },
                    ),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.save, color: AppConstants.moneyGold),
                title: const Text('I-save ang Laro Ngayon', style: TextStyle(fontFamily: AppConstants.pixelFont, color: AppConstants.textNavy, fontSize: 13)),
                onTap: () {
                  Navigator.pop(context);
                  SaveService.saveGame(state);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Matagumpay na na-save ang laro!', style: TextStyle(fontFamily: AppConstants.pixelFont))),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
