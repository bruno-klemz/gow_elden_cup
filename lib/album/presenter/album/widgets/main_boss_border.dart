import 'package:flutter/material.dart';
import '../../../../theme/app_theme.dart';

/// Card corner radius shared by the slot frame and the reveal overlay.
const double kSlotRadius = 10;

/// Thickness of the living main-boss border (shared so slot and overlay match).
const double kMainBorderWidth = 6;

/// Thin dark ring between the frost frame and the art. It seats the photo
/// *inside* the frame (not floating on top) and, crucially, keeps the boss art
/// from bleeding into the frost border.
const double _kMatteWidth = 2.5;

/// A living, breathing border reserved for defeated **main** bosses. A thick
/// frost gradient (ice-white -> frost -> deep blue) frames the card and pulses
/// in brightness + glow, so the headline boss reads as special at a glance.
///
/// The frame nests the art with a thin dark matte ring plus an inner shadow, so
/// the photo reads as sunk *into* the frame and never blends with it.
///
/// Pulsation was chosen over a rotating gradient because it repaints far
/// cheaper inside a scrolling grid. The same widget is used by the album slot
/// and by the reveal overlay's final card, so the border matches exactly and
/// never "swaps" color when the sticker lands. The widget clips [child] itself
/// at the correct inner radius — pass the raw art, unclipped.
class MainBossBorder extends StatefulWidget {
  const MainBossBorder({
    super.key,
    required this.child,
    this.accent = AppColors.frost,
    this.width = kMainBorderWidth,
    this.radius = kSlotRadius + kMainBorderWidth,
    this.period = const Duration(milliseconds: 4000),
  });

  final Widget child;

  /// Base colour the living frame is tinted with — the realm's accent, so the
  /// headline boss reads as belonging to its realm. The vibrant/resting/glow
  /// tones are all derived from this in [_MainBossBorderState].
  final Color accent;

  /// Border thickness in logical pixels.
  final double width;

  /// Outer corner radius.
  final double radius;

  /// Full breathe cycle duration.
  final Duration period;

  /// Radius the art ends up clipped to, once inside frame + matte ring.
  double get innerRadius => (radius - width - _kMatteWidth).clamp(0.0, radius);

  @override
  State<MainBossBorder> createState() => _MainBossBorderState();
}

class _MainBossBorderState extends State<MainBossBorder>
    with TickerProviderStateMixin {
  /// The living frame's five-stop gradient at the breath's VIBRANT peak,
  /// derived from [MainBossBorder.accent]: bright at the corners (accent
  /// lightened), the pure accent through the middle, a deeper accent at the
  /// centre. The Ragnarök frost blue is just the default accent.
  List<Color> get _hot {
    final a = widget.accent;
    final bright = shade(a, dl: 0.22);
    final deep = shade(a, dl: -0.16);
    return [bright, a, deep, a, bright];
  }

  /// Same shape as [_hot] but DIMMED + slightly desaturated — the resting/low
  /// point of the breath. Pulsing between dim and hot reads as the frame
  /// flaring up (brighter), never washing out.
  List<Color> get _dim {
    final a = shade(widget.accent, dl: -0.1, satFactor: 0.85);
    final bright = shade(a, dl: 0.1);
    final deep = shade(a, dl: -0.16);
    return [bright, a, deep, a, bright];
  }

  /// Glow colour: the accent lightened a touch so the halo reads as a soft
  /// bloom of the realm's colour.
  Color get _glow => shade(widget.accent, dl: 0.12);

  // Breathing pulse for the border (bounces 0 -> 1 -> 0), eased for a natural
  // in/out. Drives brightness + glow.
  late final AnimationController _pulse = AnimationController(
    vsync: this,
    duration: widget.period,
  )..repeat(reverse: true);
  late final Animation<double> _breath = CurvedAnimation(
    parent: _pulse,
    curve: Curves.easeInOut,
  );

  // Monotonic 0 -> 1 loop that sweeps the interior glint across the card.
  late final AnimationController _sweep = AnimationController(
    vsync: this,
    duration: widget.period,
  )..repeat();

  @override
  void dispose() {
    _pulse.dispose();
    _sweep.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([_pulse, _sweep]),
      builder: (context, child) {
        // Breathe: 0 -> 1 -> 0 (eased). The palette swings from DIM to HOT so
        // the pulse makes the frame flare up (more vibrant), never wash out.
        final t = _breath.value;
        final hot = _hot;
        final dim = _dim;
        final colors = [
          for (var i = 0; i < hot.length; i++) Color.lerp(dim[i], hot[i], t)!,
        ];
        final glowAlpha = 0.2 + t * 0.55; // 0.20 .. 0.75
        final glowBlur = 5 + t * 27; // 5 .. 32
        final glowSpread = t * 2.5; // 0 .. 2.5

        final innerRadius = widget.innerRadius;

        return DecoratedBox(
          // outer frost frame (pulsing) + glow
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(widget.radius),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: colors,
            ),
            boxShadow: [
              BoxShadow(
                color: _glow.withValues(alpha: glowAlpha),
                blurRadius: glowBlur,
                spreadRadius: glowSpread,
              ),
            ],
          ),
          child: Padding(
            padding: EdgeInsets.all(widget.width),
            // thin dark matte ring: separates art from the frost frame
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(innerRadius + _kMatteWidth),
              ),
              child: Padding(
                padding: const EdgeInsets.all(_kMatteWidth),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(innerRadius),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      child!,
                      // inner edge shadow: a dark vignette hugging the edges,
                      // sinking the photo into the frame (works over any art)
                      const IgnorePointer(
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            gradient: RadialGradient(
                              radius: 0.9,
                              colors: [Color(0x00000000), Color(0x59000000)],
                              stops: [0.72, 1.0],
                            ),
                          ),
                        ),
                      ),
                      // foil glint sweeping across the interior once per cycle
                      _Glint(progress: _sweep.value),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
      child: widget.child,
    );
  }
}

/// A soft diagonal shine that slides across the card — a faithful port of the
/// approved mockup, where a NARROW bright band travels through a wider gradient
/// (not the whole card moving). [progress] is a monotonic 0..1 over the cycle;
/// the band sweeps during the first ~60% (eased in/out) then rests off-screen,
/// so it reads as a gentle glint rather than a mirror crossing the whole card.
class _Glint extends StatelessWidget {
  const _Glint({required this.progress});
  final double progress;

  /// Fraction of the cycle the band is travelling (then it rests).
  static const _sweep = 0.6;

  @override
  Widget build(BuildContext context) {
    if (progress > _sweep) return const SizedBox.shrink();

    // eased travel of the band's centre from off-left (-0.3) to off-right (1.3)
    final p = Curves.easeInOut.transform((progress / _sweep).clamp(0.0, 1.0));
    final centre = -0.3 + p * 1.6;

    // a narrow bright slice (~14% wide) centred on `centre`, transparent
    // elsewhere — this is the band that slides, not the whole box
    const half = 0.07;
    final a = (centre - half).clamp(0.0, 1.0);
    final b = centre.clamp(0.0, 1.0);
    final c = (centre + half).clamp(0.0, 1.0);
    final stops = <double>[0, a, b, c, 1];

    return IgnorePointer(
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: const [
              Color(0x00FFFFFF),
              Color(0x00FFFFFF),
              Color(0x4DFFFFFF), // ~30% white at the band's core
              Color(0x00FFFFFF),
              Color(0x00FFFFFF),
            ],
            stops: stops,
          ),
        ),
      ),
    );
  }
}
