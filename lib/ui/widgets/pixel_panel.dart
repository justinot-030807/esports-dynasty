import 'package:flutter/material.dart';
import '../../core/constants.dart';
import '../../core/asset_manager.dart';

class PixelPanel extends StatelessWidget {
  final String? title;
  final Widget child;
  final double? width;
  final double? height;
  final EdgeInsets padding;
  final VoidCallback? onClose;

  const PixelPanel({
    super.key,
    this.title,
    required this.child,
    this.width,
    this.height,
    this.padding = const EdgeInsets.all(16.0),
    this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    final screenW = MediaQuery.sizeOf(context).width;
    final dialogW = width ?? (screenW * 0.92).clamp(320.0, 420.0);
    return Container(
      width: dialogW,
      height: height,
      decoration: BoxDecoration(
        color: AppConstants.panelLight,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: AppConstants.darkNavy,
          width: 3.5,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x66000000),
            offset: Offset(4, 6),
            blurRadius: 0,
          ),
        ],
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Background nine-patch panel image if available
          Positioned.fill(
            child: Opacity(
              opacity: 0.15,
              child: Image.asset(
                AssetManager.panel,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => const SizedBox.shrink(),
              ),
            ),
          ),

          // Content
          Padding(
            padding: EdgeInsets.only(
              top: title != null ? 36.0 : padding.top,
              left: padding.left,
              right: padding.right,
              bottom: padding.bottom,
            ),
            child: child,
          ),

          // Title Ribbon
          if (title != null)
            Positioned(
              top: -14,
              left: 20,
              right: 20,
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppConstants.darkNavy,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: AppConstants.moneyGold,
                      width: 2.0,
                    ),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black38,
                        offset: Offset(0, 3),
                        blurRadius: 0,
                      ),
                    ],
                  ),
                  child: Text(
                    title!,
                    style: const TextStyle(
                      fontFamily: AppConstants.pixelFont,
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: AppConstants.moneyGold,
                      letterSpacing: 0.8,
                    ),
                  ),
                ),
              ),
            ),

          // Close button
          if (onClose != null)
            Positioned(
              top: 6,
              right: 8,
              child: GestureDetector(
                onTap: onClose,
                child: Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: AppConstants.negativeRed,
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: AppConstants.darkNavy, width: 2),
                  ),
                  child: const Center(
                    child: Text(
                      'X',
                      style: TextStyle(
                        fontFamily: AppConstants.pixelFont,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
