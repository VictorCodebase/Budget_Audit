import 'package:flutter/material.dart';

class NamedColor {
  final String name;
  final Color color;

  const NamedColor({required this.name, required this.color});
}

class ColorPalette {
  static const List<NamedColor> all = [
    NamedColor(name: 'Coral Red', color: Color(0xFFFF6B6B)),
    NamedColor(name: 'Orange', color: Color(0xFFFF9F43)),
    NamedColor(name: 'Sunflower Yellow', color: Color(0xFFFECA57)),
    NamedColor(name: 'Mint Green', color: Color(0xFF1DD1A1)),
    NamedColor(name: 'Cyan', color: Color(0xFF48DBFB)),
    NamedColor(name: 'Sky Blue', color: Color(0xFF54A0FF)),
    NamedColor(name: 'Purple', color: Color(0xFF5F27CD)),
    NamedColor(name: 'Amethyst', color: Color(0xFF9B59B6)),
    NamedColor(name: 'Pink', color: Color(0xFFFF9FF3)),
    NamedColor(name: 'Teal', color: Color(0xFF00D2D3)),
    NamedColor(name: 'Strong Blue', color: Color(0xFF2E86DE)),
    NamedColor(name: 'Grey Blue', color: Color(0xFF8395A7)),
  ];

  static Color getRandom() {
    return all[DateTime.now().millisecondsSinceEpoch % all.length].color;
  }

  static String getName(Color color) {
    try {
      return all.firstWhere((nc) => nc.color.toARGB32() == color.toARGB32()).name;
    } catch (e) {
      return 'Custom Color';
    }
  }
}
