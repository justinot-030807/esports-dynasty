import 'package:flutter/material.dart';
import '../../services/save_service.dart';
import '../screens/hub_screen.dart';

enum SaveSlotMode { load, selectForNewGame }

class SaveSlotsDialog extends StatefulWidget {
  final SaveSlotMode mode;
  final Function(int slot)? onSlotSelected;

  const SaveSlotsDialog({
    super.key,
    this.mode = SaveSlotMode.load,
    this.onSlotSelected,
  });

  @override
  State<SaveSlotsDialog> createState() => _SaveSlotsDialogState();
}

class _SaveSlotsDialogState extends State<SaveSlotsDialog> {
  List<SaveSlotSummary> _summaries = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _refreshSlots();
  }

  Future<void> _refreshSlots() async {
    final s1 = await SaveService.getSlotSummary(1);
    final s2 = await SaveService.getSlotSummary(2);
    final s3 = await SaveService.getSlotSummary(3);
    if (mounted) {
      setState(() {
        _summaries = [s1, s2, s3];
        _loading = false;
      });
    }
  }

  Future<void> _loadSlot(int slot) async {
    final state = await SaveService.loadGame(slot: slot);
    if (state != null && mounted) {
      Navigator.of(context).pop();
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => HubScreen(state: state)),
      );
    }
  }

  Future<void> _confirmDelete(int slot) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
          side: const BorderSide(color: Color(0xFFEF4444), width: 2),
        ),
        title: const Text('BURAHIN ANG SAVE?', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
        content: Text('Sigurado ka bang nais mong burahin ang Slot $slot? Hindi na ito mababawi.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('CANCEL')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFEF4444)),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('BURAHIN', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (ok == true) {
      await SaveService.deleteSave(slot: slot);
      _refreshSlots();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFCBD5E1), width: 2),
          boxShadow: const [
            BoxShadow(color: Colors.black26, blurRadius: 16, offset: Offset(0, 4)),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.save, color: Color(0xFF0284C7), size: 24),
                    const SizedBox(width: 8),
                    Text(
                      widget.mode == SaveSlotMode.load ? 'PUMILI NG SAVE SLOT' : 'PUMILI KUNG SAANG SLOT I-SAVE',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                  ],
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: Color(0xFF64748B)),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
            const Divider(color: Color(0xFFE2E8F0)),
            const SizedBox(height: 8),

            if (_loading)
              const Center(child: Padding(padding: EdgeInsets.all(32), child: CircularProgressIndicator()))
            else
              for (final sum in _summaries) ...[
                _buildSlotCard(sum),
                const SizedBox(height: 10),
              ],
          ],
        ),
      ),
    );
  }

  Widget _buildSlotCard(SaveSlotSummary sum) {
    final isNewGame = widget.mode == SaveSlotMode.selectForNewGame;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: sum.exists ? const Color(0xFFF8FAFC) : const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: sum.exists ? const Color(0xFF94A3B8) : const Color(0xFFE2E8F0),
          width: 1.5,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: sum.exists ? const Color(0xFF0284C7) : const Color(0xFF94A3B8),
              borderRadius: BorderRadius.circular(6),
            ),
            alignment: Alignment.center,
            child: Text(
              'SLOT\n${sum.slot}',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white, height: 1.1),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: sum.exists
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        sum.teamName,
                        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Year ${sum.year} Month ${sum.month} Week ${sum.week} Day ${sum.day}',
                        style: const TextStyle(fontSize: 12, color: Color(0xFF475569)),
                      ),
                      Text(
                        'Funds: P${(sum.money / 1000).toStringAsFixed(1)}K • Fame: ${sum.fame}',
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF0284C7)),
                      ),
                    ],
                  )
                : const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Bakanteng Slot', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF64748B))),
                      Text('Walang nakaimbak na laro', style: TextStyle(fontSize: 12, color: Color(0xFF94A3B8))),
                    ],
                  ),
          ),
          if (sum.exists && !isNewGame) ...[
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF16A34A),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              ),
              onPressed: () => _loadSlot(sum.slot),
              child: const Text('LOAD', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline, color: Color(0xFFEF4444), size: 20),
              onPressed: () => _confirmDelete(sum.slot),
            ),
          ] else if (isNewGame) ...[
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: sum.exists ? const Color(0xFFD97706) : const Color(0xFF0284C7),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              ),
              onPressed: () {
                Navigator.of(context).pop();
                widget.onSlotSelected?.call(sum.slot);
              },
              child: Text(sum.exists ? 'OVERWRITE' : 'GAMITIN', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
            ),
          ],
        ],
      ),
    );
  }
}
