import 'package:flutter/material.dart';

/// Shared colour/style constants for the meeting details screen.
class MeetingDetailsColors {
  MeetingDetailsColors._();

  static const bg = Color(0xFFF4F5FB);
  static const ink = Color(0xFF16181F);
  static const inkSoft = Color(0xFF6B7080);
  static const border = Color(0xFFE6E8F0);
  static const fieldBg = Color(0xFFF7F7FA);
  static const purple = Color(0xFF7C5CFF);
  static const purpleSoft = Color(0xFFF1EDFF);
  static const green = Color(0xFF16A35A);
  static const greenSoft = Color(0xFFECFDF3);
  static const red = Color(0xFFE5484D);
  static const redSoft = Color(0xFFFDEEEE);
  static const amberBg = Color(0xFFFEF3D9);
  static const amberInk = Color(0xFF9A6B00);
  static const endedBg = Color(0xFFECEEF3);
  static const endedInk = Color(0xFF565B6B);
  static const endedDot = Color(0xFF8B8F9D);

  /// Returns the badge background colour for a given [status].
  static Color badgeBg(String status) {
    switch (status) {
      case 'LIVE':
        return greenSoft;
      case 'ENDED':
        return endedBg;
      case 'CANCELLED':
        return redSoft;
      default:
        return amberBg;
    }
  }

  /// Returns the badge foreground colour for a given [status].
  static Color badgeFg(String status) {
    switch (status) {
      case 'LIVE':
        return green;
      case 'ENDED':
        return endedInk;
      case 'CANCELLED':
        return red;
      default:
        return amberInk;
    }
  }

  /// Returns the lifecycle dot colour for a given [status].
  static Color dotColor(String status) {
    switch (status) {
      case 'LIVE':
        return green;
      case 'ENDED':
        return endedDot;
      case 'CANCELLED':
        return red;
      default:
        return amberInk;
    }
  }
}
