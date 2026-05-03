import 'package:flutter/material.dart';
import 'package:palette_generator/palette_generator.dart';
import 'constants.dart';

class ColorExtractor {
  static Future<Color> extractDominantColor(ImageProvider imageProvider) async {
    final PaletteGenerator paletteGenerator =
        await PaletteGenerator.fromImageProvider(imageProvider);
    return paletteGenerator.dominantColor?.color ?? AppColors.primary;
  }
}
