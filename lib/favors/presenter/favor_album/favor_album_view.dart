import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../theme/app_theme.dart';
import '../../domain/entity/favor.dart';
import '../favor_details/favor_details_screen.dart';
import 'bloc/favor_album_bloc.dart';
import 'widgets/favor_filters.dart';
import 'widgets/favor_list.dart';

/// Pure UI for the favor album. Reads [FavorAlbumBloc] from context.
///
/// Favors are displayed in a scrollable list grouped by realm.
class FavorAlbumView extends StatelessWidget {
  const FavorAlbumView({super.key});

  Future<void> _openFavor(BuildContext context, Favor favor) async {
    await FavorDetailsScreen.push(context, favor);
    if (!context.mounted) return;
    context.read<FavorAlbumBloc>().add(const FavorAlbumProgressRefreshed());
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
