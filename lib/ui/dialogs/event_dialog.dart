import 'package:flutter/material.dart';
import '../../core/constants.dart';
import '../../models/game_state.dart';
import '../../models/game_event.dart';
import '../../services/event_service.dart';
import '../widgets/pixel_panel.dart';
import '../widgets/pixel_button.dart';

class EventDialog extends StatefulWidget {
  final GameState state;
  final NarrativeEvent event;
  final VoidCallback onDismissed;

  const EventDialog({
    super.key,
    required this.state,
    required this.event,
    required this.onDismissed,
  });

  @override
  State<EventDialog> createState() => _EventDialogState();
}

class _EventDialogState extends State<EventDialog> {
  String? _outcomeText;

  String _getEventIconPath(String id, String cat, String title) {
    final lower = '$id $cat $title'.toLowerCase();
    if (lower.contains('brownout') || lower.contains('kuryente') || lower.contains('power')) return 'assets/images/icons/event_brownout.png';
    if (lower.contains('typhoon') || lower.contains('bagyo') || lower.contains('storm')) return 'assets/images/icons/event_typhoon.png';
    if (lower.contains('viral') || lower.contains('clip') || lower.contains('tiktok')) return 'assets/images/icons/event_viral_clip.png';
    if (lower.contains('drama') || lower.contains('controversy') || lower.contains('away')) return 'assets/images/icons/event_controversy.png';
    if (lower.contains('poach') || lower.contains('pirate')) return 'assets/images/icons/event_poaching.png';
    if (lower.contains('scam') || lower.contains('budol')) return 'assets/images/icons/event_scam.png';
    if (lower.contains('bribe') || lower.contains('suhol')) return 'assets/images/icons/event_bribe.png';
    if (lower.contains('burnout') || lower.contains('pagod') || lower.contains('fatigue')) return 'assets/images/icons/event_burnout.png';
    if (lower.contains('pc') || lower.contains('sira') || lower.contains('breakdown')) return 'assets/images/icons/event_pc_breakdown.png';
    if (lower.contains('patch') || lower.contains('update')) return 'assets/images/icons/event_patch_notes.png';
    if (lower.contains('fan') || lower.contains('meetup') || lower.contains('meet')) return 'assets/images/icons/event_fan_meetup.png';
    if (lower.contains('charity') || lower.contains('tulong') || lower.contains('donat')) return 'assets/images/icons/event_charity.png';
    return 'assets/images/icons/ui_warning.png';
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: PixelPanel(
        title: 'KAGANAPAN!',
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Category & Title
              Row(
                children: [
                  Image.asset(
                    _getEventIconPath(widget.event.id, widget.event.category, widget.event.title),
                    width: 36,
                    height: 36,
                    fit: BoxFit.contain,
                    filterQuality: FilterQuality.none,
                    errorBuilder: (_, _, _) => const Icon(Icons.event_note, color: AppConstants.textNavy, size: 28),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: _getCategoryColor(widget.event.category),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            widget.event.category.toUpperCase().replaceAll('_', ' '),
                            style: const TextStyle(
                              fontFamily: AppConstants.pixelFont,
                              fontSize: 8,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          widget.event.title,
                          style: const TextStyle(
                            fontFamily: AppConstants.pixelFont,
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: AppConstants.textNavy,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Manang Mika speech bubble
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFFD0D7DE), width: 2),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Image.asset(
                      'assets/images/characters/staff_mika/staff_mika_front_idle.png',
                      width: 36,
                      height: 36,
                      fit: BoxFit.contain,
                      filterQuality: FilterQuality.none,
                      errorBuilder: (_, _, _) => Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: AppConstants.famePurple.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Center(
                          child: Text(
                            'MIKA',
                            style: TextStyle(
                              fontFamily: AppConstants.pixelFont,
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                              color: AppConstants.famePurple,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        widget.event.text,
                        style: const TextStyle(
                          fontFamily: AppConstants.pixelFont,
                          fontSize: 12,
                          color: AppConstants.textNavy,
                          height: 1.3,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              if (widget.event.id.contains('fan') || widget.event.title.toLowerCase().contains('fan')) ...[
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: ['fan_kid', 'fan_teen', 'fan_student', 'fan_cosplayer'].map((f) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: Image.asset(
                        'assets/images/characters/$f/${f}_front_idle.png',
                        width: 28,
                        height: 28,
                        fit: BoxFit.contain,
                        filterQuality: FilterQuality.none,
                        errorBuilder: (_, _, _) => const SizedBox(),
                      ),
                    );
                  }).toList(),
                ),
              ],
              const SizedBox(height: 14),

              if (_outcomeText != null) ...[
                // Outcome message
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppConstants.positiveGreen.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppConstants.positiveGreen, width: 2),
                  ),
                  child: Text(
                    _outcomeText!,
                    style: const TextStyle(
                      fontFamily: AppConstants.pixelFont,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: AppConstants.textNavy,
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                PixelButton(
                  label: 'SIGE PO!',
                  color: PixelButtonColor.green,
                  onPressed: () {
                    Navigator.pop(context);
                    widget.onDismissed();
                  },
                ),
              ] else ...[
                // Choices
                const Text(
                  'ANO ANG GAGAWIN MO, BOSS?',
                  style: TextStyle(
                    fontFamily: AppConstants.pixelFont,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: Colors.black54,
                  ),
                ),
                const SizedBox(height: 8),
                for (final choice in widget.event.choices)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: _buildChoiceButton(choice),
                  ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildChoiceButton(EventChoice choice) {
    final isAvailable = EventService().isChoiceAvailable(choice, widget.state);

    return InkWell(
      onTap: isAvailable
          ? () {
              final result = EventService().applyEventChoice(
                widget.event,
                choice,
                widget.state,
              );
              setState(() {
                _outcomeText = result;
              });
            }
          : null,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        decoration: BoxDecoration(
          color: isAvailable ? Colors.white : Colors.grey.shade200,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
            color: isAvailable ? AppConstants.darkNavy : Colors.grey,
            width: 2,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    choice.text,
                    style: TextStyle(
                      fontFamily: AppConstants.pixelFont,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: isAvailable ? AppConstants.textNavy : Colors.grey.shade600,
                    ),
                  ),
                ),
                if (choice.cost > 0)
                  Text(
                    'P${choice.cost}',
                    style: TextStyle(
                      fontFamily: AppConstants.pixelFont,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: widget.state.money >= choice.cost ? AppConstants.negativeRed : Colors.grey,
                    ),
                  ),
              ],
            ),
            if (!isAvailable && choice.condition != null)
              Padding(
                padding: const EdgeInsets.only(top: 4.0),
                child: Text(
                  '(Kailangan ng pasilidad o gamit para dito)',
                  style: TextStyle(
                    fontFamily: AppConstants.pixelFont,
                    fontSize: 9,
                    color: Colors.grey.shade600,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Color _getCategoryColor(String category) {
    switch (category) {
      case 'house': return AppConstants.energyBlue;
      case 'community': return AppConstants.fansPink;
      case 'competition': return AppConstants.moneyGold;
      case 'business': return AppConstants.positiveGreen;
      case 'player_life': return AppConstants.famePurple;
      case 'team': return const Color(0xFFE28743);
      default: return AppConstants.darkNavy;
    }
  }
}
