import 'package:flutter_test/flutter_test.dart';
import 'package:gow_elden_cup/album/domain/entity/boss.dart';
import 'package:gow_elden_cup/album/domain/entity/damage_type.dart';
import 'package:gow_elden_cup/album/domain/entity/map_coord.dart';
import 'package:gow_elden_cup/album/domain/entity/loot_item.dart';

void main() {
  const kSampleJson = {
    'id': 'bjorn',
    'name': 'Björn',
    'subtitle': 'The Bear',
    'realm': 'midgard',
    'type': 'berserker',
    'art': 'assets/images/bjorn.png',
    'locationName': 'Lake of Nine',
    'mapCoord': {'x': 0.42, 'y': 0.61},
    'weaknesses': ['frost', 'chaos_blades'],
    'immunities': ['burn'],
    'strategy': 'Dodge and punish.',
    'loot': [
      {'name': 'Bonded Leather', 'icon': '🩶', 'quantity': 2}
    ],
    'lore': 'A mighty berserker from the ancient wars.',
    'mainOrder': 3,
    'needsReview': true,
  };

  test('Boss.fromJson parses all fields correctly', () {
    final boss = Boss.fromJson(kSampleJson);

    expect(boss.id, 'bjorn');
    expect(boss.name, 'Björn');
    expect(boss.subtitle, 'The Bear');
    expect(boss.realm, 'midgard');
    expect(boss.type, BossType.berserker);
    expect(boss.art, 'assets/images/bjorn.png');
    expect(boss.locationName, 'Lake of Nine');
    expect(boss.mapCoord, const MapCoord(0.42, 0.61));
    expect(boss.weaknesses, [DamageType.frost, DamageType.blades]);
    expect(boss.immunities, [DamageType.burn]);
    expect(boss.strategy, 'Dodge and punish.');
    expect(boss.loot, [const LootItem(name: 'Bonded Leather', icon: '🩶', quantity: 2)]);
    expect(boss.lore, 'A mighty berserker from the ancient wars.');
    expect(boss.mainOrder, 3);
    expect(boss.needsReview, true);
    expect(boss.isMainBoss, true);
  });

  test('isMainBoss is false when mainOrder is absent', () {
    final boss = Boss.fromJson({
      'id': 'goblin',
      'name': 'Goblin',
      'realm': 'vanaheim',
      'art': 'assets/images/goblin.png',
      'locationName': 'Jungle',
      'mapCoord': {'x': 0.1, 'y': 0.2},
      'lore': 'A weak goblin.',
    });

    expect(boss.mainOrder, 0);
    expect(boss.isMainBoss, false);
  });
}
