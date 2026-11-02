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

    // Active speed: if 0, treat visually as 1x
    final activeSpeed = state.speedMultiplier == 0 ? 1 : state.speedMultiplier;

    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF162032),
        border: Border(
          bottom: BorderSide(color: Color(0xFF2A3B5C), width: 2),
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Row 1: Emblem, Team Name, Date, Speed buttons (1x, 2x, 4x)
          Row(
            children: [
              GestureDetector(
                onTap: onLogoTapped,
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: AppConstants.moneyGold, width: 1.5),
                  ),
                  child: EmblemWidget(
                    size: 38,
                    primaryColor: pColor,
                    secondaryColor: sColor,
                    symbol: state.emblemSymbol,
                    letters: state.emblemLetters,
                  ),
                ),
              ),
              const SizedBox(width: 10),
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
                        fontSize: 16,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 1),
                    Text(
                      '${state.dateString} D${state.day}',
                      style: const TextStyle(
                        fontFamily: AppConstants.pixelFont,
                        color: AppConstants.moneyGold,
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),

              // Speed selector pills (1x, 2x, 4x) - PAUSE removed per user requirement
              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF0F172A),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: const Color(0xFF334155), width: 1.5),
                ),
                padding: const EdgeInsets.all(2),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildSpeedPill(1, '1x', activeSpeed == 1),
                    const SizedBox(width: 3),
                    _buildSpeedPill(2, '2x', activeSpeed == 2),
                    const SizedBox(width: 3),
                    _buildSpeedPill(4, '4x', activeSpeed == 4),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 6),

          // Row 2: Money, Fame, Fans counters with larger fonts and icons
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: const Color(0xFF1E293B),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: const Color(0xFF334155), width: 1.5),
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
                  const Color(0xFFC084FC),
                ),
                _buildResourceChip(
                  AssetManager.iconFans,
                  _formatNumber(state.fans),
                  const Color(0xFFF472B6),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSpeedPill(int speed, String text, bool active) {
    return GestureDetector(
      onTap: () => onSpeedChanged(speed),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 100),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: active ? AppConstants.moneyGold : Colors.transparent,
          borderRadius: BorderRadius.circular(4),
          border: Border.all(
            color: active ? Colors.white : Colors.transparent,
            width: 1,
          ),
        ),
        child: Text(
          text,
          style: TextStyle(
            fontFamily: AppConstants.pixelFont,
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: active ? AppConstants.darkNavy : const Color(0xFF94A3B8),
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
          width: 19,
          height: 19,
          fit: BoxFit.contain,
          errorBuilder: (context, error, stackTrace) =>
              Icon(Icons.stars, size: 18, color: color),
        ),
        const SizedBox(width: 6),
        Text(
          value,
          style: TextStyle(
            fontFamily: AppConstants.pixelFont,
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: color,
            shadows: const [
              Shadow(
                color: Color(0xFF0F172A),
                offset: Offset(1, 1),
                blurRadius: 0,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
