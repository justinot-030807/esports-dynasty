import 'package:flutter/material.dart';
import '../../core/constants.dart';
import '../../core/asset_manager.dart';
import '../../services/data_service.dart';
import '../../services/settings_service.dart';
import '../../services/legacy_service.dart';
import 'title_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _fadeController;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..forward();

    _initializeGame();
  }

  Future<void> _initializeGame() async {
    // 1. Load asset manifest
    await AssetManager().loadManifest();
    // 2. Load all JSON data files
    await DataService().loadAllData();
    // 3. Initialize settings & legacy state
    await SettingsService().init();
    await LegacyService().init();
    // 4. Small delay for splash presentation
    await Future.delayed(const Duration(milliseconds: 1500));

    if (mounted) {
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          pageBuilder: (context, anim, secAnim) => const TitleScreen(),
          transitionsBuilder: (context, animation, secAnim, child) {
            return FadeTransition(opacity: animation, child: child);
          },
          transitionDuration: const Duration(milliseconds: 400),
        ),
      );
    }
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppConstants.bgDark,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Splash background image
          Image.asset(
            AssetManager.splash,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) => Container(color: AppConstants.bgDark),
          ),

          // Dark overlay gradient
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0x33000000), Color(0xAA0F172A)],
              ),
            ),
          ),

          // Centered title and loading message
          FadeTransition(
            opacity: _fadeController,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Image.asset(
                  AssetManager.logo,
                  width: 260,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) => const Text(
                    'ESPORTS DYNASTY',
                    style: TextStyle(
                      fontFamily: AppConstants.pixelFont,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: AppConstants.moneyGold,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Loading Philippine Esports Scene...',
                  style: TextStyle(
                    fontFamily: AppConstants.pixelFont,
                    color: Colors.white70,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 60),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
