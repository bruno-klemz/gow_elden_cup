import 'package:flutter/material.dart';

/// Per-realm visual identity for the favors feature: an accent colour and a
/// rune image (the "seal" that fills like a pool). The shrine backdrop is a
/// single shared image used behind every realm's detail screen.
///
/// Each realm's [accent] matches the dominant colour of its rune's ring, so
/// filling the pool reads as the water "colouring in" the rune. Accents were
/// sampled from the rune art; tweak a value here to retune a realm without
/// touching any widget.
class RealmTheme {
  const RealmTheme({
    required this.accent,
    required this.runeAsset,
    required this.shrineAsset,
  });

  /// Colour used for the water fill, halo and lit rune.
  final Color accent;

  /// Rune image asset (the seal that floods bottom-up with progress).
  final String runeAsset;

  /// Full-bleed shrine image used as the (blurred) detail background. Shared by
  /// every realm.
  final String shrineAsset;

  /// The one shrine backdrop, used for all realms.
  static const _shrine = 'assets/images/shrines/alfheim.jpg';

  /// Fallbacks for any realm id not present in the maps below.
  static const _fallbackAccent = Color(0xFF45A0B9);
  static const _fallbackRune = 'assets/images/runes/alfheim.webp';

  /// Per-realm accent, matched to each rune's ring colour (sampled from art).
  static const Map<String, Color> _accents = {
    // Midgard & Asgard rings are silver/white (the olive is only the outer
    // frame), so their water is a cool silver-white rather than the sampled
    // olive.
    'midgard': Color(0xFFC8D2DA), // silver-white
    'alfheim': Color(0xFF45A0B9), // teal-blue
    'svartalfheim': Color(0xFF5255AC), // indigo
    'muspelheim': Color(0xFFAC5852), // fire red
    'niflheim': Color(0xFF66B14D), // jade green
    'vanaheim': Color(0xFFAC52AA), // magenta
    'helheim': Color(0xFF62B3AF), // pale teal
    'asgard': Color(0xFFC8D2DA), // silver-white
    'jotunheim': Color(0xFFBDAB75), // tan/gold
  };

  /// Per-realm rune assets (all nine realms shipped).
  static const Map<String, String> _runes = {
    'midgard': 'assets/images/runes/midgard.webp',
    'alfheim': 'assets/images/runes/alfheim.webp',
    'svartalfheim': 'assets/images/runes/svartalfheim.webp',
    'muspelheim': 'assets/images/runes/muspelheim.webp',
    'niflheim': 'assets/images/runes/niflheim.webp',
    'vanaheim': 'assets/images/runes/vanaheim.webp',
    'helheim': 'assets/images/runes/helheim.webp',
    'asgard': 'assets/images/runes/asgard.webp',
    'jotunheim': 'assets/images/runes/jotunheim.webp',
  };

  /// Resolves the theme for [realmId], using fallbacks for unknown realms.
  factory RealmTheme.of(String realmId) {
    return RealmTheme(
      accent: _accents[realmId] ?? _fallbackAccent,
      runeAsset: _runes[realmId] ?? _fallbackRune,
      shrineAsset: _shrine,
    );
  }
}
