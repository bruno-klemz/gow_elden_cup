import 'package:flutter/material.dart';

class AppColors {
  static const background = Color(0xFF0C1014);
  static const surface = Color(0xFF11161C);
  static const surfaceAlt = Color(0xFF161D26);
  static const frost = Color(0xFF6FA8B5); // Ragnarök frost-blue accent
  static const frostLight = Color(0xFFB8DCE4);
  // Brass gold, kept ONLY as the main-quest marker (a semantic symbol, not the
  // app's theme accent). Everything else uses [frost]/[frostLight].
  static const mainQuest = Color(0xFFC8A24B);
  static const border = Color(0xFF273340);
  static const textMuted = Color(0xFF6E8090);
  static const textBody = Color(0xFF9DB0BF);
  static const strong = Color(0xFF6FA8B5); // frost/ice
  static const weak = Color(0xFFCF7A5A); // fire/burn
  static const stickerCream = Color(0xFFF4EFE2); // die-cut sticker border
}

class AppText {
  /// Epic display family (Roman inscription capitals) for titles & labels.
  /// Body copy (see [lore]) intentionally omits it to stay on the readable
  /// platform default.
  static const displayFamily = 'Cinzel';

  static const title = TextStyle(
    fontFamily: displayFamily,
    color: AppColors.frost,
    fontSize: 20,
    fontWeight: FontWeight.w800,
  );
  static const regionLabel = TextStyle(
    fontFamily: displayFamily,
    color: Color(0xFFB9C6D2),
    fontSize: 13,
    fontWeight: FontWeight.w700,
    letterSpacing: 1,
    height: 1,
  );
  static const sectionLabel = TextStyle(
    fontFamily: displayFamily,
    color: AppColors.textMuted,
    fontSize: 11,
    fontWeight: FontWeight.w800,
    letterSpacing: 1.2,
  );
  static const lore = TextStyle(
    color: AppColors.textBody,
    fontSize: 13,
    height: 1.65,
  );
  static const slotName = TextStyle(
    fontFamily: displayFamily,
    color: AppColors.frostLight,
    fontSize: 9,
    fontWeight: FontWeight.w800,
    letterSpacing: .3,
  );
}

/// Shifts [c]'s lightness by [dl] (clamped 0..1) and scales its saturation by
/// [satFactor], in HSL — so any accent (e.g. a realm colour) can be tinted
/// lighter/darker/duller predictably. Shared by the realm-accent theming.
Color shade(Color c, {double dl = 0, double satFactor = 1}) {
  final hsl = HSLColor.fromColor(c);
  return hsl
      .withLightness((hsl.lightness + dl).clamp(0.0, 1.0))
      .withSaturation((hsl.saturation * satFactor).clamp(0.0, 1.0))
      .toColor();
}
