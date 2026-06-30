import 'package:flutter/material.dart';

class AppColors {
  static const background = Color(0xFF0C1014);
  static const surface = Color(0xFF11161C);
  static const surfaceAlt = Color(0xFF161D26);
  static const gold = Color(0xFFC8A24B); // Kratos' Blades brass accent
  static const goldLight = Color(0xFFE8D9A0);
  static const border = Color(0xFF273340);
  static const textMuted = Color(0xFF6E8090);
  static const textBody = Color(0xFF9DB0BF);
  static const strong = Color(0xFF6FA8B5); // frost/ice
  static const weak = Color(0xFFCF7A5A); // fire/burn
}

class AppText {
  static const title = TextStyle(
    color: AppColors.gold,
    fontSize: 20,
    fontWeight: FontWeight.w800,
  );
  static const regionLabel = TextStyle(
    color: Color(0xFFB9C6D2),
    fontSize: 13,
    fontWeight: FontWeight.w700,
    letterSpacing: 1,
    height: 1,
  );
  static const sectionLabel = TextStyle(
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
    color: AppColors.goldLight,
    fontSize: 9,
    fontWeight: FontWeight.w800,
    letterSpacing: .3,
  );
}
