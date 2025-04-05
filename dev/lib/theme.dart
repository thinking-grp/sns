import "package:flutter/material.dart";

class MaterialTheme {
  final TextTheme textTheme;

  const MaterialTheme(this.textTheme);

  static ColorScheme lightScheme() {
    return const ColorScheme(
      brightness: Brightness.light,
      primary: Color(0xFF131313),
      surfaceTint: Color(0xff5b5f63),
      onPrimary: Color(0xffffffff),
      primaryContainer: Color(0xffd4d7dc),
      onPrimaryContainer: Color(0xff5a5d62),
      secondary: Color(0xff5d5e60),
      onSecondary: Color(0xffffffff),
      secondaryContainer: Color(0xffe0dfe1),
      onSecondaryContainer: Color(0xff626264),
      tertiary: Color(0xff5d5e60),
      onTertiary: Color(0xffffffff),
      tertiaryContainer: Color(0xffb6b6b8),
      onTertiaryContainer: Color(0xff464749),
      error: Color(0xffba1a1a),
      onError: Color(0xffffffff),
      errorContainer: Color(0xffffdad6),
      onErrorContainer: Color(0xff93000a),
      surface: Color(0xFCFCFCFC),
      onSurface: Color(0xff1c1b1c),
      onSurfaceVariant: Color(0xff44474a),
      outline: Color(0xFF797B7D),
      outlineVariant: Color(0xffc5c6ca),
      shadow: Color(0xff000000),
      scrim: Color(0xff000000),
      inverseSurface: Color(0xFF000000),
      inversePrimary: Color(0xffc3c7cc),
      primaryFixed: Color(0xffe0e3e8),
      onPrimaryFixed: Color(0xff181c20),
      primaryFixedDim: Color(0xffc3c7cc),
      onPrimaryFixedVariant: Color(0xff43474b),
      secondaryFixed: Color(0xffe3e2e4),
      onSecondaryFixed: Color(0xff1a1c1d),
      secondaryFixedDim: Color(0xffc7c6c8),
      onSecondaryFixedVariant: Color(0xff464748),
      tertiaryFixed: Color(0xffe3e2e4),
      onTertiaryFixed: Color(0xff1a1c1d),
      tertiaryFixedDim: Color(0xffc6c6c8),
      onTertiaryFixedVariant: Color(0xff464749),
      surfaceDim: Color(0xffdcd9d9),
      surfaceBright: Color.fromARGB(255, 249, 246, 246),
      surfaceContainerLowest: Color(0xffffffff),
      surfaceContainerLow: Color(0xfff6f3f3),
      surfaceContainer: Color.fromARGB(255, 231, 228, 228),
      surfaceContainerHigh: Color.fromARGB(255, 235, 235, 235),
      surfaceContainerHighest: Color(0xFFEBEBEB),
    );
  }

  ThemeData light() {
    return theme(lightScheme());
  }

  static ColorScheme lightMediumContrastScheme() {
    return const ColorScheme(
      brightness: Brightness.light,
      primary: Color(0xFF131313),
      surfaceTint: Color(0xff5b5f63),
      onPrimary: Color(0xffffffff),
      primaryContainer: Color(0xff6a6d72),
      onPrimaryContainer: Color(0xffffffff),
      secondary: Color(0xff353638),
      onSecondary: Color(0xffffffff),
      secondaryContainer: Color(0xff6c6d6f),
      onSecondaryContainer: Color(0xffffffff),
      tertiary: Color(0xff353638),
      onTertiary: Color(0xffffffff),
      tertiaryContainer: Color(0xff6c6d6f),
      onTertiaryContainer: Color(0xffffffff),
      error: Color(0xff740006),
      onError: Color(0xffffffff),
      errorContainer: Color(0xffcf2c27),
      onErrorContainer: Color(0xffffffff),
      surface: Color(0xfcfcfcfc),
      onSurface: Color(0xff111111),
      onSurfaceVariant: Color(0xff343639),
      outline: Color(0xFF797B7D),
      outlineVariant: Color(0xff6b6d71),
      shadow: Color(0xff000000),
      scrim: Color(0xff000000),
      inverseSurface: Color(0xFF000000),
      inversePrimary: Color(0xffc3c7cc),
      primaryFixed: Color(0xff6a6d72),
      onPrimaryFixed: Color(0xffffffff),
      primaryFixedDim: Color(0xff515559),
      onPrimaryFixedVariant: Color(0xffffffff),
      secondaryFixed: Color(0xff6c6d6f),
      onSecondaryFixed: Color(0xffffffff),
      secondaryFixedDim: Color(0xff545556),
      onSecondaryFixedVariant: Color(0xffffffff),
      tertiaryFixed: Color(0xff6c6d6f),
      onTertiaryFixed: Color(0xffffffff),
      tertiaryFixedDim: Color(0xff545557),
      onTertiaryFixedVariant: Color(0xffffffff),
      surfaceDim: Color(0xffc9c6c6),
      surfaceBright: Color(0xfffcf8f8),
      surfaceContainerLowest: Color(0xffffffff),
      surfaceContainerLow: Color(0xfff6f3f3),
      surfaceContainer: Color(0xffebe7e7),
      surfaceContainerHigh: Color.fromARGB(255, 235, 235, 235),
      surfaceContainerHighest: Color(0xFFEBEBEB),
    );
  }

  ThemeData lightMediumContrast() {
    return theme(lightMediumContrastScheme());
  }

  static ColorScheme lightHighContrastScheme() {
    return const ColorScheme(
      brightness: Brightness.light,
      primary: Color(0xFF131313),
      surfaceTint: Color(0xff5b5f63),
      onPrimary: Color(0xffffffff),
      primaryContainer: Color(0xff464a4e),
      onPrimaryContainer: Color(0xffffffff),
      secondary: Color(0xff2b2c2e),
      onSecondary: Color(0xffffffff),
      secondaryContainer: Color(0xff48494b),
      onSecondaryContainer: Color(0xffffffff),
      tertiary: Color(0xff2b2c2e),
      onTertiary: Color(0xffffffff),
      tertiaryContainer: Color(0xff48494b),
      onTertiaryContainer: Color(0xffffffff),
      error: Color(0xff600004),
      onError: Color(0xffffffff),
      errorContainer: Color(0xff98000a),
      onErrorContainer: Color(0xffffffff),
      surface: Color(0xfcfcfcfc),
      onSurface: Color(0xff000000),
      onSurfaceVariant: Color(0xff000000),
      outline: Color(0xFF797B7D),
      outlineVariant: Color(0xff47494d),
      shadow: Color(0xff000000),
      scrim: Color(0xff000000),
      inverseSurface: Color(0xFF000000),
      inversePrimary: Color(0xffc3c7cc),
      primaryFixed: Color(0xff464a4e),
      onPrimaryFixed: Color(0xffffffff),
      primaryFixedDim: Color(0xff2f3337),
      onPrimaryFixedVariant: Color(0xffffffff),
      secondaryFixed: Color(0xff48494b),
      onSecondaryFixed: Color(0xffffffff),
      secondaryFixedDim: Color(0xff313334),
      onSecondaryFixedVariant: Color(0xffffffff),
      tertiaryFixed: Color(0xff48494b),
      onTertiaryFixed: Color(0xffffffff),
      tertiaryFixedDim: Color(0xff313334),
      onTertiaryFixedVariant: Color(0xffffffff),
      surfaceDim: Color(0xffbbb8b8),
      surfaceBright: Color(0xfffcf8f8),
      surfaceContainerLowest: Color(0xffffffff),
      surfaceContainerLow: Color(0xfff3f0f0),
      surfaceContainer: Color(0xffe5e2e1),
      surfaceContainerHigh: Color.fromARGB(255, 235, 235, 235),
      surfaceContainerHighest: Color(0xFFEBEBEB),
    );
  }

  ThemeData lightHighContrast() {
    return theme(lightHighContrastScheme());
  }

  static ColorScheme darkScheme() {
    return const ColorScheme(
      brightness: Brightness.dark,
      primary: Color(0xfff1f3f8),
      surfaceTint: Color(0xffc3c7cc),
      onPrimary: Color(0xff2d3135),
      primaryContainer: Color(0xffd4d7dc),
      onPrimaryContainer: Color(0xff5a5d62),
      secondary: Color(0xffc7c6c8),
      onSecondary: Color(0xff2f3032),
      secondaryContainer: Color(0xff48494b),
      onSecondaryContainer: Color(0xffb8b8ba),
      tertiary: Color(0xffd2d2d4),
      onTertiary: Color(0xff2f3032),
      tertiaryContainer: Color(0xffb6b6b8),
      onTertiaryContainer: Color(0xff464749),
      error: Color(0xffffb4ab),
      onError: Color(0xff690005),
      errorContainer: Color(0xff93000a),
      onErrorContainer: Color(0xffffdad6),
      surface: Color.fromARGB(255, 15, 15, 15),
      onSurface: Color(0xffe5e2e1),
      onSurfaceVariant: Color(0xffc5c6ca),
      outline: Color(0xFF797B7D),
      outlineVariant: Color(0xff44474a),
      shadow: Color(0xff000000),
      scrim: Color(0xff000000),
      inverseSurface: Color(0xFFFFFFFF),
      inversePrimary: Color(0xff5b5f63),
      primaryFixed: Color(0xffe0e3e8),
      onPrimaryFixed: Color(0xff181c20),
      primaryFixedDim: Color(0xffc3c7cc),
      onPrimaryFixedVariant: Color(0xff43474b),
      secondaryFixed: Color(0xffe3e2e4),
      onSecondaryFixed: Color(0xff1a1c1d),
      secondaryFixedDim: Color(0xffc7c6c8),
      onSecondaryFixedVariant: Color(0xff464748),
      tertiaryFixed: Color(0xffe3e2e4),
      onTertiaryFixed: Color(0xff1a1c1d),
      tertiaryFixedDim: Color(0xffc6c6c8),
      onTertiaryFixedVariant: Color(0xff464749),
      surfaceDim: Color(0xff131314),
      surfaceBright: Color(0xff3a3939),
      surfaceContainerLowest: Color(0xff0e0e0e),
      surfaceContainerLow: Color(0xff1c1b1c),
      surfaceContainer: Color(0xff201f20),
      surfaceContainerHigh: Color(0xff2a2a2a),
      surfaceContainerHighest: Color.fromARGB(255, 41, 41, 41),
    );
  }

  ThemeData dark() {
    return theme(darkScheme());
  }

  static ColorScheme darkMediumContrastScheme() {
    return const ColorScheme(
      brightness: Brightness.dark,
      primary: Color(0xfff1f3f8),
      surfaceTint: Color(0xffc3c7cc),
      onPrimary: Color(0xff2d3135),
      primaryContainer: Color(0xffd4d7dc),
      onPrimaryContainer: Color(0xff3d4145),
      secondary: Color(0xffdddcde),
      onSecondary: Color(0xff242627),
      secondaryContainer: Color(0xff909092),
      onSecondaryContainer: Color(0xff000000),
      tertiary: Color(0xffdcdcde),
      onTertiary: Color(0xff242627),
      tertiaryContainer: Color(0xffb6b6b8),
      onTertiaryContainer: Color(0xff292a2c),
      error: Color(0xffffd2cc),
      onError: Color(0xff540003),
      errorContainer: Color(0xffff5449),
      onErrorContainer: Color(0xff000000),
      surface: Color(0xff131314),
      onSurface: Color(0xffffffff),
      onSurfaceVariant: Color(0xffdbdce0),
      outline: Color(0xFF797B7D),
      outlineVariant: Color(0xff8e9094),
      shadow: Color(0xff000000),
      scrim: Color(0xff000000),
      inverseSurface: Color(0xFFFFFFFF),
      inversePrimary: Color(0xff44484c),
      primaryFixed: Color(0xffe0e3e8),
      onPrimaryFixed: Color(0xff0e1215),
      primaryFixedDim: Color(0xffc3c7cc),
      onPrimaryFixedVariant: Color(0xff33373b),
      secondaryFixed: Color(0xffe3e2e4),
      onSecondaryFixed: Color(0xff101113),
      secondaryFixedDim: Color(0xffc7c6c8),
      onSecondaryFixedVariant: Color(0xff353638),
      tertiaryFixed: Color(0xffe3e2e4),
      onTertiaryFixed: Color(0xff101113),
      tertiaryFixedDim: Color(0xffc6c6c8),
      onTertiaryFixedVariant: Color(0xff353638),
      surfaceDim: Color(0xff131314),
      surfaceBright: Color(0xff454444),
      surfaceContainerLowest: Color(0xff070708),
      surfaceContainerLow: Color(0xff1e1d1e),
      surfaceContainer: Color(0xff282828),
      surfaceContainerHigh: Color(0xff333233),
      surfaceContainerHighest: Color.fromARGB(255, 52, 52, 52),
    );
  }

  ThemeData darkMediumContrast() {
    return theme(darkMediumContrastScheme());
  }

  static ColorScheme darkHighContrastScheme() {
    return const ColorScheme(
      brightness: Brightness.dark,
      primary: Color(0xfff1f3f8),
      surfaceTint: Color(0xffc3c7cc),
      onPrimary: Color(0xff000000),
      primaryContainer: Color(0xffd4d7dc),
      onPrimaryContainer: Color(0xff1e2226),
      secondary: Color(0xfff0eff1),
      onSecondary: Color(0xff000000),
      secondaryContainer: Color(0xffc3c2c4),
      onSecondaryContainer: Color(0xff0a0b0d),
      tertiary: Color(0xfff0f0f2),
      onTertiary: Color(0xff000000),
      tertiaryContainer: Color(0xffc2c2c4),
      onTertiaryContainer: Color(0xff0a0b0d),
      error: Color(0xffffece9),
      onError: Color(0xff000000),
      errorContainer: Color(0xffffaea4),
      onErrorContainer: Color(0xff220001),
      surface: Color(0xff131314),
      onSurface: Color(0xffffffff),
      onSurfaceVariant: Color(0xffffffff),
      outline: Color(0xFF797B7D),
      outlineVariant: Color(0xffc1c3c6),
      shadow: Color(0xff000000),
      scrim: Color(0xff000000),
      inverseSurface: Color(0xFFFFFFFF),
      inversePrimary: Color(0xff44484c),
      primaryFixed: Color(0xffe0e3e8),
      onPrimaryFixed: Color(0xff000000),
      primaryFixedDim: Color(0xffc3c7cc),
      onPrimaryFixedVariant: Color(0xff0e1215),
      secondaryFixed: Color(0xffe3e2e4),
      onSecondaryFixed: Color(0xff000000),
      secondaryFixedDim: Color(0xffc7c6c8),
      onSecondaryFixedVariant: Color(0xff101113),
      tertiaryFixed: Color(0xffe3e2e4),
      onTertiaryFixed: Color(0xff000000),
      tertiaryFixedDim: Color(0xffc6c6c8),
      onTertiaryFixedVariant: Color(0xff101113),
      surfaceDim: Color(0xff131314),
      surfaceBright: Color(0xff515050),
      surfaceContainerLowest: Color(0xff000000),
      surfaceContainerLow: Color(0xff201f20),
      surfaceContainer: Color(0xff313030),
      surfaceContainerHigh: Color(0xff3c3b3b),
      surfaceContainerHighest: Color.fromARGB(255, 69, 69, 69),
    );
  }

  ThemeData darkHighContrast() {
    return theme(darkHighContrastScheme());
  }


  ThemeData theme(ColorScheme colorScheme) => ThemeData(
     useMaterial3: true,
     brightness: colorScheme.brightness,
     colorScheme: colorScheme,
     textTheme: textTheme.apply(
       bodyColor: colorScheme.onSurface,
       displayColor: colorScheme.onSurface,
     ),
     scaffoldBackgroundColor: colorScheme.surface,
     canvasColor: colorScheme.surface,
  );


  List<ExtendedColor> get extendedColors => [
  ];
}

class ExtendedColor {
  final Color seed, value;
  final ColorFamily light;
  final ColorFamily lightHighContrast;
  final ColorFamily lightMediumContrast;
  final ColorFamily dark;
  final ColorFamily darkHighContrast;
  final ColorFamily darkMediumContrast;

  const ExtendedColor({
    required this.seed,
    required this.value,
    required this.light,
    required this.lightHighContrast,
    required this.lightMediumContrast,
    required this.dark,
    required this.darkHighContrast,
    required this.darkMediumContrast,
  });
}

class ColorFamily {
  const ColorFamily({
    required this.color,
    required this.onColor,
    required this.colorContainer,
    required this.onColorContainer,
  });

  final Color color;
  final Color onColor;
  final Color colorContainer;
  final Color onColorContainer;
}
