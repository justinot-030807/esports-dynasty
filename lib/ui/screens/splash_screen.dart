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
  String _statusText = 'Inihahanda ang Arena Clash...';

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
    setState(() => _statusText = 'Naglo-load ng Game Assets...');
    await AssetManager().loadManifest();

    // 2. Load all JSON data files
    setState(() => _statusText = 'Naglo-load ng Tournaments & Items...');
    await DataService().loadAllData();

    // 3. Initialize settings & legacy state
    setState(() => _statusText = 'Checking Updates & Cloud Saves...');
    await SettingsService().init();
    await LegacyService().init();

    // 4. Small delay for smooth splash presentation
    await Future.delayed(const Duration(milliseconds: 900));

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
                colors: [Color(0x33000000), Color(0xCC0F172A)],
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
                  width: 290,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) => const Text(
                    'ESPORTS DYNASTY',
                    style: TextStyle(
                      fontFamily: AppConstants.pixelFont,
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: AppConstants.moneyGold,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E293B),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppConstants.moneyGold, width: 1.5),
                  ),
                  child: const Text(
                    'v1.2.0 • RELEASE EDITION',
                    style: TextStyle(
                      fontFamily: AppConstants.pixelFont,
                      color: AppConstants.moneyGold,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.8,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  _statusText,
                  style: const TextStyle(
                    fontFamily: AppConstants.pixelFont,
                    color: Color(0xFFE2E8F0),
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 50),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
