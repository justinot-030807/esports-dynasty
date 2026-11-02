import 'package:flutter/material.dart';
import '../../core/constants.dart';
import '../../core/asset_manager.dart';

enum PixelButtonColor { green, red, yellow, neutral }

class PixelButton extends StatefulWidget {
  final String label;
  final VoidCallback? onPressed;
  final PixelButtonColor color;
  final double minWidth;
  final double height;
  final double? fontSize;
  final Widget? icon;

  const PixelButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.color = PixelButtonColor.green,
    this.minWidth = 100,
    this.height = 46,
    this.fontSize,
    this.icon,
  });

  @override
  State<PixelButton> createState() => _PixelButtonState();
}

class _PixelButtonState extends State<PixelButton> {
  bool _isPressed = false;

  String get _assetImage {
    switch (widget.color) {
      case PixelButtonColor.green:
        return AssetManager.btnGreen;
      case PixelButtonColor.red:
        return AssetManager.btnRed;
      case PixelButtonColor.yellow:
        return AssetManager.btnYellow;
      case PixelButtonColor.neutral:
        return AssetManager.btnYellow;
    }
  }

  Color get _fallbackColor {
    switch (widget.color) {
      case PixelButtonColor.green:
        return AppConstants.positiveGreen;
      case PixelButtonColor.red:
        return AppConstants.negativeRed;
      case PixelButtonColor.yellow:
        return AppConstants.moneyGold;
      case PixelButtonColor.neutral:
        return const Color(0xFF64748B);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEnabled = widget.onPressed != null;

    return GestureDetector(
      onTapDown: isEnabled ? (_) => setState(() => _isPressed = true) : null,
      onTapUp: isEnabled
          ? (_) {
              setState(() => _isPressed = false);
              widget.onPressed?.call();
            }
          : null,
      onTapCancel: isEnabled ? () => setState(() => _isPressed = false) : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 60),
        margin: EdgeInsets.only(top: _isPressed ? 4.0 : 0.0, bottom: _isPressed ? 0.0 : 4.0),
        constraints: BoxConstraints(
          minWidth: widget.minWidth,
          minHeight: widget.height,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isEnabled ? _fallbackColor : Colors.grey.shade700,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
            color: AppConstants.darkNavy,
            width: 2.5,
          ),
          image: DecorationImage(
            image: AssetImage(_assetImage),
            fit: BoxFit.fill,
            colorFilter: isEnabled
                ? null
                : const ColorFilter.mode(Colors.grey, BlendMode.saturation),
          ),
          boxShadow: _isPressed
              ? []
              : [
                  const BoxShadow(
                    color: AppConstants.darkNavy,
                    offset: Offset(0, 4),
                    blurRadius: 0,
                  ),
                ],
        ),
        child: Center(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (widget.icon != null) ...[
                widget.icon!,
                const SizedBox(width: 8),
              ],
              Text(
                widget.label,
                style: TextStyle(
                  fontFamily: AppConstants.pixelFont,
                  fontSize: widget.fontSize ?? 16,
                  fontWeight: FontWeight.bold,
                  color: isEnabled ? Colors.white : Colors.grey.shade400,
                  shadows: const [
                    Shadow(
                      color: AppConstants.darkNavy,
                      offset: Offset(1, 1),
                      blurRadius: 0,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
