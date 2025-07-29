// lib/core/constants/breakpoints.dart
import 'dart:developer';

/// Costanti per breakpoint responsive design
/// Utilizzate in tutta l'applicazione per garantire consistenza
class ResponsiveBreakpoints {
  /// Breakpoint per mobile (fino a 600px)
  /// Include smartphone in modalità portrait e landscape
  static const double mobile = 600.0;

  /// Breakpoint per tablet (600px - 900px)
  /// Include tablet piccoli e smartphone grandi in landscape
  static const double tablet = 900.0;

  /// Breakpoint per desktop (900px - 1200px)
  /// Include laptop e tablet grandi
  static const double desktop = 1200.0;

  /// Breakpoint per desktop large (1200px+)
  /// Include monitor grandi e ultra-wide
  static const double largeDesktop = 1600.0;

  /// Breakpoint per monitor ultra-wide (1600px+)
  /// Include setup multi-monitor e schermi 4K
  static const double ultraWide = 2000.0;

  /// Verifica se la larghezza corrisponde a mobile
  static bool isMobile(double width) => width < mobile;

  /// Verifica se la larghezza corrisponde a tablet
  static bool isTablet(double width) => width >= mobile && width < desktop;

  /// Verifica se la larghezza corrisponde a desktop
  static bool isDesktop(double width) =>
      width >= desktop && width < largeDesktop;

  /// Verifica se la larghezza corrisponde a large desktop
  static bool isLargeDesktop(double width) =>
      width >= largeDesktop && width < ultraWide;

  /// Verifica se la larghezza corrisponde a ultra-wide
  static bool isUltraWide(double width) => width >= ultraWide;

  /// Ottiene il tipo di dispositivo basato sulla larghezza
  static DeviceType getDeviceType(double width) {
    if (width < mobile) return DeviceType.mobile;
    if (width < desktop) return DeviceType.tablet;
    if (width < largeDesktop) return DeviceType.desktop;
    if (width < ultraWide) return DeviceType.largeDesktop;
    return DeviceType.ultraWide;
  }
}

/// Enum per i tipi di dispositivo
enum DeviceType { mobile, tablet, desktop, largeDesktop, ultraWide }

/// Estensione per DeviceType con utility methods
extension DeviceTypeExtension on DeviceType {
  /// Nome leggibile del tipo di dispositivo
  String get displayName {
    switch (this) {
      case DeviceType.mobile:
        return 'Mobile';
      case DeviceType.tablet:
        return 'Tablet';
      case DeviceType.desktop:
        return 'Desktop';
      case DeviceType.largeDesktop:
        return 'Large Desktop';
      case DeviceType.ultraWide:
        return 'Ultra Wide';
    }
  }

  /// Icona rappresentativa del tipo di dispositivo
  String get icon {
    switch (this) {
      case DeviceType.mobile:
        return '📱';
      case DeviceType.tablet:
        return '📱'; // Tablet icon
      case DeviceType.desktop:
        return '💻';
      case DeviceType.largeDesktop:
        return '🖥️';
      case DeviceType.ultraWide:
        return '🖥️'; // Ultra wide monitor
    }
  }

  /// Verifica se il dispositivo è mobile o tablet (touch)
  bool get isTouchDevice =>
      this == DeviceType.mobile || this == DeviceType.tablet;

  /// Verifica se il dispositivo è desktop o superiore
  bool get isDesktopClass => index >= DeviceType.desktop.index;

  /// Verifica se il dispositivo supporta hover interactions
  bool get supportsHover => isDesktopClass;

  /// Verifica se il dispositivo dovrebbe mostrare sidebar collassata di default
  bool get shouldCollapseSidebar => this == DeviceType.tablet;
}

/// Costanti per layout responsive specifiche dell'app DM Assistant
class DMAssistantBreakpoints {
  /// Larghezza minima per mostrare la sidebar
  static const double sidebarMinWidth = ResponsiveBreakpoints.tablet;

  /// Larghezza minima per mostrare breadcrumb
  static const double breadcrumbMinWidth = ResponsiveBreakpoints.desktop;

  /// Larghezza minima per layout a 2 colonne
  static const double twoColumnMinWidth = ResponsiveBreakpoints.tablet;

  /// Larghezza minima per layout a 3 colonne
  static const double threeColumnMinWidth = ResponsiveBreakpoints.desktop;

  /// Larghezza minima per layout a 4 colonne
  static const double fourColumnMinWidth = ResponsiveBreakpoints.largeDesktop;

  /// Numero di colonne per grid basato sulla larghezza
  static int getGridColumns(double width) {
    if (width >= fourColumnMinWidth) return 4;
    if (width >= threeColumnMinWidth) return 3;
    if (width >= twoColumnMinWidth) return 2;
    return 1;
  }

  /// Verifica se mostrare la sidebar
  static bool shouldShowSidebar(double width) => width >= sidebarMinWidth;

  /// Verifica se mostrare i breadcrumb
  static bool shouldShowBreadcrumb(double width) => width >= breadcrumbMinWidth;

  /// Verifica se usare navigation rail invece di sidebar
  static bool shouldUseNavigationRail(double width) {
    return width >= ResponsiveBreakpoints.tablet &&
        width < ResponsiveBreakpoints.desktop;
  }
}

/// Configurazioni specifiche per componenti responsive
class ComponentBreakpoints {
  /// Card padding basato sulla dimensione schermo
  static double getCardPadding(double width) {
    if (width >= ResponsiveBreakpoints.largeDesktop) return 24.0;
    if (width >= ResponsiveBreakpoints.desktop) return 20.0;
    if (width >= ResponsiveBreakpoints.tablet) return 16.0;
    return 12.0;
  }

  /// Spacing tra elementi basato sulla dimensione schermo
  static double getSpacing(double width) {
    if (width >= ResponsiveBreakpoints.largeDesktop) return 32.0;
    if (width >= ResponsiveBreakpoints.desktop) return 24.0;
    if (width >= ResponsiveBreakpoints.tablet) return 16.0;
    return 12.0;
  }

  /// Font size scaling basato sulla dimensione schermo
  static double getFontScale(double width) {
    if (width >= ResponsiveBreakpoints.largeDesktop) return 1.2;
    if (width >= ResponsiveBreakpoints.desktop) return 1.1;
    if (width >= ResponsiveBreakpoints.tablet) return 1.0;
    return 0.9;
  }

  /// Maximum content width per ogni breakpoint
  static double getMaxContentWidth(double width) {
    if (width >= ResponsiveBreakpoints.ultraWide) return 1600.0;
    if (width >= ResponsiveBreakpoints.largeDesktop) return 1400.0;
    if (width >= ResponsiveBreakpoints.desktop) return 1200.0;
    return width * 0.95; // 95% della larghezza disponibile per tablet e mobile
  }

  /// Aspect ratio per card basato sulla dimensione schermo
  static double getCardAspectRatio(double width) {
    if (width >= ResponsiveBreakpoints.desktop) return 1.2;
    if (width >= ResponsiveBreakpoints.tablet) return 1.4;
    return 1.6; // Più tall su mobile per mostrare più info
  }
}

/// Utility class per calcoli responsive avanzati
class ResponsiveCalculator {
  /// Calcola il valore interpolato tra due breakpoint
  static double interpolate({
    required double currentWidth,
    required double minWidth,
    required double maxWidth,
    required double minValue,
    required double maxValue,
  }) {
    if (currentWidth <= minWidth) return minValue;
    if (currentWidth >= maxWidth) return maxValue;

    final progress = (currentWidth - minWidth) / (maxWidth - minWidth);
    return minValue + (maxValue - minValue) * progress;
  }

  /// Calcola padding responsive
  static double responsivePadding(double width) {
    return interpolate(
      currentWidth: width,
      minWidth: ResponsiveBreakpoints.mobile,
      maxWidth: ResponsiveBreakpoints.largeDesktop,
      minValue: 16.0,
      maxValue: 48.0,
    );
  }

  /// Calcola margin responsive
  static double responsiveMargin(double width) {
    return interpolate(
      currentWidth: width,
      minWidth: ResponsiveBreakpoints.mobile,
      maxWidth: ResponsiveBreakpoints.largeDesktop,
      minValue: 8.0,
      maxValue: 24.0,
    );
  }

  /// Calcola border radius responsive
  static double responsiveBorderRadius(double width) {
    return interpolate(
      currentWidth: width,
      minWidth: ResponsiveBreakpoints.mobile,
      maxWidth: ResponsiveBreakpoints.largeDesktop,
      minValue: 8.0,
      maxValue: 16.0,
    );
  }

  /// Calcola il numero di colonne per una grid responsive
  static int responsiveColumns({
    required double width,
    required double itemMinWidth,
    double spacing = 16.0,
  }) {
    final availableWidth = width - (spacing * 2); // Margini laterali
    final columns = (availableWidth / (itemMinWidth + spacing)).floor();
    return columns.clamp(1, 6); // Massimo 6 colonne
  }
}

/// Mix-in per widget che devono essere responsive
mixin ResponsiveMixin {
  /// Ottiene il tipo di dispositivo dal context
  DeviceType getDeviceType(double width) {
    return ResponsiveBreakpoints.getDeviceType(width);
  }

  /// Verifica se è mobile
  bool isMobile(double width) => ResponsiveBreakpoints.isMobile(width);

  /// Verifica se è tablet
  bool isTablet(double width) => ResponsiveBreakpoints.isTablet(width);

  /// Verifica se è desktop
  bool isDesktop(double width) => ResponsiveBreakpoints.isDesktop(width);

  /// Restituisce un valore basato sul tipo di dispositivo
  T responsive<T>({
    required double width,
    required T mobile,
    T? tablet,
    required T desktop,
    T? largeDesktop,
    T? ultraWide,
  }) {
    final deviceType = getDeviceType(width);

    switch (deviceType) {
      case DeviceType.mobile:
        return mobile;
      case DeviceType.tablet:
        return tablet ?? mobile;
      case DeviceType.desktop:
        return desktop;
      case DeviceType.largeDesktop:
        return largeDesktop ?? desktop;
      case DeviceType.ultraWide:
        return ultraWide ?? largeDesktop ?? desktop;
    }
  }
}

/// Costanti per performance responsive
class ResponsivePerformance {
  /// Debounce time per resize events (milliseconds)
  static const int resizeDebounceMs = 100;

  /// Threshold per considerare un cambio di breakpoint significativo
  static const double breakpointChangeThreshold = 50.0;

  /// Frame rate target per animazioni responsive
  static const int targetFps = 60;

  /// Durata delle animazioni responsive
  static const Duration animationDuration = Duration(milliseconds: 200);
}

/// Debug utilities per responsive design
class ResponsiveDebug {
  /// Stampa informazioni di debug sul layout corrente
  static void logLayoutInfo(double width, double height) {
    final deviceType = ResponsiveBreakpoints.getDeviceType(width);
    final columns = DMAssistantBreakpoints.getGridColumns(width);

    log('=== RESPONSIVE DEBUG ===');
    log('Screen: ${width.toStringAsFixed(0)}x${height.toStringAsFixed(0)}');
    log('Device Type: ${deviceType.displayName}');
    log('Grid Columns: $columns');
    log('Show Sidebar: ${DMAssistantBreakpoints.shouldShowSidebar(width)}');
    log(
      'Show Breadcrumb: ${DMAssistantBreakpoints.shouldShowBreadcrumb(width)}',
    );
    log('========================');
  }

  /// Ottiene una stringa di debug per il layout corrente
  static String getLayoutDebugString(double width) {
    final deviceType = ResponsiveBreakpoints.getDeviceType(width);
    return '${deviceType.icon} ${deviceType.displayName} (${width.toStringAsFixed(0)}px)';
  }
}
