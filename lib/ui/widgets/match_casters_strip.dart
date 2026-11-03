import 'package:flutter/material.dart';
import '../../core/constants.dart';
import '../text_styles.dart';
import '../../services/commentary_engine.dart';

class MatchCastersStrip extends StatefulWidget {
  final CommentaryLine? currentLine;
  final List<CommentaryLine> historyLines;
  final bool isTyping;
  final String displayedText;
  final VoidCallback onFinishTyping;
  final double animPhase;

  const MatchCastersStrip({
    super.key,
    required this.currentLine,
    required this.historyLines,
    required this.isTyping,
    required this.displayedText,
    required this.onFinishTyping,
    required this.animPhase,
  });

  @override
  State<MatchCastersStrip> createState() => _MatchCastersStripState();
}

class _MatchCastersStripState extends State<MatchCastersStrip> {
  Widget _buildCasterAvatar({
    required String name,
    required String title,
    required String spritePath,
    required String fallbackPath,
    required bool isSpeaking,
    required Color badgeColor,
  }) {
    // 6 fps mouth talking animation when speaking and typing
    final mouthOpen = isSpeaking && widget.isTyping && ((widget.animPhase * 6).toInt() % 2 == 0);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: isSpeaking ? badgeColor.withValues(alpha: 0.25) : const Color(0xFF131D33),
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSpeaking ? badgeColor : const Color(0xFF2C3E60),
                  width: isSpeaking ? 2 : 1.5,
                ),
              ),
              child: ClipOval(
                child: Image.asset(
                  spritePath,
                  fit: BoxFit.contain,
                  filterQuality: FilterQuality.none,
                  errorBuilder: (_, _, _) => Image.asset(
                    fallbackPath,
                    fit: BoxFit.contain,
                    filterQuality: FilterQuality.none,
                    errorBuilder: (_, _, _) => Icon(
                      Icons.mic,
                      color: isSpeaking ? badgeColor : Colors.white38,
                      size: 20,
                    ),
                  ),
                ),
              ),
            ),
            if (mouthOpen)
              Positioned(
                bottom: 8,
                child: Container(
                  width: 6,
                  height: 4,
                  decoration: const BoxDecoration(
                    color: Color(0xFF1B2A49),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 2),
        Text(
          name,
          style: AppTextStyles.caption12.copyWith(
            color: isSpeaking ? AppConstants.moneyGold : Colors.white70,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  static void _ignoreBubbleError(Object e, StackTrace? s) {}

  @override
  Widget build(BuildContext context) {
    final current = widget.currentLine;
    final isHypeSpeaking = current?.speaker == CasterType.hype;

    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF0F1826),
        border: Border.symmetric(
          horizontal: BorderSide(color: Color(0xFF2C3E60), width: 1.5),
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // 1. Caster 1: Tonyo (Hype Caster)
          _buildCasterAvatar(
            name: 'TONYO',
            title: 'HYPE',
            spritePath: isHypeSpeaking && widget.isTyping
                ? 'assets/images/characters/caster_tonyo_talk.png'
                : 'assets/images/characters/caster_tonyo_idle.png',
            fallbackPath: 'assets/images/characters/staff_producer/staff_producer_front_idle.png',
            isSpeaking: isHypeSpeaking,
            badgeColor: AppConstants.moneyGold,
          ),

          const SizedBox(width: 8),

          // 2. Center Speech Bubble (Tap to finish typing, 16 dp current, last 3 in 14 dp)
          Expanded(
            child: GestureDetector(
              onTap: widget.isTyping ? widget.onFinishTyping : null,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFFF0F4F8), // Game's blue-and-white pixel panel look
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: const Color(0xFF1B2A49), width: 2),
                  boxShadow: const [
                    BoxShadow(color: Color(0xFF1B2A49), offset: Offset(2, 2)),
                  ],
                  image: const DecorationImage(
                    image: AssetImage('assets/images/ui/bubble.png'),
                    fit: BoxFit.fill,
                    onError: _ignoreBubbleError,
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Speaker Badge & Title
                    Row(
                      children: [
                        Text(
                          current?.speakerName.toUpperCase() ?? 'CASTER DESK',
                          style: AppTextStyles.windowCaption.copyWith(
                            color: isHypeSpeaking ? const Color(0xFF996500) : const Color(0xFF104E8B),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '• ${current?.speakerTitle ?? "LIVE"}',
                          style: AppTextStyles.windowCaption.copyWith(color: Colors.black54),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),

                    // Current Commentary Line (16 dp)
                    Text(
                      widget.displayedText.isNotEmpty
                          ? widget.displayedText
                          : (current?.text ?? 'Nagsisimula na ang live broadcast ng torneo!'),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.currentCommentary,
                    ),

                    // Recent History Lines (14 dp)
                    if (widget.historyLines.isNotEmpty) ...[
                      const SizedBox(height: 3),
                      const Divider(height: 1, thickness: 1, color: Color(0xFFCCD6E0)),
                      const SizedBox(height: 2),
                      for (final hist in widget.historyLines.take(2))
                        Text(
                          '• ${hist.text}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyles.historyCommentary,
                        ),
                    ],
                  ],
                ),
              ),
            ),
          ),

          const SizedBox(width: 8),

          // 3. Caster 2: Maya (Tactical Analyst)
          _buildCasterAvatar(
            name: 'MAYA',
            title: 'ANALYST',
            spritePath: !isHypeSpeaking && widget.isTyping
                ? 'assets/images/characters/caster_maya_talk.png'
                : 'assets/images/characters/caster_maya_idle.png',
            fallbackPath: 'assets/images/characters/staff_analyst/staff_analyst_front_idle.png',
            isSpeaking: !isHypeSpeaking,
            badgeColor: AppConstants.energyBlue,
          ),
        ],
      ),
    );
  }
}
