import 'package:flutter_test/flutter_test.dart';
import 'package:gow_elden_cup/album/domain/entity/damage_type.dart';

void main() {
  test('fromKey maps GoW keys', () {
    expect(DamageType.fromKey('frost'), DamageType.frost);
    expect(DamageType.fromKey('burn'), DamageType.burn);
    expect(DamageType.fromKey('stun'), DamageType.stun);
    expect(DamageType.fromKey('sonic'), DamageType.sonic);
  });
  test('fromKey throws on unknown', () {
    expect(() => DamageType.fromKey('scarlet_rot'), throwsArgumentError);
  });
}
