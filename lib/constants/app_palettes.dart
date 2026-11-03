import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// Representation of a customizable static color palette in the app.
class AppColorPalette {
  final String id;
  final String nameKey;
  final Color primaryColor;
  final Color secondaryColor;
  final Color darkPrimaryColor;

  const AppColorPalette({
    required this.id,
    required this.nameKey,
    required this.primaryColor,
    required this.secondaryColor,
    required this.darkPrimaryColor,
  });

  String get localizedName => nameKey.tr;
  Color get seedColor => primaryColor;
}

/// Central catalog of available static color palettes.
/// Adding a new static color is as simple as adding an entry to [all].
class AppPalettes {
  AppPalettes._();

  static const String defaultPaletteId = 'forest_green';

  static const AppColorPalette forestGreen = AppColorPalette(
    id: 'forest_green',
    nameKey: 'palette_forest_green',
    primaryColor: Color(0xFF2C4829),
    secondaryColor: Color(0xFFF1E4D3),
    darkPrimaryColor: Color(0xFF87A481),
  );

  static const AppColorPalette crimsonRed = AppColorPalette(
    id: 'crimson_red',
    nameKey: 'palette_crimson_red',
    primaryColor: Color(0xFFB71C1C),
    secondaryColor: Color(0xFFFFEBEE),
    darkPrimaryColor: Color(0xFFEF9A9A),
  );

  static const AppColorPalette oceanBlue = AppColorPalette(
    id: 'ocean_blue',
    nameKey: 'palette_ocean_blue',
    primaryColor: Color(0xFF1565C0),
    secondaryColor: Color(0xFFE3F2FD),
    darkPrimaryColor: Color(0xFF90CAF9),
  );

  static const AppColorPalette royalPurple = AppColorPalette(
    id: 'royal_purple',
    nameKey: 'palette_royal_purple',
    primaryColor: Color(0xFF6A1B9A),
    secondaryColor: Color(0xFFF3E5F5),
    darkPrimaryColor: Color(0xFFCE93D8),
  );

  static const AppColorPalette sunsetOrange = AppColorPalette(
    id: 'sunset_orange',
    nameKey: 'palette_sunset_orange',
    primaryColor: Color(0xFFD84315),
    secondaryColor: Color(0xFFFBE9E7),
    darkPrimaryColor: Color(0xFFFFAB91),
  );

  static const AppColorPalette emeraldTeal = AppColorPalette(
    id: 'emerald_teal',
    nameKey: 'palette_emerald_teal',
    primaryColor: Color(0xFF00695C),
    secondaryColor: Color(0xFFE0F2F1),
    darkPrimaryColor: Color(0xFF80CBC4),
  );

  /// All selectable static palettes
  static const List<AppColorPalette> all = [
    forestGreen,
    crimsonRed,
    oceanBlue,
    royalPurple,
    sunsetOrange,
    emeraldTeal,
  ];

  /// Find palette by ID, falling back to default Forest Green
  static AppColorPalette findById(String? id) {
    return all.firstWhere(
      (p) => p.id == id,
      orElse: () => forestGreen,
    );
  }
}
