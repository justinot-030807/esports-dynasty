import 'package:flutter/material.dart';
import '../../core/constants.dart';
import '../../models/game_state.dart';
import '../../models/player.dart';
import '../../models/staff.dart';
import '../../services/transfer_service.dart';
import 'pixel_button.dart';

class ContractsTabView extends StatefulWidget {
  final GameState state;
  final VoidCallback onUpdated;

  const ContractsTabView({
    super.key,
    required this.state,
    required this.onUpdated,
  });

  @override
  State<ContractsTabView> createState() => _ContractsTabViewState();
}

class _ContractsTabViewState extends State<ContractsTabView> {
  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        for (final p in widget.state.players)
          _buildContractCard(p),
      ],
    );
  }

  Widget _buildContractCard(Player p) {
    final demand = TransferService().calculateSalaryDemand(p);
    final isUrgent = p.contractWeeksLeft <= 8;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: isUrgent ? Colors.red.shade50 : Colors.white,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: isUrgent ? AppConstants.negativeRed : const Color(0xFFD0D7DE),
          width: 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${p.gamerTag} (${p.role.name.toUpperCase()})',
                style: const TextStyle(
                  fontFamily: AppConstants.pixelFont,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: AppConstants.darkNavy,
                ),
              ),
              Text(
                '${p.contractWeeksLeft} wks left',
                style: TextStyle(
                  fontFamily: AppConstants.pixelFont,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: isUrgent ? AppConstants.negativeRed : AppConstants.positiveGreen,
                ),
              ),
            ],
          ),
          Text(
            'Age ${p.age} | OVR ${p.ovr} | Sahod: P${p.weeklySalary}/wk (Demand: P$demand)',
            style: const TextStyle(
              fontFamily: AppConstants.pixelFont,
              fontSize: 9,
              color: Colors.black54,
            ),
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Expanded(
                child: PixelButton(
                  label: 'RENEW (48 WKS)',
                  color: PixelButtonColor.green,
                  fontSize: 8,
                  height: 28,
                  onPressed: () {
                    TransferService().renewContract(p, 48, widget.state);
                    widget.onUpdated();
                    setState(() {});
                  },
                ),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: PixelButton(
                  label: 'RELEASE (P${p.weeklySalary * 8})',
                  color: PixelButtonColor.red,
                  fontSize: 8,
                  height: 28,
                  onPressed: () {
                    TransferService().releasePlayer(p, widget.state);
                    widget.onUpdated();
                    setState(() {});
                  },
                ),
              ),
              if (p.age >= 28 || p.ovr >= 70) ...[
                const SizedBox(width: 6),
                Expanded(
                  child: PixelButton(
                    label: 'RETIRE',
                    color: PixelButtonColor.yellow,
                    fontSize: 8,
                    height: 28,
                    onPressed: () => _confirmRetire(p),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  void _confirmRetire(Player p) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppConstants.panelLight,
        title: Text(
          'RETIREMENT: ${p.gamerTag.toUpperCase()}',
          style: const TextStyle(fontFamily: AppConstants.pixelFont, fontSize: 13, color: AppConstants.darkNavy),
        ),
        content: Text(
          'Gusto mo bang magdaos ng marangal na retirement ceremony para kay ${p.gamerTag} (Age ${p.age}, OVR ${p.ovr})?',
          style: const TextStyle(fontFamily: AppConstants.pixelFont, fontSize: 11, color: Colors.black87),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('CANCEL', style: TextStyle(fontFamily: AppConstants.pixelFont, fontSize: 10)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppConstants.famePurple),
            onPressed: () {
              Navigator.pop(ctx);
              TransferService().retirePlayer(p, widget.state);
              widget.onUpdated();
              setState(() {});
            },
            child: const Text('ISABIT ANG JERSEY', style: TextStyle(fontFamily: AppConstants.pixelFont, fontSize: 10, color: Colors.white)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppConstants.positiveGreen),
            onPressed: () {
              Navigator.pop(ctx);
              TransferService().retireAndConvertToStaff(p, StaffRole.coach, widget.state);
              widget.onUpdated();
              setState(() {});
            },
            child: const Text('MAGING HEAD COACH', style: TextStyle(fontFamily: AppConstants.pixelFont, fontSize: 10, color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
