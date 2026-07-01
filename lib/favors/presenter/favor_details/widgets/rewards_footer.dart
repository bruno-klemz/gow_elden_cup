import 'package:flutter/material.dart';

import '../../../../favors/domain/entity/reward.dart';
import '../favor_text.dart';

/// Displays the list of rewards for a favor, styled for the shrine palette.
class RewardsFooter extends StatelessWidget {
  const RewardsFooter({super.key, required this.rewards});

  final List<Reward> rewards;

  static const _ink = Color(0xFFF1E4B8);
  static const _inkBody = Color(0xFFCDBB8C);

  @override
  Widget build(BuildContext context) {
    if (rewards.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: rewards.map((r) => _RewardRow(reward: r)).toList(),
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
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: [
          const Icon(Icons.star_rounded, color: Color(0xFFE3C886), size: 14),
          const SizedBox(width: 7),
          Expanded(
            child: Text(
              reward.name,
              style: FavorText.body.copyWith(
                color: RewardsFooter._ink,
                fontWeight: FontWeight.w600,
                height: 1.2,
              ),
            ),
          ),
          if (qty != null)
            Text(
              'x$qty',
              style: FavorText.body.copyWith(
                color: RewardsFooter._inkBody,
                height: 1.2,
              ),
            ),
          if (rarity != null) ...[
            const SizedBox(width: 8),
            Text(
              rarity,
              style: FavorText.body.copyWith(
                color: RewardsFooter._inkBody,
                fontStyle: FontStyle.italic,
                height: 1.2,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
