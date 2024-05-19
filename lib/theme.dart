import 'package:flutter/material.dart';

final darkThemeData = ThemeData.dark();
final lightThemeData = ThemeData.light();

bool isDarkMode(BuildContext context) {
  final currentBrightness = Theme.of(context).brightness;
  return currentBrightness == Brightness.dark;
}
