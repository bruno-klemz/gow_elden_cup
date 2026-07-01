import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gow_elden_cup/album/domain/entity/album_data.dart';
import 'package:gow_elden_cup/album/domain/entity/boss.dart';
import 'package:gow_elden_cup/album/domain/entity/map_coord.dart';
import 'package:gow_elden_cup/album/domain/entity/realm.dart';
import 'package:gow_elden_cup/album/domain/usecase/load_album_usecase.dart';
import 'package:gow_elden_cup/dev/map_editor/bloc/map_editor_bloc.dart';
import 'package:gow_elden_cup/dev/map_editor/bloc/map_editor_state.dart';
import 'package:mocktail/mocktail.dart';

class _MockLoadAlbum extends Mock implements LoadAlbumUsecase {}

// Only the required Boss fields are set; type/weaknesses/immunities/loot use
// their defaults. `type` is a BossType enum and weaknesses/immunities are
// List<DamageType> in the real entity, so we omit them rather than pass strings.
Boss _boss(String id, String realm) => Boss(
      id: id,
      name: id,
      realm: realm,
      art: '',
      locationName: '',
      mapCoord: const MapCoord(0, 0),
      lore: '',
    );

void main() {
  late _MockLoadAlbum loadAlbum;

  setUp(() {
    loadAlbum = _MockLoadAlbum();
    when(() => loadAlbum()).thenAnswer(
      (_) async => AlbumData(
        realms: const [Realm(id: 'midgard', name: 'Midgard', order: 1)],
        bosses: [_boss('a', 'midgard'), _boss('b', 'vanaheim')],
      ),
    );
  });

  blocTest<MapEditorBloc, MapEditorState>(
    'MapEditorStarted loads realms+bosses and clears loading',
    build: () => MapEditorBloc(loadAlbum),
    act: (b) => b.add(MapEditorStarted()),
    expect: () => [
      isA<MapEditorState>()
          .having((s) => s.loading, 'loading', false)
          .having((s) => s.realms.length, 'realms', 1)
          .having((s) => s.bosses.length, 'bosses', 2),
    ],
  );

  blocTest<MapEditorBloc, MapEditorState>(
    'CoordPlaced records coord for the selected boss',
    build: () => MapEditorBloc(loadAlbum),
    seed: () => const MapEditorState(loading: false, selectedBossId: 'a'),
    act: (b) => b.add(CoordPlaced(0.4, 0.6)),
    expect: () => [
      isA<MapEditorState>().having(
        (s) => s.coords['a'],
        'coord a',
        const MapCoord(0.4, 0.6),
      ),
    ],
  );

  blocTest<MapEditorBloc, MapEditorState>(
    'CoordsExported sets exportedPath via injected ExportFn',
    build: () => MapEditorBloc(
      loadAlbum,
      export: (coords) async => '/tmp/fake/map_coords.json',
    ),
    seed: () => const MapEditorState(loading: false),
    act: (b) => b.add(CoordsExported()),
    expect: () => [
      isA<MapEditorState>().having(
        (s) => s.exportedPath,
        'exportedPath',
        '/tmp/fake/map_coords.json',
      ),
    ],
  );

  blocTest<MapEditorBloc, MapEditorState>(
    'RealmSelected clears previously selected boss',
    build: () => MapEditorBloc(loadAlbum),
    seed: () => const MapEditorState(
      loading: false,
      selectedBossId: 'a',
      selectedRealmId: 'midgard',
    ),
    act: (b) => b.add(RealmSelected('vanaheim')),
    expect: () => [
      isA<MapEditorState>()
          .having((s) => s.selectedRealmId, 'selectedRealmId', 'vanaheim')
          .having((s) => s.selectedBossId, 'selectedBossId', null),
    ],
  );
}
