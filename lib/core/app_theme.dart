import 'package:flutter/material.dart';

/// Define los temas de la aplicación.
abstract final class AppTheme {
  static const Color _cream = Color(0xFFF8F2EC);
  static const Color _seed = Color(0xFFFF7043);

  static ThemeData get light => ThemeData(
        useMaterial3: true,
        fontFamily: 'Roboto',
        scaffoldBackgroundColor: _cream,
        colorScheme: ColorScheme.fromSeed(
          seedColor: _seed,
          surface: _cream,
        ),
      );
}
