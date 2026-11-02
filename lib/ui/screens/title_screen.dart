import 'package:flutter/material.dart';
import '../../core/constants.dart';
import '../../core/asset_manager.dart';
import '../../services/save_service.dart';
import '../../models/game_state.dart';
import '../../services/audio_manager.dart';
import '../widgets/pixel_button.dart';
import '../dialogs/debug_menu_dialog.dart';
import '../dialogs/settings_dialog.dart';
import 'new_game_screen.dart';
import 'hub_screen.dart';

class TitleScreen extends StatefulWidget {
  const TitleScreen({super.key});

  @override
  State<TitleScreen> createState() => _TitleScreenState();
}

class _TitleScreenState extends State<TitleScreen> {
  bool _hasSavedGame = false;
  int _logoTapCount = 0;

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

  void _onLogoTap() {
    _logoTapCount++;
    if (_logoTapCount >= 7) {
      _logoTapCount = 0;
      // Open hidden debug menu
      showDialog(
        context: context,
        builder: (_) => DebugMenuDialog(
          state: GameState.initial(
            teamName: 'Debug Team',
            ownerName: 'Tester',
            primaryColorHex: '#1B2A49',
            secondaryColorHex: '#F5B700',
            emblemSymbol: 'lightning',
            emblemLetters: 'DT',
          ),
          onStateUpdated: () {},
        ),
      );
    }
  }

  Future<void> _continueGame() async {
    final state = await SaveService.loadGame();
    if (state != null && mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => HubScreen(state: state)),
      );
    }
  }

  void _startNewGame() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const NewGameScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppConstants.bgDark,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Settings gear button
          Positioned(
            top: 10,
            right: 12,
            child: SafeArea(
              child: IconButton(
                icon: const Icon(Icons.settings, color: AppConstants.moneyGold, size: 26),
                onPressed: () {
                  showDialog(context: context, builder: (_) => const SettingsDialog());
                },
              ),
            ),
          ),
          Opacity(
            opacity: 0.35,
            child: Image.asset(
              AssetManager.roomBg,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(color: AppConstants.bgDark),
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

                  // Tappable Logo (Tap 7 times for Debug Menu)
                  GestureDetector(
                    onTap: _onLogoTap,
                    child: Hero(
                      tag: 'app_logo',
                      child: Image.asset(
                        AssetManager.logo,
                        width: 280,
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) => const Text(
                          'ESPORTS DYNASTY',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontFamily: AppConstants.pixelFont,
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: AppConstants.moneyGold,
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 8),
                  const Text(
                    'Mula Rented Room Hanggang World Champion!',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: AppConstants.pixelFont,
                      fontSize: 13,
                      color: AppConstants.moneyGold,
                    ),
                  ),

                  const Spacer(flex: 3),

                  // Buttons: Continue, New Game
                  if (_hasSavedGame) ...[
                    PixelButton(
                      label: 'CONTINUE',
                      color: PixelButtonColor.green,
                      minWidth: 220,
                      onPressed: _continueGame,
                    ),
                    const SizedBox(height: 12),
                  ],

                  PixelButton(
                    label: 'NEW GAME',
                    color: PixelButtonColor.yellow,
                    minWidth: 220,
                    onPressed: _startNewGame,
                  ),

                  const SizedBox(height: 12),

                  // Hidden debug hint or quick button
                  GestureDetector(
                    onTap: _onLogoTap,
                    child: Text(
                      _logoTapCount > 0
                          ? 'Debug unlock in ${7 - _logoTapCount} taps...'
                          : 'v1.0.0 - Phase 1 Slice',
                      style: const TextStyle(
                        fontFamily: AppConstants.pixelFont,
                        fontSize: 11,
                        color: Colors.white38,
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
