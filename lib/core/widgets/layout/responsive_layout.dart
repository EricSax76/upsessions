import 'package:flutter/material.dart';

import '../constants/breakpoints.dart';

/// Widget que selecciona un layout según el ancho disponible.
class ResponsiveLayout extends StatelessWidget {
  const ResponsiveLayout({
    super.key,
    required this.mobile,
    this.tablet,
    this.desktop,
    this.xl,
  });

  final Widget mobile;
  final Widget? tablet;
  final Widget? desktop;
  final Widget? xl;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;

        if (width >= Breakpoints.xl && xl != null) {
          return xl!;
        }
        if (width >= Breakpoints.desktop && desktop != null) {
          return desktop!;
        }
        if (width >= Breakpoints.tablet && tablet != null) {
          return tablet!;
        }
        return mobile;
      },
    );
  }
}

/// Builder que expone el tipo de dispositivo según el ancho.
class ResponsiveBuilder extends StatelessWidget {
  const ResponsiveBuilder({
    super.key,
    required this.builder,
  });

  final Widget Function(
    BuildContext context,
    BoxConstraints constraints,
    DeviceType type,
  ) builder;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final type = _getDeviceType(constraints.maxWidth);
        return builder(context, constraints, type);
      },
    );
  }

  DeviceType _getDeviceType(double width) {
    if (width >= Breakpoints.xl) return DeviceType.xl;
    if (width >= Breakpoints.desktop) return DeviceType.desktop;
    if (width >= Breakpoints.tablet) return DeviceType.tablet;
    return DeviceType.mobile;
  }
}

enum DeviceType { mobile, tablet, desktop, xl }
