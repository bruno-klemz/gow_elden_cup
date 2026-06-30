import 'package:flutter_test/flutter_test.dart';
import 'package:gow_elden_cup/album/data/repository/boss_repository_impl.dart';
import 'package:gow_elden_cup/album/domain/entity/boss.dart';
import 'package:gow_elden_cup/album/domain/entity/damage_type.dart';

const _kSeedJson = '''
{
  "realms": [
    {"id": "asgard", "name": "Asgard", "order": 8, "mapImage": "images/map/asgard.webp"},
    {"id": "midgard", "name": "Midgard", "order": 1, "mapImage": "images/map/midgard.webp"},
    {"id": "muspelheim", "name": "Muspelheim", "order": 5, "mapImage": "images/map/muspelheim.webp"}
  ],
  "bosses": [
    {
      "id": "fraekni_the_zealous", "name": "Fraekni, a Zelosa", "subtitle": "Berserker",
      "realm": "midgard", "type": "berserker", "art": "images/placeholder.webp",
      "locationName": "Lago dos Nove", "mapCoord": {"x": 0, "y": 0},
      "weaknesses": ["stun", "blades"], "immunities": [],
      "strategy": "Padrão de ataque previsível.",
      "loot": [{"name": "Fragmento de Berserker"}], "lore": "Uma berserker.",
      "mainOrder": 0, "needsReview": true
    },
    {
      "id": "heimdall", "name": "Heimdall", "subtitle": "Guardião de Asgard",
      "realm": "asgard", "type": "story", "art": "images/placeholder.webp",
      "locationName": "Asgard", "mapCoord": {"x": 0, "y": 0},
      "weaknesses": ["spear", "stun"], "immunities": ["frost"],
      "strategy": "Use a Lança Draupnir.",
      "loot": [{"name": "Armadura do Guardião"}], "lore": "O guardião de Asgard.",
      "mainOrder": 1, "needsReview": true
    },
    {
      "id": "gna", "name": "Gná", "subtitle": "Rainha das Valquírias",
      "realm": "muspelheim", "type": "valkyrie", "art": "images/placeholder.webp",
      "locationName": "Muspelheim", "mapCoord": {"x": 0, "y": 0},
      "weaknesses": ["sonic", "burn"], "immunities": [],
      "strategy": "Faça-a vacilar.",
      "loot": [{"name": "Escudo Rond"}], "lore": "A Rainha das Valquírias.",
      "mainOrder": 0, "needsReview": true
    }
  ]
}
''';

void main() {
  group('BossRepositoryImpl', () {
    late BossRepositoryImpl repo;

    setUp(() {
      repo = BossRepositoryImpl.withLoader((_) async => _kSeedJson);
    });

    test('returns realms sorted by order', () async {
      final data = await repo.load();

      final orders = data.realms.map((r) => r.order).toList();
      expect(orders, [1, 5, 8]);
      expect(data.realms.first.id, 'midgard');
      expect(data.realms.last.id, 'asgard');
    });

    test('returns the correct number of bosses', () async {
      final data = await repo.load();

      expect(data.bosses.length, 3);
    });

    test('parses boss type correctly', () async {
      final data = await repo.load();

      final fraekni = data.bossById('fraekni_the_zealous');
      expect(fraekni.type, BossType.berserker);

      final heimdall = data.bossById('heimdall');
      expect(heimdall.type, BossType.story);

      final gna = data.bossById('gna');
      expect(gna.type, BossType.valkyrie);
    });

    test('parses boss weaknesses as DamageType list', () async {
      final data = await repo.load();

      final fraekni = data.bossById('fraekni_the_zealous');
      expect(fraekni.weaknesses, [DamageType.stun, DamageType.blades]);

      final heimdall = data.bossById('heimdall');
      expect(heimdall.weaknesses, [DamageType.spear, DamageType.stun]);
      expect(heimdall.immunities, [DamageType.frost]);
    });
  });
}
