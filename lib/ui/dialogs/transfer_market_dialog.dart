import 'package:flutter/material.dart';
import '../../core/constants.dart';
import '../../models/game_state.dart';
import '../../models/player.dart';
import '../../services/transfer_service.dart';
import '../../services/achievement_service.dart';
import '../widgets/pixel_panel.dart';
import '../widgets/pixel_button.dart';
import '../widgets/contracts_tab_view.dart';
import '../widgets/academy_tab_view.dart';

class TransferMarketDialog extends StatefulWidget {
  final GameState state;
  final VoidCallback onUpdated;

  const TransferMarketDialog({
    super.key,
    required this.state,
    required this.onUpdated,
  });

  @override
  State<TransferMarketDialog> createState() => _TransferMarketDialogState();
}

class _TransferMarketDialogState extends State<TransferMarketDialog> {
  int _tabIndex = 0; // 0 = Market, 1 = Contracts, 2 = Academy
  List<Player>? _marketTargets;

  @override
  void initState() {
    super.initState();
    _marketTargets = TransferService().generateTransferTargets(widget.state);
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 18),
      child: PixelPanel(
        title: 'TRANSFERS & ACADEMY',
        onClose: () => Navigator.pop(context),
        child: SizedBox(
          height: 490,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Segmented Tab bar
              Row(
                children: [
                  Expanded(child: _buildTabButton(0, 'Market')),
                  const SizedBox(width: 6),
                  Expanded(child: _buildTabButton(1, 'Contracts')),
                  const SizedBox(width: 6),
                  Expanded(child: _buildTabButton(2, 'Academy')),
                ],
              ),
              const SizedBox(height: 10),

              Expanded(
                child: _tabIndex == 0
                    ? _buildMarketTab()
                    : _tabIndex == 1
                        ? _buildContractsTab()
                        : _buildAcademyTab(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTabButton(int index, String title) {
    final isSelected = _tabIndex == index;
    return InkWell(
      onTap: () => setState(() => _tabIndex = index),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? AppConstants.textNavy : Colors.white,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: AppConstants.darkNavy, width: 2),
        ),
        child: Center(
          child: Text(
            title,
            style: TextStyle(
              fontFamily: AppConstants.pixelFont,
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: isSelected ? Colors.white : AppConstants.textNavy,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMarketTab() {
    final isOpen = widget.state.isTransferWindowOpen;

    return ListView(
      children: [
        // Window Status Banner
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: isOpen
                ? AppConstants.positiveGreen.withValues(alpha: 0.15)
                : Colors.grey.shade200,
            borderRadius: BorderRadius.circular(6),
            border: Border.all(
              color: isOpen ? AppConstants.positiveGreen : Colors.grey,
              width: 1.5,
            ),
          ),
          child: Row(
            children: [
              Icon(
                isOpen ? Icons.lock_open : Icons.lock,
                size: 16,
                color: isOpen ? AppConstants.positiveGreen : Colors.grey.shade700,
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  isOpen
                      ? 'BUKAS ANG TRANSFER WINDOW! (W1-W2, W25-W26)'
                      : 'SARADO ANG TRANSFER WINDOW (Bukas sa W1-W2 at W25-W26)',
                  style: TextStyle(
                    fontFamily: AppConstants.pixelFont,
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                    color: isOpen ? AppConstants.textNavy : Colors.grey.shade700,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),

        // Incoming AI rival poach offers
        if (widget.state.pendingTransferOffers.isNotEmpty) ...[
          const Text(
            'INCOMING OFFERS MULA SA RIVALS!',
            style: TextStyle(
              fontFamily: AppConstants.pixelFont,
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: AppConstants.moneyGold,
            ),
          ),
          const SizedBox(height: 6),
          for (final offer in widget.state.pendingTransferOffers)
            Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.amber.shade50,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: AppConstants.moneyGold, width: 1.5),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${offer.offeringTeamName} wants ${offer.playerName}!',
                    style: const TextStyle(fontFamily: AppConstants.pixelFont, fontSize: 11, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    'Transfer Fee Offer: P${offer.transferFee} | Sahod: P${offer.offeredSalary}/wk',
                    style: const TextStyle(fontFamily: AppConstants.pixelFont, fontSize: 9, color: AppConstants.positiveGreen, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Expanded(
                        child: PixelButton(
                          label: 'TANGGAPIN (+P${offer.transferFee})',
                          color: PixelButtonColor.green,
                          fontSize: 9,
                          height: 28,
                          onPressed: () {
                            TransferService().acceptTransferOffer(offer, widget.state);
                            widget.onUpdated();
                            setState(() {});
                          },
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: PixelButton(
                          label: 'TANGGIHAN',
                          color: PixelButtonColor.red,
                          fontSize: 9,
                          height: 28,
                          onPressed: () {
                            widget.state.pendingTransferOffers.remove(offer);
                            setState(() {});
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          const SizedBox(height: 10),
        ],

        const Text(
          'AVAILABLE NA MGA PRO PLAYERS',
          style: TextStyle(fontFamily: AppConstants.pixelFont, fontSize: 10, fontWeight: FontWeight.bold, color: Colors.black54),
        ),
        const SizedBox(height: 6),
        if (_marketTargets != null)
          for (final p in _marketTargets!)
            _buildMarketPlayerCard(p, isOpen),
      ],
    );
  }

  Widget _buildMarketPlayerCard(Player p, bool isOpen) {
    final fee = TransferService().calculateTransferFee(p, widget.state);
    final canBuy = isOpen && widget.state.money >= fee && widget.state.players.length < widget.state.maxRosterCap;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: const Color(0xFFD0D7DE), width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${p.gamerTag} (${p.role.name.toUpperCase()})',
                style: const TextStyle(fontFamily: AppConstants.pixelFont, fontSize: 11, fontWeight: FontWeight.bold, color: AppConstants.textNavy),
              ),
              Text(
                'OVR ${p.ovr} | Age ${p.age}',
                style: const TextStyle(fontFamily: AppConstants.pixelFont, fontSize: 10, color: AppConstants.energyBlue, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          Text(
            'Transfer Fee: P$fee | Sahod: P${p.weeklySalary}/wk',
            style: const TextStyle(fontFamily: AppConstants.pixelFont, fontSize: 9, color: Colors.black87),
          ),
          const SizedBox(height: 6),
          PixelButton(
            label: !isOpen ? 'LOCKED (WINDOW CLOSED)' : (widget.state.players.length >= widget.state.maxRosterCap ? 'ROSTER FULL' : 'BUY FOR P$fee'),
            color: canBuy ? PixelButtonColor.green : PixelButtonColor.red,
            fontSize: 9,
            height: 28,
            onPressed: canBuy
                ? () {
                    TransferService().buyTransferPlayer(p, widget.state);
                    AchievementService().checkMilestones(widget.state);
                    _marketTargets?.remove(p);
                    widget.onUpdated();
                    setState(() {});
                  }
                : null,
          ),
        ],
      ),
    );
  }

  Widget _buildContractsTab() {
    return ContractsTabView(
      state: widget.state,
      onUpdated: () {
        widget.onUpdated();
        setState(() {});
      },
    );
  }

  Widget _buildAcademyTab() {
    return AcademyTabView(
      state: widget.state,
      onUpdated: () {
        widget.onUpdated();
        setState(() {});
      },
    );
  }
}
