import 'package:flutter/widgets.dart';

class Responsive {
  const Responsive._();

  static bool isTablet(BuildContext context) => MediaQuery.sizeOf(context).width >= 600;

  static double maxContentWidth(BuildContext context) {
    return isTablet(context) ? 520 : double.infinity;
  }
}
