import 'dart:convert';

import 'package:flutter/services.dart' show rootBundle;

import '../../domain/entity/favor.dart';
import '../../domain/entity/favors_data.dart';
import '../../domain/repository/favors_repository.dart';

const _kAssetPath = 'assets/gow_favors.json';

class FavorsRepositoryImpl implements FavorsRepository {
  final Future<String> Function(String path) _loader;

  FavorsRepositoryImpl() : _loader = rootBundle.loadString;
  FavorsRepositoryImpl.withLoader(this._loader);

  @override
  Future<FavorsData> load() async {
    final raw = await _loader(_kAssetPath);
    final map = jsonDecode(raw) as Map<String, dynamic>;
    final favors = (map['favors'] as List)
        .map((e) => Favor.fromJson(e as Map<String, dynamic>))
        .toList();
    return FavorsData(favors: favors);
  }
}
