import 'package:flutter/material.dart';

/// CloseMap brand palette, derived from the logo.
class AppColors {
  AppColors._();

  // Brand colors from the logo
  static const Color teal = Color(0xFF2F9C8B);
  static const Color pink = Color(0xFFEFA6DA);
  static const Color blue = Color(0xFF3D6BE5);
  static const Color orange = Color(0xFFE8542F);
  static const Color navy = Color(0xFF121333);

  // Primary scheme
  static const Color primary = blue;
  static const Color primaryAction = teal;
  static const Color secondary = teal;
  static const Color accent = orange;

  // Surfaces
  static const Color scaffoldBg = Color(0xFFF8F8F8);
  static const Color background = Color(0xFFF7F8FC);
  static const Color surface = Colors.white;
  static const Color surfaceMuted = Color(0xFFEFF1F8);
  static const Color border = Color(0xFFE2E5F0);

  // Text
  static const Color textPrimary = navy;
  static const Color textSecondary = Color(0xFF6B6E8A);
  static const Color textHint = Color(0xFFA2A5BD);

  // Status
  static const Color success = Color(0xFF27AE60);
  static const Color warning = Color(0xFFF2B705);
  static const Color error = Color(0xFFE53935);

  // Application status colors (per spec: blue pending, green viewed, red rejected)
  static const Color statusPending = blue;
  static const Color statusViewed = success;
  static const Color statusRejected = error;

  // Subscription tiers
  static const Color bronze = Color(0xFFCD7F32);
  static const Color silver = Color(0xFF9EA7B3);
  static const Color gold = Color(0xFFD4A017);
}
