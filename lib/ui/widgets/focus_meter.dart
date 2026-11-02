import 'dart:math';
import 'package:flutter/material.dart';
import '../../core/constants.dart';

class FocusMeterDialog extends StatefulWidget {
  final int captainMental;
  final String momentTitle;
  final Function(double bonus, String outcome) onResult;

  const FocusMeterDialog({
    super.key,
    required this.captainMental,
    required this.momentTitle,
    required this.onResult,
  });

  @override
  State<FocusMeterDialog> createState() => _FocusMeterDialogState();
}

class _FocusMeterDialogState extends State<FocusMeterDialog>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  bool _locked = false;
  String? _outcomeText;
  Color _outcomeColor = Colors.white;
  double _lockedBonus = 0.0;

  double get _perfectWidth {
    final mentalBonus = (min(100, max(0, widget.captainMental)) / 100.0) * 0.08;
    return 0.14 + mentalBonus;
  }

  double get _goodWidth => 0.30;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 950),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _lockIn() {
    if (_locked) return;
    setState(() {
      _locked = true;
      _controller.stop();
    });

    final pos = _controller.value;
    final halfPerfect = _perfectWidth / 2.0;
    final halfGood = _goodWidth / 2.0;

    if (pos >= (0.5 - halfPerfect) && pos <= (0.5 + halfPerfect)) {
      _lockedBonus = 3.0;
      _outcomeText = 'PERFECT TIMING! +3.0 POWER';
      _outcomeColor = AppConstants.moneyGold;
    } else if (pos >= (0.5 - halfGood) && pos <= (0.5 + halfGood)) {
      _lockedBonus = 1.5;
      _outcomeText = 'GOOD CALL! +1.5 POWER';
      _outcomeColor = AppConstants.positiveGreen;
    } else {
      _lockedBonus = 0.0;
      _outcomeText = 'MISSED CHANCE! +0.0 POWER';
      _outcomeColor = AppConstants.negativeRed;
    }

    Future.delayed(const Duration(milliseconds: 900), () {
      if (mounted) {
        widget.onResult(_lockedBonus, _outcomeText!);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppConstants.bgDark,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppConstants.moneyGold, width: 2),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.flash_on, color: AppConstants.moneyGold, size: 20),
                const SizedBox(width: 6),
                Text(
                  widget.momentTitle.toUpperCase(),
                  style: const TextStyle(
                    fontFamily: AppConstants.pixelFont,
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: AppConstants.moneyGold,
                    letterSpacing: 1.5,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              'Captain Mental (${widget.captainMental}) expands Perfect Zone!',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontFamily: AppConstants.pixelFont,
                fontSize: 8,
                color: Colors.white70,
              ),
            ),
            const SizedBox(height: 16),

            // Focus Bar
            AnimatedBuilder(
              animation: _controller,
              builder: (context, _) {
                final markerPos = _controller.value;
                return Container(
                  height: 38,
                  decoration: BoxDecoration(
                    color: const Color(0xFF142036),
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: Colors.white24, width: 1.5),
                  ),
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final totalWidth = constraints.maxWidth;
                      final goodPixels = totalWidth * _goodWidth;
                      final perfectPixels = totalWidth * _perfectWidth;

                      final goodStart = (totalWidth - goodPixels) / 2.0;
                      final perfStart = (totalWidth - perfectPixels) / 2.0;
                      final markerPixels = markerPos * (totalWidth - 6);

                      return Stack(
                        children: [
                          // Miss Zones (Background is dark red-grey)
                          Positioned.fill(
                            child: Container(
                              color: const Color(0xFF331622),
                            ),
                          ),

                          // Good Zone
                          Positioned(
                            left: goodStart,
                            width: goodPixels,
                            top: 0,
                            bottom: 0,
                            child: Container(
                              color: const Color(0xFF1B4E3B),
                            ),
                          ),

                          // Perfect Zone
                          Positioned(
                            left: perfStart,
                            width: perfectPixels,
                            top: 0,
                            bottom: 0,
                            child: Container(
                              color: const Color(0xFF8A6D0B),
                              child: const Center(
                                child: Text(
                                  'PERFECT',
                                  style: TextStyle(
                                    fontFamily: AppConstants.pixelFont,
                                    fontSize: 7,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ),

                          // Sweeping Indicator Marker
                          Positioned(
                            left: markerPixels,
                            top: 0,
                            bottom: 0,
                            child: Container(
                              width: 6,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(2),
                                boxShadow: const [
                                  BoxShadow(
                                    color: Colors.white,
                                    blurRadius: 4,
                                    spreadRadius: 1,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                );
              },
            ),
            const SizedBox(height: 12),

            // Outcome feedback or Call to action
            if (_outcomeText != null)
              Container(
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: _outcomeColor.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: _outcomeColor),
                ),
                child: Text(
                  _outcomeText!,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: AppConstants.pixelFont,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: _outcomeColor,
                  ),
                ),
              )
            else
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppConstants.positiveGreen,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                ),
                icon: const Icon(Icons.touch_app, color: Colors.white, size: 18),
                label: const Text(
                  'TAP TO FOCUS!',
                  style: TextStyle(
                    fontFamily: AppConstants.pixelFont,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 1.2,
                  ),
                ),
                onPressed: _lockIn,
              ),
          ],
        ),
      ),
    );
  }
}
