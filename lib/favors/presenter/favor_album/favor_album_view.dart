import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../theme/app_theme.dart';
import '../../domain/entity/favor.dart';
import '../favor_details/favor_details_screen.dart';
import 'bloc/favor_album_bloc.dart';
import 'widgets/favor_filter_sheet.dart';
import 'widgets/realm_favor_page.dart';

/// Album of favors as a sticker-album: one realm per page (swipeable), each a
/// 2-column grid of pool cards. A single "Filtros" chip opens a bottomsheet for
/// realm + status filtering.
class FavorAlbumView extends StatefulWidget {
  const FavorAlbumView({super.key});

  @override
  State<FavorAlbumView> createState() => _FavorAlbumViewState();
}

class _FavorAlbumViewState extends State<FavorAlbumView> {
  final _pageController = PageController();
  int _page = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _openFavor(BuildContext context, Favor favor) async {
    await FavorDetailsScreen.push(context, favor);
    if (!context.mounted) return;
    context.read<FavorAlbumBloc>().add(const FavorAlbumProgressRefreshed());
  }

  Future<void> _openFilters(
    BuildContext context,
    FavorAlbumState state,
    List<String> realms,
  ) async {
    final bloc = context.read<FavorAlbumBloc>();
    final result = await showFavorFilterSheet(
      context,
      realmIds: state.realmIds,
      selectedRealm: state.realmFilter,
      selectedStatus: state.statusFilter,
    );
    if (result == null) return;

    bloc.add(FavorAlbumStatusFilterChanged(result.status));
    bloc.add(FavorAlbumRealmFilterChanged(result.realm));

    // Jump the PageView to the chosen realm (or first page when cleared).
    final target = result.realm == null ? 0 : realms.indexOf(result.realm!);
    if (target >= 0 && _pageController.hasClients) {
      _pageController.jumpToPage(target);
      setState(() => _page = target);
    }
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

          final realms = _visibleRealms(state);
          final activeFilters = (state.realmFilter != null ? 1 : 0) +
              (state.statusFilter != null ? 1 : 0);

          return Column(
            children: [
              _FilterBar(
                activeCount: activeFilters,
                favorCount: state.filteredFavors.length,
                onTap: () => _openFilters(context, state, realms),
              ),
              if (realms.isEmpty)
                const Expanded(
                  child: Center(
                    child: Text(
                      'Nenhum favor encontrado.',
                      style: TextStyle(color: AppColors.textMuted),
                    ),
                  ),
                )
              else ...[
                Expanded(
                  child: PageView.builder(
                    controller: _pageController,
                    itemCount: realms.length,
                    onPageChanged: (p) => setState(() => _page = p),
                    itemBuilder: (context, i) {
                      final realmId = realms[i];
                      return RealmFavorPage(
                        realmId: realmId,
                        favors: _favorsForRealm(state, realmId),
                        state: state,
                        onFavorTap: (favor) => _openFavor(context, favor),
                      );
                    },
                  ),
                ),
                _Pager(
                  count: realms.length,
                  index: _page.clamp(0, realms.length - 1),
                  label: realms[_page.clamp(0, realms.length - 1)],
                ),
              ],
            ],
          );
        },
      ),
    );
  }

  /// Realms that have at least one favor matching the current filters, in
  /// encounter order.
  List<String> _visibleRealms(FavorAlbumState state) {
    final seen = <String>{};
    final realms = <String>[];
    for (final favor in state.filteredFavors) {
      if (seen.add(favor.realm)) realms.add(favor.realm);
    }
    return realms;
  }

  List<Favor> _favorsForRealm(FavorAlbumState state, String realmId) =>
      state.filteredFavors.where((f) => f.realm == realmId).toList();
}

class _FilterBar extends StatelessWidget {
  const _FilterBar({
    required this.activeCount,
    required this.favorCount,
    required this.onTap,
  });

  final int activeCount;
  final int favorCount;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GestureDetector(
            onTap: onTap,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.surfaceAlt,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.gold),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Filtros',
                    style: TextStyle(
                      color: AppColors.goldLight,
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  if (activeCount > 0) ...[
                    const SizedBox(width: 7),
                    Container(
                      constraints: const BoxConstraints(minWidth: 18),
                      height: 18,
                      alignment: Alignment.center,
                      padding: const EdgeInsets.symmetric(horizontal: 5),
                      decoration: BoxDecoration(
                        color: AppColors.gold,
                        borderRadius: BorderRadius.circular(9),
                      ),
                      child: Text(
                        '$activeCount',
                        style: const TextStyle(
                          color: AppColors.background,
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
          Text(
            '$favorCount favores',
            style: const TextStyle(color: AppColors.textMuted, fontSize: 12),
          ),
        ],
      ),
    );
  }
}

class _Pager extends StatelessWidget {
  const _Pager({
    required this.count,
    required this.index,
    required this.label,
  });

  final int count;
  final int index;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 4, 0, 14),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          for (var i = 0; i < count; i++)
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.symmetric(horizontal: 3),
              width: i == index ? 20 : 7,
              height: 7,
              decoration: BoxDecoration(
                color: i == index ? AppColors.gold : AppColors.border,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          const SizedBox(width: 10),
          Text(
            '${_capitalize(label)} · ${index + 1}/$count',
            style: const TextStyle(color: AppColors.textMuted, fontSize: 11),
          ),
        ],
      ),
    );
  }

  static String _capitalize(String s) =>
      s.isEmpty ? s : '${s[0].toUpperCase()}${s.substring(1)}';
}
