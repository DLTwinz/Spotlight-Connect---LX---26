import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppSpacing {
  // Spacing values
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 16.0;
  static const double lg = 24.0;
  static const double xl = 32.0;
  static const double xxl = 48.0;

  // Edge insets shortcuts
  static const EdgeInsets paddingXs = EdgeInsets.all(xs);
  static const EdgeInsets paddingSm = EdgeInsets.all(sm);
  static const EdgeInsets paddingMd = EdgeInsets.all(md);
  static const EdgeInsets paddingLg = EdgeInsets.all(lg);
  static const EdgeInsets paddingXl = EdgeInsets.all(xl);

  // Horizontal padding
  static const EdgeInsets horizontalXs = EdgeInsets.symmetric(horizontal: xs);
  static const EdgeInsets horizontalSm = EdgeInsets.symmetric(horizontal: sm);
  static const EdgeInsets horizontalMd = EdgeInsets.symmetric(horizontal: md);
  static const EdgeInsets horizontalLg = EdgeInsets.symmetric(horizontal: lg);
  static const EdgeInsets horizontalXl = EdgeInsets.symmetric(horizontal: xl);

  // Vertical padding
  static const EdgeInsets verticalXs = EdgeInsets.symmetric(vertical: xs);
  static const EdgeInsets verticalSm = EdgeInsets.symmetric(vertical: sm);
  static const EdgeInsets verticalMd = EdgeInsets.symmetric(vertical: md);
  static const EdgeInsets verticalLg = EdgeInsets.symmetric(vertical: lg);
  static const EdgeInsets verticalXl = EdgeInsets.symmetric(vertical: xl);
}

/// Border radius constants for consistent rounded corners
class AppRadius {
  static const double sm = 8.0;
  static const double md = 12.0;
  static const double lg = 16.0;
  static const double xl = 24.0;
}

// =============================================================================
// TEXT STYLE EXTENSIONS
// =============================================================================

/// Extension to add text style utilities to BuildContext
/// Access via context.textStyles
extension TextStyleContext on BuildContext {
  TextTheme get textStyles => Theme.of(this).textTheme;
}

/// Helper methods for common text style modifications
extension TextStyleExtensions on TextStyle {
  /// Make text bold
  TextStyle get bold => copyWith(fontWeight: FontWeight.bold);

  /// Make text semi-bold
  TextStyle get semiBold => copyWith(fontWeight: FontWeight.w600);

  /// Make text medium weight
  TextStyle get medium => copyWith(fontWeight: FontWeight.w500);

  /// Make text normal weight
  TextStyle get normal => copyWith(fontWeight: FontWeight.w400);

  /// Make text light
  TextStyle get light => copyWith(fontWeight: FontWeight.w300);

  /// Add custom color
  TextStyle withColor(Color color) => copyWith(color: color);

  /// Add custom size
  TextStyle withSize(double size) => copyWith(fontSize: size);
}

// =============================================================================
// COLORS
// =============================================================================

/// Modern, neutral color palette for light mode
/// Uses soft grays and blues instead of purple for a contemporary look
class LightModeColors {
  // Primary: SPOTLIGHT neon-lime accent (kept readable for light surfaces)
  static const lightPrimary = Color(0xFF2BBF5B);
  static const lightOnPrimary = Color(0xFFFFFFFF);
  static const lightPrimaryContainer = Color(0xFFBFF5CF);
  static const lightOnPrimaryContainer = Color(0xFF0B2B18);

  // Secondary
  static const lightSecondary = Color(0xFF5C6B7A);
  static const lightOnSecondary = Color(0xFFFFFFFF);

  // Tertiary
  static const lightTertiary = Color(0xFF6B7C8C);
  static const lightOnTertiary = Color(0xFFFFFFFF);

  // Error colors
  static const lightError = Color(0xFFBA1A1A);
  static const lightOnError = Color(0xFFFFFFFF);
  static const lightErrorContainer = Color(0xFFFFDAD6);
  static const lightOnErrorContainer = Color(0xFF410002);

  // Surface and background: High contrast for readability
  static const lightSurface = Color(0xFFFFFFFF); // Sharper white
  static const lightOnSurface = Color(0xFF111111); // Sharper dark text
  static const lightBackground =
      Color(0xFFF5F7FA); // Very light crisp background
  static const lightSurfaceVariant = Color(0xFFE2E8F0);
  static const lightOnSurfaceVariant = Color(0xFF44474E);

  // Outline and shadow
  static const lightOutline = Color(0xFFCBD5E1);
  static const lightShadow = Color(0xFF000000);
  static const lightInversePrimary = Color(0xFFACC7E3);
}

/// Dark mode colors with cinematic, premium feel
class DarkModeColors {
  // Primary: neon/lime accent on cinematic dark background
  static const darkPrimary = Color(0xFFB7FF2A);
  static const darkOnPrimary = Color(0xFF07110A);
  static const darkPrimaryContainer = Color(0xFF1E3514);
  static const darkOnPrimaryContainer = Color(0xFFDFFFC0);

  // Secondary
  static const darkSecondary = Color(0xFFBCC7D6);
  static const darkOnSecondary = Color(0xFF2E3842);

  // Tertiary
  static const darkTertiary = Color(0xFFB8C8D8);
  static const darkOnTertiary = Color(0xFF344451);

  // Error colors
  static const darkError = Color(0xFFFFB4AB);
  static const darkOnError = Color(0xFF690005);
  static const darkErrorContainer = Color(0xFF93000A);
  static const darkOnErrorContainer = Color(0xFFFFDAD6);

  // Surface and background: True cinematic dark mode
  static const darkSurface =
      Color(0xFF121212); // Slightly elevated from pure black
  static const darkOnSurface = Color(0xFFF8FAFC); // Crisp light text
  static const darkSurfaceVariant = Color(0xFF1E1E1E);
  static const darkOnSurfaceVariant = Color(0xFFC4C7CF);

  // Background
  static const darkBackground = Color(0xFF000105); // Deep cinematic black

  // Outline and shadow
  static const darkOutline = Color(0xFF333333);
  static const darkShadow = Color(0xFF000000);
  static const darkInversePrimary = Color(0xFF5B7C99);
  static const darkGold = Color(0xFFD4AF37); // Premium Gold
  static const darkOnGold = Color(0xFF000000);
}

/// Font size constants

class SpotlightColors {
  static const Color canvasDark = Color(0xFF06070A);
  static const Color shellDark = Color(0xFF0B0F14);
  static const Color panelDark = Color(0xFF10161D);
  static const Color panelDarkAlt = Color(0xFF151C24);
  static const Color borderDark = Color(0xFF223041);

  static const Color canvasLight = Color(0xFFF4F7FB);
  static const Color shellLight = Color(0xFFFFFFFF);
  static const Color panelLight = Color(0xFFFFFFFF);
  static const Color panelLightAlt = Color(0xFFEDF3F8);
  static const Color borderLight = Color(0xFFD7E0EA);

  static const Color accentTeal = Color(0xFF18C7C9);
  static const Color accentTealSoft = Color(0xFF7EE7E7);
  static const Color accentGold = Color(0xFFD4AF37);

  static const Color success = Color(0xFF34C759);
  static const Color warning = Color(0xFFFFB020);
  static const Color danger = Color(0xFFFF5D73);
}

extension SpotlightThemeX on BuildContext {
  ThemeData get appTheme => Theme.of(this);
  ColorScheme get colors => Theme.of(this).colorScheme;

  Color get shellBg => Theme.of(this).brightness == Brightness.dark
      ? SpotlightColors.shellDark
      : SpotlightColors.shellLight;

  Color get panelBg => Theme.of(this).brightness == Brightness.dark
      ? SpotlightColors.panelDark
      : SpotlightColors.panelLight;

  Color get panelAltBg => Theme.of(this).brightness == Brightness.dark
      ? SpotlightColors.panelDarkAlt
      : SpotlightColors.panelLightAlt;

  Color get panelBorder => Theme.of(this).brightness == Brightness.dark
      ? SpotlightColors.borderDark
      : SpotlightColors.borderLight;

  Color get spotlightAccent => SpotlightColors.accentTeal;
}


enum DashboardRoleVariant { admin, business, talent, audience }

extension DashboardRoleVariantX on DashboardRoleVariant {
  static DashboardRoleVariant fromRole(String? role) {
    switch ((role ?? '').trim().toLowerCase()) {
      case 'admin':
        return DashboardRoleVariant.admin;
      case 'business':
        return DashboardRoleVariant.business;
      case 'audience':
        return DashboardRoleVariant.audience;
      case 'talent':
      default:
        return DashboardRoleVariant.talent;
    }
  }
}

extension SpotlightDashboardThemeX on BuildContext {
  DashboardRoleVariant dashboardRoleVariant(String? role) =>
      DashboardRoleVariantX.fromRole(role);

  Color roleAccent(String? role) {
    switch (dashboardRoleVariant(role)) {
      case DashboardRoleVariant.admin:
        return const Color(0xFFFF6B6B);
      case DashboardRoleVariant.business:
        return SpotlightColors.accentTeal;
      case DashboardRoleVariant.audience:
        return const Color(0xFF8EBCFF);
      case DashboardRoleVariant.talent:
        return const Color(0xFF7CFFB2);
    }
  }

  Color roleShellBackground(String? role) {
    switch (dashboardRoleVariant(role)) {
      case DashboardRoleVariant.admin:
        return const Color(0xFF090B10);
      case DashboardRoleVariant.business:
        return const Color(0xFF071118);
      case DashboardRoleVariant.audience:
        return const Color(0xFF0B1016);
      case DashboardRoleVariant.talent:
        return const Color(0xFF0A0D12);
    }
  }

  Color rolePanelBackground(String? role) {
    switch (dashboardRoleVariant(role)) {
      case DashboardRoleVariant.admin:
        return const Color(0xFF12161D);
      case DashboardRoleVariant.business:
        return const Color(0xFF0E1821);
      case DashboardRoleVariant.audience:
        return const Color(0xFF111925);
      case DashboardRoleVariant.talent:
        return const Color(0xFF11161F);
    }
  }

  Color rolePanelBorder(String? role) {
    switch (dashboardRoleVariant(role)) {
      case DashboardRoleVariant.admin:
        return const Color(0xFF303846);
      case DashboardRoleVariant.business:
        return const Color(0xFF1D4E59);
      case DashboardRoleVariant.audience:
        return const Color(0xFF314760);
      case DashboardRoleVariant.talent:
        return const Color(0xFF28433A);
    }
  }

  Color roleNavBackground(String? role) {
    switch (dashboardRoleVariant(role)) {
      case DashboardRoleVariant.admin:
        return const Color(0xFF0D1117);
      case DashboardRoleVariant.business:
        return const Color(0xFF0B141B);
      case DashboardRoleVariant.audience:
        return const Color(0xFF101722);
      case DashboardRoleVariant.talent:
        return const Color(0xFF0D1319);
    }
  }
}

class FontSizes {
  static const double displayLarge = 57.0;
  static const double displayMedium = 45.0;
  static const double displaySmall = 36.0;
  static const double headlineLarge = 32.0;
  static const double headlineMedium = 28.0;
  static const double headlineSmall = 24.0;
  static const double titleLarge = 22.0;
  static const double titleMedium = 16.0;
  static const double titleSmall = 14.0;
  static const double labelLarge = 14.0;
  static const double labelMedium = 12.0;
  static const double labelSmall = 11.0;
  static const double bodyLarge = 16.0;
  static const double bodyMedium = 14.0;
  static const double bodySmall = 12.0;
}

// =============================================================================
// THEMES
// =============================================================================

/// Light theme with modern, neutral aesthetic
ThemeData get lightTheme => ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.light(
        primary: LightModeColors.lightPrimary,
        onPrimary: LightModeColors.lightOnPrimary,
        primaryContainer: LightModeColors.lightPrimaryContainer,
        onPrimaryContainer: LightModeColors.lightOnPrimaryContainer,
        secondary: LightModeColors.lightSecondary,
        onSecondary: LightModeColors.lightOnSecondary,
        tertiary: LightModeColors.lightTertiary,
        onTertiary: LightModeColors.lightOnTertiary,
        error: LightModeColors.lightError,
        onError: LightModeColors.lightOnError,
        errorContainer: LightModeColors.lightErrorContainer,
        onErrorContainer: LightModeColors.lightOnErrorContainer,
        surface: LightModeColors.lightSurface,
        onSurface: LightModeColors.lightOnSurface,
        surfaceContainerHighest: LightModeColors.lightSurfaceVariant,
        onSurfaceVariant: LightModeColors.lightOnSurfaceVariant,
        outline: LightModeColors.lightOutline,
        shadow: LightModeColors.lightShadow,
        inversePrimary: LightModeColors.lightInversePrimary,
      ),
      brightness: Brightness.light,
      scaffoldBackgroundColor: LightModeColors.lightBackground,
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        foregroundColor: LightModeColors.lightOnSurface,
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(
            color: LightModeColors.lightOutline.withValues(alpha: 0.2),
            width: 1,
          ),
        ),
      ),
      textTheme: _buildTextTheme(Brightness.light),
    );

/// Dark theme with good contrast and readability
ThemeData get darkTheme => ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.dark(
        primary: DarkModeColors.darkPrimary,
        onPrimary: DarkModeColors.darkOnPrimary,
        primaryContainer: DarkModeColors.darkPrimaryContainer,
        onPrimaryContainer: DarkModeColors.darkOnPrimaryContainer,
        secondary: DarkModeColors.darkSecondary,
        onSecondary: DarkModeColors.darkOnSecondary,
        tertiary: DarkModeColors.darkTertiary,
        onTertiary: DarkModeColors.darkOnTertiary,
        error: DarkModeColors.darkError,
        onError: DarkModeColors.darkOnError,
        errorContainer: DarkModeColors.darkErrorContainer,
        onErrorContainer: DarkModeColors.darkOnErrorContainer,
        surface: DarkModeColors.darkSurface,
        onSurface: DarkModeColors.darkOnSurface,
        surfaceContainerHighest: DarkModeColors.darkSurfaceVariant,
        onSurfaceVariant: DarkModeColors.darkOnSurfaceVariant,
        outline: DarkModeColors.darkOutline,
        shadow: DarkModeColors.darkShadow,
        inversePrimary: DarkModeColors.darkInversePrimary,
      ),
      brightness: Brightness.dark,
      scaffoldBackgroundColor: DarkModeColors.darkBackground,
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        foregroundColor: DarkModeColors.darkOnSurface,
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(
            color: DarkModeColors.darkOutline.withValues(alpha: 0.2),
            width: 1,
          ),
        ),
      ),
      textTheme: _buildTextTheme(Brightness.dark),
    );

/// Build text theme using Inter font family
TextTheme _buildTextTheme(Brightness brightness) {
  return TextTheme(
    displayLarge: GoogleFonts.inter(
      fontSize: FontSizes.displayLarge,
      fontWeight: FontWeight.w400,
      letterSpacing: -0.25,
    ),
    displayMedium: GoogleFonts.inter(
      fontSize: FontSizes.displayMedium,
      fontWeight: FontWeight.w400,
    ),
    displaySmall: GoogleFonts.inter(
      fontSize: FontSizes.displaySmall,
      fontWeight: FontWeight.w400,
    ),
    headlineLarge: GoogleFonts.inter(
      fontSize: FontSizes.headlineLarge,
      fontWeight: FontWeight.w600,
      letterSpacing: -0.5,
    ),
    headlineMedium: GoogleFonts.inter(
      fontSize: FontSizes.headlineMedium,
      fontWeight: FontWeight.w600,
    ),
    headlineSmall: GoogleFonts.inter(
      fontSize: FontSizes.headlineSmall,
      fontWeight: FontWeight.w600,
    ),
    titleLarge: GoogleFonts.inter(
      fontSize: FontSizes.titleLarge,
      fontWeight: FontWeight.w600,
    ),
    titleMedium: GoogleFonts.inter(
      fontSize: FontSizes.titleMedium,
      fontWeight: FontWeight.w500,
    ),
    titleSmall: GoogleFonts.inter(
      fontSize: FontSizes.titleSmall,
      fontWeight: FontWeight.w500,
    ),
    labelLarge: GoogleFonts.inter(
      fontSize: FontSizes.labelLarge,
      fontWeight: FontWeight.w500,
      letterSpacing: 0.1,
    ),
    labelMedium: GoogleFonts.inter(
      fontSize: FontSizes.labelMedium,
      fontWeight: FontWeight.w500,
      letterSpacing: 0.5,
    ),
    labelSmall: GoogleFonts.inter(
      fontSize: FontSizes.labelSmall,
      fontWeight: FontWeight.w500,
      letterSpacing: 0.5,
    ),
    bodyLarge: GoogleFonts.inter(
      fontSize: FontSizes.bodyLarge,
      fontWeight: FontWeight.w400,
      letterSpacing: 0.15,
    ),
    bodyMedium: GoogleFonts.inter(
      fontSize: FontSizes.bodyMedium,
      fontWeight: FontWeight.w400,
      letterSpacing: 0.25,
    ),
    bodySmall: GoogleFonts.inter(
      fontSize: FontSizes.bodySmall,
      fontWeight: FontWeight.w400,
      letterSpacing: 0.4,
    ),
  );
}
