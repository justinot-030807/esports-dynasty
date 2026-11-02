import 'package:flutter/material.dart';
import '../../core/constants.dart';
import '../../models/game_state.dart';
import '../../models/hall_of_fame.dart';
import '../widgets/pixel_panel.dart';
import '../widgets/pixel_button.dart';

class HallOfFameDialog extends StatefulWidget {
  final GameState state;

  const HallOfFameDialog({super.key, required this.state});

  @override
  State<HallOfFameDialog> createState() => _HallOfFameDialogState();
}

class _HallOfFameDialogState extends State<HallOfFameDialog> {
  String _categoryFilter = 'ALL'; // 'ALL', 'CHAMPIONS', 'MVPS', 'AWARDS'

  @override
  Widget build(BuildContext context) {
    List<HallOfFameRecord> records = widget.state.hallOfFame;
    if (_categoryFilter == 'CHAMPIONS') {
      records = records.where((r) => r.category.toLowerCase().contains('champ') || r.category == 'tot').toList();
    } else if (_categoryFilter == 'MVPS') {
      records = records.where((r) => r.category.toLowerCase().contains('mvp')).toList();
    } else if (_categoryFilter == 'AWARDS') {
      records = records.where((r) => r.category != 'tot' && !r.category.contains('champ')).toList();
    }

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: PixelPanel(
        title: 'HALL OF FAME',
        width: 330,
        child: Padding(
          padding: const EdgeInsets.all(4),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Container(
                padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 10),
                decoration: BoxDecoration(
                  color: AppConstants.moneyGold.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: AppConstants.moneyGold),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.military_tech, color: AppConstants.moneyGold, size: 16),
                    SizedBox(width: 6),
                    Text(
                      'HALL OF FAME',
                      style: TextStyle(
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

              // Filter Tabs
              Row(
                children: [
                  _buildTab('ALL'),
                  const SizedBox(width: 4),
                  _buildTab('CHAMPIONS'),
                  const SizedBox(width: 4),
                  _buildTab('MVPS'),
                  const SizedBox(width: 4),
                  _buildTab('AWARDS'),
                ],
              ),
              const SizedBox(height: 8),

              // List of Records
              SizedBox(
                height: 260,
                child: records.isEmpty
                    ? Center(
                        child: Text(
                          widget.state.hallOfFame.isEmpty
                              ? 'Wala pang Hall of Fame entries!\nMagtapos ng season para magtala ng kasaysayan.'
                              : 'Walang entry para sa kategoryang ito.',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontFamily: AppConstants.pixelFont,
                            fontSize: 9,
                            color: Colors.white54,
                          ),
                        ),
                      )
                    : ListView.builder(
                        itemCount: records.length,
                        itemBuilder: (ctx, i) {
                          final r = records[records.length - 1 - i]; // most recent first
                          return Container(
                            margin: const EdgeInsets.only(bottom: 6),
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: const Color(0xFF1B2A49),
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(color: AppConstants.darkNavy),
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: AppConstants.moneyGold,
                                    borderRadius: BorderRadius.circular(3),
                                  ),
                                  child: Text(
                                    'Y${r.year}',
                                    style: const TextStyle(
                                      fontFamily: AppConstants.pixelFont,
                                      fontSize: 8,
                                      fontWeight: FontWeight.bold,
                                      color: AppConstants.bgDark,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        r.title.toUpperCase(),
                                        style: const TextStyle(
                                          fontFamily: AppConstants.pixelFont,
                                          fontSize: 9,
                                          fontWeight: FontWeight.bold,
                                          color: AppConstants.moneyGold,
                                        ),
                                      ),
                                      Text(
                                        '${r.recipientName} (${r.teamName})',
                                        style: const TextStyle(
                                          fontFamily: AppConstants.pixelFont,
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                                      Text(
                                        r.details,
                                        style: const TextStyle(
                                          fontFamily: AppConstants.pixelFont,
                                          fontSize: 8,
                                          color: Colors.white60,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
              ),
              const SizedBox(height: 10),

              // Close Button
              PixelButton(
                label: 'CLOSE',
                color: PixelButtonColor.neutral,
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTab(String cat) {
    final isSel = _categoryFilter == cat;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _categoryFilter = cat),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 4),
          decoration: BoxDecoration(
            color: isSel ? AppConstants.energyBlue : const Color(0xFF233458),
            borderRadius: BorderRadius.circular(3),
          ),
          child: Text(
            cat,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: AppConstants.pixelFont,
              fontSize: 7,
              fontWeight: isSel ? FontWeight.bold : FontWeight.normal,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}
