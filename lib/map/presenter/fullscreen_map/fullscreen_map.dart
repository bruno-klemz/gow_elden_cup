import 'package:flutter/material.dart';
import '../../../album/domain/entity/boss.dart';
import '../../../theme/app_theme.dart';

/// Fallback asset path when a realm has no dedicated map image.
const _kFallbackMap = 'assets/images/placeholder.webp';

class FullscreenMap extends StatelessWidget {
  const FullscreenMap({
    super.key,
    required this.boss,
    required this.realmMapImage,
  });

  final Boss boss;

  /// Realm-specific map image path (e.g. `images/map/midgard.webp`), or null
  /// to fall back to the generic placeholder map.
  final String? realmMapImage;

  String get _mapAsset =>
      realmMapImage != null ? 'assets/$realmMapImage' : _kFallbackMap;

  static Future<void> show(
          BuildContext context, Boss boss, {String? realmMapImage}) =>
      Navigator.of(context).push(MaterialPageRoute(
          fullscreenDialog: true,
          builder: (_) =>
              FullscreenMap(boss: boss, realmMapImage: realmMapImage)));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D0A07),
      body: Stack(
        children: [
          Positioned.fill(
            child: InteractiveViewer(
              minScale: 0.8,
              maxScale: 5,
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return Stack(
                    children: [
                      Image.asset(_mapAsset,
                          fit: BoxFit.cover,
                          width: constraints.maxWidth,
                          height: constraints.maxHeight,
                          errorBuilder: (context, error, stack) =>
                              Container(color: const Color(0xFF14201A))),
                      Positioned(
                        left: boss.mapCoord.x * constraints.maxWidth - 14,
                        top: boss.mapCoord.y * constraints.maxHeight - 28,
                        child: const Text('📍',
                            style: TextStyle(fontSize: 28)),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(children: [
                IconButton(
                  icon:
                      const Icon(Icons.close, color: AppColors.goldLight),
                  onPressed: () => Navigator.of(context).pop(),
                ),
                Text('Localização de ${boss.name}',
                    style: const TextStyle(
                        color: AppColors.goldLight,
                        fontWeight: FontWeight.w800,
                        fontSize: 15)),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}
