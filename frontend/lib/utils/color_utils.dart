// lib/utils/color_utils.dart

import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class ColorUtils {
  ColorUtils._();

  // Determine if a color is light or dark
  static bool isLightColor(Color color) {
    // Calculate relative luminance
    final luminance = color.computeLuminance();
    return luminance > 0.5;
  }

  // Get contrasting text color for a given background
  static Color getContrastingTextColor(Color backgroundColor) {
    return isLightColor(backgroundColor) 
        ? VivaBemColors.cinzaEscuro 
        : VivaBemColors.branco;
  }

  // Get icon color based on background (specific to app's design)
  static Color getIconColor(Color backgroundColor) {
    // Special case for yellow/golden color - use dark icon
    if (backgroundColor == VivaBemColors.amareloDourado) {
      return VivaBemColors.cinzaEscuro;
    }
    
    // For other colors, use white icon
    return VivaBemColors.branco;
  }

  // Get app bar icon/text color based on background
  static Color getAppBarContentColor(Color backgroundColor) {
    // List of light colors that need dark text/icons
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

  // Add opacity to a color
  static Color withOpacity(Color color, double opacity) {
    return color.withOpacity(opacity);
  }

  // Lighten a color
  static Color lighten(Color color, [double amount = 0.1]) {
    assert(amount >= 0 && amount <= 1);
    final hsl = HSLColor.fromColor(color);
    final lightness = (hsl.lightness + amount).clamp(0.0, 1.0);
    return hsl.withLightness(lightness).toColor();
  }

  // Darken a color
  static Color darken(Color color, [double amount = 0.1]) {
    assert(amount >= 0 && amount <= 1);
    final hsl = HSLColor.fromColor(color);
    final lightness = (hsl.lightness - amount).clamp(0.0, 1.0);
    return hsl.withLightness(lightness).toColor();
  }
}
