import 'package:flutter/material.dart';
import '../../utils/app_colors.dart';

class AppTheme {
  // Simple shared text styles. Import and use where needed for consistent typography.
  static TextStyle get titleLarge => const TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w700,
    color: Color(0xFF111827),
  );

  static TextStyle get titleMedium => const TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: Color(0xFF111827),
  );

  static TextStyle get body =>
      TextStyle(fontSize: 14, color: AppColors.secondaryText);
}
