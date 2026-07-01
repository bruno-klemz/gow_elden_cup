import 'dart:math' as math;

import 'package:flutter/material.dart';

/// A one-shot sparkle burst played when a favor is completed. Spawns a ring of
/// particles that fly outward and fade. Call [SparkleController.fire] to play.
class CompletionSparkle extends StatefulWidget {
  const CompletionSparkle({
    super.key,
    required this.controller,
    required this.color,
    this.particleCount = 14,
  });

  final SparkleController controller;
  final Color color;
  final int particleCount;

  @override
  State<CompletionSparkle> createState() => _CompletionSparkleState();
}

/// Lets a parent trigger the sparkle without owning animation state.
class SparkleController extends ChangeNotifier {
  void fire() => notifyListeners();
}

class _CompletionSparkleState extends State<CompletionSparkle>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  );

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_play);
  }

  void _play() {
    _c
      ..reset()
      ..forward();
  }

  @override
  void dispose() {
    widget.controller.removeListener(_play);
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: AnimatedBuilder(
        animation: _c,
        builder: (context, _) {
          if (_c.isDismissed) return const SizedBox.shrink();
          return CustomPaint(
            painter: _SparklePainter(
              t: _c.value,
              color: widget.color,
              count: widget.particleCount,
            ),
            size: Size.infinite,
          );
        },
      ),
    );
  }
}

class _SparklePainter extends CustomPainter {
  _SparklePainter({required this.t, required this.color, required this.count});

  final double t;
  final Color color;
  final int count;

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final maxR = size.shortestSide * 0.55;
    final paint = Paint()..color = color.withValues(alpha: (1 - t).clamp(0, 1));

    for (var i = 0; i < count; i++) {
      final angle = (i / count) * 2 * math.pi;
      final r = maxR * Curves.easeOut.transform(t);
      final p = center + Offset(math.cos(angle), math.sin(angle)) * r;
      final radius = 3.0 * (1 - t) + 1;
      canvas.drawCircle(p, radius, paint);
    }
  }

  @override
  bool shouldRepaint(_SparklePainter old) => old.t != t;
}
