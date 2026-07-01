import 'package:flutter/material.dart';
import '../../../domain/entity/boss.dart';
import '../../../../shared/widgets/pending_art.dart';
import '../../../../theme/app_theme.dart';
import 'main_boss_border.dart';
import 'type_badge.dart';

class StickerSlot extends StatelessWidget {
  const StickerSlot({
    super.key,
    required this.boss,
    required this.defeated,
    required this.onTap,
    this.accent = AppColors.frost,
    this.isMain = false,
    this.revealing = false,
    this.onQuickDefeat,
  });

  final Boss boss;
  final bool defeated;
  final VoidCallback onTap;

  /// The realm's accent — tints the living main-boss frame and its name so a
  /// headline boss reads as belonging to its realm. Regular slots ignore it.
  final Color accent;

  /// Headline boss of its realm. When defeated, it gets the living
  /// [MainBossBorder] (a thick, breathing frame in the realm's accent) instead
  /// of the discreet border regular slots use. While pending it looks like any
  /// other slot.
  final bool isMain;

  /// True while the full-screen peel-and-stick overlay is playing for this
  /// boss. The slot keeps its pending look so the sticker only appears to
  /// "stick" once the overlay hands back (defeated art shows afterwards).
  final bool revealing;

  /// Quick-check shortcut shown on pending slots; marks the boss defeated
  /// without opening the details screen.
  final VoidCallback? onQuickDefeat;

  @override
  Widget build(BuildContext context) {
    // While the overlay is playing for this boss, keep the pending look — the
    // sticker only "sticks" once the overlay finishes and revealing clears.
    final showColored = defeated && !revealing;
    final isMainDone = isMain && showColored;

    // Raw card content (art + overlays). MainBossBorder clips it to its own
    // inner radius; the regular frame clips it to the slot radius.
    final content = Stack(
      fit: StackFit.expand,
      children: [
        _artLayer(showColored),
        _nameStrip(showColored, isMainDone),
        if (showColored)
          Positioned(top: 4, right: 4, child: TypeBadge(type: boss.type)),
        // No quick-check while the reveal overlay is mid-flight.
        if (!showColored && !revealing && onQuickDefeat != null)
          _quickCheckButton(),
      ],
    );

    return GestureDetector(
      onTap: onTap,
      child: AspectRatio(
        aspectRatio: 3 / 4,
        child: isMainDone
            ? MainBossBorder(accent: accent, child: content)
            : _regularFrame(
                showColored,
                ClipRRect(
                  borderRadius: BorderRadius.circular(kSlotRadius),
                  child: content,
                ),
              ),
      ),
    );
  }

  /// Discreet static frame for regular slots (brown once defeated, dim while
  /// pending). Gold is reserved for main bosses.
  Widget _regularFrame(bool showColored, Widget child) => Container(
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(kSlotRadius),
      border: Border.all(
        color: showColored ? const Color(0xFF4A3C2A) : AppColors.border,
        width: 1,
      ),
    ),
    child: child,
  );

  /// A single static art layer: colored once defeated (and not mid-reveal),
  /// otherwise the pending treatment. The peel-and-stick animation lives in the
  /// full-screen [StickerRevealOverlay], not here.
  Widget _artLayer(bool showColored) =>
      showColored ? _coloredArt() : _pendingArt();

  Widget _coloredArt() => Image.asset(
    'assets/${boss.art}',
    fit: BoxFit.cover,
    alignment: const Alignment(0, -0.6),
    errorBuilder: (context, error, stack) =>
        Container(color: AppColors.surfaceAlt),
  );

  Widget _pendingArt() =>
      PendingArt(art: boss.art, blurSigma: 6, grayscale: true, darken: 0.45);

  Widget _nameStrip(bool showColored, bool isMainDone) => Positioned(
    bottom: 0,
    left: 0,
    right: 0,
    child: Container(
      padding: const EdgeInsets.fromLTRB(3, 12, 3, 4),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.transparent, Colors.black.withValues(alpha: 0.9)],
        ),
      ),
      child: Text(
        boss.name.toUpperCase(),
        textAlign: TextAlign.center,
        style: AppText.slotName.copyWith(
          color: isMainDone
              // The realm accent, lightened so it stays legible on the strip.
              ? shade(accent, dl: 0.25)
              : showColored
              ? const Color(0xFFCBB88A) // muted gold for regulars
              : const Color(0xFF9A8A66),
        ),
      ),
    ),
  );

  Widget _quickCheckButton() => Positioned(
    top: 4,
    right: 4,
    child: GestureDetector(
      onTap: onQuickDefeat,
      child: CustomPaint(
        key: const Key('slot-quick-check'),
        painter: _DashedCirclePainter(),
        child: Container(
          width: 28,
          height: 28,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: AppColors.background.withValues(alpha: 0.55),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.add, size: 18, color: AppColors.frostLight),
        ),
      ),
    ),
  );
}

/// Draws a dashed gold ring — signals "empty, tap to fill" (an action), not a
/// filled status badge.
class _DashedCirclePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.frost
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    final center = size.center(Offset.zero);
    final radius = size.shortestSide / 2 - 0.75;
    const dashCount = 16;
    const sweep = 2 * 3.1415926 / dashCount;
    for (var i = 0; i < dashCount; i++) {
      final start = i * sweep;
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        start,
        sweep * 0.55, // dash vs gap ratio
        false,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
