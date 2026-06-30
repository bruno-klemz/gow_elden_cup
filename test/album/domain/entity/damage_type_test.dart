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
  test('fromKey resolves snake_case aliases', () {
    expect(DamageType.fromKey('chaos_blades'), DamageType.blades);
    expect(DamageType.fromKey('leviathan_axe'), DamageType.axe);
    expect(DamageType.fromKey('draupnir_spear'), DamageType.spear);
  });
}
