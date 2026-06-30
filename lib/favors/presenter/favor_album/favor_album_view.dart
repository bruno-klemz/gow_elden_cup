import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../theme/app_theme.dart';
import '../../domain/entity/favor.dart';
import 'bloc/favor_album_bloc.dart';
import 'widgets/favor_card.dart';
import 'widgets/favor_filters.dart';

/// Pure UI for the favor album. Reads [FavorAlbumBloc] from context.
///
/// Favors are displayed in a scrollable list grouped by realm.
class FavorAlbumView extends StatelessWidget {
  const FavorAlbumView({super.key});

  // Task 11 will replace this stub with a real FavorDetailsScreen push.
  // ignore: avoid_positional_boolean_parameters
  void _openFavor(BuildContext context, Favor favor) {
    // TODO(task-11): push FavorDetailsScreen(favor: favor).
    // Left as a documented no-op so Task 11 can wire it without searching.
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        title: const Text('Favores', style: AppText.title),
        centerTitle: false,
      ),
      body: BlocBuilder<FavorAlbumBloc, FavorAlbumState>(
        builder: (context, state) {
          if (!state.isLoaded) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.gold),
            );
          }

          final favors = state.filteredFavors;

          return Column(
            children: [
              FavorFilters(
                realmIds: state.realmIds,
                selectedRealm: state.realmFilter,
                selectedStatus: state.statusFilter,
                onRealmChanged: (realmId) => context
                    .read<FavorAlbumBloc>()
                    .add(FavorAlbumRealmFilterChanged(realmId)),
                onStatusChanged: (status) => context
                    .read<FavorAlbumBloc>()
                    .add(FavorAlbumStatusFilterChanged(status)),
              ),
              Expanded(
                child: favors.isEmpty
                    ? const _EmptyState()
                    : _FavorList(
                        favors: favors,
                        state: state,
                        onFavorTap: (favor) => _openFavor(context, favor),
                      ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _FavorList extends StatelessWidget {
  const _FavorList({
    required this.favors,
    required this.state,
    required this.onFavorTap,
  });

  final List<Favor> favors;
  final FavorAlbumState state;
  final ValueChanged<Favor> onFavorTap;

  @override
  Widget build(BuildContext context) {
    // Group favors by realm while preserving encounter order.
    final realmIds = <String>[];
    final byRealm = <String, List<Favor>>{};
    for (final favor in favors) {
      if (!byRealm.containsKey(favor.realm)) {
        realmIds.add(favor.realm);
        byRealm[favor.realm] = [];
      }
      byRealm[favor.realm]!.add(favor);
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(14, 0, 14, 24),
      itemCount: realmIds.length,
      itemBuilder: (context, index) {
        final realmId = realmIds[index];
        final realmFavors = byRealm[realmId]!;
        return _RealmSection(
          realmId: realmId,
          favors: realmFavors,
          state: state,
          onFavorTap: onFavorTap,
        );
      },
    );
  }
}

class _RealmSection extends StatelessWidget {
  const _RealmSection({
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

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text(
        'Nenhum favor encontrado.',
        style: TextStyle(color: AppColors.textMuted),
      ),
    );
  }
}
