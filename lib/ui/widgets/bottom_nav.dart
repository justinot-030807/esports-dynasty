import 'package:flutter/material.dart';
import '../../core/constants.dart';

enum NavTab { team, plan, compete, build, more }

class BottomNav extends StatelessWidget {
  final NavTab currentTab;
  final Function(NavTab tab) onTabSelected;

  const BottomNav({
    super.key,
    required this.currentTab,
    required this.onTabSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 52,
      decoration: const BoxDecoration(
        color: AppConstants.darkNavy,
        border: Border(
          top: BorderSide(color: Color(0xFF2B3A5E), width: 2),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildNavItem(NavTab.team, 'Team', Icons.people),
          _buildNavItem(NavTab.plan, 'Plan', Icons.calendar_month),
          _buildNavItem(NavTab.compete, 'Compete', Icons.emoji_events),
          _buildNavItem(NavTab.build, 'Build', Icons.home_work),
          _buildNavItem(NavTab.more, 'More', Icons.menu),
        ],
      ),
    );
  }

  Widget _buildNavItem(NavTab tab, String label, IconData icon) {
    final isSelected = currentTab == tab;

    return GestureDetector(
      onTap: () => onTabSelected(tab),
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 20,
            color: isSelected ? AppConstants.moneyGold : Colors.white60,
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              fontFamily: AppConstants.pixelFont,
              fontSize: 10,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              color: isSelected ? AppConstants.moneyGold : Colors.white60,
            ),
          ),
        ],
      ),
    );
  }
}
