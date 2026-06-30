import 'package:flutter/material.dart';

import '../../../../theme/app_theme.dart';
import '../../../../favors/domain/entity/reward.dart';

/// Displays the list of rewards for a completed favor.
class RewardsFooter extends StatelessWidget {
  const RewardsFooter({super.key, required this.rewards});

  final List<Reward> rewards;

  @override
  Widget build(BuildContext context) {
    if (rewards.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(top: 18, bottom: 8),
          child: Text(
            '💎 RECOMPENSAS',
            style: AppText.sectionLabel,
          ),
        ),
        ...rewards.map((r) => _RewardRow(reward: r)),
      ],
    );
  }
}

class _RewardRow extends StatelessWidget {
  const _RewardRow({required this.reward});
  final Reward reward;

  @override
  Widget build(BuildContext context) {
    final qty = reward.quantity;
    final rarity = reward.rarity;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          const Icon(Icons.star_rounded, color: AppColors.gold, size: 14),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              reward.name,
              style: const TextStyle(
                color: AppColors.goldLight,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          if (qty != null)
            Text(
              'x$qty',
              style: const TextStyle(
                color: AppColors.textBody,
                fontSize: 12,
              ),
            ),
          if (rarity != null) ...[
            const SizedBox(width: 8),
            Text(
              rarity,
              style: const TextStyle(
                color: AppColors.textBody,
                fontSize: 11,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
