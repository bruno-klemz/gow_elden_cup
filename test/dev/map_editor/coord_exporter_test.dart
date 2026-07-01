import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:gow_elden_cup/album/domain/entity/map_coord.dart';
import 'package:gow_elden_cup/dev/map_editor/coord_exporter.dart';

void main() {
  test('encodeCoords sorts keys and emits x,y', () {
    final json = encodeCoords({
      'boss_b': const MapCoord(0.5, 0.25),
      'boss_a': const MapCoord(0.1, 0.9),
    });
    expect(
      json,
      '{"boss_a":{"x":0.1,"y":0.9},"boss_b":{"x":0.5,"y":0.25}}',
    );
  });

  test('exportCoords writes map_coords.json to the given dir', () async {
    final tmp = await Directory.systemTemp.createTemp('mapcoords');
    addTearDown(() => tmp.delete(recursive: true));
    final path = await exportCoords(
      {'boss_a': const MapCoord(0.2, 0.3)},
      getDir: () async => tmp,
    );
    expect(path, '${tmp.path}/map_coords.json');
    expect(
      await File(path).readAsString(),
      '{"boss_a":{"x":0.2,"y":0.3}}',
    );
  });
}
