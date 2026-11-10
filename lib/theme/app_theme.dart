import 'package:flutter/material.dart';

class AppColors {
  // Backgrounds
  static const Color background = Color(0xFF0B0F19); // 딥 옵시디언 네이비
  static const Color surface = Color(0xFF131B2E); // 카드 표면
  static const Color surfaceLighter = Color(0xFF1E293B); // 서브 카드/컨테이너
  static const Color border = Color(0xFF1E2942); // 글래스모피즘 보더
  static const Color borderGlow = Color(0xFF334155);

  // Brand Accents
  static const Color primary = Color(0xFF6366F1); // 인디고 바이올렛
  static const Color primaryGlow = Color(0x336366F1);
  static const Color accent = Color(0xFF8B5CF6);
  static const Color success = Color(0xFF10B981);
  static const Color warning = Color(0xFFF59E0B);
  static const Color danger = Color(0xFFEF4444);

  // Platform Colors
  static const Color github = Color(0xFFF0F6FC);
  static const Color reddit = Color(0xFFFF5722);
  static const Color xTwitter = Color(0xFF38BDF8);
  static const Color facebook = Color(0xFF3B82F6);
  static const Color google = Color(0xFF34A853);

  // Text
  static const Color textPrimary = Color(0xFFF8FAFC);
  static const Color textSecondary = Color(0xFF94A3B8);
  static const Color textMuted = Color(0xFF64748B);
}

class AppTheme {
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.background,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.primary,
        secondary: AppColors.accent,
        surface: AppColors.surface,
        background: AppColors.background,
        onPrimary: Colors.white,
        onSurface: AppColors.textPrimary,
      ),
      fontFamily: 'Pretendard',
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.background,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: AppColors.textPrimary,
          letterSpacing: -0.5,
        ),
      ),
      cardTheme: CardTheme(
        color: AppColors.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AppColors.border, width: 1),
        ),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
    );
  }
}
