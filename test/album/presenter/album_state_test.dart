import 'package:gow_elden_cup/album/domain/entity/album_data.dart';
import 'package:gow_elden_cup/album/domain/entity/boss.dart';
import 'package:gow_elden_cup/album/domain/entity/map_coord.dart';
import 'package:gow_elden_cup/album/domain/entity/realm.dart';
import 'package:gow_elden_cup/album/presenter/album/bloc/album_bloc.dart';
import 'package:flutter_test/flutter_test.dart';

Boss _boss(String id, String name, {int mainOrder = 0}) => Boss(
      id: id,
      name: name,
      realm: 'midgard',
      art: 'a.webp',
      locationName: 'loc',
      mapCoord: const MapCoord(0.1, 0.2),
      lore: 'l',
      mainOrder: mainOrder,
    );

void main() {
  group('AlbumState.otherBossesIn', () {
    test('orders non-main bosses alphabetically (case-insensitive)', () {
      final state = AlbumState(
        status: AlbumStatus.loaded,
        data: AlbumData(
          realms: const [Realm(id: 'midgard', name: 'Midgard', order: 1)],
          bosses: [
            _boss('z', 'Zamor'),
            _boss('a', 'berserker'), // lowercase to prove case-insensitivity
            _boss('m', 'Baldur', mainOrder: 1), // main boss, excluded
            _boss('c', 'Frost Ancient'),
          ],
        ),
      );

      final names =
          state.otherBossesIn('midgard').map((b) => b.name).toList();

      expect(names, ['berserker', 'Frost Ancient', 'Zamor']);
    });
  });
}
