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
}
