import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// DEV-ONLY: tap a realm map to read a boss's relative (x,y) coordinate.
/// Not wired into the shipped app. To use temporarily, set
/// `home: const CoordPickerScreen()` in main.dart and pass a realm map image.
class CoordPickerScreen extends StatelessWidget {
  const CoordPickerScreen({super.key, this.realmMapImage});

  /// Asset path under `assets/` for the realm map to display, e.g.
  /// `images/map/midgard.webp`. Falls back to a generic placeholder when null.
  final String? realmMapImage;

  String get _mapAsset => realmMapImage != null
      ? 'assets/$realmMapImage'
      : 'assets/images/map/base_map.webp';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Coord Picker (dev)')),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return GestureDetector(
            onTapDown: (details) {
              final x = (details.localPosition.dx / constraints.maxWidth).clamp(
                0.0,
                1.0,
              );
              final y = (details.localPosition.dy / constraints.maxHeight)
                  .clamp(0.0, 1.0);
              final text =
                  '"mapCoord": { "x": ${x.toStringAsFixed(3)}, "y": ${y.toStringAsFixed(3)} }';
              debugPrint(text);
              ScaffoldMessenger.of(context)
                ..clearSnackBars()
                ..showSnackBar(SnackBar(content: Text(text)));
            },
            child: Image.asset(
              _mapAsset,
              fit: BoxFit.cover,
              width: constraints.maxWidth,
              height: constraints.maxHeight,
              errorBuilder: (context, error, stack) => const Center(
                child: Text(
                  'Mapa ausente (placeholder)',
                  style: TextStyle(color: AppColors.textMuted),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
