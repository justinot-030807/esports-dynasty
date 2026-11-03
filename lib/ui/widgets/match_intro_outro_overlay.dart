import 'package:flutter/material.dart';
import '../../core/constants.dart';
import '../../services/audio_manager.dart';
import '../text_styles.dart';

enum MatchPhaseState { intro, live, gameOutro, seriesOutro }

class MatchIntroOverlay extends StatefulWidget {
  final int gameNumber;
  final String userTeamName;
  final String oppTeamName;
  final VoidCallback onIntroFinished;

  const MatchIntroOverlay({
    super.key,
    required this.gameNumber,
    required this.userTeamName,
    required this.oppTeamName,
    required this.onIntroFinished,
  });

  @override
  State<MatchIntroOverlay> createState() => _MatchIntroOverlayState();
}

class _MatchIntroOverlayState extends State<MatchIntroOverlay>
    with SingleTickerProviderStateMixin {
  late final AnimationController _anim;
  int _countdown = 3;

  @override
  void initState() {
    super.initState();
    _anim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );

    AudioManager().playSfx(AudioSfx.countdown);

    _anim.addListener(() {
      final val = _anim.value;
      final newCount = val < 0.33 ? 3 : (val < 0.66 ? 2 : (val < 0.90 ? 1 : 0));
      if (newCount != _countdown) {
        setState(() {
          _countdown = newCount;
        });
        if (_countdown == 0) {
          AudioManager().playSfx(AudioSfx.whistle);
        } else {
          AudioManager().playSfx(AudioSfx.countdown);
        }
      }
    });

    _anim.forward().then((_) {
      if (mounted) widget.onIntroFinished();
    });
  }

  @override
  void dispose() {
    _anim.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        _anim.stop();
        AudioManager().playSfx(AudioSfx.whistle);
        widget.onIntroFinished();
      },
      child: Container(
        color: Colors.black.withValues(alpha: 0.85),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Game N Header
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 6),
                decoration: BoxDecoration(
                  color: AppConstants.moneyGold,
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: Colors.white, width: 2),
                ),
                child: Text(
                  'GAME ${widget.gameNumber}',
                  style: AppTextStyles.killBanner.copyWith(
                    color: Colors.black,
                    fontSize: 22,
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Versus Row: Team User vs Team Opponent
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // User Team
                  Column(
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: const BoxDecoration(
                          color: AppConstants.energyBlue,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.shield, color: Colors.white, size: 28),
                      ),
                      const SizedBox(height: 6),
                      Text(widget.userTeamName, style: AppTextStyles.teamName),
                    ],
                  ),

                  // VS Badge
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: const Color(0xFF1B2A49),
                      shape: BoxShape.circle,
                      border: Border.all(color: AppConstants.moneyGold, width: 2),
                      image: const DecorationImage(
                        image: AssetImage('assets/images/effects/badge_vs.png'),
                        fit: BoxFit.contain,
                      ),
                    ),
                    alignment: Alignment.center,
                    child: const Text('VS', style: AppTextStyles.label14),
                  ),

                  // Opponent Team
                  Column(
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: const BoxDecoration(
                          color: AppConstants.negativeRed,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.shield, color: Colors.white, size: 28),
                      ),
                      const SizedBox(height: 6),
                      Text(widget.oppTeamName, style: AppTextStyles.teamName),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 32),

              // Countdown / FIGHT!
              Text(
                _countdown > 0 ? '$_countdown' : 'FIGHT!',
                style: AppTextStyles.killBanner.copyWith(
                  fontSize: _countdown > 0 ? 56 : 48,
                  color: _countdown > 0 ? AppConstants.moneyGold : AppConstants.positiveGreen,
                ),
              ),

              const SizedBox(height: 16),
              const Text('TAP TO SKIP', style: AppTextStyles.caption12),
            ],
          ),
        ),
      ),
    );
  }
}

class MatchOutroOverlay extends StatelessWidget {
  final bool userWon;
  final String mvpTag;
  final VoidCallback onDismiss;

  const MatchOutroOverlay({
    super.key,
    required this.userWon,
    required this.mvpTag,
    required this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onDismiss,
      child: Container(
        color: Colors.black.withValues(alpha: 0.8),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // VICTORY or DEFEAT Stamp
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 12),
                decoration: BoxDecoration(
                  color: userWon ? const Color(0xFF1B4E3B) : const Color(0xFF4A1A22),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: userWon ? AppConstants.positiveGreen : AppConstants.negativeRed,
                    width: 3,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: (userWon ? AppConstants.positiveGreen : AppConstants.negativeRed).withValues(alpha: 0.6),
                      blurRadius: 16,
                    ),
                  ],
                ),
                child: Text(
                  userWon ? 'VICTORY' : 'DEFEAT',
                  style: AppTextStyles.killBanner.copyWith(
                    fontSize: 36,
                    letterSpacing: 3.0,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // MVP Highlight with Gold Ring
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFF142036),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: AppConstants.moneyGold, width: 2),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.star, color: AppConstants.moneyGold, size: 24),
                    const SizedBox(width: 8),
                    Text('GAME MVP: $mvpTag', style: AppTextStyles.label14),
                  ],
                ),
              ),

              const SizedBox(height: 24),
              const Text('TAP TO CONTINUE', style: AppTextStyles.caption12),
            ],
          ),
        ),
      ),
    );
  }
}
