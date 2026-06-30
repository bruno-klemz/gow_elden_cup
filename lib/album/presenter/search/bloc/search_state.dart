part of 'search_bloc.dart';

class SearchState extends Equatable {
  final AlbumData? data;
  final Progress progress;
  final SearchTab tab;
  final String query;
  final bool loaded;
  final BossType? typeFilter;

  const SearchState({
    this.data,
    this.progress = const Progress(),
    this.tab = SearchTab.realms,
    this.query = '',
    this.loaded = false,
    this.typeFilter,
  });

  int realmCount() => data?.realms.length ?? 0;
  int bossCount() => data?.bosses.length ?? 0;

  int defeatedIn(String realmId) => progress.defeatedCountIn(
      (data?.bossesIn(realmId) ?? const []).map((b) => b.id));

  /// Realms sorted by most defeated (desc); ties keep the game order.
  List<Realm> realms() {
    final list = [...?data?.realms];
    list.sort((a, b) {
      final byDefeated = defeatedIn(b.id).compareTo(defeatedIn(a.id));
      if (byDefeated != 0) return byDefeated;
      return a.order.compareTo(b.order);
    });
    return list.where((r) => searchMatches(r.name, query)).toList();
  }

  /// Main bosses (A-Z) followed by the rest (A-Z), filtered by query and type.
  List<Boss> mainBosses() => _sortedBosses(mainOnly: true);
  List<Boss> otherBosses() => _sortedBosses(mainOnly: false);

  List<Boss> _sortedBosses({required bool mainOnly}) {
    final all = [...?data?.bosses]
        .where((b) => b.isMainBoss == mainOnly)
        .where((b) => searchMatches(b.name, query))
        .where((b) => typeFilter == null || b.type == typeFilter)
        .toList()
      ..sort((a, b) =>
          a.name.toLowerCase().compareTo(b.name.toLowerCase()));
    return all;
  }

  bool isDefeated(String bossId) => progress.isDefeated(bossId);

  String realmName(String realmId) =>
      data?.realms.firstWhere((r) => r.id == realmId).name ?? realmId;

  String? realmMapImage(String realmId) =>
      data?.realms.where((r) => r.id == realmId).firstOrNull?.mapImage;

  SearchState copyWith({
    AlbumData? data,
    Progress? progress,
    SearchTab? tab,
    String? query,
    bool? loaded,
    BossType? typeFilter,
    bool clearTypeFilter = false,
  }) {
    return SearchState(
      data: data ?? this.data,
      progress: progress ?? this.progress,
      tab: tab ?? this.tab,
      query: query ?? this.query,
      loaded: loaded ?? this.loaded,
      typeFilter: clearTypeFilter ? null : (typeFilter ?? this.typeFilter),
    );
  }

  @override
  List<Object?> get props => [data, progress, tab, query, loaded, typeFilter];
}
