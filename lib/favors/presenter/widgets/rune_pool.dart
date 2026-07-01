import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

/// Fills its whole box bottom-up like a pool of water, and lights up a rune as
/// the water rises over it.
///
/// The water rises from the box bottom to [progress] of the box height — so on
/// a tall card, low progress only wets the base and the rune (sitting higher
/// up) stays dry until the level reaches it. The rune is drawn twice, pinned to
/// the same [runeRect]: a dry desaturated copy, and a full-colour copy revealed
/// only below the waterline. A soft wave ripples along the surface.
///
/// This is the shared primitive for both the album card (rectangular box) and
/// the detail seal (circular box, via a [ClipOval] wrapper).
class RunePool extends StatefulWidget {
  const RunePool({
    super.key,
    required this.runeAsset,
    required this.accent,
    required this.progress,
    required this.runeRect,
    this.showWave = true,
  });

  final String runeAsset;
  final Color accent;

  /// Fraction of the whole box filled, 0..1.
  final double progress;

  /// Where the rune sits inside the box, as pixel insets from each edge. The
  /// pool fills the entire box; this only positions the rune within it.
  final RelativeRect runeRect;

  /// Whether the surface ripples. Disable in dense grids to save battery.
  final bool showWave;

  @override
  State<RunePool> createState() => _RunePoolState();
}

class _RunePoolState extends State<RunePool> with TickerProviderStateMixin {
  late final AnimationController _wave;

  /// 0 while incomplete, animates to 1 on completion — drives the water toward
  /// a vivid, saturated colour so a finished favor's pool "comes alive".
  late final AnimationController _complete;

  bool get _isComplete => widget.progress >= 1.0;

  @override
  void initState() {
    super.initState();
    _wave = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    );
    if (widget.showWave) _wave.repeat();

    _complete = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
      value: _isComplete ? 1 : 0,
    );
  }

  @override
  void didUpdateWidget(RunePool old) {
    super.didUpdateWidget(old);
    if (widget.showWave && !_wave.isAnimating) {
      _wave.repeat();
    } else if (!widget.showWave && _wave.isAnimating) {
      _wave.stop();
    }
    if (_isComplete &&
        _complete.status != AnimationStatus.forward &&
        _complete.value != 1) {
      _complete.forward();
    } else if (!_isComplete && _complete.value != 0) {
      _complete.reverse();
    }
  }

  @override
  void dispose() {
    _wave.dispose();
    _complete.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final p = widget.progress.clamp(0.0, 1.0);

    Widget rune({required bool lit}) => Positioned.fromRelativeRect(
      rect: widget.runeRect,
      child: lit
          ? Image.asset(widget.runeAsset, fit: BoxFit.contain)
          : ColorFiltered(
              colorFilter: const ColorFilter.matrix(_desaturateDim),
              child: Image.asset(widget.runeAsset, fit: BoxFit.contain),
            ),
    );

    return Stack(
      fit: StackFit.expand,
      children: [
        // Dry rune (desaturated) — the "unfilled" state, whole rune.
        rune(lit: false),
        // Water body + lit rune, both clipped to the waterline over the BOX.
        ClipRect(
          clipper: _WaterClipper(p),
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Water body: brighter near the surface, deeper below, for
              // volume and a clear "liquid" read. On completion it animates
              // toward a vivid, more opaque colour.
              AnimatedBuilder(
                animation: _complete,
                builder: (context, _) {
                  final t = _complete.value;
                  final vivid = _vivid(widget.accent);
                  final bottom = Color.lerp(
                    widget.accent.withValues(alpha: 0.60),
                    vivid.withValues(alpha: 0.82),
                    t,
                  )!;
                  final top = Color.lerp(
                    widget.accent.withValues(alpha: 0.40),
                    vivid.withValues(alpha: 0.60),
                    t,
                  )!;
                  return DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                        colors: [bottom, top],
                      ),
                    ),
                  );
                },
              ),
              // Accent glow behind the submerged rune so the lit part reads as
              // "energised", not just recoloured.
              _RuneGlow(rect: widget.runeRect, color: widget.accent),
              rune(lit: true),
            ],
          ),
        ),
        // Rippling surface line at the box's waterline.
        if (p > 0 && p < 1)
          AnimatedBuilder(
            animation: _wave,
            builder: (context, _) => CustomPaint(
              painter: _SurfacePainter(
                progress: p,
                phase: _wave.value,
                color: widget.accent,
              ),
            ),
          ),
      ],
    );
  }

  /// A more saturated, slightly brighter version of [c] — the "alive" water
  /// colour used once a favor is complete.
  ///
  /// The saturation boost scales with how colourful [c] already is, so a
  /// near-white accent (e.g. Midgard/Asgard) stays white and just brightens,
  /// while a vivid accent pops fully.
  static Color _vivid(Color c) {
    final hsl = HSLColor.fromColor(c);
    final boost = 0.35 * hsl.saturation; // proportional, so grays stay gray
    return hsl
        .withSaturation((hsl.saturation + boost).clamp(0.0, 1.0))
        .withLightness((hsl.lightness + 0.08).clamp(0.0, 1.0))
        .toColor();
  }

  // Greyscale + dim, applied to the dry rune.
  static const List<double> _desaturateDim = <double>[
    0.13, 0.27, 0.04, 0, 0, //
    0.13, 0.27, 0.04, 0, 0, //
    0.13, 0.27, 0.04, 0, 0, //
    0, 0, 0, 1, 0, //
  ];
}

/// Clips to the bottom [progress] fraction of the box (the submerged region).
class _WaterClipper extends CustomClipper<Rect> {
  _WaterClipper(this.progress);
  final double progress;

  @override
  Rect getClip(Size size) =>
      Rect.fromLTRB(0, size.height * (1 - progress), size.width, size.height);

  @override
  bool shouldReclip(_WaterClipper old) => old.progress != progress;
}

/// Draws the waterline as a bright rippling crest plus a soft "foam" glow band
/// just below it, so the surface reads clearly and feels alive.
class _SurfacePainter extends CustomPainter {
  _SurfacePainter({
    required this.progress,
    required this.phase,
    required this.color,
  });

  final double progress;
  final double phase;
  final Color color;

  static const _amplitude = 4.0;

  /// The wave's vertical offset at [x] for the current phase.
  double _waveY(double x, double width) {
    // Two summed sines at different frequencies for a livelier, less regular
    // crest than a single sine.
    final shift = phase * 2 * math.pi;
    final a = math.sin((x / width) * 2 * math.pi + shift);
    final b = 0.4 * math.sin((x / width) * 4 * math.pi - shift * 1.5);
    return (a + b) * _amplitude;
  }

  @override
  void paint(Canvas canvas, Size size) {
    final y = size.height * (1 - progress);

    // Build the crest path once, reused for the foam band and the line.
    final crest = Path()..moveTo(0, y + _waveY(0, size.width));
    for (double x = 0; x <= size.width; x += 3) {
      crest.lineTo(x, y + _waveY(x, size.width));
    }

    // Foam glow band: fill from the crest down a short distance, fading out.
    final foamHeight = (size.height * 0.10).clamp(8.0, 26.0);
    final foam = Path.from(crest)
      ..lineTo(size.width, y + foamHeight)
      ..lineTo(0, y + foamHeight)
      ..close();
    canvas.drawPath(
      foam,
      Paint()
        ..shader = ui.Gradient.linear(Offset(0, y), Offset(0, y + foamHeight), [
          color.withValues(alpha: 0.55),
          color.withValues(alpha: 0.0),
        ])
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3),
    );

    // Bright crest line.
    canvas.drawPath(
      crest,
      Paint()
        ..color = _lighten(color)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 1.5),
    );
  }

  static Color _lighten(Color c) => Color.lerp(c, Colors.white, 0.35)!;

  @override
  bool shouldRepaint(_SurfacePainter old) =>
      old.progress != progress || old.phase != phase;
}

/// A soft accent glow centred on the rune's box — sits behind the lit (wet)
/// rune to make the submerged part read as "energised".
class _RuneGlow extends StatelessWidget {
  const _RuneGlow({required this.rect, required this.color});

  final RelativeRect rect;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Positioned.fromRelativeRect(
      rect: rect,
      child: DecoratedBox(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(color: color.withValues(alpha: 0.45), blurRadius: 22),
          ],
          gradient: RadialGradient(
            colors: [color.withValues(alpha: 0.30), Colors.transparent],
          ),
        ),
      ),
    );
  }
}
