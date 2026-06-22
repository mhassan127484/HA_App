import 'package:flutter/material.dart';

class HAColors {
  // ── Brand Palette ──────────────────────────────────────────────
  static const Color primary      = Color(0xFF0F172A); // Slate 900
  static const Color secondary    = Color(0xFF3B82F6); // Blue 500
  static const Color accent       = Color(0xFF06B6D4); // Cyan 500

  // ── Semantic ───────────────────────────────────────────────────
  static const Color success      = Color(0xFF10B981); // Emerald 500
  static const Color warning      = Color(0xFFF59E0B); // Amber 500
  static const Color error        = Color(0xFFEF4444); // Red 500
  static const Color info         = Color(0xFF6366F1); // Indigo 500

  // ── Neutrals ───────────────────────────────────────────────────
  static const Color slate50      = Color(0xFFF8FAFC);
  static const Color slate100     = Color(0xFFF1F5F9);
  static const Color slate200     = Color(0xFFE2E8F0);
  static const Color slate300     = Color(0xFFCBD5E1);
  static const Color slate400     = Color(0xFF94A3B8);
  static const Color slate500     = Color(0xFF64748B);
  static const Color slate600     = Color(0xFF475569);
  static const Color slate700     = Color(0xFF334155);
  static const Color slate800     = Color(0xFF1E293B);
  static const Color slate900     = Color(0xFF0F172A);
  static const Color slate950     = Color(0xFF020617);

  // ── Dark Theme Surface ─────────────────────────────────────────
  static const Color darkBg           = Color(0xFF0A0E1A);
  static const Color darkSurface      = Color(0xFF111827);
  static const Color darkCard         = Color(0xFF1C2534);
  static const Color darkElevated     = Color(0xFF243040);
  static const Color darkBorder       = Color(0xFF2D3A4F);
  static const Color darkDivider      = Color(0xFF1F2D3D);

  // ── Light Theme Surface ────────────────────────────────────────
  static const Color lightBg          = Color(0xFFF8FAFC);
  static const Color lightSurface     = Color(0xFFFFFFFF);
  static const Color lightCard        = Color(0xFFFFFFFF);
  static const Color lightElevated    = Color(0xFFF1F5F9);
  static const Color lightBorder      = Color(0xFFE2E8F0);
  static const Color lightDivider     = Color(0xFFF1F5F9);

  // ── Gradients ─────────────────────────────────────────────────
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF3B82F6), Color(0xFF06B6D4)],
  );

  static const LinearGradient darkGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFF0F172A), Color(0xFF1E293B)],
  );

  static const LinearGradient flashSaleGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFEF4444), Color(0xFFF59E0B)],
  );

  static const LinearGradient cardGlassGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0x1AFFFFFF), Color(0x0DFFFFFF)],
  );

  // ── Shimmer ────────────────────────────────────────────────────
  static const Color shimmerBase      = Color(0xFF1C2534);
  static const Color shimmerHighlight = Color(0xFF2D3A4F);
  static const Color shimmerBaseLight = Color(0xFFE8EAED);
  static const Color shimmerHighlightLight = Color(0xFFF5F5F5);

  // ── Text ───────────────────────────────────────────────────────
  static const Color textPrimaryDark   = Color(0xFFF8FAFC);
  static const Color textSecondaryDark = Color(0xFF94A3B8);
  static const Color textTertiaryDark  = Color(0xFF64748B);
  static const Color textPrimaryLight  = Color(0xFF0F172A);
  static const Color textSecondaryLight= Color(0xFF475569);
  static const Color textTertiaryLight = Color(0xFF94A3B8);

  // ── Aliases ────────────────────────────────────────────────────
  static const Color darkBackground = darkBg;
  static const Color lightBackground = lightBg;
}
