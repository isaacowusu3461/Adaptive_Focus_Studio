
import 'package:flutter/material.dart';

class AppMotion {
  static const Duration short = Duration(milliseconds: 200);
  static const Duration medium = Duration(milliseconds: 350);
  static const Duration long = Duration(milliseconds: 600);

  static Duration duration(
    Duration normal, {
    required bool reduceMotion,
  }) {
    return reduceMotion ? Duration.zero : normal;
  }

  static Curve get standardCurve => Curves.easeInOut;
}
