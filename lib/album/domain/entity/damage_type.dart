import 'package:flutter/material.dart';

enum DamageType {
  frost('Gelo', '❄️', Color(0xFF1F2C3A)),
  burn('Queimadura', '🔥', Color(0xFF3A2418)),
  poison('Veneno', '☠️', Color(0xFF26331F)),
  lightning('Raio', '⚡', Color(0xFF33301A)),
  stun('Atordoamento', '💫', Color(0xFF33301A)),
  sonic('Sônico', '🔊', Color(0xFF231F3A)),
  bifrost('Bifröst', '🌈', Color(0xFF231F3A)),
  blades('Lâminas do Caos', '🗡️', Color(0xFF3A1A1A)),
  axe('Machado Leviatã', '🪓', Color(0xFF1F2C3A)),
  spear('Lança Draupnir', '🔱', Color(0xFF2A2420)),
  physical('Físico', '👊', Color(0xFF2A2420)),
  weaken('Enfraquecer', '🩸', Color(0xFF3A1A1A));

  const DamageType(this.label, this.emoji, this.color);
  final String label;
  final String emoji;
  final Color color;

  static DamageType fromKey(String key) {
    for (final t in DamageType.values) {
      if (t.name == key) return t;
    }
    // explicit aliases for snake_case JSON keys
    switch (key) {
      case 'chaos_blades':
        return DamageType.blades;
      case 'leviathan_axe':
        return DamageType.axe;
      case 'draupnir_spear':
        return DamageType.spear;
      default:
        throw ArgumentError('Unknown damage type: $key');
    }
  }
}
