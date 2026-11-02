import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'ui/theme.dart';
import 'ui/screens/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Lock to portrait orientation per GAME_DESIGN.md
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Dark retro status & nav bars
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
    systemNavigationBarColor: Color(0xFF1B2A49),
    systemNavigationBarIconBrightness: Brightness.light,
  ));

  runApp(const EsportsDynastyApp());
}

class EsportsDynastyApp extends StatelessWidget {
  const EsportsDynastyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ESPORTS DYNASTY',
      debugShowCheckedModeBanner: false,
      theme: GameTheme.themeData,
      home: const SplashScreen(),
    );
  }
}
