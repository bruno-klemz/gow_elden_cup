import 'package:flutter/material.dart';
import '../../../../favors/domain/entity/favor.dart';
import '../../../../theme/app_theme.dart';
import 'favor_progress_ring.dart';

/// Prop-driven card representing a single [Favor] in the album grid.
///
/// Shows name, realm/region, giver, and a [FavorProgressRing] for X/N steps.
/// Invokes [onTap] when tapped (caller handles navigation).
class FavorCard extends StatelessWidget {
  const FavorCard({
    super.key,
    required this.favor,
    required this.done,
    required this.onTap,
  });

  final Favor favor;

  /// Number of completed steps.
  final int done;

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: _NameAndMeta(favor: favor)),
                const SizedBox(width: 8),
                FavorProgressRing(
                  done: done,
                  total: favor.stepIds.length,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _NameAndMeta extends StatelessWidget {
  const _NameAndMeta({required this.favor});

  final Favor favor;

  @override
  Widget build(BuildContext context) {
    final region = favor.region;
    final giver = favor.giver;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          favor.name,
          style: const TextStyle(
            color: AppColors.goldLight,
            fontSize: 13,
            fontWeight: FontWeight.w700,
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        if (region != null) ...[
          const SizedBox(height: 3),
          Text(
            region,
            style: const TextStyle(
              color: AppColors.textBody,
              fontSize: 11,
            ),
          ),
        ],
        if (giver != null) ...[
          const SizedBox(height: 2),
          Text(
            giver,
            style: const TextStyle(
              color: AppColors.textMuted,
              fontSize: 11,
            ),
          ),
        ],
      ],
    );
  }
}
