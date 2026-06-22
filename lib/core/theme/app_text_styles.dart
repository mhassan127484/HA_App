import 'package:flutter/material.dart';
import 'app_colors.dart';

class HATextStyles {
  static const String _fontFamily = 'Inter';

  // ── Display ────────────────────────────────────────────────────
  static const TextStyle displayLarge = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 57,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.25,
    height: 1.12,
  );

  static const TextStyle displayMedium = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 45,
    fontWeight: FontWeight.w700,
    letterSpacing: 0,
    height: 1.16,
  );

  // ── Headlines ──────────────────────────────────────────────────
  static const TextStyle h1 = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 32,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.5,
    height: 1.25,
  );

  static const TextStyle h2 = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 26,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.3,
    height: 1.3,
  );

  static const TextStyle h3 = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 22,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.2,
    height: 1.36,
  );

  static const TextStyle h4 = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 18,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.1,
    height: 1.44,
  );

  static const TextStyle h5 = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 16,
    fontWeight: FontWeight.w600,
    letterSpacing: 0,
    height: 1.5,
  );

  // ── Body ───────────────────────────────────────────────────────
  static const TextStyle bodyLarge = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 16,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.15,
    height: 1.5,
  );

  static const TextStyle bodyMedium = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.25,
    height: 1.43,
  );

  static const TextStyle bodySmall = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 12,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.4,
    height: 1.33,
  );

  // ── Label / Caption ────────────────────────────────────────────
  static const TextStyle labelLarge = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.1,
    height: 1.43,
  );

  static const TextStyle labelMedium = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 12,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.5,
    height: 1.33,
  );

  static const TextStyle labelSmall = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 11,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.5,
    height: 1.45,
  );

  // ── Price ──────────────────────────────────────────────────────
  static const TextStyle priceLarge = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 24,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.5,
    color: HAColors.secondary,
  );

  static const TextStyle priceMedium = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 18,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.3,
    color: HAColors.secondary,
  );

  static const TextStyle priceSmall = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: HAColors.secondary,
  );

  static const TextStyle priceStrikethrough = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 12,
    fontWeight: FontWeight.w400,
    decoration: TextDecoration.lineThrough,
    color: HAColors.slate400,
  );

  // ── Aliases ───────────────────────────────────────────────────
  static const TextStyle priceMain     = priceLarge;
  static const TextStyle priceOriginal = priceStrikethrough;
}
