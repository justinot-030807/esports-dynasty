import 'package:flutter/material.dart';
import '../../core/constants.dart';
import '../../models/patch_data.dart';

class BroadcastMetaStrip extends StatelessWidget {
  final PatchDef patch;
  final String currentStrategy;

  const BroadcastMetaStrip({
    super.key,
    required this.patch,
    required this.currentStrategy,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      color: const Color(0xFF142036),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'PATCH ${patch.version}: ${patch.favoredStrategy.toUpperCase()} +3 / ${patch.nerfedStrategy.toUpperCase()} -3',
            style: const TextStyle(fontFamily: AppConstants.pixelFont, fontSize: 8, color: AppConstants.moneyGold),
          ),
          Text(
            'TACTIC: ${currentStrategy.toUpperCase()}',
            style: const TextStyle(fontFamily: AppConstants.pixelFont, fontSize: 8, color: AppConstants.energyBlue),
          ),
        ],
      ),
    );
  }
}

class BroadcastCommentaryBox extends StatelessWidget {
  final List<String> commentaryFeed;

  const BroadcastCommentaryBox({
    super.key,
    required this.commentaryFeed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: const Color(0xFF121B2A),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: const Color(0xFF223554)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Row(
            children: [
              Icon(Icons.mic, color: AppConstants.moneyGold, size: 14),
              SizedBox(width: 4),
              Text(
                'TAGLISH LIVE COMMENTARY',
                style: TextStyle(
                  fontFamily: AppConstants.pixelFont,
                  fontSize: 8,
                  fontWeight: FontWeight.bold,
                  color: AppConstants.moneyGold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Expanded(
            child: ListView.builder(
              itemCount: commentaryFeed.length,
              itemBuilder: (ctx, i) => Text(
                commentaryFeed[i],
                style: TextStyle(
                  fontFamily: AppConstants.pixelFont,
                  fontSize: 8,
                  color: i == 0 ? Colors.white : Colors.white60,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
