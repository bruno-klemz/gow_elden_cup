import 'package:gow_elden_cup/album/presenter/search/search_match.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('matches case-insensitively', () {
    expect(searchMatches('Midgard', 'mid'), isTrue);
    expect(searchMatches('midgard', 'MID'), isTrue);
  });

  test('matches ignoring diacritics', () {
    expect(searchMatches('Niflheim da Névoa', 'nevoa'), isTrue);
    expect(searchMatches('Asgard Cinérea', 'cinerea'), isTrue);
  });

  test('matches anywhere in the string', () {
    expect(searchMatches('O Lobo Fenrir de Odin', 'fenrir'), isTrue);
  });

  test('empty query matches everything', () {
    expect(searchMatches('whatever', ''), isTrue);
    expect(searchMatches('whatever', '   '), isTrue);
  });

  test('non-match returns false', () {
    expect(searchMatches('Midgard', 'vanaheim'), isFalse);
  });
}
