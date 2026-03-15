import 'package:flutter/widgets.dart';

class Breakpoints {
  Breakpoints._();

  static const double mobile = 600;

  static const double tablet = 1024;

  static const double desktop = 1024;

  static const double xl = 1440;
}

extension ResponsiveContext on BuildContext {
  bool get isMobile => MediaQuery.of(this).size.width < Breakpoints.mobile;
  bool get isTablet =>
      MediaQuery.of(this).size.width >= Breakpoints.mobile &&
      MediaQuery.of(this).size.width < Breakpoints.desktop;
  bool get isDesktop => MediaQuery.of(this).size.width >= Breakpoints.desktop;
  bool get isXL => MediaQuery.of(this).size.width >= Breakpoints.xl;

  /// Ejecuta el callback correspondiente según el ancho actual.
  T responsive<T>({required T mobile, T? tablet, T? desktop, T? xl}) {
    if (isXL && xl != null) return xl;
    if (isDesktop && desktop != null) return desktop;
    if (isTablet && tablet != null) return tablet;
    return mobile;
  }
}
