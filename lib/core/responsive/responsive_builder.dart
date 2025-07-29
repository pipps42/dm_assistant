// lib/core/responsive/responsive_builder.dart
import 'package:flutter/material.dart';

/// Breakpoint per diverse dimensioni schermo
class Breakpoints {
  static const double mobile = 600;
  static const double tablet = 900;
  static const double desktop = 1200;
  static const double largeDesktop = 1600;
}

/// Enum per identificare il tipo di dispositivo
enum DeviceType { mobile, tablet, desktop, largeDesktop }

/// Widget per costruire layout responsive
class ResponsiveBuilder extends StatelessWidget {
  final Widget mobile;
  final Widget? tablet;
  final Widget desktop;
  final Widget? largeDesktop;

  const ResponsiveBuilder({
    super.key,
    required this.mobile,
    required this.desktop,
    this.tablet,
    this.largeDesktop,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final deviceType = _getDeviceType(constraints.maxWidth);

        switch (deviceType) {
          case DeviceType.mobile:
            return mobile;
          case DeviceType.tablet:
            return tablet ?? mobile;
          case DeviceType.desktop:
            return desktop;
          case DeviceType.largeDesktop:
            return largeDesktop ?? desktop;
        }
      },
    );
  }

  DeviceType _getDeviceType(double width) {
    if (width >= Breakpoints.largeDesktop) {
      return DeviceType.largeDesktop;
    } else if (width >= Breakpoints.desktop) {
      return DeviceType.desktop;
    } else if (width >= Breakpoints.tablet) {
      return DeviceType.tablet;
    } else {
      return DeviceType.mobile;
    }
  }
}

/// Extension per semplificare i controlli responsive nel BuildContext
extension ResponsiveExtension on BuildContext {
  /// Restituisce true se il dispositivo è mobile
  bool get isMobile {
    final width = MediaQuery.of(this).size.width;
    return width < Breakpoints.mobile;
  }

  /// Restituisce true se il dispositivo è tablet
  bool get isTablet {
    final width = MediaQuery.of(this).size.width;
    return width >= Breakpoints.mobile && width < Breakpoints.desktop;
  }

  /// Restituisce true se il dispositivo è desktop
  bool get isDesktop {
    final width = MediaQuery.of(this).size.width;
    return width >= Breakpoints.desktop;
  }

  /// Restituisce true se il dispositivo è large desktop
  bool get isLargeDesktop {
    final width = MediaQuery.of(this).size.width;
    return width >= Breakpoints.largeDesktop;
  }

  /// Restituisce il tipo di dispositivo corrente
  DeviceType get deviceType {
    final width = MediaQuery.of(this).size.width;
    if (width >= Breakpoints.largeDesktop) {
      return DeviceType.largeDesktop;
    } else if (width >= Breakpoints.desktop) {
      return DeviceType.desktop;
    } else if (width >= Breakpoints.tablet) {
      return DeviceType.tablet;
    } else {
      return DeviceType.mobile;
    }
  }

  /// Restituisce un valore basato sul tipo di dispositivo
  T responsive<T>({
    required T mobile,
    T? tablet,
    required T desktop,
    T? largeDesktop,
  }) {
    switch (deviceType) {
      case DeviceType.mobile:
        return mobile;
      case DeviceType.tablet:
        return tablet ?? mobile;
      case DeviceType.desktop:
        return desktop;
      case DeviceType.largeDesktop:
        return largeDesktop ?? desktop;
    }
  }
}

/// Widget helper per spacing responsive
class ResponsiveSpacing extends StatelessWidget {
  final double mobile;
  final double? tablet;
  final double desktop;
  final double? largeDesktop;
  final bool isHorizontal;

  const ResponsiveSpacing({
    super.key,
    required this.mobile,
    required this.desktop,
    this.tablet,
    this.largeDesktop,
    this.isHorizontal = false,
  });

  const ResponsiveSpacing.horizontal({
    Key? key,
    required double mobile,
    required double desktop,
    double? tablet,
    double? largeDesktop,
  }) : this(
         key: key,
         mobile: mobile,
         desktop: desktop,
         tablet: tablet,
         largeDesktop: largeDesktop,
         isHorizontal: true,
       );

  const ResponsiveSpacing.vertical({
    Key? key,
    required double mobile,
    required double desktop,
    double? tablet,
    double? largeDesktop,
  }) : this(
         key: key,
         mobile: mobile,
         desktop: desktop,
         tablet: tablet,
         largeDesktop: largeDesktop,
         isHorizontal: false,
       );

  @override
  Widget build(BuildContext context) {
    final spacing = context.responsive<double>(
      mobile: mobile,
      tablet: tablet,
      desktop: desktop,
      largeDesktop: largeDesktop,
    );

    return isHorizontal ? SizedBox(width: spacing) : SizedBox(height: spacing);
  }
}

/// Widget helper per padding responsive
class ResponsivePadding extends StatelessWidget {
  final Widget child;
  final EdgeInsets mobile;
  final EdgeInsets? tablet;
  final EdgeInsets desktop;
  final EdgeInsets? largeDesktop;

  const ResponsivePadding({
    super.key,
    required this.child,
    required this.mobile,
    required this.desktop,
    this.tablet,
    this.largeDesktop,
  });

  @override
  Widget build(BuildContext context) {
    final padding = context.responsive<EdgeInsets>(
      mobile: mobile,
      tablet: tablet,
      desktop: desktop,
      largeDesktop: largeDesktop,
    );

    return Padding(padding: padding, child: child);
  }
}
