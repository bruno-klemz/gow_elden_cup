import 'package:flutter/material.dart';

/// Typography for the favor "diary/shrine" detail screen.
///
/// The design calls for a differentiated themic typeface — a medieval/epic
/// display for titles and a book serif for body. The exact fonts are NOT
/// decided yet; they'll be embedded as assets at a later step. For now these
/// resolve to the platform default. To adopt the real fonts, declare them in
/// pubspec under `fonts:` and set [_displayFamily] / [_bodyFamily] here — every
/// style below picks them up, no widget changes needed.
class FavorText {
  /// Medieval/epic display family for titles & section headers.
  static const String _displayFamily = 'Cinzel';

  /// Book serif family for body copy. Null = default.
  static const String? _bodyFamily = null;

  /// Favor name shown in the body (the prominent title).
  static const title = TextStyle(
    fontFamily: _displayFamily,
    color: Color(0xFFF1E4B8),
    fontSize: 24,
    fontWeight: FontWeight.w700,
    letterSpacing: 0.5,
    height: 1.15,
    shadows: [Shadow(color: Colors.black, blurRadius: 8, offset: Offset(0, 2))],
  );

  /// Section header label (PERGAMINHO / PASSOS / RECOMPENSAS).
  static const sectionLabel = TextStyle(
    fontFamily: _displayFamily,
    color: Color(0xFFE3C886),
    fontSize: 14,
    fontWeight: FontWeight.w700,
    letterSpacing: 1,
  );

  /// Step title.
  static const stepTitle = TextStyle(
    fontFamily: _displayFamily,
    fontSize: 15,
    fontWeight: FontWeight.w700,
    letterSpacing: 0.3,
  );

  /// Body / lore / detail copy.
  static const body = TextStyle(
    fontFamily: _bodyFamily,
    fontSize: 13.5,
    height: 1.7,
  );
}
