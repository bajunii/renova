import 'package:flutter/material.dart';

class AppColors {
  // Prevent instantiation
  AppColors._();

  static const Color primary = Colors.green;
  static const Color accent = Colors.greenAccent;
  static const Color background = Colors.white;
  static const Color text = Color(0xFF111827);

  // Optional extras for better UI consistency
  static const Color secondaryText = Color(0xFF374151); // lighter gray text
  static const Color border = Color(0xFFE5E7EB); // subtle border gray
  static const Color success = Color(0xFF10B981); // green for success
  static const Color error = Color(0xFFEF4444); // red for error

    // Base colors
  // static const Color primary = Color(0xFF1565C0);
  // static const Color secondary = Color(0xFF2E7D32);
  // static const Color error = Color(0xFFB00020);
  // static const Color success = Color(0xFF388E3C);
  // static const Color warning = Color(0xFFF57F17);
  // static const Color info = Color(0xFF0288D1);
  
  // Text colors
  static const Color textPrimary = Color(0xFF212121);
  static const Color textSecondary = Color(0xFF757575);
  static const Color textDisabled = Color(0xFFBDBDBD);
  static const Color textOnPrimary = Color(0xFFFFFFFF);
  static const Color textOnSecondary = Color(0xFFFFFFFF);
  
  // Background colors
  static const Color backgroundPrimary = Color(0xFFFFFFFF);
  static const Color backgroundSecondary = Color(0xFFF5F5F5);
  static const Color backgroundDisabled = Color(0xFFE0E0E0);
}
