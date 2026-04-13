import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'mock_data.dart';

enum MockAccentKind { green, orange, pink, blue }

enum MockFontKind {
  jetbrainsMono,
  ibmPlexSans,
  inter,
  sourceSans3,
  manrope,
  spaceGrotesk,
  nunitoSans,
  publicSans,
  firaSans,
  workSans,
}

class MockPalette {
  static const Color bg = Color(0xFFF5EEE2);
  static const Color panel = Color(0xFFF5EEE2);
  static const Color panelSoft = Color(0xFFEDE3D4);
  static const Color text = Color(0xFF111111);
  static const Color muted = Color(0xFF111111);
  static const Color border = Color(0xFFD8CCBA);
  static const Color green = Color(0xFF166534);
  static const Color greenDark = Color(0xFF0F3F20);
  static const Color greenSoft = Color(0xFFDFF1E5);
  static const Color orange = Color(0xFFDC7C2F);
  static const Color orangeDark = Color(0xFF9C561D);
  static const Color orangeSoft = Color(0xFFFFF1DE);
  static const Color pink = Color(0xFFD65C89);
  static const Color pinkDark = Color(0xFF9D355D);
  static const Color pinkSoft = Color(0xFFFBE6EE);
  static const Color darkShell = Color(0xFF181A1B);
  static const Color darkPanel = Color(0xFF1E1F22);
  static const Color darkPanelSoft = Color(0xFF232529);
  static const Color darkPanelStrong = Color(0xFF2C2F34);
  static const Color darkBorder = Color(0xFF353942);
  static const Color darkText = Color(0xFFF3F4F6);
  static const Color darkMuted = Color(0xFFBBC0C9);
  static const Color railPanel = Color(0xFF143726);
  static const Color railPanelSoft = Color(0xFF1F4A33);
  static const Color railBorder = Color(0xFF3C6B53);
  static const Color railText = Color(0xFFF8FCF9);
  static const Color railMuted = Color(0xFFD6E5DB);
  static const Color amber = Color(0xFFEA7A12);
  static const Color amberSoft = Color(0xFFFFF1DB);
  static const Color thread = Color(0xFFF7F1E6);
  static const Color threadBorder = Color(0xFFDDD0BE);
  static const Color purple = Color(0xFF7C3AED);
  static const Color purpleSoft = Color(0xFFF2EAFD);
  static const Color blue = Color(0xFF2563EB);
  static const Color blueSoft = Color(0xFFE7F0FF);
  static const Color warning = Color(0xFFB45309);
  static const Color warningSoft = Color(0xFFFFF0DE);
}

class MockAccentTheme extends ThemeExtension<MockAccentTheme> {
  const MockAccentTheme({
    required this.kind,
    required this.primary,
    required this.title,
    required this.soft,
    required this.badge,
  });

  final MockAccentKind kind;
  final Color primary;
  final Color title;
  final Color soft;
  final Color badge;

  @override
  MockAccentTheme copyWith({
    MockAccentKind? kind,
    Color? primary,
    Color? title,
    Color? soft,
    Color? badge,
  }) {
    return MockAccentTheme(
      kind: kind ?? this.kind,
      primary: primary ?? this.primary,
      title: title ?? this.title,
      soft: soft ?? this.soft,
      badge: badge ?? this.badge,
    );
  }

  @override
  MockAccentTheme lerp(ThemeExtension<MockAccentTheme>? other, double t) {
    if (other is! MockAccentTheme) {
      return this;
    }

    return MockAccentTheme(
      kind: t < 0.5 ? kind : other.kind,
      primary: Color.lerp(primary, other.primary, t) ?? primary,
      title: Color.lerp(title, other.title, t) ?? title,
      soft: Color.lerp(soft, other.soft, t) ?? soft,
      badge: Color.lerp(badge, other.badge, t) ?? badge,
    );
  }
}

String mockAccentLabel(MockAccentKind kind) {
  switch (kind) {
    case MockAccentKind.green:
      return 'Green';
    case MockAccentKind.orange:
      return 'Orange';
    case MockAccentKind.pink:
      return 'Pink';
    case MockAccentKind.blue:
      return 'Blue';
  }
}

String mockFontLabel(MockFontKind kind) {
  switch (kind) {
    case MockFontKind.jetbrainsMono:
      return 'JetBrains Mono';
    case MockFontKind.ibmPlexSans:
      return 'IBM Plex Sans';
    case MockFontKind.inter:
      return 'Inter';
    case MockFontKind.sourceSans3:
      return 'Source Sans 3';
    case MockFontKind.manrope:
      return 'Manrope';
    case MockFontKind.spaceGrotesk:
      return 'Space Grotesk';
    case MockFontKind.nunitoSans:
      return 'Nunito Sans';
    case MockFontKind.publicSans:
      return 'Public Sans';
    case MockFontKind.firaSans:
      return 'Fira Sans';
    case MockFontKind.workSans:
      return 'Work Sans';
  }
}

TextStyle? _fontStyleForKind(MockFontKind kind, TextStyle? style) {
  if (style == null) {
    return null;
  }

  return GoogleFonts.getFont(mockFontLabel(kind), textStyle: style);
}

TextTheme _fontTextTheme(TextTheme base, MockFontKind kind) {
  return TextTheme(
    displaySmall: _fontStyleForKind(kind, base.displaySmall),
    headlineSmall: _fontStyleForKind(kind, base.headlineSmall),
    titleLarge: _fontStyleForKind(kind, base.titleLarge),
    titleMedium: _fontStyleForKind(kind, base.titleMedium),
    bodyLarge: _fontStyleForKind(kind, base.bodyLarge),
    bodyMedium: _fontStyleForKind(kind, base.bodyMedium),
    labelLarge: _fontStyleForKind(kind, base.labelLarge),
    labelSmall: _fontStyleForKind(kind, base.labelSmall),
  );
}

MockAccentTheme accentThemeForMode(
  MockAccentKind kind, {
  required bool isDarkMode,
}) {
  if (isDarkMode) {
    switch (kind) {
      case MockAccentKind.green:
        return const MockAccentTheme(
          kind: MockAccentKind.green,
          primary: Color(0xFF5DD691),
          title: Color(0xFF8FD4A9),
          soft: Color(0xFF21372B),
          badge: Color(0xFF2A4635),
        );
      case MockAccentKind.orange:
        return const MockAccentTheme(
          kind: MockAccentKind.orange,
          primary: Color(0xFFE59A55),
          title: Color(0xFFF1BD84),
          soft: Color(0xFF3A281B),
          badge: Color(0xFF503422),
        );
      case MockAccentKind.pink:
        return const MockAccentTheme(
          kind: MockAccentKind.pink,
          primary: Color(0xFFE07EA2),
          title: Color(0xFFF1ADC8),
          soft: Color(0xFF3A2330),
          badge: Color(0xFF4B2E3D),
        );
      case MockAccentKind.blue:
        return const MockAccentTheme(
          kind: MockAccentKind.blue,
          primary: Color(0xFF6CA9F2),
          title: Color(0xFFA9CBFF),
          soft: Color(0xFF1E3044),
          badge: Color(0xFF29405A),
        );
    }
  }

  switch (kind) {
    case MockAccentKind.green:
      return const MockAccentTheme(
        kind: MockAccentKind.green,
        primary: MockPalette.green,
        title: MockPalette.greenDark,
        soft: MockPalette.greenSoft,
        badge: Color(0xFFCFE7D8),
      );
    case MockAccentKind.orange:
      return const MockAccentTheme(
        kind: MockAccentKind.orange,
        primary: MockPalette.orange,
        title: MockPalette.orangeDark,
        soft: MockPalette.orangeSoft,
        badge: Color(0xFFF4E2CB),
      );
    case MockAccentKind.pink:
      return const MockAccentTheme(
        kind: MockAccentKind.pink,
        primary: MockPalette.pink,
        title: MockPalette.pinkDark,
        soft: MockPalette.pinkSoft,
        badge: Color(0xFFF0D7E0),
      );
    case MockAccentKind.blue:
      return const MockAccentTheme(
        kind: MockAccentKind.blue,
        primary: MockPalette.blue,
        title: Color(0xFF1E4DB7),
        soft: MockPalette.blueSoft,
        badge: Color(0xFFD8E5FC),
      );
  }
}

MockAccentTheme mockAccentTheme(BuildContext context) {
  return Theme.of(context).extension<MockAccentTheme>() ??
      accentThemeForMode(
        MockAccentKind.green,
        isDarkMode: Theme.of(context).brightness == Brightness.dark,
      );
}

class MockTypeStyle {
  const MockTypeStyle({
    required this.label,
    required this.accent,
    required this.soft,
    required this.border,
  });

  final String label;
  final Color accent;
  final Color soft;
  final Color border;
}

class MockStageStyle {
  const MockStageStyle({
    required this.label,
    required this.accent,
    required this.soft,
  });

  final String label;
  final Color accent;
  final Color soft;
}

MockTypeStyle typeStyleFor(MockProjectType type) {
  return typeStyleForMode(type, isDarkMode: false);
}

MockTypeStyle typeStyleForMode(
  MockProjectType type, {
  required bool isDarkMode,
}) {
  switch (type) {
    case MockProjectType.production:
      return isDarkMode
          ? const MockTypeStyle(
              label: 'Production',
              accent: MockPalette.darkText,
              soft: Color(0xFF37403C),
              border: Color(0xFF4A5550),
            )
          : const MockTypeStyle(
              label: 'Production',
              accent: Color(0xFF14532D),
              soft: Color(0xFFE5ECE1),
              border: Color(0xFFD1DBCE),
            );
    case MockProjectType.service:
      return isDarkMode
          ? const MockTypeStyle(
              label: 'Service',
              accent: MockPalette.darkText,
              soft: Color(0xFF2E3633),
              border: Color(0xFF414B46),
            )
          : const MockTypeStyle(
              label: 'Service',
              accent: Color(0xFF24372A),
              soft: Color(0xFFF0F4EE),
              border: Color(0xFFDDE4DB),
            );
  }
}

MockStageStyle stageStyleFor(MockProjectStage stage) {
  return stageStyleForMode(stage, isDarkMode: false);
}

MockStageStyle stageStyleForMode(
  MockProjectStage stage, {
  required bool isDarkMode,
}) {
  const background = Color(0xFF50555D);
  const foreground = Color(0xFFF5F7FA);

  switch (stage) {
    case MockProjectStage.proposal:
      return const MockStageStyle(
        label: 'Demand Signalling',
        accent: foreground,
        soft: background,
      );
    case MockProjectStage.planning:
      return const MockStageStyle(
        label: 'Planning',
        accent: foreground,
        soft: background,
      );
    case MockProjectStage.funding:
      return const MockStageStyle(
        label: 'Acquisition',
        accent: foreground,
        soft: background,
      );
    case MockProjectStage.ongoing:
      return const MockStageStyle(
        label: 'Ongoing',
        accent: foreground,
        soft: background,
      );
    case MockProjectStage.completed:
      return const MockStageStyle(
        label: 'Completed',
        accent: foreground,
        soft: background,
      );
    case MockProjectStage.cancelled:
      return const MockStageStyle(
        label: 'Cancelled',
        accent: foreground,
        soft: background,
      );
  }
}

ThemeData buildMockTheme({
  required bool isDarkMode,
  required MockAccentKind accentKind,
  required MockFontKind fontKind,
}) {
  final brightness = isDarkMode ? Brightness.dark : Brightness.light;
  final scaffold = isDarkMode ? MockPalette.darkShell : MockPalette.bg;
  final surface = isDarkMode ? MockPalette.darkPanel : MockPalette.panel;
  final surfaceSoft = isDarkMode
      ? MockPalette.darkPanelSoft
      : MockPalette.panelSoft;
  final border = isDarkMode ? MockPalette.darkBorder : MockPalette.border;
  final text = isDarkMode ? MockPalette.darkText : MockPalette.text;
  final muted = isDarkMode ? MockPalette.darkMuted : MockPalette.muted;
  final secondaryText = isDarkMode ? muted : text;
  final accent = accentThemeForMode(accentKind, isDarkMode: isDarkMode);
  final fontName = mockFontLabel(fontKind);
  final baseTextTheme = TextTheme(
    displaySmall: TextStyle(
      color: text,
      fontSize: 30,
      fontWeight: FontWeight.w800,
      height: 1.05,
    ),
    headlineSmall: TextStyle(
      color: text,
      fontSize: 20,
      fontWeight: FontWeight.w800,
    ),
    titleLarge: TextStyle(
      color: text,
      fontSize: 16,
      fontWeight: FontWeight.w800,
    ),
    titleMedium: TextStyle(
      color: text,
      fontSize: 14,
      fontWeight: FontWeight.w700,
    ),
    bodyLarge: TextStyle(color: text, fontSize: 14, height: 1.45),
    bodyMedium: TextStyle(color: secondaryText, fontSize: 13, height: 1.4),
    labelLarge: TextStyle(
      color: text,
      fontSize: 13,
      fontWeight: FontWeight.w700,
    ),
    labelSmall: TextStyle(
      color: secondaryText,
      fontSize: 11.5,
      fontWeight: FontWeight.w700,
    ),
  );
  final textTheme = _fontTextTheme(baseTextTheme, fontKind);
  final colorScheme = ColorScheme.fromSeed(
    brightness: brightness,
    seedColor: accent.primary,
    primary: accent.primary,
    surface: surface,
  );

  return ThemeData(
    useMaterial3: true,
    brightness: brightness,
    colorScheme: colorScheme.copyWith(
      primary: accent.primary,
      secondary: accent.title,
      surface: surface,
      onSurface: text,
      outline: border,
    ),
    extensions: [accent],
    scaffoldBackgroundColor: scaffold,
    canvasColor: surface,
    dividerColor: border,
    hoverColor: accent.primary.withValues(alpha: isDarkMode ? 0.18 : 0.14),
    splashColor: accent.primary.withValues(alpha: isDarkMode ? 0.18 : 0.12),
    highlightColor: accent.primary.withValues(alpha: isDarkMode ? 0.12 : 0.1),
    cardTheme: CardThemeData(
      color: surface,
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: surfaceSoft,
      hintStyle: GoogleFonts.getFont(
        fontName,
        textStyle: TextStyle(color: muted),
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(4),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(4),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(4),
        borderSide: BorderSide(color: accent.primary, width: 1.2),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: accent.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
        textStyle: GoogleFonts.getFont(
          fontName,
          textStyle: const TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: text,
        side: BorderSide.none,
        backgroundColor: Colors.transparent,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
        textStyle: GoogleFonts.getFont(
          fontName,
          textStyle: const TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: text,
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        minimumSize: Size.zero,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
        textStyle: GoogleFonts.getFont(
          fontName,
          textStyle: const TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
    ),
    chipTheme: ChipThemeData(
      backgroundColor: surfaceSoft,
      side: BorderSide.none,
      labelStyle: GoogleFonts.getFont(
        fontName,
        textStyle: TextStyle(color: text, fontWeight: FontWeight.w700),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
    ),
    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return isDarkMode ? Colors.white : accent.title;
        }
        return isDarkMode ? MockPalette.darkMuted : MockPalette.border;
      }),
      trackColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return accent.primary;
        }
        return isDarkMode ? MockPalette.darkPanelStrong : MockPalette.panelSoft;
      }),
    ),
    textTheme: textTheme,
  );
}
