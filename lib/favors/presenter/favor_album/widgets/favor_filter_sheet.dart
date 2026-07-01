import 'package:flutter/material.dart';

import '../../../../theme/app_theme.dart';
import '../bloc/favor_album_bloc.dart';

/// Result of the filter bottomsheet: the chosen realm (null = all) and status
/// (null = all). Returned via `Navigator.pop`.
class FavorFilterResult {
  const FavorFilterResult({this.realm, this.status});
  final String? realm;
  final FavorStatus? status;
}

const _statusLabels = {
  FavorStatus.pending: 'Pendente',
  FavorStatus.inProgress: 'Em progresso',
  FavorStatus.complete: 'Completo',
};

/// Opens the filter bottomsheet and returns the chosen filters, or null if
/// dismissed without applying.
Future<FavorFilterResult?> showFavorFilterSheet(
  BuildContext context, {
  required List<String> realmIds,
  required String? selectedRealm,
  required FavorStatus? selectedStatus,
}) {
  return showModalBottomSheet<FavorFilterResult>(
    context: context,
    backgroundColor: AppColors.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
    ),
    builder: (_) => _FilterSheet(
      realmIds: realmIds,
      selectedRealm: selectedRealm,
      selectedStatus: selectedStatus,
    ),
  );
}

class _FilterSheet extends StatefulWidget {
  const _FilterSheet({
    required this.realmIds,
    required this.selectedRealm,
    required this.selectedStatus,
  });

  final List<String> realmIds;
  final String? selectedRealm;
  final FavorStatus? selectedStatus;

  @override
  State<_FilterSheet> createState() => _FilterSheetState();
}

class _FilterSheetState extends State<_FilterSheet> {
  late String? _realm = widget.selectedRealm;
  late FavorStatus? _status = widget.selectedStatus;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 18),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 14),
            const Text('FILTRAR FAVORES', style: AppText.sectionLabel),
            const SizedBox(height: 14),
            const _GroupLabel('REINO'),
            Wrap(
              spacing: 7,
              runSpacing: 7,
              children: [
                _Choice(
                  label: 'Todos',
                  selected: _realm == null,
                  onTap: () => setState(() => _realm = null),
                ),
                for (final realm in widget.realmIds)
                  _Choice(
                    label: _capitalize(realm),
                    selected: _realm == realm,
                    onTap: () => setState(() => _realm = realm),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            const _GroupLabel('STATUS'),
            Wrap(
              spacing: 7,
              runSpacing: 7,
              children: [
                _Choice(
                  label: 'Todos',
                  selected: _status == null,
                  onTap: () => setState(() => _status = null),
                ),
                for (final entry in _statusLabels.entries)
                  _Choice(
                    label: entry.value,
                    selected: _status == entry.key,
                    onTap: () => setState(() => _status = entry.key),
                  ),
              ],
            ),
            const SizedBox(height: 18),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: AppColors.border),
                      foregroundColor: AppColors.textBody,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    onPressed: () => setState(() {
                      _realm = null;
                      _status = null;
                    }),
                    child: const Text('Limpar'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: FilledButton(
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.frost,
                      foregroundColor: AppColors.background,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    onPressed: () => Navigator.of(
                      context,
                    ).pop(FavorFilterResult(realm: _realm, status: _status)),
                    child: const Text(
                      'Aplicar',
                      style: TextStyle(fontWeight: FontWeight.w800),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  static String _capitalize(String s) =>
      s.isEmpty ? s : '${s[0].toUpperCase()}${s.substring(1)}';
}

class _GroupLabel extends StatelessWidget {
  const _GroupLabel(this.text);
  final String text;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Text(
      text,
      style: const TextStyle(
        color: AppColors.textMuted,
        fontSize: 10,
        fontWeight: FontWeight.w800,
        letterSpacing: 1.2,
      ),
    ),
  );
}

class _Choice extends StatelessWidget {
  const _Choice({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: selected ? AppColors.frost : AppColors.surfaceAlt,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: selected ? AppColors.frost : AppColors.border,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? AppColors.background : AppColors.textBody,
            fontSize: 12,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}
