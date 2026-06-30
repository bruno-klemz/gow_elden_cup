import 'package:flutter_test/flutter_test.dart';
import 'package:gow_elden_cup/favors/data/repository/favors_repository_impl.dart';

const _kSeedJson = '''
{
  "favors": [
    {
      "id": "the_lost_lindwyrm",
      "name": "A Linhagem Perdida",
      "realm": "svartalfheim",
      "region": "Jarnsmida Pitmines",
      "giver": "Lunda",
      "summary": "Recupere um tesouro anão.",
      "lore": "Os anões de Svartalfheim guardam segredos antigos sob a terra.",
      "steps": [
        {"id": "s1", "title": "Abra o portão da mina", "detail": "Use a Lança Draupnir no mecanismo ao sul.", "tip": "Cuidado com os Grims."},
        {"id": "s2", "title": "Derrote o guardião", "detail": "Um Dreki bloqueia a câmara final.", "bossId": "dreki_poison"}
      ],
      "rewards": [{"name": "Encantamento Raro", "rarity": "epic"}, {"name": "Hacksilver", "quantity": 8000}],
      "needsReview": true
    },
    {
      "id": "weight_of_chains",
      "name": "O Peso das Correntes",
      "realm": "alfheim",
      "summary": "Liberte os prisioneiros da Luz.",
      "lore": "A Luz de Alfheim corrompeu muitos.",
      "steps": [
        {"id": "s1", "title": "Encontre a prisão", "detail": "Nas cavernas ao norte."}
      ],
      "rewards": [{"name": "XP", "quantity": 3000}],
      "needsReview": false
    }
  ]
}
''';

void main() {
  group('FavorsRepositoryImpl', () {
    late FavorsRepositoryImpl repo;

    setUp(() {
      repo = FavorsRepositoryImpl.withLoader((_) async => _kSeedJson);
    });

    test('returns the correct number of favors', () async {
      final data = await repo.load();

      expect(data.favors.length, 2);
    });

    test('parses steps correctly for the first favor', () async {
      final data = await repo.load();

      final favor = data.favorById('the_lost_lindwyrm');
      expect(favor.steps, hasLength(2));
      expect(favor.steps[0].tip, 'Cuidado com os Grims.');
      expect(favor.steps[1].bossId, 'dreki_poison');
      expect(favor.stepIds, ['s1', 's2']);
    });

    test('favorById returns the right favor', () async {
      final data = await repo.load();

      final favor = data.favorById('weight_of_chains');
      expect(favor.name, 'O Peso das Correntes');
      expect(favor.realm, 'alfheim');
      expect(favor.rewards.first.quantity, 3000);
    });

    test('parses needsReview correctly', () async {
      final data = await repo.load();

      expect(data.favorById('the_lost_lindwyrm').needsReview, isTrue);
      expect(data.favorById('weight_of_chains').needsReview, isFalse);
    });
  });
}
