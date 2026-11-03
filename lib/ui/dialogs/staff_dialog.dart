import 'package:flutter/material.dart';
import '../../core/constants.dart';
import '../../models/game_state.dart';
import '../../models/staff.dart';
import '../../services/achievement_service.dart';
import '../widgets/pixel_panel.dart';
import '../widgets/pixel_button.dart';

class StaffDialog extends StatefulWidget {
  final GameState state;
  final VoidCallback onUpdated;

  const StaffDialog({
    super.key,
    required this.state,
    required this.onUpdated,
  });

  @override
  State<StaffDialog> createState() => _StaffDialogState();
}

class _StaffDialogState extends State<StaffDialog> {
  String _getStaffSprite(StaffRole role) {
    switch (role) {
      case StaffRole.coach: return 'assets/images/characters/staff_coach/staff_coach_front_idle.png';
      case StaffRole.analyst: return 'assets/images/characters/staff_analyst/staff_analyst_front_idle.png';
      case StaffRole.manager: return 'assets/images/characters/staff_manager/staff_manager_front_idle.png';
      case StaffRole.psychologist: return 'assets/images/characters/staff_psychologist/staff_psychologist_front_idle.png';
      case StaffRole.cook: return 'assets/images/characters/staff_cook/staff_cook_front_idle.png';
      case StaffRole.streamProducer: return 'assets/images/characters/staff_producer/staff_producer_front_idle.png';
    }
  }
  @override
  Widget build(BuildContext context) {
    final staff = widget.state.staff;
    final maxSlots = widget.state.maxStaffSlots;
    final hiredRoles = staff.map((s) => s.role).toSet();
    final availableRoles = StaffRole.values.where((r) => !hiredRoles.contains(r)).toList();

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 20),
      child: PixelPanel(
        title: 'STAFF & COACHES',
        onClose: () => Navigator.pop(context),
        child: SizedBox(
          height: 480,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Slots: ${staff.length} / $maxSlots (Tumaas sa House Upgrades)',
                style: const TextStyle(
                  fontFamily: AppConstants.pixelFont,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: AppConstants.textNavy,
                ),
              ),
              const SizedBox(height: 10),
              Expanded(
                child: ListView(
                  children: [
                    const Text(
                      'KASALUKUYANG STAFF',
                      style: TextStyle(
                        fontFamily: AppConstants.pixelFont,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: Colors.black54,
                      ),
                    ),
                    const SizedBox(height: 6),
                    if (staff.isEmpty)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 8.0),
                        child: Text(
                          'Wala pang hired staff. Mag-hire sa ibaba!',
                          style: TextStyle(fontFamily: AppConstants.pixelFont, fontSize: 11, color: Colors.black54),
                        ),
                      )
                    else
                      for (final member in staff)
                        _buildStaffCard(member),

                    if (staff.length < maxSlots && availableRoles.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      const Text(
                        'AVAILABLE NA MGA POSISYON',
                        style: TextStyle(
                          fontFamily: AppConstants.pixelFont,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: Colors.black54,
                        ),
                      ),
                      const SizedBox(height: 6),
                      for (final role in availableRoles)
                        _buildHireCard(role),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStaffCard(StaffMember s) {
    final cost = s.upgradeCost;
    final canUpgrade = s.level < 5 && widget.state.money >= cost;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: const Color(0xFFD0D7DE), width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Image.asset(
                _getStaffSprite(s.role),
                width: 38,
                height: 38,
                fit: BoxFit.contain,
                filterQuality: FilterQuality.none,
                errorBuilder: (_, _, _) => const Icon(Icons.person, size: 28),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          s.roleTitle,
                          style: const TextStyle(
                            fontFamily: AppConstants.pixelFont,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: AppConstants.textNavy,
                          ),
                        ),
                        Row(
                          children: [
                            for (int i = 0; i < s.level; i++)
                              const Icon(Icons.star, size: 14, color: AppConstants.moneyGold),
                            for (int i = s.level; i < 5; i++)
                              Icon(Icons.star_border, size: 14, color: Colors.grey.shade400),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${s.name} | Sahod: P${s.salary}/wk',
                      style: const TextStyle(fontFamily: AppConstants.pixelFont, fontSize: 10, color: Colors.black54),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            s.effectDescription,
            style: const TextStyle(
              fontFamily: AppConstants.pixelFont,
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: AppConstants.positiveGreen,
            ),
          ),
          const SizedBox(height: 8),
          if (s.level < 5)
            PixelButton(
              label: 'UPGRADE TO LV ${s.level + 1} (P$cost)',
              color: canUpgrade ? PixelButtonColor.yellow : PixelButtonColor.red,
              fontSize: 10,
              height: 30,
              onPressed: canUpgrade
                  ? () {
                      widget.state.money -= cost;
                      widget.state.monthExpenses += cost;
                      s.levelUp();
                      AchievementService().checkMilestones(widget.state);
                      widget.onUpdated();
                      setState(() {});
                    }
                  : null,
            )
          else
            const Text(
              'MAX LEVEL REACHED!',
              style: TextStyle(
                fontFamily: AppConstants.pixelFont,
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: AppConstants.moneyGold,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildHireCard(StaffRole role) {
    final title = _getRoleTitle(role);
    final desc = _getRoleDesc(role);
    final signingCost = 3000;
    final canHire = widget.state.money >= signingCost;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0xFFF6F8FA),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: const Color(0xFFD0D7DE), width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Image.asset(
                _getStaffSprite(role),
                width: 36,
                height: 36,
                fit: BoxFit.contain,
                filterQuality: FilterQuality.none,
                errorBuilder: (_, _, _) => const Icon(Icons.person_add, size: 28),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontFamily: AppConstants.pixelFont,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: AppConstants.textNavy,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      desc,
                      style: const TextStyle(fontFamily: AppConstants.pixelFont, fontSize: 9, color: Colors.black54),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          PixelButton(
            label: 'HIRE (P$signingCost Signing Bonus)',
            color: canHire ? PixelButtonColor.green : PixelButtonColor.red,
            fontSize: 10,
            height: 30,
            onPressed: canHire
                ? () {
                    widget.state.money -= signingCost;
                    widget.state.monthExpenses += signingCost;
                    widget.state.staff.add(
                      StaffMember(
                        id: 'staff_${DateTime.now().millisecondsSinceEpoch}',
                        name: _getDefaultName(role),
                        role: role,
                        level: 1,
                        salary: 2000,
                      ),
                    );
                    AchievementService().checkMilestones(widget.state);
                    widget.onUpdated();
                    setState(() {});
                  }
                : null,
          ),
        ],
      ),
    );
  }

  String _getRoleTitle(StaffRole r) {
    switch (r) {
      case StaffRole.coach: return 'Head Coach';
      case StaffRole.analyst: return 'Analyst';
      case StaffRole.manager: return 'Manager';
      case StaffRole.psychologist: return 'Sports Psychologist';
      case StaffRole.cook: return 'Cook (Kusinero)';
      case StaffRole.streamProducer: return 'Stream Producer';
    }
  }

  String _getRoleDesc(StaffRole r) {
    switch (r) {
      case StaffRole.coach: return '+6% training gain kada level, binubuksan ang strategies';
      case StaffRole.analyst: return 'Scouting accuracy at +0.5 match prep power kada level';
      case StaffRole.manager: return '+8% sponsor pay at -4% transfer fees kada level';
      case StaffRole.psychologist: return '+10% morale recovery kada level, iwas burnout';
      case StaffRole.cook: return '+8% fatigue recovery kada level, masarap na luto';
      case StaffRole.streamProducer: return '+10% stream income at +5% fan growth kada level';
    }
  }

  String _getDefaultName(StaffRole r) {
    switch (r) {
      case StaffRole.coach: return 'Coach Ramon';
      case StaffRole.analyst: return 'Analyst Dexter';
      case StaffRole.manager: return 'Manager Joy';
      case StaffRole.psychologist: return 'Doc Patricia';
      case StaffRole.cook: return 'Kusinerong Berto';
      case StaffRole.streamProducer: return 'Producer JP';
    }
  }
}
