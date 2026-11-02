import 'package:flutter/material.dart';
import '../../core/constants.dart';
import '../../models/game_state.dart';
import '../../models/tournament.dart';
import '../../services/tournament_service.dart';

class TournamentOverviewView extends StatelessWidget {
  final GameState state;
  final TournamentDef def;
  final TournamentInstance instance;
  final VoidCallback onRegister;
  final VoidCallback onWithdraw;

  const TournamentOverviewView({
    super.key,
    required this.state,
    required this.def,
    required this.instance,
    required this.onRegister,
    required this.onWithdraw,
  });

  @override
  Widget build(BuildContext context) {
    final curWeek = state.weekOfYear;
    final isRegOpen = curWeek >= def.startWeek + def.regOpenOffset &&
        curWeek <= def.startWeek + def.regCloseOffset;
    final isRegistered = instance.isUserRegistered;
    final totalCost = def.entryFee + def.travelCost;
    final fameOk = state.fame >= def.minFame && state.fame <= def.maxFame;
    final moneyOk = state.money >= totalCost;
    final rosterOk = state.starters.length >= 5 && !state.starters.any((p) => p.isExhausted);
    final qualOk = TournamentService.checkUserQualified(state, def);

    return ListView(
      padding: const EdgeInsets.all(12),
      children: [
        // Rewards Panel
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: const Color(0xFF142036),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Column(children: [
                const Text('CHAMPION', style: TextStyle(fontFamily: AppConstants.pixelFont, fontSize: 8, color: Colors.white54)),
                Text('P${def.championPrize}', style: const TextStyle(fontFamily: AppConstants.pixelFont, fontSize: 12, fontWeight: FontWeight.bold, color: AppConstants.moneyGold)),
              ]),
              Column(children: [
                const Text('FAME / FANS', style: TextStyle(fontFamily: AppConstants.pixelFont, fontSize: 8, color: Colors.white54)),
                Text('+${def.championFame} / +${def.championFans}', style: const TextStyle(fontFamily: AppConstants.pixelFont, fontSize: 10, color: AppConstants.fansPink)),
              ]),
              Column(children: [
                const Text('CIRCUIT', style: TextStyle(fontFamily: AppConstants.pixelFont, fontSize: 8, color: Colors.white54)),
                Text('+${def.circuitPoints} pts', style: const TextStyle(fontFamily: AppConstants.pixelFont, fontSize: 10, color: AppConstants.famePurple)),
              ]),
            ],
          ),
        ),
        const SizedBox(height: 12),

        // Requirement Checklist
        const Text('REQUIREMENTS CHECKLIST', style: TextStyle(fontFamily: AppConstants.pixelFont, fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white70)),
        const SizedBox(height: 4),
        _buildCheckRow('Fame Range (${def.minFame} - ${def.maxFame})', fameOk, 'Current: ${state.fame}'),
        _buildCheckRow('Funds for Entry (P$totalCost)', moneyOk, 'Cash: P${state.money}'),
        _buildCheckRow('5 Healthy Starters (Walang Exhausted)', rosterOk, '${state.starters.length} starters'),
        _buildCheckRow('Qualification Status', qualOk, qualOk ? 'QUALIFIED' : 'NOT QUALIFIED'),
        const SizedBox(height: 16),

        // Action Button
        Center(
          child: isRegistered
              ? ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(backgroundColor: AppConstants.negativeRed, minimumSize: const Size(200, 38)),
                  icon: const Icon(Icons.cancel, size: 16, color: Colors.white),
                  label: const Text('WITHDRAW (50% REFUND)', style: TextStyle(fontFamily: AppConstants.pixelFont, fontSize: 11, color: Colors.white)),
                  onPressed: curWeek < def.startWeek ? onWithdraw : null,
                )
              : ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isRegOpen && fameOk && moneyOk && rosterOk && qualOk ? AppConstants.positiveGreen : Colors.grey.shade700,
                    minimumSize: const Size(200, 38),
                  ),
                  icon: const Icon(Icons.how_to_reg, size: 16, color: Colors.white),
                  label: Text(
                    isRegOpen ? 'REGISTER (P$totalCost)' : 'REGISTRATION CLOSED',
                    style: const TextStyle(fontFamily: AppConstants.pixelFont, fontSize: 11, color: Colors.white),
                  ),
                  onPressed: isRegOpen && fameOk && moneyOk && rosterOk && qualOk ? onRegister : null,
                ),
        ),
      ],
    );
  }

  Widget _buildCheckRow(String title, bool ok, String detail) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Icon(ok ? Icons.check_circle : Icons.cancel, color: ok ? AppConstants.positiveGreen : AppConstants.negativeRed, size: 14),
          const SizedBox(width: 6),
          Expanded(child: Text(title, style: const TextStyle(fontFamily: AppConstants.pixelFont, fontSize: 9, color: Colors.white))),
          Text(detail, style: TextStyle(fontFamily: AppConstants.pixelFont, fontSize: 8, color: ok ? Colors.white60 : AppConstants.negativeRed)),
        ],
      ),
    );
  }
}
