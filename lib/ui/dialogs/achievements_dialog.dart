import 'package:flutter/material.dart';
import '../../core/constants.dart';
import '../../models/game_state.dart';
import '../../models/achievement.dart';
import '../../services/data_service.dart';
import '../../services/achievement_service.dart';
import '../widgets/pixel_panel.dart';
import '../widgets/pixel_button.dart';

class AchievementsDialog extends StatefulWidget {
  final GameState state;
  final VoidCallback onUpdated;

  const AchievementsDialog({
    super.key,
    required this.state,
    required this.onUpdated,
  });

  @override
  State<AchievementsDialog> createState() => _AchievementsDialogState();
}

class _AchievementsDialogState extends State<AchievementsDialog> {
  String _selectedCategory = 'all';

  @override
  Widget build(BuildContext context) {
    final all = DataService().achievements;
    final unlockedCount = widget.state.unlockedAchievements.length;

    final filtered = _selectedCategory == 'all'
        ? all
        : all.where((a) => a.category == _selectedCategory).toList();

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 20),
      child: PixelPanel(
        title: 'MGA PARANGAL',
        onClose: () => Navigator.pop(context),
        child: SizedBox(
          height: 480,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Na-unlock: $unlockedCount / ${all.length}',
                style: const TextStyle(
                  fontFamily: AppConstants.pixelFont,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: AppConstants.textNavy,
                ),
              ),
              const SizedBox(height: 8),

              // Filter pills
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _buildFilterPill('all', 'Lahat'),
                    _buildFilterPill('competition', 'Labanan'),
                    _buildFilterPill('base', 'Gaming House'),
                    _buildFilterPill('roster', 'Roster'),
                    _buildFilterPill('fans', 'Fans'),
                    _buildFilterPill('economy', 'Pera'),
                    _buildFilterPill('dynasty', 'Dynasty'),
                  ],
                ),
              ),
              const SizedBox(height: 10),

              Expanded(
                child: ListView.builder(
                  itemCount: filtered.length,
                  itemBuilder: (context, idx) {
                    final ach = filtered[idx];
                    return _buildAchievementCard(ach);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFilterPill(String cat, String label) {
    final isSelected = _selectedCategory == cat;
    return Padding(
      padding: const EdgeInsets.only(right: 6.0),
      child: InkWell(
        onTap: () => setState(() => _selectedCategory = cat),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: isSelected ? AppConstants.textNavy : Colors.white,
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: AppConstants.darkNavy, width: 1.5),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontFamily: AppConstants.pixelFont,
              fontSize: 9,
              fontWeight: FontWeight.bold,
              color: isSelected ? Colors.white : AppConstants.textNavy,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAchievementCard(AchievementDef ach) {
    final isUnlocked = widget.state.unlockedAchievements.contains(ach.id);
    final isClaimed = widget.state.claimedAchievements.contains(ach.id);

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: isUnlocked ? Colors.white : const Color(0xFFF0F2F5),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: isUnlocked ? AppConstants.moneyGold : const Color(0xFFD0D7DE),
          width: 1.5,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: isUnlocked ? AppConstants.moneyGold.withValues(alpha: 0.2) : Colors.grey.shade300,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Icon(
              Icons.emoji_events,
              size: 20,
              color: isUnlocked ? AppConstants.moneyGold : Colors.grey.shade600,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  ach.title,
                  style: TextStyle(
                    fontFamily: AppConstants.pixelFont,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: isUnlocked ? AppConstants.textNavy : Colors.grey.shade700,
                  ),
                ),
                Text(
                  ach.desc,
                  style: const TextStyle(fontFamily: AppConstants.pixelFont, fontSize: 9, color: Colors.black54),
                ),
                const SizedBox(height: 4),
                Text(
                  'Gantimpala: ${ach.rewardMoney > 0 ? "P${ach.rewardMoney} " : ""}${ach.rewardFame > 0 ? "+${ach.rewardFame} Fame " : ""}${ach.rewardFans > 0 ? "+${ach.rewardFans} Fans" : ""}',
                  style: const TextStyle(
                    fontFamily: AppConstants.pixelFont,
                    fontSize: 9,
                    color: AppConstants.positiveGreen,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (isUnlocked && !isClaimed) ...[
                  const SizedBox(height: 6),
                  PixelButton(
                    label: 'KUNIN ANG GANTIMPALA',
                    color: PixelButtonColor.yellow,
                    fontSize: 9,
                    height: 26,
                    onPressed: () {
                      AchievementService().claimReward(ach, widget.state);
                      widget.onUpdated();
                      setState(() {});
                    },
                  ),
                ],
              ],
            ),
          ),
          if (isClaimed)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
              decoration: BoxDecoration(
                color: AppConstants.positiveGreen.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Text(
                'CLAIMED',
                style: TextStyle(fontFamily: AppConstants.pixelFont, fontSize: 8, fontWeight: FontWeight.bold, color: AppConstants.positiveGreen),
              ),
            ),
        ],
      ),
    );
  }
}
