import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Background — warm off-white, not stark white
  static const Color background = Color(0xFFFAFAF7);
  static const Color surface    = Color(0xFFFFFFFF);

  // Ink — never pure black, always slightly warm
  static const Color textPrimary   = Color(0xFF1A1A18);
  static const Color textSecondary = Color(0xFF6B6B66);
  static const Color textTertiary  = Color(0xFFB4B2A9);

  // Hairlines
  static const Color border       = Color(0x141A1A18); // 8% ink
  static const Color borderStrong = Color(0x1F1A1A18); // 12% ink

  // Single accent — terracotta
  static const Color accent     = Color(0xFFC9522E);
  static const Color accentSoft = Color(0x14C9522E); // 8% terracotta

  // Semantic — used quietly, never as primary expression
  static const Color success = Color(0xFF1D9E75);
  static const Color error   = Color(0xFFA32D2D);
  static const Color warning = Color(0xFFBA7517);

  // Legacy aliases — keep so existing screens still compile
  static const Color primary       = accent;
  static const Color secondary     = success;
}
