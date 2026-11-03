import 'package:flutter/material.dart';
import '../../core/constants.dart';
import '../../models/game_state.dart';
import '../../services/save_service.dart';
import '../widgets/pixel_panel.dart';
import '../widgets/pixel_button.dart';

class PrologueDialog extends StatefulWidget {
  final GameState state;
  final VoidCallback onComplete;

  const PrologueDialog({
    super.key,
    required this.state,
    required this.onComplete,
  });

  @override
  State<PrologueDialog> createState() => _PrologueDialogState();
}

class _PrologueDialogState extends State<PrologueDialog> {
  int _currentSlide = 0;

  List<_StorySlide> _getSlides() {
    final team = widget.state.teamName;
    final owner = widget.state.ownerName;

    return [
      _StorySlide(
        title: 'KABANATA 1: ANG PANGARAP SA KANTO',
        subtitle: 'Taong 2026 | Sa isang simpleng computer shop...',
        body: 'Sa isang maingay na computer shop sa kanto ng Barangay, nagkita-kita ang mga nangangarap.\n\n'
            'Doon mo nakita ang tatlong pambato ng shop—sina Kidlat, Amihan, at Tsinelas. '
            'Mabilis ang kamay at gutom sa tagumpay, ngunit kulang sa gabay at matinong kagamitan.\n\n'
            'Kinausap mo si Manang Mika, ang ate at katiwala sa shop: '
            '"Mika, bakit hindi tayo magtayo ng sarili nating esports team?"',
        quote: '"Lahat ng alamat, Boss, nagsisimula sa pangarap at piso net!" - Mika',
      ),
      _StorySlide(
        title: 'KABANATA 2: ISINILANG ANG ${team.toUpperCase()}',
        subtitle: 'Mula Kanto Hanggang Entablado',
        body: 'Hawak ang P50,000 na ipon, nag-arkila ka ng isang simpleng paupahan at itinatag ang $team.\n\n'
            'Wala pa tayong aircon o magagarang gaming chair, pero may puso at determinasyon ang squad.\n\n'
            'Ang layunin natin: Magsimula sa Grassroots Circuit (Tier 1)—sa mga paliga sa barangay at cafe cups. '
            'Kapag nakaipon ng Fame at Pera, aakyat tayo sa Provincial, National, at World Championship!',
        quote: '"Wala man tayong marangyang gaming house ngayon, dito magsisimula ang kasaysayan natin!"',
      ),
      _StorySlide(
        title: 'KABANATA 3: ANG HAMON NI MANANG MIKA',
        subtitle: 'Mga Unang Hakbang ng Bagong Boss',
        body: 'Mika: "Boss $owner, ako ang bahala sa bahay, pagkain, at mga paalala sa squad. '
            'Pero kayo ang utak ng buong operasyon!\n\n'
            'Kailangan natin ng 5 manlalaro bago mag-Week 3. Mag-scout tayo ng 2 pang rookie sa Scouting board, '
            'maglagay ng PC desk, at mag-set ng training plan.\n\n'
            'Naniniwala ako sa inyo, Boss. Ipakita natin sa mundo kung paano lumaban ang Pinoy!"',
        quote: '"Handa na ang gaming house, Boss. Simulan na natin ang ating Esports Dynasty!"',
      ),
    ];
  }

  void _finishPrologue() {
    widget.state.storyFlags['prologue_seen'] = true;
    SaveService.saveGame(widget.state);
    widget.onComplete();
  }

  @override
  Widget build(BuildContext context) {
    final slides = _getSlides();
    final cur = slides[_currentSlide];
    final isLast = _currentSlide == slides.length - 1;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 20),
      child: PixelPanel(
        title: 'ANG SIMULA NG PANGARAP',
        width: 340,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header indicator & skip
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: List.generate(slides.length, (i) {
                      final active = i == _currentSlide;
                      return Container(
                        margin: const EdgeInsets.only(right: 6),
                        width: active ? 18 : 8,
                        height: 6,
                        decoration: BoxDecoration(
                          color: active ? AppConstants.moneyGold : const Color(0xFF334155),
                          borderRadius: BorderRadius.circular(3),
                        ),
                      );
                    }),
                  ),
                  GestureDetector(
                    onTap: _finishPrologue,
                    child: const Text(
                      'LAKTAWAN (SKIP)',
                      style: TextStyle(
                        fontFamily: AppConstants.pixelFont,
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                        color: Colors.white54,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              // Mika Portrait & Title
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF142036),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: const Color(0xFF2B3A5E)),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      padding: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        color: AppConstants.famePurple.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: AppConstants.moneyGold, width: 1.5),
                      ),
                      child: Image.asset(
                        'assets/images/characters/staff_mika/staff_mika_front_idle.png',
                        fit: BoxFit.contain,
                        filterQuality: FilterQuality.none,
                        errorBuilder: (_, _, _) => const Icon(Icons.person, color: AppConstants.moneyGold),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            cur.title,
                            style: const TextStyle(
                              fontFamily: AppConstants.pixelFont,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: AppConstants.moneyGold,
                              letterSpacing: 0.5,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            cur.subtitle,
                            style: const TextStyle(
                              fontFamily: AppConstants.pixelFont,
                              fontSize: 8,
                              color: Color(0xFF94A3B8),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),

              // Story narrative text
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: const Color(0xFFCBD5E1), width: 1.5),
                ),
                child: Text(
                  cur.body,
                  style: const TextStyle(
                    fontFamily: AppConstants.pixelFont,
                    fontSize: 11,
                    color: AppConstants.textNavy,
                    height: 1.35,
                  ),
                ),
              ),
              const SizedBox(height: 8),

              // Quote callout
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: AppConstants.moneyGold.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: AppConstants.moneyGold.withValues(alpha: 0.5)),
                ),
                child: Text(
                  cur.quote,
                  style: const TextStyle(
                    fontFamily: AppConstants.pixelFont,
                    fontSize: 9,
                    fontStyle: FontStyle.italic,
                    color: AppConstants.moneyGold,
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // Navigation Buttons
              Row(
                children: [
                  if (_currentSlide > 0) ...[
                    Expanded(
                      flex: 1,
                      child: PixelButton(
                        label: 'BUMALIK',
                        color: PixelButtonColor.red,
                        fontSize: 10,
                        height: 34,
                        onPressed: () => setState(() => _currentSlide--),
                      ),
                    ),
                    const SizedBox(width: 8),
                  ],
                  Expanded(
                    flex: 2,
                    child: PixelButton(
                      label: isLast ? 'SIMULAN ANG DYNASTY! ➔' : 'SUSUNOD ➔',
                      color: isLast ? PixelButtonColor.green : PixelButtonColor.yellow,
                      fontSize: 10,
                      height: 34,
                      onPressed: () {
                        if (isLast) {
                          _finishPrologue();
                        } else {
                          setState(() => _currentSlide++);
                        }
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StorySlide {
  final String title;
  final String subtitle;
  final String body;
  final String quote;

  const _StorySlide({
    required this.title,
    required this.subtitle,
    required this.body,
    required this.quote,
  });
}
