import 'package:flutter/material.dart';
import '../../../../theme/app_theme.dart';
import '../bloc/favor_album_bloc.dart';

/// Prop-driven filter bar: a row of realm chips followed by status chips.
///
/// Emits [FavorAlbumEvent]s via [onRealmChanged] and [onStatusChanged];
/// the view wires these to the bloc. This widget is stateless and leaf-pure.
class FavorFilters extends StatelessWidget {
  const FavorFilters({
    super.key,
    required this.realmIds,
    required this.selectedRealm,
    required this.selectedStatus,
    required this.onRealmChanged,
    required this.onStatusChanged,
  });

  final List<String> realmIds;
  final String? selectedRealm;
  final FavorStatus? selectedStatus;
  final ValueChanged<String?> onRealmChanged;
  final ValueChanged<FavorStatus?> onStatusChanged;

  static const _kStatusLabels = {
    FavorStatus.pending: 'Pendente',
    FavorStatus.inProgress: 'Em Progresso',
    FavorStatus.complete: 'Completo',
  };

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (realmIds.isNotEmpty) _RealmChips(
          realmIds: realmIds,
          selected: selectedRealm,
          onChanged: onRealmChanged,
        ),
        _StatusChips(
          selected: selectedStatus,
          onChanged: onStatusChanged,
          labels: _kStatusLabels,
        ),
      ],
    );
  }
}

class _RealmChips extends StatelessWidget {
  const _RealmChips({
    required this.realmIds,
    required this.selected,
    required this.onChanged,
  });

  final List<String> realmIds;
  final String? selected;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.fromLTRB(14, 6, 14, 0),
      child: Row(
        children: [
          _chip(label: 'Todos', value: null),
          for (final id in realmIds) ...[
            const SizedBox(width: 6),
            _chip(label: id, value: id),
          ],
        ],
      ),
    );
  }

  Widget _chip({required String label, required String? value}) {
    final active = selected == value;
    return Padding(
      padding: const EdgeInsets.only(right: 0),
      child: ChoiceChip(
        label: Text(label),
        selected: active,
        onSelected: (_) => onChanged(value),
        labelStyle: TextStyle(
          color: active ? AppColors.background : AppColors.textMuted,
          fontSize: 11,
          fontWeight: FontWeight.w700,
        ),
        selectedColor: AppColors.gold,
        backgroundColor: AppColors.surfaceAlt,
        side: BorderSide(color: active ? AppColors.gold : AppColors.border),
        showCheckmark: false,
        visualDensity: VisualDensity.compact,
      ),
    );
  }
}

class _StatusChips extends StatelessWidget {
  const _StatusChips({
    required this.selected,
    required this.onChanged,
    required this.labels,
  });

  final FavorStatus? selected;
  final ValueChanged<FavorStatus?> onChanged;
  final Map<FavorStatus, String> labels;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.fromLTRB(14, 6, 14, 8),
      child: Row(
        children: [
          _chip(label: 'Todos', value: null),
          for (final status in FavorStatus.values) ...[
            const SizedBox(width: 6),
            _chip(label: labels[status] ?? status.name, value: status),
          ],
        ],
      ),
    );
  }

  Widget _chip({required String label, required FavorStatus? value}) {
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
      selectedColor: AppColors.gold,
      backgroundColor: AppColors.surfaceAlt,
      side: BorderSide(color: active ? AppColors.gold : AppColors.border),
      showCheckmark: false,
      visualDensity: VisualDensity.compact,
    );
  }
}
