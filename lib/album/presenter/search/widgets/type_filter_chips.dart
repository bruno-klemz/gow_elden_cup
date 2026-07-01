import 'package:flutter/material.dart';
import '../../../../theme/app_theme.dart';
import '../../../domain/entity/boss.dart';

/// Prop-driven row of [ChoiceChip]s: "Todos" + one per [BossType].
///
/// Emits `null` via [onChanged] when the "Todos" chip is selected,
/// or the corresponding [BossType] for any other chip.
class TypeFilterChips extends StatelessWidget {
  const TypeFilterChips({
    super.key,
    required this.selected,
    required this.onChanged,
  });

  final BossType? selected;
  final ValueChanged<BossType?> onChanged;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.fromLTRB(14, 4, 14, 8),
      child: Row(
        children: [
          _chip(label: 'Todos', value: null),
          const SizedBox(width: 6),
          for (final type in BossType.values) ...[
            _chip(label: type.label, value: type),
            const SizedBox(width: 6),
          ],
        ],
      ),
    );
  }

  Widget _chip({required String label, required BossType? value}) {
    final active = selected == value;
    return ChoiceChip(
      label: Text(label),
      selected: active,
      onSelected: (_) => onChanged(value),
      labelStyle: TextStyle(
        color: active ? AppColors.background : AppColors.textMuted,
        fontSize: 11,
        fontWeight: FontWeight.w700,
      ),
      selectedColor: AppColors.frost,
      backgroundColor: AppColors.surfaceAlt,
      side: BorderSide(color: active ? AppColors.frost : AppColors.border),
      showCheckmark: false,
      visualDensity: VisualDensity.compact,
    );
  }
}
