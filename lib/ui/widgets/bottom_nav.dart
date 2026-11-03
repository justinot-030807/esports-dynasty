import 'package:flutter/material.dart';
import '../../core/constants.dart';

enum NavTab { team, plan, compete, build, more }

class BottomNav extends StatelessWidget {
  final NavTab? currentTab;
  final Function(NavTab tab) onTabSelected;

  const BottomNav({
    super.key,
    required this.currentTab,
    required this.onTabSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 60,
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(color: Color(0xFFCBD5E1), width: 1.5),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildNavItem(NavTab.team, 'Team', Icons.people_alt),
          _buildNavItem(NavTab.plan, 'Plan', Icons.calendar_month),
          _buildNavItem(NavTab.compete, 'Compete', Icons.emoji_events),
          _buildNavItem(NavTab.build, 'Build', Icons.home_work),
          _buildNavItem(NavTab.more, 'More', Icons.menu),
        ],
      ),
    );
  }

  String _getNavIconPath(NavTab tab) {
    switch (tab) {
      case NavTab.team: return 'assets/images/icons/nav_team.png';
      case NavTab.plan: return 'assets/images/icons/nav_plan.png';
      case NavTab.compete: return 'assets/images/icons/nav_compete.png';
      case NavTab.build: return 'assets/images/icons/nav_build.png';
      case NavTab.more: return 'assets/images/icons/nav_more.png';
    }
  }

  Widget _buildNavItem(NavTab tab, String label, IconData icon) {
    final isSelected = currentTab == tab;

    return Expanded(
      child: GestureDetector(
        onTap: () => onTabSelected(tab),
        behavior: HitTestBehavior.opaque,
        child: Container(
          color: isSelected ? const Color(0xFFFEF3C7) : Colors.transparent,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                _getNavIconPath(tab),
                width: 24,
                height: 24,
                fit: BoxFit.contain,
                filterQuality: FilterQuality.none,
                errorBuilder: (_, _, _) => Icon(
                  icon,
                  size: 24,
                  color: isSelected ? const Color(0xFFD97706) : const Color(0xFF64748B),
                ),
              ),
              const SizedBox(height: 3),
              Text(
                label,
                style: TextStyle(
                  fontFamily: AppConstants.pixelFont,
                  fontSize: 13,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                  color: isSelected ? const Color(0xFFD97706) : const Color(0xFF64748B),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
