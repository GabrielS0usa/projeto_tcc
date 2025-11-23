import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

class ColorUtils {
  ColorUtils._();

  static bool isLightColor(Color color) {
    final luminance = color.computeLuminance();
    return luminance > 0.5;
  }

  static Color getContrastingTextColor(Color backgroundColor) {
    return isLightColor(backgroundColor)
        ? VivaBemColors.cinzaEscuro
        : VivaBemColors.branco;
  }

  static Color getIconColor(Color backgroundColor) {
    if (backgroundColor == VivaBemColors.amareloDourado) {
      return VivaBemColors.cinzaEscuro;
    }

    return VivaBemColors.branco;
  }

  static Color getAppBarContentColor(Color backgroundColor) {
    final lightColors = [
      VivaBemColors.amareloDourado,
      VivaBemColors.azulRoyal,
      VivaBemColors.laranjaVibrante,
      VivaBemColors.verdeEsmeralda,
    ];

    if (lightColors.contains(backgroundColor)) {
      return VivaBemColors.cinzaEscuro;
    }

    return VivaBemColors.branco;
  }

  static Color withOpacity(Color color, double opacity) {
    return color.withOpacity(opacity);
  }

  static Color lighten(Color color, [double amount = 0.1]) {
    assert(amount >= 0 && amount <= 1);
    final hsl = HSLColor.fromColor(color);
    final lightness = (hsl.lightness + amount).clamp(0.0, 1.0);
    return hsl.withLightness(lightness).toColor();
  }

  static Color darken(Color color, [double amount = 0.1]) {
    assert(amount >= 0 && amount <= 1);
    final hsl = HSLColor.fromColor(color);
    final lightness = (hsl.lightness - amount).clamp(0.0, 1.0);
    return hsl.withLightness(lightness).toColor();
  }
}
