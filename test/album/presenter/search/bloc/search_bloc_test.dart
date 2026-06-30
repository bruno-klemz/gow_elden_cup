import 'package:bloc_test/bloc_test.dart';
import 'package:gow_elden_cup/album/domain/entity/album_data.dart';
import 'package:gow_elden_cup/album/domain/entity/boss.dart';
import 'package:gow_elden_cup/album/domain/entity/map_coord.dart';
import 'package:gow_elden_cup/album/domain/entity/realm.dart';
import 'package:gow_elden_cup/album/domain/usecase/load_album_usecase.dart';
import 'package:gow_elden_cup/album/presenter/search/bloc/search_bloc.dart';
import 'package:gow_elden_cup/boss/domain/entity/progress.dart';
import 'package:gow_elden_cup/boss/domain/usecase/load_progress_usecase.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockLoadAlbum extends Mock implements LoadAlbumUsecase {}

class _MockLoadProgress extends Mock implements LoadProgressUsecase {}

Boss _b(String id, String name, String realm,
        {int mainOrder = 0, BossType type = BossType.misc}) =>
    Boss(
      id: id,
      name: name,
      realm: realm,
      art: 'a.webp',
      locationName: 'loc',
      mapCoord: const MapCoord(0, 0),
      lore: '',
      mainOrder: mainOrder,
      type: type,
    );

final _data = AlbumData(
  realms: const [
    Realm(id: 'midgard', name: 'Midgard', order: 1),
    Realm(id: 'alfheim', name: 'Alfheim', order: 2),
  ],
  bosses: [
    _b('thor', 'Thor', 'midgard', mainOrder: 1, type: BossType.story),
    _b('odin', 'Odin', 'midgard', mainOrder: 2, type: BossType.story),
    _b('nidhogg', 'Nidhogg', 'midgard', type: BossType.dragon),
    _b('berserker1', 'Berserker Alpha', 'alfheim', type: BossType.berserker),
  ],
);

void main() {
  late _MockLoadAlbum loadAlbum;
  late _MockLoadProgress loadProgress;

  setUp(() {
    loadAlbum = _MockLoadAlbum();
    loadProgress = _MockLoadProgress();
    when(() => loadAlbum()).thenAnswer((_) async => _data);
    when(() => loadProgress())
        .thenAnswer((_) async => const Progress(defeated: {'odin'}));
  });

  SearchBloc build() =>
      SearchBloc(loadAlbum: loadAlbum, loadProgress: loadProgress);

  blocTest<SearchBloc, SearchState>(
    'realms sorted by most defeated; ties keep game order',
    build: build,
    act: (b) => b.add(const SearchStarted()),
    verify: (b) {
      // midgard has 1 defeated (odin) -> first; alfheim 0 -> second by order
      expect(
          b.state.realms().map((r) => r.id).toList(), ['midgard', 'alfheim']);
    },
  );

  blocTest<SearchBloc, SearchState>(
    'bosses: mains A-Z then others A-Z',
    build: build,
    act: (b) => b.add(const SearchStarted()),
    verify: (b) {
      expect(b.state.mainBosses().map((x) => x.name).toList(),
          ['Odin', 'Thor']); // A-Z across all mains
      expect(b.state.otherBosses().map((x) => x.name).toList(),
          ['Berserker Alpha', 'Nidhogg']);
    },
  );

  blocTest<SearchBloc, SearchState>(
    'query filters the lists (diacritic-insensitive)',
    build: build,
    act: (b) {
      b.add(const SearchStarted());
      b.add(const SearchQueryChanged('thor'));
    },
    verify: (b) {
      expect(b.state.realms(), isEmpty);
      expect(b.state.mainBosses().map((x) => x.name).toList(), ['Thor']);
      expect(b.state.otherBosses(), isEmpty);
    },
  );

  blocTest<SearchBloc, SearchState>(
    'tab change keeps the query',
    build: build,
    act: (b) {
      b.add(const SearchStarted());
      b.add(const SearchQueryChanged('thor'));
      b.add(const SearchTabChanged(SearchTab.bosses));
    },
    verify: (b) {
      expect(b.state.tab, SearchTab.bosses);
      expect(b.state.query, 'thor');
    },
  );

  // GoW-specific: type filter tests
  blocTest<SearchBloc, SearchState>(
    'type filter narrows results to matching boss type',
    build: build,
    act: (b) {
      b.add(const SearchStarted());
      b.add(const SearchTypeFilterChanged(BossType.story));
    },
    verify: (b) {
      // Only story bosses: Thor (main) and Odin (main); no others
      expect(b.state.mainBosses().map((x) => x.name).toList(), ['Odin', 'Thor']);
      expect(b.state.otherBosses(), isEmpty);
    },
  );

  blocTest<SearchBloc, SearchState>(
    'query combined with type filter narrows results further',
    build: build,
    act: (b) {
      b.add(const SearchStarted());
      b.add(const SearchTypeFilterChanged(BossType.story));
      b.add(const SearchQueryChanged('thor'));
    },
    verify: (b) {
      // story type + "thor" query -> only Thor
      expect(b.state.mainBosses().map((x) => x.name).toList(), ['Thor']);
      expect(b.state.otherBosses(), isEmpty);
    },
  );

  blocTest<SearchBloc, SearchState>(
    'clearing type filter (null) restores full result set',
    build: build,
    act: (b) {
      b.add(const SearchStarted());
      b.add(const SearchTypeFilterChanged(BossType.dragon));
      b.add(const SearchTypeFilterChanged(null)); // clear filter
    },
    verify: (b) {
      // Filter cleared: all bosses returned
      expect(b.state.typeFilter, isNull);
      expect(b.state.mainBosses().map((x) => x.name).toList(), ['Odin', 'Thor']);
      expect(
          b.state.otherBosses().map((x) => x.name).toList(),
          ['Berserker Alpha', 'Nidhogg']);
    },
  );

  blocTest<SearchBloc, SearchState>(
    'type filter with no matches returns empty lists',
    build: build,
    act: (b) {
      b.add(const SearchStarted());
      b.add(const SearchTypeFilterChanged(BossType.valkyrie));
    },
    verify: (b) {
      expect(b.state.mainBosses(), isEmpty);
      expect(b.state.otherBosses(), isEmpty);
    },
  );
}
