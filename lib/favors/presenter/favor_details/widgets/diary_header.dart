import 'package:flutter/material.dart';

import '../../../../theme/app_theme.dart';

/// Displays the favor identity and a status seal in a parchment-styled block.
class DiaryHeader extends StatelessWidget {
  const DiaryHeader({
    super.key,
    required this.name,
    required this.realm,
    this.region,
    this.giver,
    required this.sealText,
  });

  final String name;
  final String realm;
  final String? region;
  final String? giver;
  final String sealText;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceAlt,
        border: Border.all(color: AppColors.gold, width: 1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(name, style: AppText.title),
          const SizedBox(height: 4),
          _LocationRow(realm: realm, region: region),
          if (giver != null) ...[
            const SizedBox(height: 2),
            Text(
              'Dado por: ${giver!}',
              style: const TextStyle(
                color: AppColors.textBody,
                fontSize: 12,
              ),
            ),
          ],
          const SizedBox(height: 12),
          _SealBadge(text: sealText),
        ],
      ),
    );
  }
}

class _LocationRow extends StatelessWidget {
  const _LocationRow({required this.realm, this.region});
  final String realm;
  final String? region;

  @override
  Widget build(BuildContext context) {
    final label = region != null ? '$realm · $region' : realm;
    return Text(label.toUpperCase(), style: AppText.regionLabel);
  }
}

class _SealBadge extends StatelessWidget {
  const _SealBadge({required this.text});
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.gold),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: AppColors.gold,
          fontSize: 12,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
