import 'package:flutter/material.dart';
import 'package:requra/theme/font_manager.dart';

//=================How to use it==========================
/*

* */

TextStyle _getTextStyle(double fontSize, FontWeight fontWeight, Color color) {
  return TextStyle(
      fontWeight: fontWeight,
      fontFamily: FontConstants.fontFamily,
      color: color,
      fontSize: fontSize);
}

TextStyle regularStyle({required double fontSize, required Color color}) {
  return _getTextStyle(fontSize, FontWeightManager.regular, color);
}

TextStyle boldStyle({required double fontSize, required Color color}) {
  return _getTextStyle(fontSize, FontWeightManager.bold, color);
}
TextStyle semiBoldStyle({required double fontSize, required Color color}) {
  return _getTextStyle(fontSize, FontWeightManager.semiBold, color);
}
