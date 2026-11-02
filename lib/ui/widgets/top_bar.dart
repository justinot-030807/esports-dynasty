import 'package:flutter/material.dart';
import '../../core/constants.dart';
import '../../core/asset_manager.dart';
import '../../models/game_state.dart';
import 'emblem_widget.dart';

class TopBar extends StatelessWidget {
  final GameState state;
  final Function(int speed) onSpeedChanged;
  final VoidCallback onLogoTapped;

  const TopBar({
    super.key,
    required this.state,
    required this.onSpeedChanged,
    required this.onLogoTapped,
  });

  String _formatNumber(int value) {
    if (value.abs() >= 1000000) {
      return '${(value / 1000000).toStringAsFixed(1)}M';
    }
    if (value.abs() >= 1000) {
      return '${(value / 1000).toStringAsFixed(1)}K';
    }
    return value.toString();
  }

  Color _parseColor(String hex, Color fallback) {
    try {
      final clean = hex.replaceAll('#', '');
      return Color(int.parse('FF$clean', radix: 16));
    } catch (_) {
      return fallback;
    }
  }

  @override
  Widget build(BuildContext context) {
    final pColor = _parseColor(state.primaryColorHex, AppConstants.darkNavy);
    final sColor = _parseColor(state.secondaryColorHex, AppConstants.moneyGold);

    return Container(
      color: AppConstants.darkNavy,
      padding: const EdgeInsets.only(top: 4, bottom: 4, left: 8, right: 8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Row 1: Emblem, Team Name, Date, Speed buttons
          Row(
            children: [
              GestureDetector(
                onTap: onLogoTapped,
                child: EmblemWidget(
                  size: 32,
                  primaryColor: pColor,
                  secondaryColor: sColor,
                  symbol: state.emblemSymbol,
                  letters: state.emblemLetters,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      state.teamName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontFamily: AppConstants.pixelFont,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    Text(
                      '${state.dateString} D${state.day}',
                      style: const TextStyle(
                        fontFamily: AppConstants.pixelFont,
                        color: AppConstants.moneyGold,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),

              // Speed controls (Pause, 1x, 2x, 4x)
              _buildSpeedButton(0, 'PAUSE', state.speedMultiplier == 0),
              const SizedBox(width: 3),
              _buildSpeedButton(1, '1x', state.speedMultiplier == 1),
              const SizedBox(width: 3),
              _buildSpeedButton(2, '2x', state.speedMultiplier == 2),
              const SizedBox(width: 3),
              _buildSpeedButton(4, '4x', state.speedMultiplier == 4),
            ],
          ),

          const SizedBox(height: 4),

          // Row 2: Money, Fame, Fans counters with icons
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: const Color(0xFF131D33),
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: const Color(0xFF2B3A5E), width: 1),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildResourceChip(
                  AssetManager.iconMoney,
                  'P${_formatNumber(state.money)}',
                  AppConstants.moneyGold,
                ),
                _buildResourceChip(
                  AssetManager.iconFame,
                  _formatNumber(state.fame),
                  AppConstants.famePurple,
                ),
                _buildResourceChip(
                  AssetManager.iconFans,
                  _formatNumber(state.fans),
                  AppConstants.fansPink,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSpeedButton(int speed, String text, bool active) {
    return GestureDetector(
      onTap: () => onSpeedChanged(speed),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 3),
        decoration: BoxDecoration(
          color: active ? AppConstants.moneyGold : const Color(0xFF2B3A5E),
          borderRadius: BorderRadius.circular(3),
          border: Border.all(
            color: active ? Colors.white : AppConstants.darkNavy,
            width: 1,
          ),
        ),
        child: Text(
          text,
          style: TextStyle(
            fontFamily: AppConstants.pixelFont,
            fontSize: 10,
            fontWeight: FontWeight.bold,
            color: active ? AppConstants.darkNavy : Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _buildResourceChip(String iconAsset, String value, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Image.asset(
          iconAsset,
          width: 16,
          height: 16,
          fit: BoxFit.contain,
          errorBuilder: (context, error, stackTrace) => const Icon(Icons.circle, size: 14, color: Colors.amber),
        ),
        const SizedBox(width: 4),
        Text(
          value,
          style: TextStyle(
            fontFamily: AppConstants.pixelFont,
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }
}
