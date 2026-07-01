import 'package:equatable/equatable.dart';
import 'damage_type.dart';
import 'loot_item.dart';
import 'map_coord.dart';

enum BossType {
  story('História'),
  berserker('Berserker'),
  valkyrie('Valquíria'),
  dragon('Dragão'),
  dreki('Dreki'),
  phantom('Fantasma'),
  favor('Favor'),
  misc('Diversos');

  const BossType(this.label);
  final String label;

  static BossType fromKey(String? key) {
    if (key == null) return BossType.misc;
    for (final t in BossType.values) {
      if (t.name == key) return t;
    }
    return BossType.misc;
  }
}

class Boss extends Equatable {
  final String id;
  final String name;
  final String? subtitle;
  final String realm;
  final BossType type;
  final String art;
  final String locationName;
  final MapCoord mapCoord;
  final List<DamageType> weaknesses;
  final List<DamageType> immunities;
  final String? strategy;
  final List<LootItem> loot;
  final String lore;
  final int mainOrder;
  final bool needsReview;

  const Boss({
    required this.id,
    required this.name,
    this.subtitle,
    required this.realm,
    this.type = BossType.misc,
    required this.art,
    required this.locationName,
    required this.mapCoord,
    this.weaknesses = const [],
    this.immunities = const [],
    this.strategy,
    this.loot = const [],
    required this.lore,
    this.mainOrder = 0,
    this.needsReview = false,
  });

  bool get isMainBoss => mainOrder > 0;

  factory Boss.fromJson(Map<String, dynamic> json) {
    List<DamageType> dmg(String key) => ((json[key] as List?) ?? const [])
        .map((e) => DamageType.fromKey(e as String))
        .toList();
    return Boss(
      id: json['id'] as String,
      name: json['name'] as String,
      subtitle: json['subtitle'] as String?,
      realm: json['realm'] as String,
      type: BossType.fromKey(json['type'] as String?),
      art: json['art'] as String,
      locationName: json['locationName'] as String,
      mapCoord: MapCoord.fromJson(json['mapCoord'] as Map<String, dynamic>),
      weaknesses: dmg('weaknesses'),
      immunities: dmg('immunities'),
      strategy: json['strategy'] as String?,
      loot: ((json['loot'] as List?) ?? const [])
          .map((e) => LootItem.fromJson(e as Map<String, dynamic>))
          .toList(),
      lore: json['lore'] as String,
      mainOrder: json['mainOrder'] as int? ?? 0,
      needsReview: json['needsReview'] as bool? ?? false,
    );
  }

  @override
  List<Object?> get props => [
    id,
    name,
    subtitle,
    realm,
    type,
    art,
    locationName,
    mapCoord,
    weaknesses,
    immunities,
    strategy,
    loot,
    lore,
    mainOrder,
    needsReview,
  ];
}
