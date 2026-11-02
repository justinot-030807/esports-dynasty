import 'package:flutter/material.dart';
import '../../core/constants.dart';

enum PixelButtonColor { green, red, yellow, neutral }

/// Procedural 3D-beveled pixel-art button with physical press feedback.
/// Replaces cropped/stretched raster sprites with razor-sharp procedural rendering.
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

  _ButtonPalette get _palette {
    switch (widget.color) {
      case PixelButtonColor.green:
        return const _ButtonPalette(
          fill: Color(0xFF22C55E),
          highlight: Color(0xFF86EFAC),
          shadow: Color(0xFF15803D),
          border: Color(0xFF0F172A),
          textColor: Colors.white,
          textShadow: Color(0xFF14532D),
        );
      case PixelButtonColor.red:
        return const _ButtonPalette(
          fill: Color(0xFFEF4444),
          highlight: Color(0xFFFCA5A5),
          shadow: Color(0xFFB91C1C),
          border: Color(0xFF0F172A),
          textColor: Colors.white,
          textShadow: Color(0xFF7F1D1D),
        );
      case PixelButtonColor.yellow:
        return const _ButtonPalette(
          fill: Color(0xFFF5B700),
          highlight: Color(0xFFFEF08A),
          shadow: Color(0xFFB45309),
          border: Color(0xFF0F172A),
          textColor: Color(0xFF1B2A49),
          textShadow: Color(0x33FFFFFF),
        );
      case PixelButtonColor.neutral:
        return const _ButtonPalette(
          fill: Color(0xFF475569),
          highlight: Color(0xFF94A3B8),
          shadow: Color(0xFF1E293B),
          border: Color(0xFF0F172A),
          textColor: Colors.white,
          textShadow: Color(0xFF0F172A),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEnabled = widget.onPressed != null;
    final palette = isEnabled
        ? _palette
        : const _ButtonPalette(
            fill: Color(0xFF334155),
            highlight: Color(0xFF64748B),
            shadow: Color(0xFF1E293B),
            border: Color(0xFF0F172A),
            textColor: Color(0xFF94A3B8),
            textShadow: Color(0xFF0F172A),
          );

    final resolvedFontSize = widget.fontSize ?? 14.0;

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
        duration: const Duration(milliseconds: 50),
        margin: EdgeInsets.only(
          top: _isPressed ? 3.0 : 0.0,
          bottom: _isPressed ? 0.0 : 3.0,
        ),
        constraints: BoxConstraints(
          minWidth: widget.minWidth,
          minHeight: widget.height,
        ),
        decoration: BoxDecoration(
          color: palette.border,
          borderRadius: BorderRadius.circular(5),
          boxShadow: _isPressed
              ? []
              : [
                  BoxShadow(
                    color: palette.border,
                    offset: const Offset(0, 3.5),
                    blurRadius: 0,
                  ),
                ],
        ),
        child: Container(
          margin: const EdgeInsets.all(2.0),
          decoration: BoxDecoration(
            color: palette.fill,
            borderRadius: BorderRadius.circular(3),
            border: Border(
              top: BorderSide(color: palette.highlight, width: 2.5),
              left: BorderSide(color: palette.highlight, width: 2.5),
              bottom: BorderSide(color: palette.shadow, width: 2.5),
              right: BorderSide(color: palette.shadow, width: 2.5),
            ),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              if (widget.icon != null) ...[
                widget.icon!,
                const SizedBox(width: 8),
              ],
              Flexible(
                child: Text(
                  widget.label,
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontFamily: AppConstants.pixelFont,
                    fontSize: resolvedFontSize,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                    color: palette.textColor,
                    shadows: [
                      Shadow(
                        color: palette.textShadow,
                        offset: const Offset(1, 1),
                        blurRadius: 0,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ButtonPalette {
  final Color fill;
  final Color highlight;
  final Color shadow;
  final Color border;
  final Color textColor;
  final Color textShadow;

  const _ButtonPalette({
    required this.fill,
    required this.highlight,
    required this.shadow,
    required this.border,
    required this.textColor,
    required this.textShadow,
  });
}
