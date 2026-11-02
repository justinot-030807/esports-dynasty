import 'package:flutter/material.dart';
import '../../core/constants.dart';
import '../widgets/pixel_panel.dart';
import '../widgets/pixel_button.dart';

class CreditsDialog extends StatelessWidget {
  const CreditsDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: PixelPanel(
        title: 'MGA KREDITO',
        width: 330,
        onClose: () => Navigator.pop(context),
        child: SizedBox(
          height: 440,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: ListView(
                  children: [
                    _buildSectionHeader('ESPORTS DYNASTY'),
                    const Text(
                      'Pinoy Portrait Mobile Management Sim\nBinuo gamit ang Flutter at Flame Engine.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontFamily: AppConstants.pixelFont, fontSize: 10, color: Colors.black87),
                    ),
                    const SizedBox(height: 12),

                    _buildSectionHeader('TYPOGRAPHY & FONTS'),
                    const Text(
                      'Pixelify Sans by Stefie Justprince\nLisensya: SIL Open Font License, Version 1.1 (OFL)',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontFamily: AppConstants.pixelFont, fontSize: 9.5, color: Colors.black87),
                    ),
                    const SizedBox(height: 12),

                    _buildSectionHeader('AUDIO & SOUND DESIGN'),
                    const Text(
                      'Chiptune Synth & SFX Suite\nLisensya: Creative Commons Zero (CC0 1.0 Universal) Public Domain Dedication.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontFamily: AppConstants.pixelFont, fontSize: 9.5, color: Colors.black87),
                    ),
                    const SizedBox(height: 12),

                    _buildSectionHeader('OPEN SOURCE SOFTWARE'),
                    const Text(
                      'Flutter Framework (Google LLC)\nFlame Game Engine (Blue Fire Team)\nShared Preferences (Flutter Community)',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontFamily: AppConstants.pixelFont, fontSize: 9.5, color: Colors.black87),
                    ),
                    const SizedBox(height: 16),

                    const Text(
                      'Mabuhay ang Pinoy Esports Community!\nMaraming salamat sa paglalaro!',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: AppConstants.pixelFont,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: AppConstants.darkNavy,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              PixelButton(
                label: 'ISARA',
                color: PixelButtonColor.yellow,
                fontSize: 10,
                height: 32,
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Container(
      margin: const EdgeInsets.only(bottom: 4),
      padding: const EdgeInsets.symmetric(vertical: 4),
      color: AppConstants.darkNavy,
      child: Text(
        title,
        textAlign: TextAlign.center,
        style: const TextStyle(
          fontFamily: AppConstants.pixelFont,
          fontSize: 10,
          fontWeight: FontWeight.bold,
          color: AppConstants.moneyGold,
        ),
      ),
    );
  }
}
