import 'package:flutter/material.dart';
import '../../../domain/entity/boss.dart';
import '../../../../theme/app_theme.dart';

class TypeBadge extends StatelessWidget {
  const TypeBadge({super.key, required this.type});
  final BossType type;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
      decoration: BoxDecoration(
        color: AppColors.surfaceAlt,
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(type.label, style: AppText.slotName),
    );
  }
}
