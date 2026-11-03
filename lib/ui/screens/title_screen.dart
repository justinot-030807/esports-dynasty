import 'package:flutter/material.dart';
import '../../core/constants.dart';
import '../../core/asset_manager.dart';
import '../../services/save_service.dart';
import '../../services/audio_manager.dart';
import '../widgets/pixel_button.dart';
import '../dialogs/settings_dialog.dart';
import '../dialogs/save_slots_dialog.dart';
import 'new_game_screen.dart';

class TitleScreen extends StatefulWidget {
  const TitleScreen({super.key});

  @override
  State<TitleScreen> createState() => _TitleScreenState();
}

class _TitleScreenState extends State<TitleScreen> {
  bool _hasSavedGame = false;

  @override
  void initState() {
    super.initState();
    _checkSave();
    AudioManager().playBgm(AudioBgm.title);
  }

  Future<void> _checkSave() async {
    final hasSave = await SaveService.hasSavedGame();
    if (mounted) {
      setState(() => _hasSavedGame = hasSave);
    }
  }

  Future<void> _continueGame() async {
    showDialog(
      context: context,
      builder: (_) => const SaveSlotsDialog(mode: SaveSlotMode.load),
    );
  }

  void _startNewGame() {
    showDialog(
      context: context,
      builder: (_) => SaveSlotsDialog(
        mode: SaveSlotMode.selectForNewGame,
        onSlotSelected: (slot) {
          SaveService.currentSlot = slot;
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const NewGameScreen()),
          );
        },
      ),
    );
  }

  void _showUpdatesDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1E293B),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
          side: const BorderSide(color: AppConstants.moneyGold, width: 2),
        ),
        title: const Row(
          children: [
            Icon(Icons.new_releases, color: AppConstants.moneyGold, size: 24),
            SizedBox(width: 8),
            Text(
              'ANO ANG BAGO? (v1.2.0)',
              style: TextStyle(
                fontFamily: AppConstants.pixelFont,
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        content: const SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _UpdateBullet(
                title: 'Mas Malalaking Text sa Buong Laro',
                description: 'Pinalaki ang lahat ng font sa top bar, news ticker, roster, tabs, at buttons para malinaw at madaling basahin sa mobile.',
              ),
              _UpdateBullet(
                title: 'Maliwanag na Esports Theme',
                description: 'Inalis ang madilim na black void background at pinalitan ng maliwanag at modernong esports gaming house ambiance.',
              ),
              _UpdateBullet(
                title: 'Bagong 3D Pixel Arcade Buttons',
                description: 'Tunay na procedural pixel-art bevel buttons na may tactile press animation—wala nang blurred o stretched na images!',
              ),
              _UpdateBullet(
                title: 'Inayos ang Gaming House Floor',
                description: 'Tunay na pixelated parquet floor at maayos na pagkaka-pwesto ng PC desks, beds, at kusina (hindi na lumulutang sa kisame!).',
              ),
              _UpdateBullet(
                title: 'Makinis na Speed Control (1x, 2x, 4x)',
                description: 'Inalis ang pause button; tuloy-tuloy ang laro at hindi na naiipit sa pause pagkatapos ng match day o events.',
              ),
              _UpdateBullet(
                title: 'Official Production Release',
                description: 'Inalis ang debug mode para sa tapat at tunay na karanasan sa pagiging esports manager!',
              ),
            ],
          ),
        ),
        actions: [
          PixelButton(
            label: 'NAKUHA KO!',
            color: PixelButtonColor.yellow,
            height: 40,
            fontSize: 13,
            onPressed: () => Navigator.pop(ctx),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppConstants.bgDark,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Background ambient room
          Opacity(
            opacity: 0.35,
            child: Image.asset(
              AssetManager.roomBg,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(color: AppConstants.bgDark),
            ),
          ),

          // Settings gear button
          Positioned(
            top: 10,
            right: 12,
            child: SafeArea(
              child: IconButton(
                icon: const Icon(Icons.settings, color: AppConstants.moneyGold, size: 28),
                onPressed: () {
                  showDialog(context: context, builder: (_) => const SettingsDialog());
                },
              ),
            ),
          ),

          // Main Title content
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Spacer(flex: 2),

                  // Logo
                  Hero(
                    tag: 'app_logo',
                    child: Image.asset(
                      AssetManager.logo,
                      width: 290,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) => const Text(
                        'ESPORTS DYNASTY',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: AppConstants.pixelFont,
                          fontSize: 34,
                          fontWeight: FontWeight.bold,
                          color: AppConstants.moneyGold,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 10),
                  const Text(
                    'Mula Rented Room Hanggang World Champion!',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: AppConstants.pixelFont,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: AppConstants.moneyGold,
                      shadows: [
                        Shadow(color: Color(0xFF0F172A), offset: Offset(1, 1)),
                      ],
                    ),
                  ),

                  const Spacer(flex: 3),

                  // Buttons: Continue, New Game
                  if (_hasSavedGame) ...[
                    PixelButton(
                      label: 'CONTINUE',
                      color: PixelButtonColor.green,
                      minWidth: 240,
                      height: 52,
                      fontSize: 16,
                      onPressed: _continueGame,
                    ),
                    const SizedBox(height: 14),
                  ],

                  PixelButton(
                    label: 'NEW GAME',
                    color: PixelButtonColor.yellow,
                    minWidth: 240,
                    height: 52,
                    fontSize: 16,
                    onPressed: _startNewGame,
                  ),

                  const SizedBox(height: 20),

                  // Updates and Version Badge
                  GestureDetector(
                    onTap: _showUpdatesDialog,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1E293B),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: const Color(0xFF475569), width: 1.5),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.tips_and_updates, color: AppConstants.moneyGold, size: 16),
                          SizedBox(width: 6),
                          Text(
                            'v1.2.0 Release Edition • Tingnan ang Update Notes',
                            style: TextStyle(
                              fontFamily: AppConstants.pixelFont,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFFCBD5E1),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const Spacer(flex: 1),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _UpdateBullet extends StatelessWidget {
  final String title;
  final String description;

  const _UpdateBullet({required this.title, required this.description});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.check_circle, size: 16, color: AppConstants.positiveGreen),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontFamily: AppConstants.pixelFont,
                    color: AppConstants.moneyGold,
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 3),
          Padding(
            padding: const EdgeInsets.only(left: 22.0),
            child: Text(
              description,
              style: const TextStyle(
                fontFamily: AppConstants.pixelFont,
                color: Color(0xFFE2E8F0),
                fontSize: 12,
                height: 1.3,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
