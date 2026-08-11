import 'package:flutter/material.dart';

class AppColors {
  // Premium Tech Palette
  static const Color primary = Color(0xFF6C5CE7); // Electric purple
  static const Color primaryDark = Color(0xFF5A4BD1);
  static const Color primaryLight = Color(0xFFA29BFE);

  static const Color secondary = Color(0xFF00D2FF); // Cyan neon
  static const Color accent = Color(0xFFFD79A8); // Pink accent

  static const Color backgroundLight = Color(0xFFF8F9FA);
  static const Color backgroundDark = Color(0xFF0F0F14);
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color surfaceDark = Color(0xFF1E1E2A);

  static const Color cardLight = Color(0xFFFFFFFF);
  static const Color cardDark = Color(0xFF252836);

  static const Color textPrimaryLight = Color(0xFF1A1D29);
  static const Color textPrimaryDark = Color(0xFFEAEAF0);
  static const Color textSecondaryLight = Color(0xFF6B7280);
  static const Color textSecondaryDark = Color(0xFF9CA3AF);

  static const Color borderLight = Color(0xFFE5E7EB);
  static const Color borderDark = Color(0xFF2D3748);

  static const Color success = Color(0xFF00B894);
  static const Color warning = Color(0xFFFDCB6E);
  static const Color error = Color(0xFFD63031);
  static const Color info = Color(0xFF0984E3);

  static const Color shimmerBaseLight = Color(0xFFE5E7EB);
  static const Color shimmerHighlightLight = Color(0xFFF3F4F6);
  static const Color shimmerBaseDark = Color(0xFF2D3748);
  static const Color shimmerHighlightDark = Color(0xFF3A4558);

  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primary, secondary],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient cardGradient = LinearGradient(
    colors: [Color(0xFF6C5CE7), Color(0xFF00D2FF)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient darkGradient = LinearGradient(
    colors: [Color(0xFF1E1E2A), Color(0xFF2D2D44)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}

class AppShadows {
  static const BoxShadow cardLight = BoxShadow(
    color: Color(0x0A000000),
    blurRadius: 12,
    offset: Offset(0, 4),
  );
  static const BoxShadow cardDark = BoxShadow(
    color: Color(0x1A000000),
    blurRadius: 16,
    offset: Offset(0, 8),
  );
  static const BoxShadow elevated = BoxShadow(
    color: Color(0x15000000),
    blurRadius: 24,
    offset: Offset(0, 12),
  );
}
