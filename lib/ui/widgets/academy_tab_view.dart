import 'package:flutter/material.dart';
import '../../core/constants.dart';
import '../../models/game_state.dart';
import '../../models/player.dart';
import '../../services/academy_service.dart';
import '../../services/achievement_service.dart';
import 'pixel_button.dart';

class AcademyTabView extends StatefulWidget {
  final GameState state;
  final VoidCallback onUpdated;

  const AcademyTabView({
    super.key,
    required this.state,
    required this.onUpdated,
  });

  @override
  State<AcademyTabView> createState() => _AcademyTabViewState();
}

class _AcademyTabViewState extends State<AcademyTabView> {
  Player? _prospect;

  @override
  void initState() {
    super.initState();
    _prospect = AcademyService().checkAcademyProspect(widget.state);
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.state.isAcademyUnlocked) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.school, size: 40, color: Colors.grey),
              const SizedBox(height: 8),
              const Text(
                'LOCKED ANG ACADEMY',
                style: TextStyle(
                  fontFamily: AppConstants.pixelFont,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: AppConstants.darkNavy,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Mag-upgrade sa Pro Gaming House (Tier 3) upang magbukas ang Academy at makapag-scout ng 16-anyos na mga prodigy tuwing 12 linggo!',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: AppConstants.pixelFont,
                  fontSize: 10,
                  color: Colors.black54,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return ListView(
      children: [
        if (_prospect != null) ...[
          const Text(
            'BAGONG SIBOL NA PROSPECT!',
            style: TextStyle(
              fontFamily: AppConstants.pixelFont,
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: AppConstants.positiveGreen,
            ),
          ),
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppConstants.positiveGreen.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: AppConstants.positiveGreen, width: 2),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${_prospect!.gamerTag} (${_prospect!.realName})',
                  style: const TextStyle(
                    fontFamily: AppConstants.pixelFont,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: AppConstants.darkNavy,
                  ),
                ),
                Text(
                  'Role: ${_prospect!.role.name.toUpperCase()} | Age: ${_prospect!.age} | OVR: ${_prospect!.ovr}',
                  style: const TextStyle(fontFamily: AppConstants.pixelFont, fontSize: 10, color: Colors.black87),
                ),
                Text(
                  'Potential: ${_prospect!.potentialStars} Stars | Traits: ${_prospect!.traits.join(", ")}',
                  style: const TextStyle(
                    fontFamily: AppConstants.pixelFont,
                    fontSize: 10,
                    color: AppConstants.famePurple,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                PixelButton(
                  label: 'ENROLL SA ROSTER (LIBRE)',
                  color: PixelButtonColor.green,
                  fontSize: 10,
                  height: 30,
                  onPressed: () {
                    AcademyService().enrollProspect(_prospect!, widget.state);
                    AchievementService().checkMilestones(widget.state);
                    setState(() {
                      _prospect = null;
                    });
                    widget.onUpdated();
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
        ],
        const Text(
          'BENCH & ACADEMY ROSTER',
          style: TextStyle(
            fontFamily: AppConstants.pixelFont,
            fontSize: 10,
            fontWeight: FontWeight.bold,
            color: Colors.black54,
          ),
        ),
        const SizedBox(height: 6),
        if (widget.state.subs.isEmpty)
          const Text('Walang nakareserbang subs sa bench.', style: TextStyle(fontFamily: AppConstants.pixelFont, fontSize: 10, color: Colors.black54))
        else
          for (final sub in widget.state.subs)
            Container(
              margin: const EdgeInsets.only(bottom: 6),
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: const Color(0xFFD0D7DE), width: 1.5),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${sub.gamerTag} (${sub.role.name.toUpperCase()})',
                    style: const TextStyle(fontFamily: AppConstants.pixelFont, fontSize: 10, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    'OVR ${sub.ovr} | Age ${sub.age}',
                    style: const TextStyle(fontFamily: AppConstants.pixelFont, fontSize: 9, color: Colors.black54),
                  ),
                ],
              ),
            ),
      ],
    );
  }
}
