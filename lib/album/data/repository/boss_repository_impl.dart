import 'dart:convert';

import 'package:flutter/services.dart' show rootBundle;

import '../../domain/entity/album_data.dart';
import '../../domain/entity/boss.dart';
import '../../domain/entity/realm.dart';
import '../../domain/repository/boss_repository.dart';

const _kAssetPath = 'assets/gow_bosses.json';

class BossRepositoryImpl implements BossRepository {
  final Future<String> Function(String path) _loader;

  BossRepositoryImpl() : _loader = rootBundle.loadString;
  BossRepositoryImpl.withLoader(this._loader);

  @override
  Future<AlbumData> load() async {
    final raw = await _loader(_kAssetPath);
    final map = jsonDecode(raw) as Map<String, dynamic>;
    final realms = (map['realms'] as List)
        .map((e) => Realm.fromJson(e as Map<String, dynamic>))
        .toList()
      ..sort((a, b) => a.order.compareTo(b.order));
    final bosses = (map['bosses'] as List)
        .map((e) => Boss.fromJson(e as Map<String, dynamic>))
        .toList();
    return AlbumData(realms: realms, bosses: bosses);
  }
}
