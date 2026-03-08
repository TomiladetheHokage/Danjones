import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static TextStyle inter({
    double fontSize = 14,
    FontWeight fontWeight = FontWeight.normal,
    Color color = Colors.white,
    double letterSpacing = 0,
    double height = 1.5,
  }) {
    return GoogleFonts.inter(
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
      letterSpacing: letterSpacing,
      height: height,
    );
  }

  // Predefined text styles
  static TextStyle get heading1 => inter(fontSize: 32, fontWeight: FontWeight.bold);
  static TextStyle get heading2 => inter(fontSize: 24, fontWeight: FontWeight.bold);
  static TextStyle get heading3 => inter(fontSize: 18, fontWeight: FontWeight.bold);
  static TextStyle get body => inter(fontSize: 14, fontWeight: FontWeight.normal);
  static TextStyle get bodySmall => inter(fontSize: 12, fontWeight: FontWeight.normal);
  static TextStyle get caption => inter(fontSize: 11, fontWeight: FontWeight.normal);
  static TextStyle get button => inter(fontSize: 14, fontWeight: FontWeight.w600);
}
