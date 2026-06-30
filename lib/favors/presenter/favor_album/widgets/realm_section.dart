import 'package:flutter/material.dart';
import '../../../../theme/app_theme.dart';
import '../../../domain/entity/favor.dart';
import '../bloc/favor_album_bloc.dart';
import 'favor_card.dart';

/// Displays a single realm heading followed by its list of [FavorCard]s.
class RealmSection extends StatelessWidget {
  const RealmSection({
    super.key,
    required this.realmId,
    required this.favors,
    required this.state,
    required this.onFavorTap,
  });

  final String realmId;
  final List<Favor> favors;
  final FavorAlbumState state;
  final ValueChanged<Favor> onFavorTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 16, bottom: 8),
          child: Text(
            realmId.toUpperCase(),
            style: AppText.sectionLabel,
          ),
        ),
        for (final favor in favors) ...[
          FavorCard(
            favor: favor,
            done: state.progress.completedStepCount(
              favor.id,
              favor.stepIds,
            ),
            onTap: () => onFavorTap(favor),
          ),
          const SizedBox(height: 8),
        ],
      ],
    );
  }
}
