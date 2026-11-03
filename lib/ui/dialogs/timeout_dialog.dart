import 'dart:math';
import 'package:flutter/material.dart';
import '../../core/constants.dart';
import '../../models/game_state.dart';
import '../../models/player.dart';

class TimeoutDialog extends StatefulWidget {
  final GameState state;
  final int timeoutsRemaining;
  final String currentStrategy;
  final Function(String newStrategy, String logMessage) onStrategyChanged;
  final Function(String logMessage) onPepTalkApplied;
  final Function(Player starterOut, Player subIn) onSubstituted;

  const TimeoutDialog({
    super.key,
    required this.state,
    required this.timeoutsRemaining,
    required this.currentStrategy,
    required this.onStrategyChanged,
    required this.onPepTalkApplied,
    required this.onSubstituted,
  });

  @override
  State<TimeoutDialog> createState() => _TimeoutDialogState();
}

class _TimeoutDialogState extends State<TimeoutDialog> {
  int _selectedTab = 0; // 0: Pep Talk, 1: Adjust Strategy, 2: Substitute
  late String _selectedStrategy;
  Player? _starterToSwap;
  Player? _subToSwap;

  @override
  void initState() {
    super.initState();
    _selectedStrategy = widget.currentStrategy;
  }

  void _applyPepTalk() {
    for (final p in widget.state.starters) {
      p.morale = min(100, p.morale + 10);
    }
    widget.onPepTalkApplied('Pep Talk: +10 Morale sa lahat ng starters para sa susunod na game!');
    Navigator.of(context).pop();
  }

  void _applyStrategyChange() {
    widget.onStrategyChanged(_selectedStrategy, 'Strategy adjusted: Binago ang playstyle patungong $_selectedStrategy!');
    Navigator.of(context).pop();
  }

  void _applySubstitute() {
    if (_starterToSwap == null || _subToSwap == null) return;
    _starterToSwap!.isStarter = false;
    _subToSwap!.isStarter = true;
    widget.onSubstituted(_starterToSwap!, _subToSwap!);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final canUse = widget.timeoutsRemaining > 0;
    final benchPlayers = widget.state.players.where((p) => !p.isStarter).toList();
    final starters = widget.state.starters;

    return Dialog(
      backgroundColor: AppConstants.bgDark,
      insetPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 24),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppConstants.energyBlue, width: 2),
        ),
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Row(
                  children: [
                    Icon(Icons.timer, color: AppConstants.energyBlue, size: 18),
                    SizedBox(width: 6),
                    Text(
                      'TACTICAL TIMEOUT',
                      style: TextStyle(
                        fontFamily: AppConstants.pixelFont,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: AppConstants.energyBlue,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: canUse ? const Color(0xFF1B4E3B) : const Color(0xFF4A1A22),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    '${widget.timeoutsRemaining}/2 LEFT',
                    style: TextStyle(
                      fontFamily: AppConstants.pixelFont,
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                      color: canUse ? AppConstants.positiveGreen : AppConstants.negativeRed,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),

            // Tab Selector
            Row(
              children: [
                _buildTabBtn(0, 'PEP TALK'),
                const SizedBox(width: 4),
                _buildTabBtn(1, 'STRATEGY'),
                const SizedBox(width: 4),
                _buildTabBtn(2, 'SUBSTITUTE'),
              ],
            ),
            const SizedBox(height: 12),

            // Tab Contents
            if (_selectedTab == 0) _buildPepTalkView(canUse),
            if (_selectedTab == 1) _buildStrategyView(canUse),
            if (_selectedTab == 2) _buildSubstituteView(canUse, starters, benchPlayers),
            const SizedBox(height: 10),

            // Cancel Button
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text(
                'CLOSE (NO TIMEOUT)',
                style: TextStyle(
                  fontFamily: AppConstants.pixelFont,
                  fontSize: 9,
                  color: Colors.white54,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabBtn(int index, String label) {
    final isSel = _selectedTab == index;
    return Expanded(
      child: InkWell(
        onTap: () => setState(() => _selectedTab = index),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 6),
          decoration: BoxDecoration(
            color: isSel ? AppConstants.energyBlue : const Color(0xFF142036),
            borderRadius: BorderRadius.circular(4),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              fontFamily: AppConstants.pixelFont,
              fontSize: 8,
              fontWeight: FontWeight.bold,
              color: isSel ? Colors.black : Colors.white70,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPepTalkView(bool canUse) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0xFF142036),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            '"Huwag mawalan ng loob! Bawiin natin sa teamfight at ipatupad ang plano!"',
            style: TextStyle(
              fontFamily: AppConstants.pixelFont,
              fontSize: 9,
              fontStyle: FontStyle.italic,
              color: AppConstants.moneyGold,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Effect: +10 Morale sa lahat ng 5 starters para sa susunod na laro.',
            style: TextStyle(
              fontFamily: AppConstants.pixelFont,
              fontSize: 8,
              color: Colors.white70,
            ),
          ),
          const SizedBox(height: 12),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: canUse ? AppConstants.positiveGreen : Colors.grey[800],
            ),
            onPressed: canUse ? _applyPepTalk : null,
            child: const Text(
              'CALL TIMEOUT: GIVE PEP TALK',
              style: TextStyle(
                fontFamily: AppConstants.pixelFont,
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStrategyView(bool canUse) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0xFF142036),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Pumili ng bagong diskarte para i-counter ang kalaban:',
            style: TextStyle(
              fontFamily: AppConstants.pixelFont,
              fontSize: 8,
              color: Colors.white70,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: ['Rush', 'Teamfight', 'Scale', 'Split'].map((strat) {
              final isSel = _selectedStrategy == strat;
              return ChoiceChip(
                label: Text(
                  strat,
                  style: TextStyle(
                    fontFamily: AppConstants.pixelFont,
                    fontSize: 9,
                    color: isSel ? Colors.black : Colors.white,
                  ),
                ),
                selected: isSel,
                selectedColor: AppConstants.moneyGold,
                backgroundColor: const Color(0xFF1B2A49),
                onSelected: (_) => setState(() => _selectedStrategy = strat),
              );
            }).toList(),
          ),
          const SizedBox(height: 12),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: canUse ? AppConstants.energyBlue : Colors.grey[800],
            ),
            onPressed: canUse ? _applyStrategyChange : null,
            child: const Text(
              'CALL TIMEOUT: LOCK IN STRATEGY',
              style: TextStyle(
                fontFamily: AppConstants.pixelFont,
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubstituteView(bool canUse, List<Player> starters, List<Player> bench) {
    if (bench.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFF142036),
          borderRadius: BorderRadius.circular(6),
        ),
        child: const Text(
          'Walang available bench players para ipalit.',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: AppConstants.pixelFont,
            fontSize: 9,
            color: Colors.white54,
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0xFF142036),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Pumili ng starter na papalitan at bench player na ipapasok:',
            style: TextStyle(
              fontFamily: AppConstants.pixelFont,
              fontSize: 8,
              color: Colors.white70,
            ),
          ),
          const SizedBox(height: 6),
          // Starter selection
          DropdownButtonFormField<Player>(
            initialValue: _starterToSwap,
            dropdownColor: const Color(0xFF142036),
            decoration: const InputDecoration(
              labelText: 'STARTER (OUT)',
              labelStyle: TextStyle(fontFamily: AppConstants.pixelFont, fontSize: 8, color: Colors.white60),
              isDense: true,
            ),
            items: starters.map((p) => DropdownMenuItem(
              value: p,
              child: Text(
                '${p.gamerTag} (${p.role.name.toUpperCase()} ${p.ovr} OVR - ${p.condition.name})',
                style: const TextStyle(fontFamily: AppConstants.pixelFont, fontSize: 8, color: Colors.white),
              ),
            )).toList(),
            onChanged: (p) => setState(() => _starterToSwap = p),
          ),
          const SizedBox(height: 6),
          // Bench selection
          DropdownButtonFormField<Player>(
            initialValue: _subToSwap,
            dropdownColor: const Color(0xFF142036),
            decoration: const InputDecoration(
              labelText: 'BENCH SUB (IN)',
              labelStyle: TextStyle(fontFamily: AppConstants.pixelFont, fontSize: 8, color: Colors.white60),
              isDense: true,
            ),
            items: bench.map((p) => DropdownMenuItem(
              value: p,
              child: Text(
                '${p.gamerTag} (${p.role.name.toUpperCase()} ${p.ovr} OVR - ${p.condition.name})',
                style: const TextStyle(fontFamily: AppConstants.pixelFont, fontSize: 8, color: Colors.white),
              ),
            )).toList(),
            onChanged: (p) => setState(() => _subToSwap = p),
          ),
          const SizedBox(height: 12),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: canUse && _starterToSwap != null && _subToSwap != null ? AppConstants.positiveGreen : Colors.grey[800],
            ),
            onPressed: canUse && _starterToSwap != null && _subToSwap != null ? _applySubstitute : null,
            child: const Text('CALL TIMEOUT: MAKE SUBSTITUTION',
              style: TextStyle(fontFamily: AppConstants.pixelFont, fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
