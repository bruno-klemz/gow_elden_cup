import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../boss/presenter/boss_details/boss_details_screen.dart';
import '../../../shared/widgets/pending_art.dart';
import '../../../theme/app_theme.dart';
import '../../../favors/presenter/theme/realm_theme.dart';
import '../../domain/entity/boss.dart';
import '../../domain/entity/realm.dart';
import 'bloc/search_bloc.dart';
import 'widgets/type_filter_chips.dart';

/// Pure UI for search. Reads [SearchBloc]. Boss taps push [BossDetailsScreen]
/// directly (resolving realmMapImage the same way [album_view] does). Realm
/// rows are display-only; navigation from realm rows was removed because the
/// screen lives in a permanent [IndexedStack] and was unreachable via push.
class SearchView extends StatelessWidget {
  const SearchView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        iconTheme: const IconThemeData(color: AppColors.goldLight),
        title: const Text('Buscar',
            style: TextStyle(
                color: AppColors.goldLight, fontWeight: FontWeight.w800)),
      ),
      body: BlocBuilder<SearchBloc, SearchState>(
        builder: (context, state) {
          final bloc = context.read<SearchBloc>();
          return Column(
            children: [
              _field(bloc),
              _tabs(context, state, bloc),
              if (state.tab == SearchTab.bosses)
                TypeFilterChips(
                  selected: state.typeFilter,
                  onChanged: (t) => bloc.add(SearchTypeFilterChanged(t)),
                ),
              Expanded(
                child: state.tab == SearchTab.realms
                    ? _realmList(context, state)
                    : _bossList(context, state),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _field(SearchBloc bloc) => Padding(
        padding: const EdgeInsets.fromLTRB(14, 8, 14, 8),
        child: TextField(
          autofocus: false,
          style: const TextStyle(color: AppColors.goldLight, fontSize: 14),
          cursorColor: AppColors.gold,
          onChanged: (v) => bloc.add(SearchQueryChanged(v)),
          decoration: InputDecoration(
            hintText: 'Buscar reino ou boss...',
            hintStyle: const TextStyle(color: Color(0xFF6B5D44)),
            prefixIcon:
                const Icon(Icons.search, color: AppColors.textMuted, size: 20),
            filled: true,
            fillColor: AppColors.surfaceAlt,
            contentPadding: const EdgeInsets.symmetric(vertical: 0),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.border),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.gold),
            ),
          ),
        ),
      );

  Widget _tabs(BuildContext context, SearchState state, SearchBloc bloc) => Row(
        children: [
          _tab(state, bloc, SearchTab.realms, 'Reinos', state.realmCount()),
          _tab(state, bloc, SearchTab.bosses, 'Bosses', state.bossCount()),
        ],
      );

  Widget _tab(SearchState state, SearchBloc bloc, SearchTab tab, String label,
      int count) {
    final active = state.tab == tab;
    return Expanded(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => bloc.add(SearchTabChanged(tab)),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: active ? AppColors.gold : AppColors.border,
                width: active ? 2 : 1,
              ),
            ),
          ),
          child: Text('$label  $count',
              style: TextStyle(
                  color: active ? AppColors.gold : AppColors.textMuted,
                  fontSize: 13,
                  fontWeight: FontWeight.w700)),
        ),
      ),
    );
  }

  Widget _realmList(BuildContext context, SearchState state) {
    final realms = state.realms();
    if (realms.isEmpty) return const _Empty();
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(10, 4, 10, 16),
      itemCount: realms.length,
      itemBuilder: (context, i) => _realmTile(context, state, realms[i]),
    );
  }

  Widget _realmTile(BuildContext context, SearchState state, Realm realm) {
    final defeated = state.defeatedIn(realm.id);
    final total = state.data!.bossesIn(realm.id).length;
    return _tile(
      leading: SizedBox(
        width: 34,
        height: 34,
        child: Image.asset(
          RealmTheme.of(realm.id).runeAsset,
          fit: BoxFit.contain,
          errorBuilder: (c, e, s) => const SizedBox.shrink(),
        ),
      ),
      title: realm.name,
      subtitle: '$defeated/$total derrotados',
    );
  }

  Widget _bossList(BuildContext context, SearchState state) {
    final mains = state.mainBosses();
    final others = state.otherBosses();
    if (mains.isEmpty && others.isEmpty) return const _Empty();
    return ListView(
      padding: const EdgeInsets.fromLTRB(10, 4, 10, 16),
      children: [
        if (mains.isNotEmpty) ...[
          _sectionLabel('★ Principais'),
          for (final b in mains) _bossTile(context, state, b),
        ],
        if (others.isNotEmpty) ...[
          _sectionLabel('Demais'),
          for (final b in others) _bossTile(context, state, b),
        ],
      ],
    );
  }

  Widget _bossTile(BuildContext context, SearchState state, Boss boss) {
    final defeated = state.isDefeated(boss.id);
    final thumb = Image.asset('assets/${boss.art}',
        fit: BoxFit.cover,
        alignment: const Alignment(0, -0.6),
        errorBuilder: (c, e, s) => Container(color: AppColors.surfaceAlt));
    return _tile(
      leading: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: SizedBox(
          width: 34,
          height: 34,
          // Search thumbs are grayscale-only while pending (never blurred);
          // blurSigma 0 keeps the global blur toggle a no-op here.
          child: defeated
              ? thumb
              : PendingArt(art: boss.art, blurSigma: 0, grayscale: true),
        ),
      ),
      // crown only once defeated (reward), name muted while pending
      title: (boss.isMainBoss && defeated) ? '${boss.name}  👑' : boss.name,
      titleColor: defeated ? AppColors.goldLight : const Color(0xFF9A8A66),
      subtitle: state.realmName(boss.realm),
      onTap: () => _openBoss(context, state, boss),
    );
  }

  /// Resolves [realmMapImage] from state and pushes [BossDetailsScreen]
  /// directly — same behaviour as album_view's _openBoss.
  Future<void> _openBoss(
      BuildContext context, SearchState state, Boss boss) async {
    final mapImage = state.realmMapImage(boss.realm);
    await BossDetailsScreen.push(context, boss, realmMapImage: mapImage);
    if (!context.mounted) return;
    context.read<SearchBloc>().add(const SearchProgressRefreshed());
  }

  Widget _sectionLabel(String text) => Padding(
        padding: const EdgeInsets.fromLTRB(6, 12, 6, 4),
        child: Text(text,
            style: const TextStyle(
                color: AppColors.textMuted,
                fontSize: 10,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.2)),
      );

  Widget _tile({
    required Widget leading,
    required String title,
    required String subtitle,
    VoidCallback? onTap,
    Color titleColor = AppColors.goldLight,
  }) =>
      InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 13),
          child: Row(
            children: [
              leading,
              const SizedBox(width: 11),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                            color: titleColor,
                            fontSize: 14,
                            fontWeight: FontWeight.w700)),
                    const SizedBox(height: 5),
                    Text(subtitle,
                        style: const TextStyle(
                            color: AppColors.textMuted, fontSize: 11)),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right,
                  color: Color(0xFF4A3C2A), size: 20),
            ],
          ),
        ),
      );
}

class _Empty extends StatelessWidget {
  const _Empty();
  @override
  Widget build(BuildContext context) => const Center(
        child: Text('Nada encontrado',
            style: TextStyle(color: AppColors.textMuted)),
      );
}
