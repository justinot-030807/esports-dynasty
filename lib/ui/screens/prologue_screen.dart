import 'package:flutter/material.dart';
import '../../core/constants.dart';
import '../../models/game_state.dart';
import '../dialogs/prologue_dialog.dart';
import 'hub_screen.dart';

class PrologueScreen extends StatelessWidget {
  final GameState state;

  const PrologueScreen({super.key, required this.state});

  void _proceedToHub(BuildContext context) {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => HubScreen(state: state)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppConstants.bgDark,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: PrologueDialog(
              state: state,
              onComplete: () => _proceedToHub(context),
            ),
          ),
        ),
      ),
    );
  }
}
