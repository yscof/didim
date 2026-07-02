import 'package:flutter/material.dart';

/// 디딤 브랜드 컬러. 신뢰감 있는 딥 블루 계열 + 성장 강조용 그린.
const Color kSeedColor = Color(0xFF2E5BFF);
const Color kGrowthColor = Color(0xFF12B76A);
const Color kPrincipalColor = Color(0xFF98A2B3);

ThemeData buildAppTheme() {
  final scheme = ColorScheme.fromSeed(
    seedColor: kSeedColor,
    brightness: Brightness.light,
  );
  return ThemeData(
    colorScheme: scheme,
    useMaterial3: true,
    scaffoldBackgroundColor: const Color(0xFFF7F8FA),
    appBarTheme: const AppBarTheme(
      centerTitle: true,
      backgroundColor: Colors.transparent,
      elevation: 0,
    ),
    cardTheme: CardThemeData(
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      margin: EdgeInsets.zero,
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        minimumSize: const Size.fromHeight(54),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
      ),
    ),
  );
}
