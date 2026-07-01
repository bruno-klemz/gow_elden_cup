import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';

import '../../album/domain/entity/map_coord.dart';

/// Serializes captured coords to deterministic JSON: keys sorted, each value
/// `{"x":.., "y":..}`. Deterministic ordering keeps diffs/logs stable.
String encodeCoords(Map<String, MapCoord> coords) {
  final sortedKeys = coords.keys.toList()..sort();
  final map = <String, dynamic>{
    for (final k in sortedKeys) k: {'x': coords[k]!.x, 'y': coords[k]!.y},
  };
  return jsonEncode(map);
}

/// Writes `map_coords.json` into the app documents dir (overriding [getDir]
/// in tests) and returns the written file path.
Future<String> exportCoords(
  Map<String, MapCoord> coords, {
  Future<Directory> Function() getDir = getApplicationDocumentsDirectory,
}) async {
  final dir = await getDir();
  final file = File('${dir.path}/map_coords.json');
  await file.writeAsString(encodeCoords(coords));
  return file.path;
}
