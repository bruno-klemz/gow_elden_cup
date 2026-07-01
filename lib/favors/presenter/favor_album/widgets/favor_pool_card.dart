import 'package:flutter/material.dart';

import '../../../../theme/app_theme.dart';
import '../../../domain/entity/favor.dart';
import '../../../../theme/realm_theme.dart';
import '../../widgets/rune_pool.dart';

/// Album card for a single favor: a 3/4 portrait "seal" that fills like a pool
/// as steps complete. Dark background with a realm-accent halo behind the rune,
/// a quest-type badge (blue = side, gold = main), and the name + step count.
class FavorPoolCard extends StatelessWidget {
  const FavorPoolCard({
    super.key,
    required this.favor,
    required this.done,
    required this.onTap,
  });

  final Favor favor;
  final int done;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = RealmTheme.of(favor.realm);
    final total = favor.stepIds.length;
    final progress = total == 0 ? 0.0 : (done / total).clamp(0.0, 1.0);
    final complete = total > 0 && done == total;

    // Border lights up with the fill: it lerps from the neutral border toward
    // the realm accent as the pool rises, and a matching glow grows with it —
    // so a card visibly "charges up" rather than only reacting at 100%.
    final borderColor = Color.lerp(AppColors.border, theme.accent, progress)!;

    return GestureDetector(
      onTap: onTap,
      child: _CardFrame(
        accent: theme.accent,
        borderColor: borderColor,
        progress: progress,
        complete: complete,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(13),
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Neutral radial vignette — depth, not tint.
              const DecoratedBox(
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    center: Alignment(0, -0.4),
                    radius: 0.95,
                    colors: [Color(0xFF141B22), Color(0xFF080B0F)],
                  ),
                ),
              ),
              // The pool fills the WHOLE card bottom-up; the rune sits in the
              // upper area and lights up as the water level rises over it.
              RunePool(
                runeAsset: theme.runeAsset,
                accent: theme.accent,
                progress: progress,
                // Rune occupies the top ~62% of the card (clear of the strip),
                // horizontally inset a touch.
                runeRect: const RelativeRect.fromLTRB(18, 16, 18, 38),
                // Waves on every grid card are costly; keep them only where
                // there's actual in-progress motion.
                showWave: progress > 0 && progress < 1,
              ),
              // Name + count strip.
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: _MetaStrip(name: favor.name, done: done, total: total),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// The card's outer frame (background, border, glow). While incomplete it
/// shows a static "charging up" border+glow scaled by [progress]. When
/// [complete] it pulses a stronger accent glow continuously, so a finished
/// favor clearly stands out in the grid — like a claimed trophy.
class _CardFrame extends StatefulWidget {
  const _CardFrame({
    required this.accent,
    required this.borderColor,
    required this.progress,
    required this.complete,
    required this.child,
  });

  final Color accent;
  final Color borderColor;
  final double progress;
  final bool complete;
  final Widget child;

  @override
  State<_CardFrame> createState() => _CardFrameState();
}

class _CardFrameState extends State<_CardFrame>
    with SingleTickerProviderStateMixin {
  AnimationController? _pulse;

  /// Creates the pulse controller on first need and starts it.
  void _startPulse() {
    _pulse ??= AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    );
    _pulse!.repeat(reverse: true);
  }

  @override
  void initState() {
    super.initState();
    if (widget.complete) _startPulse();
  }

  @override
  void didUpdateWidget(_CardFrame old) {
    super.didUpdateWidget(old);
    if (widget.complete && !(_pulse?.isAnimating ?? false)) {
      _startPulse();
    } else if (!widget.complete && (_pulse?.isAnimating ?? false)) {
      _pulse!
        ..stop()
        ..value = 0;
    }
  }

  @override
  void dispose() {
    _pulse?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.complete) {
      return DecoratedBox(
        decoration: _decoration(
          glowAlpha: 0.35 * widget.progress,
          glowBlur: 6 + 10 * widget.progress,
          width: 1,
        ),
        child: widget.child,
      );
    }
    // Completed: pulse the glow between a strong and a stronger state.
    final pulse = (_pulse ??= AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    ));
    return AnimatedBuilder(
      animation: pulse,
      builder: (context, child) {
        final t = pulse.value; // 0..1
        return DecoratedBox(
          decoration: _decoration(
            glowAlpha: 0.45 + 0.30 * t,
            glowBlur: 16 + 10 * t,
            glowSpread: 1 + 1.5 * t,
            width: 2,
          ),
          child: child,
        );
      },
      child: widget.child,
    );
  }

  BoxDecoration _decoration({
    required double glowAlpha,
    required double glowBlur,
    double glowSpread = 0,
    required double width,
  }) {
    return BoxDecoration(
      color: const Color(0xFF0A0E12),
      borderRadius: BorderRadius.circular(13),
      border: Border.all(color: widget.borderColor, width: width),
      boxShadow: (widget.complete || widget.progress > 0)
          ? [
              BoxShadow(
                color: widget.accent.withValues(alpha: glowAlpha),
                blurRadius: glowBlur,
                spreadRadius: glowSpread,
              ),
            ]
          : null,
    );
  }
}

class _MetaStrip extends StatelessWidget {
  const _MetaStrip({
    required this.name,
    required this.done,
    required this.total,
  });

  final String name;
  final int done;
  final int total;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(9, 14, 9, 9),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.transparent, Color(0xEB000000)],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            name.toUpperCase(),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: AppColors.frostLight,
              fontSize: 11,
              fontWeight: FontWeight.w800,
              height: 1.15,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            '$done / $total',
            textAlign: TextAlign.right,
            style: const TextStyle(
              color: Color(0xFFCFE2E7),
              fontSize: 10,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}
