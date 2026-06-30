import 'package:flutter/material.dart';

import '../../../../theme/app_theme.dart';
import '../../../../favors/domain/entity/favor_step.dart';

/// A single tappable quest step row with a checkbox, title, detail, and
/// optional tip text.
class StepEntry extends StatelessWidget {
  const StepEntry({
    super.key,
    required this.step,
    required this.isChecked,
    required this.onChanged,
  });

  final FavorStep step;
  final bool isChecked;
  final ValueChanged<bool?> onChanged;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => onChanged(!isChecked),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Checkbox(
              value: isChecked,
              onChanged: onChanged,
              activeColor: AppColors.gold,
              checkColor: AppColors.background,
              side: const BorderSide(color: AppColors.gold),
            ),
            const SizedBox(width: 4),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 12),
                  Text(
                    step.title,
                    style: TextStyle(
                      color: isChecked
                          ? AppColors.textBody
                          : AppColors.goldLight,
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      decoration:
                          isChecked ? TextDecoration.lineThrough : null,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(step.detail, style: AppText.lore),
                  if (step.tip != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      '💡 ${step.tip}',
                      style: const TextStyle(
                        color: AppColors.strong,
                        fontSize: 12,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
