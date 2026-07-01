import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../../theme/app_theme.dart';
import '../../../../theme/realm_theme.dart';
import '../../../domain/entity/boss.dart';
import 'main_boss_border.dart';

/// Full-screen "colar figurinha" reveal. Given the on-screen [slotRect] of the
/// freshly defeated boss's slot, it plays a cinematic peel-and-stick:
///
/// 1. sticker + white backing appear stacked and centered,
/// 2. they separate (sticker left, paper right), the paper fades away,
/// 3. a hero hold with a foil glint,
/// 4. the sticker arcs to the slot,
/// 5. it lands flat and adheres bottom-to-top (a clip reveal with a glue line),
/// 6. a settle bounce and a golden sparkle burst.
///
/// The widget positions itself; the caller only supplies the slot rect (in the
/// overlay's own coordinate space) and the boss. [onDone] fires once the whole
/// sequence completes so the caller can clear the reveal state.
class StickerRevealOverlay extends StatefulWidget {
  const StickerRevealOverlay({
    super.key,
    required this.boss,
    required this.slotRect,
    required this.onDone,
  });

  final Boss boss;

  /// Destination slot rectangle, in the overlay's local coordinates.
  final Rect slotRect;

  final VoidCallback onDone;

  @override
  State<StickerRevealOverlay> createState() => _StickerRevealOverlayState();
}

class _StickerRevealOverlayState extends State<StickerRevealOverlay>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 3050),
  );

  // Phase intervals over the single 0..1 timeline. Kept as fields so the build
  // logic reads like the storyboard.
  static const _popIn = Interval(0.00, 0.10, curve: Curves.easeOutBack);
  static const _separate = Interval(0.10, 0.26, curve: Curves.easeOutCubic);
  static const _paperOut = Interval(0.26, 0.38, curve: Curves.easeIn);
  static const _recentre = Interval(0.26, 0.40, curve: Curves.easeOutBack);
  static const _hero = Interval(0.40, 0.52);
  static const _fly = Interval(0.52, 0.74, curve: Curves.easeInOutCubic);
  static const _glue = Interval(0.74, 0.90, curve: Curves.easeInOut);
  static const _settle = Interval(0.90, 1.00, curve: Curves.easeOut);

  @override
  void initState() {
    super.initState();
    _c.forward().whenComplete(widget.onDone);
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  double _t(Interval i) => i.transform(_c.value);

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _c,
      builder: (context, _) => LayoutBuilder(
        builder: (context, constraints) => _frame(constraints.biggest),
      ),
    );
  }

  Widget _frame(Size size) {
    final slot = widget.slotRect;

    // The "big" centered sticker footprint, sized off screen width and kept in
    // 3:4 like the slots.
    final bigW = size.width * 0.60;
    final bigH = bigW * 4 / 3;
    final centre = Offset(size.width / 2, size.height * 0.40);
    final bigRect = Rect.fromCenter(center: centre, width: bigW, height: bigH);

    // ---- current sticker rect (centre while peeling/hero, then flies) ----
    final flyT = _t(_fly);
    Rect rect;
    if (_c.value < _fly.begin) {
      rect = bigRect;
    } else if (_c.value < _glue.begin) {
      // arc: interpolate centre->slot with a raised apex, shrinking to slot size
      final from = bigRect;
      final to = slot;
      final r = Rect.lerp(from, to, flyT)!;
      final arcLift = math.sin(flyT * math.pi) * size.height * 0.10;
      rect = r.translate(0, -arcLift);
    } else {
      rect = slot;
    }

    final children = <Widget>[];

    // dashed socket at the slot showing where it lands, until glue starts
    if (_c.value < _glue.begin) {
      children.add(Positioned.fromRect(rect: slot, child: _socket()));
    }

    // ---- separation phase: sticker slides left, white paper slides right ----
    final sep = _t(_separate);
    final gap = bigW * 0.34 * sep;

    // white backing paper (only visible until it fades out)
    final paperOpacity = _c.value < _paperOut.begin ? 1.0 : (1 - _t(_paperOut));
    if (paperOpacity > 0.01 && _c.value < _fly.begin) {
      children.add(
        Positioned.fromRect(
          rect: bigRect.translate(gap, 0),
          child: Opacity(
            opacity: paperOpacity.clamp(0.0, 1.0),
            child: Transform.rotate(
              angle: 0.07 * sep + (paperOpacity < 1 ? 0.05 : 0),
              child: const _BackingPaper(),
            ),
          ),
        ),
      );
    }

    // ---- the sticker itself ----
    children.add(
      Positioned.fromRect(
        rect: _c.value < _fly.begin ? bigRect.translate(-gap, 0) : rect,
        child: _sticker(size),
      ),
    );

    // ---- sparkle burst on settle ----
    if (_c.value >= _settle.begin) {
      children.add(
        Positioned.fromRect(
          rect: slot.inflate(slot.width),
          child: IgnorePointer(
            child: CustomPaint(painter: _SparkleBurst(_t(_settle))),
          ),
        ),
      );
    }

    return Stack(clipBehavior: Clip.none, children: children);
  }

  Widget _socket() => DecoratedBox(
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(8),
      border: Border.all(
        color: AppColors.frost.withValues(alpha: 0.45),
        width: 1.5,
      ),
    ),
  );

  Widget _sticker(Size size) {
    final popIn = _t(_popIn);
    final scale = _c.value < _popIn.end
        ? Tween(begin: 0.6, end: 1.0).transform(popIn)
        : 1.0;

    // separation tilt (slides left with a small rotation), settling bounce
    final sep = _t(_separate);
    final recentre = _t(_recentre);
    double angle = 0;
    if (_c.value >= _separate.begin && _c.value < _recentre.end) {
      // rotate out during separation, then back to 0 as it recentres
      angle = -0.05 * sep * (1 - recentre);
    }

    // settle squash/stretch near the very end
    double settleScale = 1.0;
    if (_c.value >= _settle.begin) {
      final s = _t(_settle);
      // 1 -> 1.06 -> 1 bump
      settleScale = 1 + math.sin(s * math.pi) * 0.06;
    }

    // bottom-up glue reveal: clip fraction from bottom
    final glueT = _t(_glue);
    final revealed = _c.value < _glue.begin
        ? (_c.value < _fly.begin ? 1.0 : 0.0) // fully shown before flying
        : glueT;

    Widget card = _StickerCard(
      boss: widget.boss,
      // corner curl only shows during the trigger of separation
      curl: _c.value >= _separate.begin && _c.value < _paperOut.begin
          ? (1 - sep).clamp(0.0, 1.0)
          : 0.0,
      glint: _c.value >= _hero.begin && _c.value < _hero.end ? _t(_hero) : 0.0,
    );

    // During glue, clip the card so it adheres bottom -> top, with a glue line.
    if (_c.value >= _glue.begin && _c.value < _settle.begin) {
      card = _GlueReveal(revealed: revealed, child: card);
    }

    return Transform.scale(
      scale: scale * settleScale,
      child: Transform.rotate(angle: angle, child: card),
    );
  }
}

/// The peel-off white backing sheet: a glossy white card with a dashed die-cut
/// silhouette where the sticker used to sit.
class _BackingPaper extends StatelessWidget {
  const _BackingPaper();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFFFFFFF), Color(0xFFEEF0F2), Color(0xFFD9DDE1)],
          stops: [0, 0.55, 1],
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x73000000),
            blurRadius: 22,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(5),
        child: DottedRoundedBorder(color: const Color(0x807A8590), radius: 7),
      ),
    );
  }
}

/// The sticker in flight. It wears its FINAL frame the whole time — the living
/// [MainBossBorder] for a headline boss, or the discreet brown frame otherwise
/// — so nothing swaps color when it glues into the slot. On top sits the boss
/// art, a foil glint, and an optional lifted corner curl while peeling.
class _StickerCard extends StatelessWidget {
  const _StickerCard({required this.boss, this.curl = 0, this.glint = 0});

  final Boss boss;

  /// 0..1 size of the peeling corner curl (bottom-right).
  final double curl;

  /// 0..1 progress of the foil glint sweep.
  final double glint;

  @override
  Widget build(BuildContext context) {
    // Main boss wears the living frame (which clips the art itself); a regular
    // boss gets the discreet brown frame.
    if (boss.isMainBoss) {
      // Tint the living frame with the boss's realm accent so it matches the
      // album slot exactly when the sticker glues home.
      return MainBossBorder(
        accent: RealmTheme.of(boss.realm).accent,
        child: _artStack(),
      );
    }
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(kSlotRadius),
        border: Border.all(color: const Color(0xFF4A3C2A), width: 1),
        boxShadow: const [
          BoxShadow(
            color: Color(0x33000000),
            blurRadius: 24,
            offset: Offset(0, 12),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(kSlotRadius - 1),
        child: _artStack(),
      ),
    );
  }

  Widget _artStack() => Stack(
    fit: StackFit.expand,
    children: [
      Image.asset(
        'assets/${boss.art}',
        fit: BoxFit.cover,
        alignment: const Alignment(0, -0.6),
        errorBuilder: (context, error, stack) =>
            Container(color: AppColors.surfaceAlt),
      ),
      if (glint > 0) _GlintSweep(progress: glint),
      if (curl > 0)
        Align(
          alignment: Alignment.bottomRight,
          child: FractionallySizedBox(
            widthFactor: 0.42 * curl,
            heightFactor: 0.42 * curl,
            child: DecoratedBox(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFFFFFDF6), Color(0xFFCFC4A8)],
                ),
                boxShadow: [
                  BoxShadow(
                    color: Color(0x59000000),
                    blurRadius: 8,
                    offset: Offset(-3, -3),
                  ),
                ],
              ),
            ),
          ),
        ),
    ],
  );
}

/// A diagonal light band sweeping across the sticker (foil shimmer).
class _GlintSweep extends StatelessWidget {
  const _GlintSweep({required this.progress});
  final double progress;

  @override
  Widget build(BuildContext context) {
    // move a bright diagonal band from -1..1 across the card
    final x = -1.0 + progress * 2;
    return IgnorePointer(
      child: FractionalTranslation(
        translation: Offset(x, 0),
        child: DecoratedBox(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0x00FFFFFF), Color(0xBFFFFFFF), Color(0x00FFFFFF)],
              stops: [0.35, 0.5, 0.65],
            ),
          ),
        ),
      ),
    );
  }
}

/// Reveals [child] from the bottom up by [revealed] (0..1), painting a bright
/// "glue line" at the current frontier.
class _GlueReveal extends StatelessWidget {
  const _GlueReveal({required this.revealed, required this.child});
  final double revealed;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      clipBehavior: Clip.none,
      children: [
        ClipRect(clipper: _BottomUpClipper(revealed), child: child),
        // glue line at the frontier
        Align(
          alignment: Alignment(0, 1 - 2 * revealed),
          child: FractionallySizedBox(
            widthFactor: 1.04,
            heightFactor: 0.05,
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.white.withValues(alpha: 0.9),
                    AppColors.frostLight,
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// Clips to the bottom [revealed] fraction of the box (reveal grows upward).
class _BottomUpClipper extends CustomClipper<Rect> {
  const _BottomUpClipper(this.revealed);
  final double revealed;

  @override
  Rect getClip(Size size) =>
      Rect.fromLTRB(0, size.height * (1 - revealed), size.width, size.height);

  @override
  bool shouldReclip(_BottomUpClipper old) => old.revealed != revealed;
}

/// A rounded-rect dashed border (die-cut silhouette on the backing paper).
class DottedRoundedBorder extends StatelessWidget {
  const DottedRoundedBorder({super.key, required this.color, this.radius = 7});
  final Color color;
  final double radius;

  @override
  Widget build(BuildContext context) => CustomPaint(
    painter: _DashedRRectPainter(color, radius),
    child: const SizedBox.expand(),
  );
}

class _DashedRRectPainter extends CustomPainter {
  _DashedRRectPainter(this.color, this.radius);
  final Color color;
  final double radius;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    final rrect = RRect.fromRectAndRadius(
      Offset.zero & size,
      Radius.circular(radius),
    );
    final path = Path()..addRRect(rrect);
    const dash = 5.0, gap = 4.0;
    for (final metric in path.computeMetrics()) {
      var dist = 0.0;
      while (dist < metric.length) {
        canvas.drawPath(metric.extractPath(dist, dist + dash), paint);
        dist += dash + gap;
      }
    }
  }

  @override
  bool shouldRepaint(_DashedRRectPainter old) =>
      old.color != color || old.radius != radius;
}

/// Golden particle burst radiating from the centre, driven by [t] (0..1).
class _SparkleBurst extends CustomPainter {
  _SparkleBurst(this.t);
  final double t;

  static const _count = 12;

  @override
  void paint(Canvas canvas, Size size) {
    final centre = size.center(Offset.zero);
    final maxDist = size.shortestSide * 0.42;
    for (var i = 0; i < _count; i++) {
      final ang = (math.pi * 2 * i) / _count + i * 0.7;
      final dist = maxDist * Curves.easeOut.transform(t);
      final pos = centre + Offset(math.cos(ang), math.sin(ang)) * dist;
      final radius = (1 - t) * 3.5 + 1;
      final paint = Paint()
        ..color = (i.isEven ? Colors.white : AppColors.frostLight).withValues(
          alpha: (1 - t).clamp(0.0, 1.0),
        );
      canvas.drawCircle(pos, radius, paint);
    }
  }

  @override
  bool shouldRepaint(_SparkleBurst old) => old.t != t;
}
