import 'dart:ui';
import 'package:flutter/material.dart';

class AppTheme {
  // ========== Border Radius ==========
  static const double radiusXs = 4.0;
  static const double radiusSm = 8.0;
  static const double radiusMd = 12.0;
  static const double radiusLg = 16.0;
  static const double radiusXl = 20.0;
  static const double radius2xl = 24.0;
  static const double radiusFull = 9999.0;

  // ========== Spacing ==========
  static const double spacing2xs = 4.0;
  static const double spacingXs = 8.0;
  static const double spacingSm = 12.0;
  static const double spacingMd = 16.0;
  static const double spacingLg = 24.0;
  static const double spacingXl = 32.0;
  static const double spacing2xl = 48.0;
  static const double spacing3xl = 64.0;

  // ========== Typography ==========

  // Headings
  static const TextStyle h1 = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.5,
  );

  static const TextStyle h2 = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.3,
  );

  static const TextStyle h3 = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.2,
  );

  static const TextStyle h4 = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
  );

  // Text
  static const TextStyle bodyLarge = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    height: 1.5,
  );

  static const TextStyle bodyMedium = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    height: 1.5,
  );

  static const TextStyle bodySmall = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    height: 1.5,
  );

  static const TextStyle button = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.5,
  );

  static const TextStyle caption = TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w400,
    height: 1.27,
  );

  static const TextStyle label = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w500,
  );

  // ========== Theme Data ==========
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      extensions: const <ThemeExtension<dynamic>>[
        ColorTheme(
          // Brand colors
          primary: Color(0xFFFF6B9D), // primaryPink
          secondary: Color(0xFF7DD3FC), // primaryBlue
          tertiary: Color(0xFFA78BFA), // primaryPurple

          // Semantic colors
          success: Color(0xFF10B981),
          warning: Color(0xFFF59E0B),
          info: Color(0xFF3B82F6),
          error: Color(0xFFEF4444),

          // Background & Surface
          background: Color(0xFFFFFFFF),
          surface: Color(0xFFF5F5F5),
          surfaceVariant: Color(0xFFE5E7EB),

          // Text colors
          textPrimary: Color(0xFF1F1F1F),
          textSecondary: Color(0xFF6B7280),
          textTertiary: Color(0xFF9CA3AF),

          // Border colors
          border: Color(0xFFE5E5E5),
          borderAccent: Color(0xFFC7C7C7),

          // Gradient
          gradientColors: [
            Color(0xFFFFF1F7), // Soft blush pink
            Color(0xFFFCE7F3), // Light rose
            Color(0xFFE0F2FE), // Sky blue
          ],
        ),
      ],
      scaffoldBackgroundColor: Colors.transparent,
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFFFFFFFF),
        elevation: 0,
        iconTheme: IconThemeData(color: Color(0xFF1F1F1F)),
        titleTextStyle: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          letterSpacing: -0.2,
          color: Color(0xFF1F1F1F),
        ),
      ),
      cardTheme: CardThemeData(
        color: Colors.white,
        elevation: 1,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusXl),
          side: const BorderSide(color: Color(0xFFE5E5E5), width: 1),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFFF6B9D),
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(
            horizontal: spacingLg,
            vertical: spacingSm,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusMd),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFFF5F5F5),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusSm),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusSm),
          borderSide: const BorderSide(color: Color(0xFFE5E5E5), width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusSm),
          borderSide: const BorderSide(color: Color(0xFFFF6B9D), width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusSm),
          borderSide: const BorderSide(color: Color(0xFFEF4444), width: 1),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: spacingMd,
          vertical: spacingSm,
        ),
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      extensions: const <ThemeExtension<dynamic>>[
        ColorTheme(
          // Brand colors (same across themes)
          primary: Color(0xFFFF6B9D),
          secondary: Color(0xFF7DD3FC),
          tertiary: Color(0xFFA78BFA),

          // Semantic colors (brighter for dark mode)
          success: Color(0xFF34D399),
          warning: Color(0xFFFBBF24),
          info: Color(0xFF60A5FA),
          error: Color(0xFFF87171),

          // Background & Surface
          background: Color(0xFF121212),
          surface: Color(0xFF1E1E1E),
          surfaceVariant: Color(0xFF2D2D2D),

          // Text colors
          textPrimary: Color(0xFFE5E5E5),
          textSecondary: Color(0xFF9CA3AF),
          textTertiary: Color(0xFF6B7280),

          // Border colors
          border: Color(0xFF374151),
          borderAccent: Color(0xFF4B5563),

          // Gradient
          gradientColors: [
            Color(0xFF1a0b2e), // Deep purple-black
            Color(0xFF2d1b4e), // Rich purple
            Color(0xFF1e3a5f), // Deep blue
          ],
        ),
      ],
      scaffoldBackgroundColor: Colors.transparent,
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFF1E1E1E),
        elevation: 0,
        iconTheme: IconThemeData(color: Color(0xFFE5E5E5)),
        titleTextStyle: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          letterSpacing: -0.2,
          color: Color(0xFFE5E5E5),
        ),
      ),
      cardTheme: CardThemeData(
        color: const Color(0xFF1E1E1E),
        elevation: 1,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusXl),
          side: const BorderSide(color: Color(0xFF374151), width: 1),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFFF6B9D),
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(
            horizontal: spacingLg,
            vertical: spacingSm,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusMd),
          ),
        ),
      ),
    );
  }

  // ========== Glass Morphism Helper ==========
  /// Creates a theme-aware glass morphism container
  /// Automatically adjusts colors based on light/dark mode
  static Widget glassContainer({
    required Widget child,
    required BuildContext context,
    double opacity = 0.1,
    double blurAmount = 10.0,
    BorderRadius? borderRadius,
    EdgeInsets? padding,
    double? width,
    double? height,
    Color? customColor, // Override automatic color selection
  }) {
    // Get theme-aware colors
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Choose base color based on theme (or use custom)
    final baseColor = customColor ?? (isDark ? Colors.black : Colors.white);

    // Border color adapts to theme
    final borderColor =
        isDark ? Colors.white.withOpacity(0.1) : Colors.white.withOpacity(0.3);

    return ClipRRect(
      borderRadius: borderRadius ?? BorderRadius.circular(radiusXl),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blurAmount, sigmaY: blurAmount),
        child: Container(
          width: width,
          height: height,
          padding: padding,
          decoration: BoxDecoration(
            color: baseColor.withOpacity(opacity),
            borderRadius: borderRadius ?? BorderRadius.circular(radiusXl),
            border: Border.all(
              color: borderColor,
              width: 1.5,
            ),
          ),
          child: child,
        ),
      ),
    );
  }

  /// Creates a frosted glass card with theme-aware styling
  static Widget glassCard({
    required Widget child,
    required BuildContext context,
    EdgeInsets? padding,
    EdgeInsets? margin,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: margin ?? const EdgeInsets.all(spacingMd),
      child: glassContainer(
        context: context,
        opacity: isDark ? 0.15 : 0.7,
        blurAmount: 12.0,
        padding: padding ?? const EdgeInsets.all(spacingLg),
        child: child,
      ),
    );
  }
}

// ========== Single Color System ==========
/// ColorTheme is the ONLY color system in the app.
/// All colors are defined here and change based on light/dark mode.
class ColorTheme extends ThemeExtension<ColorTheme> {
  // Brand colors
  final Color primary;
  final Color secondary;
  final Color tertiary;

  // Semantic colors
  final Color success;
  final Color warning;
  final Color info;
  final Color error;

  // Background & Surface
  final Color background;
  final Color surface;
  final Color surfaceVariant;

  // Text colors
  final Color textPrimary;
  final Color textSecondary;
  final Color textTertiary;

  // Border colors
  final Color border;
  final Color borderAccent;

  // Gradients
  final List<Color> gradientColors;

  const ColorTheme({
    required this.primary,
    required this.secondary,
    required this.tertiary,
    required this.success,
    required this.warning,
    required this.info,
    required this.error,
    required this.background,
    required this.surface,
    required this.surfaceVariant,
    required this.textPrimary,
    required this.textSecondary,
    required this.textTertiary,
    required this.border,
    required this.borderAccent,
    required this.gradientColors,
  });

  @override
  ColorTheme copyWith({
    Color? primary,
    Color? secondary,
    Color? tertiary,
    Color? success,
    Color? warning,
    Color? info,
    Color? error,
    Color? background,
    Color? surface,
    Color? surfaceVariant,
    Color? textPrimary,
    Color? textSecondary,
    Color? textTertiary,
    Color? border,
    Color? borderAccent,
    List<Color>? gradientColors,
  }) {
    return ColorTheme(
      primary: primary ?? this.primary,
      secondary: secondary ?? this.secondary,
      tertiary: tertiary ?? this.tertiary,
      success: success ?? this.success,
      warning: warning ?? this.warning,
      info: info ?? this.info,
      error: error ?? this.error,
      background: background ?? this.background,
      surface: surface ?? this.surface,
      surfaceVariant: surfaceVariant ?? this.surfaceVariant,
      textPrimary: textPrimary ?? this.textPrimary,
      textSecondary: textSecondary ?? this.textSecondary,
      textTertiary: textTertiary ?? this.textTertiary,
      border: border ?? this.border,
      borderAccent: borderAccent ?? this.borderAccent,
      gradientColors: gradientColors ?? this.gradientColors,
    );
  }

  @override
  ColorTheme lerp(ThemeExtension<ColorTheme>? other, double t) {
    if (other is! ColorTheme) {
      return this;
    }
    return ColorTheme(
      primary: Color.lerp(primary, other.primary, t)!,
      secondary: Color.lerp(secondary, other.secondary, t)!,
      tertiary: Color.lerp(tertiary, other.tertiary, t)!,
      success: Color.lerp(success, other.success, t)!,
      warning: Color.lerp(warning, other.warning, t)!,
      info: Color.lerp(info, other.info, t)!,
      error: Color.lerp(error, other.error, t)!,
      background: Color.lerp(background, other.background, t)!,
      surface: Color.lerp(surface, other.surface, t)!,
      surfaceVariant: Color.lerp(surfaceVariant, other.surfaceVariant, t)!,
      textPrimary: Color.lerp(textPrimary, other.textPrimary, t)!,
      textSecondary: Color.lerp(textSecondary, other.textSecondary, t)!,
      textTertiary: Color.lerp(textTertiary, other.textTertiary, t)!,
      border: Color.lerp(border, other.border, t)!,
      borderAccent: Color.lerp(borderAccent, other.borderAccent, t)!,
      gradientColors: List.generate(
        gradientColors.length,
        (index) => Color.lerp(
          gradientColors[index],
          other.gradientColors[index],
          t,
        )!,
      ),
    );
  }
}

// ========== Helper Extension ==========
extension ThemeExtras on BuildContext {
  /// Access all app colors through this single property
  ColorTheme get colors => Theme.of(this).extension<ColorTheme>()!;
}
