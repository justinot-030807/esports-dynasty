import 'package:flutter/material.dart';
import '../../core/constants.dart';
import '../../models/game_state.dart';
import '../../services/save_service.dart';
import '../../services/legacy_service.dart';
import '../dialogs/legacy_shop_dialog.dart';
import '../widgets/pixel_panel.dart';
import '../widgets/pixel_button.dart';
import '../widgets/emblem_widget.dart';
import 'hub_screen.dart';

class NewGameScreen extends StatefulWidget {
  const NewGameScreen({super.key});

  @override
  State<NewGameScreen> createState() => _NewGameScreenState();
}

class _NewGameScreenState extends State<NewGameScreen> {
  final _teamNameController = TextEditingController(text: 'Agila Esports');
  final _ownerNameController = TextEditingController(text: 'Boss Juan');
  final _lettersController = TextEditingController(text: 'AE');

  Color _primaryColor = const Color(0xFF1B2A49);
  Color _secondaryColor = const Color(0xFFF5B700);
  final String _symbol = 'lightning';
  String _difficulty = 'normal';

  final List<Color> _colorPalette = [
    const Color(0xFF1B2A49), // Navy
    const Color(0xFFF5B700), // Gold
    const Color(0xFFE5484D), // Red
    const Color(0xFF3DBE5A), // Green
    const Color(0xFF3FA7FF), // Blue
    const Color(0xFF9B5DE5), // Purple
    const Color(0xFFFF6FA5), // Pink
    const Color(0xFF2D3748), // Charcoal
  ];

  String _colorToHex(Color c) {
    return '#${c.toARGB32().toRadixString(16).padLeft(8, '0').substring(2).toUpperCase()}';
  }

  void _createGame() async {
    final teamName = _teamNameController.text.trim().isNotEmpty
        ? _teamNameController.text.trim()
        : 'Agila Esports';
    final ownerName = _ownerNameController.text.trim().isNotEmpty
        ? _ownerNameController.text.trim()
        : 'Boss Juan';
    final letters = _lettersController.text.trim().toUpperCase();

    final state = GameState.initial(
      teamName: teamName,
      ownerName: ownerName,
      primaryColorHex: _colorToHex(_primaryColor),
      secondaryColorHex: _colorToHex(_secondaryColor),
      emblemSymbol: _symbol,
      emblemLetters: letters.isNotEmpty ? letters : 'AE',
      difficulty: _difficulty,
      activeLegacyPerks: LegacyService().globalLegacy.activePerkIds,
    );

    await SaveService.saveGame(state);

    if (mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => HubScreen(state: state)),
      );
    }
  }

  @override
  void dispose() {
    _teamNameController.dispose();
    _ownerNameController.dispose();
    _lettersController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppConstants.bgDark,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: PixelPanel(
              title: 'CREATE YOUR TEAM',
              width: 330,
              onClose: () => Navigator.of(context).pop(),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Center(
                    child: EmblemWidget(
                      size: 64,
                      primaryColor: _primaryColor,
                      secondaryColor: _secondaryColor,
                      symbol: _symbol,
                      letters: _lettersController.text.trim().toUpperCase(),
                    ),
                  ),
                  const SizedBox(height: 12),

                  _buildLabel('TEAM NAME:'),
                  _buildTextField(_teamNameController, 'Hal. Agila Esports'),
                  const SizedBox(height: 8),

                  _buildLabel('MANAGER NAME:'),
                  _buildTextField(_ownerNameController, 'Hal. Boss Juan'),
                  const SizedBox(height: 8),

                  _buildLabel('EMBLEM LETTERS:'),
                  _buildTextField(_lettersController, 'AE', maxLength: 3, onChanged: (_) => setState(() {})),
                  const SizedBox(height: 8),

                  _buildLabel('DIFFICULTY MODE:'),
                  Row(
                    children: [
                      for (final mode in ['easy', 'normal', 'hard'])
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 2.0),
                            child: InkWell(
                              onTap: () => setState(() => _difficulty = mode),
                              child: Container(
                                padding: const EdgeInsets.symmetric(vertical: 6),
                                decoration: BoxDecoration(
                                  color: _difficulty == mode ? AppConstants.textNavy : Colors.white,
                                  borderRadius: BorderRadius.circular(4),
                                  border: Border.all(color: AppConstants.darkNavy, width: 1.5),
                                ),
                                child: Center(
                                  child: Text(
                                    mode.toUpperCase(),
                                    style: TextStyle(
                                      fontFamily: AppConstants.pixelFont,
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      color: _difficulty == mode ? Colors.white : AppConstants.textNavy,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  _buildLabel('PRIMARY COLOR:'),
                  _buildColorPicker(
                    selected: _primaryColor,
                    onSelect: (c) => setState(() => _primaryColor = c),
                  ),
                  const SizedBox(height: 8),

                  _buildLabel('SECONDARY COLOR:'),
                  _buildColorPicker(
                    selected: _secondaryColor,
                    onSelect: (c) => setState(() => _secondaryColor = c),
                  ),
                  const SizedBox(height: 16),

                  if (LegacyService().globalLegacy.totalLegacyPoints > 0) ...[
                    PixelButton(
                      label: 'LEGACY PERKS (${LegacyService().globalLegacy.activePerkIds.length} ACTIVE)',
                      color: PixelButtonColor.yellow,
                      fontSize: 10,
                      height: 32,
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (_) => LegacyShopDialog(onPerksUpdated: () => setState(() {})),
                        );
                      },
                    ),
                    const SizedBox(height: 8),
                  ],

                  PixelButton(
                    label: 'SIMULAN ANG LABAN!',
                    color: PixelButtonColor.green,
                    onPressed: _createGame,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 3.0),
      child: Text(
        text,
        style: const TextStyle(
          fontFamily: AppConstants.pixelFont,
          fontSize: 11,
          fontWeight: FontWeight.bold,
          color: AppConstants.darkNavy,
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String hint, {int? maxLength, Function(String)? onChanged}) {
    return SizedBox(
      height: 38,
      child: TextField(
        controller: controller,
        maxLength: maxLength,
        onChanged: onChanged,
        style: const TextStyle(
          fontFamily: AppConstants.pixelFont,
          fontSize: 13,
          color: AppConstants.darkNavy,
        ),
        decoration: InputDecoration(
          counterText: '',
          filled: true,
          fillColor: Colors.white,
          hintText: hint,
          hintStyle: const TextStyle(fontSize: 12, color: Colors.black38),
          contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(4),
            borderSide: const BorderSide(color: AppConstants.darkNavy, width: 2),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(4),
            borderSide: const BorderSide(color: AppConstants.moneyGold, width: 2.5),
          ),
        ),
      ),
    );
  }

  Widget _buildColorPicker({required Color selected, required Function(Color) onSelect}) {
    return Wrap(
      spacing: 6,
      runSpacing: 4,
      children: _colorPalette.map((color) {
        final isSelected = color == selected;
        return GestureDetector(
          onTap: () => onSelect(color),
          child: Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(4),
              border: Border.all(
                color: isSelected ? Colors.white : AppConstants.darkNavy,
                width: isSelected ? 3.0 : 1.5,
              ),
              boxShadow: isSelected
                  ? [const BoxShadow(color: Colors.black45, offset: Offset(0, 2), blurRadius: 2)]
                  : [],
            ),
          ),
        );
      }).toList(),
    );
  }
}
