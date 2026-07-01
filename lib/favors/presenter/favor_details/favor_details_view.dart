import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../theme/app_theme.dart';
import '../../domain/entity/favor.dart';
import '../../../theme/realm_theme.dart';
import '../widgets/rune_pool.dart';
import 'bloc/favor_details_bloc.dart';
import 'favor_text.dart';
import 'widgets/completion_sparkle.dart';
import 'widgets/rewards_footer.dart';
import 'widgets/step_entry.dart';

/// Shrine-style detail view for a favor: the realm shrine image as a blurred
/// ambient backdrop, a rune "seal" that fills as steps complete, and steps as
/// diary entries with wax-stamp markers. Completing the last step plays a
/// sparkle burst and seals the rune.
class FavorDetailsView extends StatefulWidget {
  const FavorDetailsView({super.key, required this.favor});

  final Favor favor;

  @override
  State<FavorDetailsView> createState() => _FavorDetailsViewState();
}

class _FavorDetailsViewState extends State<FavorDetailsView> {
  final _sparkle = SparkleController();

  static const _inkMeta = Color(0xFFD8C79A);
  static const _inkBody = Color(0xFFCDBB8C);

  @override
  void dispose() {
    _sparkle.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final favor = widget.favor;
    final theme = RealmTheme.of(favor.realm);
    final total = favor.stepIds.length;

    return Scaffold(
      backgroundColor: AppColors.background,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.frostLight),
      ),
      body: BlocListener<FavorDetailsBloc, FavorDetailsState>(
        listenWhen: (prev, next) =>
            !prev.isComplete(favor) && next.isComplete(favor),
        listener: (context, _) => _sparkle.fire(),
        child: Stack(
          fit: StackFit.expand,
          children: [
            _ShrineBackground(asset: theme.shrineAsset, accent: theme.accent),
            BlocBuilder<FavorDetailsBloc, FavorDetailsState>(
              builder: (context, state) {
                final bloc = context.read<FavorDetailsBloc>();
                final done = state.completedCount(favor);
                final progress = total == 0 ? 0.0 : done / total;
                final complete = state.isComplete(favor);

                return SingleChildScrollView(
                  padding: EdgeInsets.fromLTRB(
                    18,
                    MediaQuery.of(context).padding.top + kToolbarHeight,
                    18,
                    36,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _Seal(
                        theme: theme,
                        progress: progress,
                        complete: complete,
                        sparkle: _sparkle,
                      ),
                      const SizedBox(height: 4),
                      _StatusBadge(
                        text: state.sealText(favor),
                        accent: theme.accent,
                        complete: complete,
                      ),
                      const SizedBox(height: 12),
                      Center(
                        child: Text(
                          favor.name,
                          textAlign: TextAlign.center,
                          style: FavorText.title,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Center(child: _meta(favor)),
                      const _SectionRule(label: 'Pergaminho'),
                      Text(
                        favor.summary,
                        style: FavorText.body.copyWith(color: _inkBody),
                      ),
                      if (favor.lore.isNotEmpty) ...[
                        const SizedBox(height: 6),
                        Text(
                          favor.lore,
                          style: FavorText.body.copyWith(
                            color: _inkBody,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ],
                      const _SectionRule(label: 'Passos'),
                      ...favor.steps.map(
                        (step) => StepEntry(
                          step: step,
                          isChecked: state.progress.isStepDone(
                            favor.id,
                            step.id,
                          ),
                          accent: theme.accent,
                          onChanged: (_) => bloc.add(FavorStepToggled(step.id)),
                        ),
                      ),
                      if (favor.rewards.isNotEmpty) ...[
                        const _SectionRule(label: 'Recompensas'),
                        RewardsFooter(rewards: favor.rewards),
                      ],
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _meta(Favor favor) {
    final parts = <String>[
      favor.realm.toUpperCase(),
      if (favor.region != null) favor.region!.toUpperCase(),
    ];
    return Column(
      children: [
        Text(
          parts.join(' · '),
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: _inkMeta,
            fontSize: 11,
            fontWeight: FontWeight.w700,
            letterSpacing: 1,
          ),
        ),
        if (favor.giver != null) ...[
          const SizedBox(height: 2),
          Text(
            'Dado por: ${favor.giver}',
            style: FavorText.body.copyWith(
              color: _inkBody,
              fontStyle: FontStyle.italic,
              height: 1.2,
            ),
          ),
        ],
      ],
    );
  }
}

/// Full-bleed shrine image, blurred + desaturated + darkened as ambient.
class _ShrineBackground extends StatelessWidget {
  const _ShrineBackground({required this.asset, required this.accent});

  final String asset;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        ColorFiltered(
          colorFilter: const ColorFilter.matrix(_dim),
          child: ImageFiltered(
            imageFilter: ui.ImageFilter.blur(sigmaX: 6, sigmaY: 6),
            child: Image.asset(asset, fit: BoxFit.cover),
          ),
        ),
        const DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0x8C140A04), Color(0xD10C0703)],
            ),
          ),
        ),
        DecoratedBox(
          decoration: BoxDecoration(
            gradient: RadialGradient(
              center: const Alignment(0, -0.7),
              radius: 0.9,
              colors: [accent.withValues(alpha: 0.14), Colors.transparent],
            ),
          ),
        ),
      ],
    );
  }

  // Desaturate ~70% + dim, so the busy shrine recedes behind content.
  static const List<double> _dim = <double>[
    0.43, 0.36, 0.05, 0, -18, //
    0.21, 0.58, 0.05, 0, -18, //
    0.21, 0.36, 0.27, 0, -18, //
    0, 0, 0, 1, 0, //
  ];
}

class _Seal extends StatelessWidget {
  const _Seal({
    required this.theme,
    required this.progress,
    required this.complete,
    required this.sparkle,
  });

  final RealmTheme theme;
  final double progress;
  final bool complete;
  final SparkleController sparkle;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        width: 150,
        height: 150,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Container(
              width: 112,
              height: 112,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: theme.accent.withValues(alpha: complete ? 1 : 0.55),
                  width: 2,
                ),
                boxShadow: complete
                    ? [
                        BoxShadow(
                          color: theme.accent.withValues(alpha: 0.6),
                          blurRadius: 26,
                        ),
                      ]
                    : const [BoxShadow(color: Colors.black54, blurRadius: 14)],
              ),
              child: ClipOval(
                child: RunePool(
                  runeAsset: theme.runeAsset,
                  accent: theme.accent,
                  progress: progress,
                  // Rune nearly fills the circular seal; the pool fills the
                  // whole circle bottom-up.
                  runeRect: const RelativeRect.fromLTRB(9, 9, 9, 9),
                ),
              ),
            ),
            CompletionSparkle(controller: sparkle, color: theme.accent),
          ],
        ),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({
    required this.text,
    required this.accent,
    required this.complete,
  });

  final String text;
  final Color accent;
  final bool complete;

  @override
  Widget build(BuildContext context) {
    final label = complete ? '✦ FAVOR CONCLUÍDO ✦' : text.toUpperCase();
    return Center(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
        decoration: BoxDecoration(
          color: const Color(0x99140A04),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: accent.withValues(alpha: 0.6)),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: accent,
            fontSize: 11,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.5,
          ),
        ),
      ),
    );
  }
}

/// A gold-ruled section divider with a centred label.
class _SectionRule extends StatelessWidget {
  const _SectionRule({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 20, 0, 8),
      child: Row(
        children: [
          const Expanded(child: _Rule()),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Text(label, style: FavorText.sectionLabel),
          ),
          const Expanded(child: _Rule()),
        ],
      ),
    );
  }
}

class _Rule extends StatelessWidget {
  const _Rule();

  @override
  Widget build(BuildContext context) => Container(
    height: 1,
    decoration: const BoxDecoration(
      gradient: LinearGradient(
        colors: [Colors.transparent, Color(0xFFB58A3E), Colors.transparent],
      ),
    ),
  );
}
