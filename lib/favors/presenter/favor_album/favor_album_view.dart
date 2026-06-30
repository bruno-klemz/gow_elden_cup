import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../theme/app_theme.dart';
import '../../domain/entity/favor.dart';
import 'bloc/favor_album_bloc.dart';
import 'widgets/favor_filters.dart';
import 'widgets/favor_list.dart';

/// Pure UI for the favor album. Reads [FavorAlbumBloc] from context.
///
/// Favors are displayed in a scrollable list grouped by realm.
class FavorAlbumView extends StatelessWidget {
  const FavorAlbumView({super.key});

  // Task 11 will replace this stub with a real FavorDetailsScreen push.
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
                    ? const Center(
                        child: Text(
                          'Nenhum favor encontrado.',
                          style: TextStyle(color: AppColors.textMuted),
                        ),
                      )
                    : FavorList(
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
