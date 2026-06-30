import 'package:flutter_test/flutter_test.dart';
import 'package:gow_elden_cup/favors/domain/entity/favor.dart';
import 'package:gow_elden_cup/favors/domain/entity/favor_step.dart';
import 'package:gow_elden_cup/favors/domain/entity/favors_data.dart';
import 'package:gow_elden_cup/favors/domain/entity/reward.dart';

void main() {
  group('FavorStep.fromJson', () {
    test('parses required fields', () {
      final step = FavorStep.fromJson({
        'id': 's1',
        'title': 'Find the mine',
        'detail': 'Go south.',
      });

      expect(step.id, 's1');
      expect(step.title, 'Find the mine');
      expect(step.detail, 'Go south.');
      expect(step.tip, isNull);
      expect(step.bossId, isNull);
    });

    test('parses optional fields tip and bossId', () {
      final step = FavorStep.fromJson({
        'id': 's2',
        'title': 'Defeat the guardian',
        'detail': 'Watch out.',
        'tip': 'Use Draupnir.',
        'bossId': 'dreki_poison',
      });

      expect(step.tip, 'Use Draupnir.');
      expect(step.bossId, 'dreki_poison');
    });
  });

  group('Reward.fromJson', () {
    test('parses required name', () {
      final reward = Reward.fromJson({'name': 'XP'});

      expect(reward.name, 'XP');
      expect(reward.rarity, isNull);
      expect(reward.quantity, isNull);
    });

    test('parses optional rarity and quantity', () {
      final reward = Reward.fromJson({
        'name': 'Rare Enchantment',
        'rarity': 'epic',
        'quantity': 5000,
      });

      expect(reward.rarity, 'epic');
      expect(reward.quantity, 5000);
    });
  });

  group('Favor.fromJson', () {
    test('parses steps, rewards, and stepIds order', () {
      final f = Favor.fromJson({
        'id': 'lost_treasure',
        'name': 'O Tesouro Perdido',
        'realm': 'svartalfheim',
        'giver': 'Lunda',
        'summary': 'Ajude Lunda.',
        'lore': '...',
        'steps': [
          {'id': 's1', 'title': 'Encontre a mina', 'detail': 'Vá ao sul.'},
          {
            'id': 's2',
            'title': 'Derrote o guardião',
            'detail': 'Cuidado.',
            'bossId': 'dreki_poison'
          },
        ],
        'rewards': [
          {'name': 'Encantamento Raro', 'rarity': 'epic'},
          {'name': 'XP', 'quantity': 5000}
        ],
      });

      expect(f.steps, hasLength(2));
      expect(f.steps[1].bossId, 'dreki_poison');
      expect(f.rewards.first.rarity, 'epic');
      expect(f.stepIds, ['s1', 's2']);
    });

    test('parses optional fields and defaults', () {
      final f = Favor.fromJson({
        'id': 'test_favor',
        'name': 'Test Favor',
        'realm': 'midgard',
        'summary': 'A test.',
        'lore': 'Some lore.',
        'steps': [],
        'rewards': [],
      });

      expect(f.region, isNull);
      expect(f.giver, isNull);
      expect(f.needsReview, isFalse);
      expect(f.stepIds, isEmpty);
    });
  });

  group('FavorsData', () {
    late FavorsData data;

    setUp(() {
      data = FavorsData(favors: [
        Favor.fromJson({
          'id': 'favor_a',
          'name': 'Favor A',
          'realm': 'midgard',
          'summary': 'Summary A.',
          'lore': 'Lore A.',
          'steps': [],
          'rewards': [],
        }),
        Favor.fromJson({
          'id': 'favor_b',
          'name': 'Favor B',
          'realm': 'svartalfheim',
          'summary': 'Summary B.',
          'lore': 'Lore B.',
          'steps': [],
          'rewards': [],
        }),
        Favor.fromJson({
          'id': 'favor_c',
          'name': 'Favor C',
          'realm': 'midgard',
          'summary': 'Summary C.',
          'lore': 'Lore C.',
          'steps': [],
          'rewards': [],
        }),
      ]);
    });

    test('favorsIn returns only favors in the given realm', () {
      final midgard = data.favorsIn('midgard');

      expect(midgard, hasLength(2));
      expect(midgard.map((f) => f.id), containsAll(['favor_a', 'favor_c']));
    });

    test('favorById returns the matching favor', () {
      final favor = data.favorById('favor_b');

      expect(favor.name, 'Favor B');
      expect(favor.realm, 'svartalfheim');
    });
  });
}
