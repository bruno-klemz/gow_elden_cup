import 'package:flutter/material.dart';

import '../../../../theme/app_theme.dart';
import '../../../domain/entity/favor.dart';
import '../bloc/favor_album_bloc.dart';
import 'favor_pool_card.dart';

/// One realm's page in the album PageView: a realm header with aggregate
/// progress, then a 2-column grid of [FavorPoolCard]s.
class RealmFavorPage extends StatelessWidget {
  const RealmFavorPage({
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
    final completed = favors
        .where((f) => favorStatus(f, state.progress) == FavorStatus.complete)
        .length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
          child: Row(
            children: [
              Text(realmId.toUpperCase(), style: AppText.sectionLabel),
              const SizedBox(width: 10),
              Expanded(
                child: Container(
                  height: 1,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [AppColors.frost, Colors.transparent],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Text(
                '$completed/${favors.length}',
                style: const TextStyle(
                  color: AppColors.textBody,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: GridView.builder(
            padding: const EdgeInsets.fromLTRB(14, 4, 14, 16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 10,
              crossAxisSpacing: 10,
              childAspectRatio: 3 / 4,
            ),
            itemCount: favors.length,
            itemBuilder: (context, i) {
              final favor = favors[i];
              return FavorPoolCard(
                favor: favor,
                done: state.progress.completedStepCount(
                  favor.id,
                  favor.stepIds,
                ),
                onTap: () => onFavorTap(favor),
              );
            },
          ),
        ),
      ],
    );
  }
}
