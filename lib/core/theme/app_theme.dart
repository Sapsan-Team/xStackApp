import 'package:flutter/material.dart';

/// Design tokens for the XStack interface.
///
/// The language is deliberately closer to a developer tool than a consumer
/// messenger: hairline borders, a single blue accent, dense monospace type and
/// almost no elevation. Green is reserved for presence and success, red for
/// destructive actions, so the interface stays calm while still being scannable.
@immutable
class AppColors extends ThemeExtension<AppColors> {
  const AppColors({
    required this.canvas,
    required this.surface,
    required this.surfaceMuted,
    required this.border,
    required this.borderMuted,
    required this.text,
    required this.textSecondary,
    required this.textMuted,
    required this.accent,
    required this.accentMuted,
    required this.success,
    required this.warning,
    required this.danger,
    required this.dangerMuted,
    required this.brandRed,
    required this.brandOrange,
    required this.brandGreen,
    required this.brandBlue,
    required this.brandPurple,
  });

  final Color canvas;
  final Color surface;
  final Color surfaceMuted;
  final Color border;
  final Color borderMuted;
  final Color text;
  final Color textSecondary;
  final Color textMuted;
  final Color accent;
  final Color accentMuted;
  final Color success;
  final Color warning;
  final Color danger;
  final Color dangerMuted;

  final Color brandRed;
  final Color brandOrange;
  final Color brandGreen;
  final Color brandBlue;
  final Color brandPurple;

  static const dark = AppColors(
    canvas: Color(0xFF0B0F14),
    surface: Color(0xFF11161D),
    surfaceMuted: Color(0xFF161C24),
    border: Color(0xFF2A3441),
    borderMuted: Color(0xFF1D2631),
    text: Color(0xFFE6EDF3),
    textSecondary: Color(0xFF9AA7B4),
    textMuted: Color(0xFF6E7C8A),
    accent: Color(0xFF58A6FF),
    accentMuted: Color(0x1F58A6FF),
    success: Color(0xFF3FB950),
    warning: Color(0xFFD29922),
    danger: Color(0xFFF85149),
    dangerMuted: Color(0x1FF85149),
    brandRed: Color(0xFFFF4A4A),
    brandOrange: Color(0xFFFFB34A),
    brandGreen: Color(0xFF3BAF54),
    brandBlue: Color(0xFF3C8AC2),
    brandPurple: Color(0xFFA14AFF),
  );

  static const light = AppColors(
    canvas: Color(0xFFFFFFFF),
    surface: Color(0xFFF6F8FA),
    surfaceMuted: Color(0xFFEFF2F5),
    border: Color(0xFFD0D7DE),
    borderMuted: Color(0xFFE6EAEF),
    text: Color(0xFF1F2328),
    textSecondary: Color(0xFF59636E),
    textMuted: Color(0xFF818B98),
    accent: Color(0xFF0969DA),
    accentMuted: Color(0x140969DA),
    success: Color(0xFF1A7F37),
    warning: Color(0xFF9A6700),
    danger: Color(0xFFCF222E),
    dangerMuted: Color(0x14CF222E),
    brandRed: Color(0xFFE03C3C),
    brandOrange: Color(0xFFD98A1F),
    brandGreen: Color(0xFF2E9447),
    brandBlue: Color(0xFF2F79AD),
    brandPurple: Color(0xFF8A3EDB),
  );

  @override
  AppColors copyWith({
    Color? canvas,
    Color? surface,
    Color? surfaceMuted,
    Color? border,
    Color? borderMuted,
    Color? text,
    Color? textSecondary,
    Color? textMuted,
    Color? accent,
    Color? accentMuted,
    Color? success,
    Color? warning,
    Color? danger,
    Color? dangerMuted,
    Color? brandRed,
    Color? brandOrange,
    Color? brandGreen,
    Color? brandBlue,
    Color? brandPurple,
  }) {
    return AppColors(
      canvas: canvas ?? this.canvas,
      surface: surface ?? this.surface,
      surfaceMuted: surfaceMuted ?? this.surfaceMuted,
      border: border ?? this.border,
      borderMuted: borderMuted ?? this.borderMuted,
      text: text ?? this.text,
      textSecondary: textSecondary ?? this.textSecondary,
      textMuted: textMuted ?? this.textMuted,
      accent: accent ?? this.accent,
      accentMuted: accentMuted ?? this.accentMuted,
      success: success ?? this.success,
      warning: warning ?? this.warning,
      danger: danger ?? this.danger,
      dangerMuted: dangerMuted ?? this.dangerMuted,
      brandRed: brandRed ?? this.brandRed,
      brandOrange: brandOrange ?? this.brandOrange,
      brandGreen: brandGreen ?? this.brandGreen,
      brandBlue: brandBlue ?? this.brandBlue,
      brandPurple: brandPurple ?? this.brandPurple,
    );
  }

  @override
  AppColors lerp(AppColors? other, double t) {
    if (other == null) return this;
    return AppColors(
      canvas: Color.lerp(canvas, other.canvas, t)!,
      surface: Color.lerp(surface, other.surface, t)!,
      surfaceMuted: Color.lerp(surfaceMuted, other.surfaceMuted, t)!,
      border: Color.lerp(border, other.border, t)!,
      borderMuted: Color.lerp(borderMuted, other.borderMuted, t)!,
      text: Color.lerp(text, other.text, t)!,
      textSecondary: Color.lerp(textSecondary, other.textSecondary, t)!,
      textMuted: Color.lerp(textMuted, other.textMuted, t)!,
      accent: Color.lerp(accent, other.accent, t)!,
      accentMuted: Color.lerp(accentMuted, other.accentMuted, t)!,
      success: Color.lerp(success, other.success, t)!,
      warning: Color.lerp(warning, other.warning, t)!,
      danger: Color.lerp(danger, other.danger, t)!,
      dangerMuted: Color.lerp(dangerMuted, other.dangerMuted, t)!,
      brandRed: Color.lerp(brandRed, other.brandRed, t)!,
      brandOrange: Color.lerp(brandOrange, other.brandOrange, t)!,
      brandGreen: Color.lerp(brandGreen, other.brandGreen, t)!,
      brandBlue: Color.lerp(brandBlue, other.brandBlue, t)!,
      brandPurple: Color.lerp(brandPurple, other.brandPurple, t)!,
    );
  }
}

extension AppColorsContext on BuildContext {
  AppColors get colors => Theme.of(this).extension<AppColors>()!;
}

class AppTheme {
  AppTheme._();

  static const String fontFamily = 'JetBrainsMono';

  static const double radius = 6;
  static const double controlHeight = 34;

  static ThemeData light() => _build(AppColors.light, Brightness.light);

  static ThemeData dark() => _build(AppColors.dark, Brightness.dark);

  static ThemeData _build(AppColors colors, Brightness brightness) {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: colors.accent,
      brightness: brightness,
    ).copyWith(
      primary: colors.accent,
      onPrimary: brightness == Brightness.dark
          ? const Color(0xFF06121F)
          : Colors.white,
      secondary: colors.accent,
      onSecondary: brightness == Brightness.dark
          ? const Color(0xFF06121F)
          : Colors.white,
      surface: colors.canvas,
      onSurface: colors.text,
      surfaceContainerHighest: colors.surfaceMuted,
      onSurfaceVariant: colors.textSecondary,
      outline: colors.border,
      outlineVariant: colors.borderMuted,
      error: colors.danger,
      onError: Colors.white,
      errorContainer: colors.dangerMuted,
      onErrorContainer: colors.danger,
    );

    final textTheme = _textTheme(colors);
    final border = OutlineInputBorder(
      borderRadius: BorderRadius.circular(radius),
      borderSide: BorderSide(color: colors.border),
    );

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      fontFamily: fontFamily,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: colors.canvas,
      canvasColor: colors.canvas,
      cardColor: colors.surface,
      dividerColor: colors.borderMuted,
      splashFactory: NoSplash.splashFactory,
      highlightColor: Colors.transparent,
      hoverColor: colors.surfaceMuted.withValues(alpha: 0.65),
      focusColor: colors.accentMuted,
      textTheme: textTheme,
      primaryTextTheme: textTheme,
      iconTheme: IconThemeData(color: colors.textSecondary, size: 16),
      dividerTheme: DividerThemeData(
        color: colors.borderMuted,
        thickness: 1,
        space: 1,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: colors.surface,
        foregroundColor: colors.text,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleSpacing: 16,
        toolbarHeight: 48,
        titleTextStyle: textTheme.titleSmall,
        iconTheme: IconThemeData(color: colors.textSecondary, size: 16),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: false,
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 10,
          vertical: 11,
        ),
        hintStyle: textTheme.bodySmall?.copyWith(color: colors.textMuted),
        labelStyle: textTheme.bodySmall?.copyWith(color: colors.textSecondary),
        floatingLabelStyle: textTheme.labelSmall?.copyWith(
          color: colors.accent,
        ),
        prefixIconColor: colors.textMuted,
        suffixIconColor: colors.textMuted,
        prefixIconConstraints: const BoxConstraints(minWidth: 34, minHeight: 20),
        suffixIconConstraints: const BoxConstraints(minWidth: 34, minHeight: 20),
        border: border,
        enabledBorder: border,
        disabledBorder: border.copyWith(
          borderSide: BorderSide(color: colors.borderMuted),
        ),
        focusedBorder: border.copyWith(
          borderSide: BorderSide(color: colors.accent),
        ),
        errorBorder: border.copyWith(
          borderSide: BorderSide(color: colors.danger),
        ),
        focusedErrorBorder: border.copyWith(
          borderSide: BorderSide(color: colors.danger),
        ),
        errorStyle: textTheme.labelSmall?.copyWith(color: colors.danger),
        errorMaxLines: 2,
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size(0, controlHeight),
          padding: const EdgeInsets.symmetric(horizontal: 14),
          backgroundColor: colors.accent,
          foregroundColor: colorScheme.onPrimary,
          disabledBackgroundColor: colors.borderMuted,
          disabledForegroundColor: colors.textMuted,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radius),
          ),
          textStyle: textTheme.labelLarge,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(0, controlHeight),
          padding: const EdgeInsets.symmetric(horizontal: 14),
          foregroundColor: colors.text,
          side: BorderSide(color: colors.border),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radius),
          ),
          textStyle: textTheme.labelLarge,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          minimumSize: const Size(0, 28),
          padding: const EdgeInsets.symmetric(horizontal: 6),
          foregroundColor: colors.textSecondary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radius),
          ),
          textStyle: textTheme.labelMedium,
        ),
      ),
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(
          foregroundColor: colors.textSecondary,
          hoverColor: colors.surfaceMuted,
          highlightColor: Colors.transparent,
          minimumSize: const Size(30, 30),
          padding: const EdgeInsets.all(6),
          iconSize: 16,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radius),
          ),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: colors.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: BorderSide(color: colors.border),
        ),
        titleTextStyle: textTheme.titleSmall,
        contentTextStyle: textTheme.bodySmall,
      ),
      popupMenuTheme: PopupMenuThemeData(
        color: colors.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radius),
          side: BorderSide(color: colors.border),
        ),
        textStyle: textTheme.bodySmall?.copyWith(color: colors.text),
      ),
      tooltipTheme: TooltipThemeData(
        decoration: BoxDecoration(
          color: colors.surfaceMuted,
          border: Border.all(color: colors.border),
          borderRadius: BorderRadius.circular(4),
        ),
        textStyle: textTheme.labelSmall?.copyWith(color: colors.text),
        waitDuration: const Duration(milliseconds: 400),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: colors.surfaceMuted,
        contentTextStyle: textTheme.bodySmall?.copyWith(color: colors.text),
        behavior: SnackBarBehavior.floating,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radius),
          side: BorderSide(color: colors.border),
        ),
      ),
      scrollbarTheme: ScrollbarThemeData(
        thumbColor: WidgetStatePropertyAll(
          colors.textMuted.withValues(alpha: 0.35),
        ),
        radius: const Radius.circular(10),
        thickness: const WidgetStatePropertyAll(6),
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: colors.accent,
        linearTrackColor: colors.borderMuted,
        circularTrackColor: Colors.transparent,
      ),
      textSelectionTheme: TextSelectionThemeData(
        cursorColor: colors.accent,
        selectionColor: colors.accentMuted,
        selectionHandleColor: colors.accent,
      ),
      extensions: [colors],
    );
  }

  static TextTheme _textTheme(AppColors colors) {
    TextStyle base(double size, {FontWeight weight = FontWeight.w400}) {
      return TextStyle(
        fontFamily: fontFamily,
        fontSize: size,
        fontWeight: weight,
        color: colors.text,
        height: 1.5,
        letterSpacing: 0,
      );
    }

    return TextTheme(
      // Auth headline.
      displaySmall: base(26, weight: FontWeight.w700).copyWith(
        height: 1.25,
        letterSpacing: -0.6,
      ),
      // Panel headings.
      headlineSmall: base(19, weight: FontWeight.w700).copyWith(height: 1.3),
      titleLarge: base(16, weight: FontWeight.w700).copyWith(height: 1.35),
      // Dialog titles and chat titles.
      titleMedium: base(14, weight: FontWeight.w600),
      titleSmall: base(13, weight: FontWeight.w600),
      bodyLarge: base(13),
      bodyMedium: base(12),
      bodySmall: base(12).copyWith(color: colors.textSecondary),
      labelLarge: base(12, weight: FontWeight.w600),
      labelMedium: base(11, weight: FontWeight.w500).copyWith(
        color: colors.textSecondary,
      ),
      labelSmall: base(10, weight: FontWeight.w500).copyWith(
        color: colors.textMuted,
        height: 1.4,
      ),
    );
  }
}
