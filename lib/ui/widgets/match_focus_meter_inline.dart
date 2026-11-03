import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/constants.dart';
import '../../services/audio_manager.dart';
import '../text_styles.dart';

class MatchFocusMeterInline extends StatefulWidget {
  final int captainMental;
  final String momentTitle;
  final Function(double powerBonus, String outcome) onResolved;

  const MatchFocusMeterInline({
    super.key,
    required this.captainMental,
    required this.momentTitle,
    required this.onResolved,
  });

  @override
  State<MatchFocusMeterInline> createState() => _MatchFocusMeterInlineState();
}

class _MatchFocusMeterInlineState extends State<MatchFocusMeterInline>
    with SingleTickerProviderStateMixin {
  late final AnimationController _anim;
  bool _stopped = false;
  String? _resultLabel;
  Color _resultColor = Colors.white;

  // Perfect zone: 14% base + up to 8% from captain's mental (0-100)
  double get _perfectWidthFraction => 0.14 + (widget.captainMental / 100.0) * 0.08;
  // Good zone: 30% width
  double get _goodWidthFraction => 0.30;

  @override
  void initState() {
    super.initState();
    _anim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _anim.dispose();
    super.dispose();
  }

  void _onTap() {
    if (_stopped) return;
    _stopped = true;
    _anim.stop();

    final markerPos = _anim.value; // 0.0 to 1.0
    // Center is 0.5
    final distFromCenter = (markerPos - 0.5).abs();
    final halfPerfect = _perfectWidthFraction / 2.0;
    final halfGood = _goodWidthFraction / 2.0;

    double bonus = 0.0;
    String outcome = 'MISS';
    Color color = Colors.grey;

    if (distFromCenter <= halfPerfect) {
      bonus = 3.0;
      outcome = 'PERFECT!';
      color = AppConstants.moneyGold;
      HapticFeedback.mediumImpact();
      AudioManager().playSfx(AudioSfx.focusPerfect);
    } else if (distFromCenter <= halfGood) {
      bonus = 1.5;
      outcome = 'GOOD!';
      color = AppConstants.positiveGreen;
      AudioManager().playSfx(AudioSfx.focusGood);
    } else {
      bonus = 0.0;
      outcome = 'MISS';
      color = Colors.white60;
      AudioManager().playSfx(AudioSfx.focusMiss);
    }

    setState(() {
      _resultLabel = outcome;
      _resultColor = color;
    });

    Future.delayed(const Duration(milliseconds: 650), () {
      if (mounted) {
        widget.onResolved(bonus, outcome);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: const Color(0xFF142036),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: AppConstants.moneyGold, width: 2),
        boxShadow: const [
          BoxShadow(color: Colors.black54, offset: Offset(0, 3), blurRadius: 6),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header: Moment Title & Outcome
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '⚡ ${widget.momentTitle} ⚡',
                style: AppTextStyles.caption12.copyWith(color: AppConstants.moneyGold),
              ),
              if (_resultLabel != null)
                Text(
                  _resultLabel!,
                  style: AppTextStyles.label14.copyWith(color: _resultColor),
                )
              else
                const Text('TAP ON GOLD!', style: AppTextStyles.caption12),
            ],
          ),
          const SizedBox(height: 6),

          // 28 dp tall Focus Bar with zones (Red, Green, Gold)
          LayoutBuilder(
            builder: (context, constraints) {
              final totalWidth = constraints.maxWidth;
              final perfectWidth = totalWidth * _perfectWidthFraction;
              final goodWidth = totalWidth * _goodWidthFraction;

              return SizedBox(
                height: 28,
                child: Stack(
                  alignment: Alignment.centerLeft,
                  children: [
                    // 1. Red Base (Miss Zone)
                    Container(
                      width: totalWidth,
                      height: 28,
                      decoration: BoxDecoration(
                        color: AppConstants.negativeRed,
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(color: const Color(0xFF1B2A49), width: 1.5),
                      ),
                    ),

                    // 2. Green Zone (Good)
                    Positioned(
                      left: (totalWidth - goodWidth) / 2.0,
                      child: Container(
                        width: goodWidth,
                        height: 28,
                        color: AppConstants.positiveGreen,
                      ),
                    ),

                    // 3. Gold Zone (Perfect)
                    Positioned(
                      left: (totalWidth - perfectWidth) / 2.0,
                      child: Container(
                        width: perfectWidth,
                        height: 28,
                        decoration: BoxDecoration(
                          color: AppConstants.moneyGold,
                          boxShadow: [
                            BoxShadow(
                              color: AppConstants.moneyGold.withValues(alpha: 0.8),
                              blurRadius: 6,
                            ),
                          ],
                        ),
                      ),
                    ),

                    // 4. Sweeping Marker (8 dp wide)
                    AnimatedBuilder(
                      animation: _anim,
                      builder: (context, _) {
                        final markerLeft = (_anim.value * (totalWidth - 8)).clamp(0.0, totalWidth - 8);
                        return Positioned(
                          left: markerLeft,
                          child: Container(
                            width: 8,
                            height: 28,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(2),
                              border: Border.all(color: Colors.black, width: 1),
                              boxShadow: const [
                                BoxShadow(color: Colors.black87, blurRadius: 4),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              );
            },
          ),

          const SizedBox(height: 8),

          // 64 dp tall Full-Width Pulsing TAP Button
          SizedBox(
            width: double.infinity,
            height: 64,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: _stopped ? _resultColor : AppConstants.moneyGold,
                foregroundColor: Colors.black,
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4),
                  side: const BorderSide(color: Color(0xFF1B2A49), width: 2),
                ),
              ),
              onPressed: _stopped ? null : _onTap,
              child: Text(
                _stopped ? (_resultLabel ?? 'FOCUS LOCKED!') : 'TAP FOR CLUTCH FOCUS!',
                style: AppTextStyles.buttonText.copyWith(
                  color: Colors.black,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
