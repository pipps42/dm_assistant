// lib/core/utils/platform_utils.dart
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Utility class per gestire specifiche della piattaforma
class PlatformUtils {
  /// Verifica se l'app è in esecuzione su Android
  static bool get isAndroid => !kIsWeb && Platform.isAndroid;

  /// Verifica se l'app è in esecuzione su iOS
  static bool get isIOS => !kIsWeb && Platform.isIOS;

  /// Verifica se l'app è in esecuzione su Windows
  static bool get isWindows => !kIsWeb && Platform.isWindows;

  /// Verifica se l'app è in esecuzione su macOS
  static bool get isMacOS => !kIsWeb && Platform.isMacOS;

  /// Verifica se l'app è in esecuzione su Linux
  static bool get isLinux => !kIsWeb && Platform.isLinux;

  /// Verifica se l'app è in esecuzione su Web
  static bool get isWeb => kIsWeb;

  /// Verifica se è una piattaforma mobile (Android o iOS)
  static bool get isMobile => isAndroid || isIOS;

  /// Verifica se è una piattaforma desktop (Windows, macOS, Linux)
  static bool get isDesktop => isWindows || isMacOS || isLinux;

  /// Verifica se è una piattaforma che supporta hover
  static bool get supportsHover => isDesktop || isWeb;

  /// Verifica se è una piattaforma touch
  static bool get isTouchDevice => isMobile;

  /// Ottiene il nome della piattaforma corrente
  static String get platformName {
    if (isAndroid) return 'Android';
    if (isIOS) return 'iOS';
    if (isWindows) return 'Windows';
    if (isMacOS) return 'macOS';
    if (isLinux) return 'Linux';
    if (isWeb) return 'Web';
    return 'Unknown';
  }

  /// Ottiene l'icona appropriata per la piattaforma
  static IconData get platformIcon {
    if (isAndroid) return Icons.android;
    if (isIOS) return Icons.phone_iphone;
    if (isWindows) return Icons.desktop_windows;
    if (isMacOS) return Icons.desktop_mac;
    if (isLinux) return Icons.computer;
    if (isWeb) return Icons.web;
    return Icons.device_unknown;
  }

  /// GESTIONE KEYBOARD SHORTCUTS (principalmente per desktop)

  /// Verifica se il comando è il tasto Ctrl (Windows/Linux) o Cmd (macOS)
  static bool isCommandKey(LogicalKeyboardKey key) {
    return (isMacOS && key == LogicalKeyboardKey.meta) ||
        (!isMacOS && key == LogicalKeyboardKey.control);
  }

  /// Ottiene il modificatore principale per shortcuts (Cmd su macOS, Ctrl altrove)
  static LogicalKeyboardKey get primaryModifier {
    return isMacOS ? LogicalKeyboardKey.meta : LogicalKeyboardKey.control;
  }

  /// Crea un set di LogicalKeyboardKey per shortcuts
  static Set<LogicalKeyboardKey> createShortcut(LogicalKeyboardKey key) {
    return {primaryModifier, key};
  }

  /// Shortcuts comuni
  static Set<LogicalKeyboardKey> get copyShortcut =>
      createShortcut(LogicalKeyboardKey.keyC);

  static Set<LogicalKeyboardKey> get pasteShortcut =>
      createShortcut(LogicalKeyboardKey.keyV);

  static Set<LogicalKeyboardKey> get saveShortcut =>
      createShortcut(LogicalKeyboardKey.keyS);

  static Set<LogicalKeyboardKey> get newShortcut =>
      createShortcut(LogicalKeyboardKey.keyN);

  static Set<LogicalKeyboardKey> get searchShortcut =>
      createShortcut(LogicalKeyboardKey.keyF);

  static Set<LogicalKeyboardKey> get refreshShortcut =>
      createShortcut(LogicalKeyboardKey.keyR);

  /// GESTIONE UI SPECIFICA PER PIATTAFORMA

  /// Ottiene l'altezza appropriata per app bar basata sulla piattaforma
  static double get appBarHeight {
    if (isMobile) return kToolbarHeight;
    return 64.0; // Più alta su desktop
  }

  /// Ottiene il padding appropriato per il contenuto
  static EdgeInsets get defaultContentPadding {
    if (isMobile) return const EdgeInsets.all(16.0);
    return const EdgeInsets.all(24.0); // Più spazio su desktop
  }

  /// Ottiene la dimensione appropriata per i pulsanti floating action
  static double get fabSize {
    if (isMobile) return 56.0;
    return 64.0; // Più grande su desktop
  }

  /// Verifica se mostrare le animazioni (potrebbero essere disabilitate su desktop per performance)
  static bool get shouldShowAnimations {
    // Su desktop riduciamo le animazioni per migliori performance
    return isMobile || !isDesktop;
  }

  /// Durata delle animazioni appropriata per la piattaforma
  static Duration get animationDuration {
    if (isMobile) return const Duration(milliseconds: 300);
    return const Duration(milliseconds: 200); // Più veloce su desktop
  }

  /// GESTIONE FEEDBACK TATTILE

  /// Fornisce feedback tattile se supportato
  static void provideTactileFeedback([
    HapticFeedbackType type = HapticFeedbackType.lightTap,
  ]) {
    if (isMobile) {
      switch (type) {
        case HapticFeedbackType.lightTap:
          HapticFeedback.lightImpact();
          break;
        case HapticFeedbackType.mediumTap:
          HapticFeedback.mediumImpact();
          break;
        case HapticFeedbackType.heavyTap:
          HapticFeedback.heavyImpact();
          break;
        case HapticFeedbackType.selectionClick:
          HapticFeedback.selectionClick();
          break;
      }
    }
  }

  /// GESTIONE INTERFACCIA DESKTOP

  /// Verifica se dovremmo mostrare la sidebar
  static bool shouldShowSidebar(double screenWidth) {
    if (!isDesktop) return false;
    return screenWidth >= 900; // Mostra sidebar solo su schermi larghi desktop
  }

  /// Verifica se dovremmo usare un layout multi-pannello
  static bool shouldUseMultiPanel(double screenWidth) {
    if (!isDesktop) return false;
    return screenWidth >= 1200;
  }

  /// Ottiene il numero appropriato di colonne per una grid
  static int getGridColumns(double screenWidth) {
    if (isDesktop) {
      if (screenWidth >= 1600) return 4;
      if (screenWidth >= 1200) return 3;
      if (screenWidth >= 900) return 2;
    }
    return 1;
  }

  /// GESTIONE FILE E PATHS

  /// Ottiene il separatore di path appropriato
  static String get pathSeparator {
    if (isWindows) return '\\';
    return '/';
  }

  /// Converte un path in formato appropriato per la piattaforma
  static String normalizePath(String path) {
    if (isWindows) {
      return path.replaceAll('/', '\\');
    }
    return path.replaceAll('\\', '/');
  }

  /// GESTIONE WINDOW (Desktop)

  /// Dimensioni minime della finestra per desktop
  static Size get minWindowSize {
    return const Size(800, 600);
  }

  /// Dimensioni iniziali della finestra per desktop
  static Size get initialWindowSize {
    return const Size(1200, 800);
  }

  /// Verifica se la finestra può essere ridimensionata
  static bool get canResizeWindow => isDesktop;

  /// UTILITY PER PERFORMANCE

  /// Verifica se dovremmo usare immagini ad alta risoluzione
  static bool shouldUseHighResImages(BuildContext context) {
    final pixelRatio = MediaQuery.of(context).devicePixelRatio;
    return pixelRatio > 2.0 || isDesktop;
  }

  /// Ottiene la qualità appropriata per le immagini
  static int getImageQuality() {
    if (isDesktop) return 95; // Alta qualità su desktop
    if (isMobile) return 85; // Qualità media su mobile per risparmiare memoria
    return 90; // Default per web
  }

  /// Verifica se dovremmo precaricare le immagini
  static bool shouldPreloadImages() {
    return isDesktop; // Solo su desktop dove abbiamo più memoria
  }

  /// GESTIONE INPUT

  /// Verifica se supportiamo input con mouse
  static bool get supportsMouseInput => isDesktop || isWeb;

  /// Verifica se supportiamo input touch
  static bool get supportsTouchInput => isMobile || isWeb;

  /// Verifica se supportiamo input da tastiera
  static bool get supportsKeyboardInput => isDesktop || isWeb;

  /// Dimensione appropriata per target touch
  static double get touchTargetSize {
    if (isMobile) return 48.0; // Material Design standard
    return 32.0; // Più piccolo su desktop con mouse precision
  }

  /// GESTIONE NOTIFICHE

  /// Verifica se possiamo mostrare notifiche di sistema
  static bool get canShowSystemNotifications => !isWeb;

  /// Verifica se dovremmo mostrare badge numbers
  static bool get shouldShowBadgeNumbers => isMobile;

  /// DEBUGGING E SVILUPPO

  /// Informazioni di debug sulla piattaforma
  static Map<String, dynamic> get debugInfo {
    return {
      'platform': platformName,
      'isWeb': isWeb,
      'isMobile': isMobile,
      'isDesktop': isDesktop,
      'isDebugMode': kDebugMode,
      'isProfileMode': kProfileMode,
      'isReleaseMode': kReleaseMode,
      'supportsHover': supportsHover,
      'supportsTouchInput': supportsTouchInput,
      'supportsKeyboardInput': supportsKeyboardInput,
    };
  }

  /// Stampa le informazioni di debug
  static void printDebugInfo() {
    if (kDebugMode) {
      print('=== PLATFORM DEBUG INFO ===');
      debugInfo.forEach((key, value) {
        print('$key: $value');
      });
      print('===========================');
    }
  }
}

/// Enum per tipi di feedback tattile
enum HapticFeedbackType { lightTap, mediumTap, heavyTap, selectionClick }

/// Mixin per widget che devono adattarsi alla piattaforma
mixin PlatformAware {
  /// Verifica se siamo su mobile
  bool get isMobile => PlatformUtils.isMobile;

  /// Verifica se siamo su desktop
  bool get isDesktop => PlatformUtils.isDesktop;

  /// Verifica se supportiamo hover
  bool get supportsHover => PlatformUtils.supportsHover;

  /// Fornisce feedback tattile
  void provideTactileFeedback([
    HapticFeedbackType type = HapticFeedbackType.lightTap,
  ]) {
    PlatformUtils.provideTactileFeedback(type);
  }

  /// Ottiene il padding appropriato per il contenuto
  EdgeInsets get contentPadding => PlatformUtils.defaultContentPadding;

  /// Ottiene la durata delle animazioni appropriata
  Duration get animationDuration => PlatformUtils.animationDuration;
}

/// Extension per BuildContext con utility platform-aware
extension PlatformContextExtension on BuildContext {
  /// Verifica se siamo su mobile
  bool get isMobile => PlatformUtils.isMobile;

  /// Verifica se siamo su desktop
  bool get isDesktop => PlatformUtils.isDesktop;

  /// Verifica se supportiamo hover
  bool get supportsHover => PlatformUtils.supportsHover;

  /// Ottiene il padding appropriato per il contenuto
  EdgeInsets get platformContentPadding => PlatformUtils.defaultContentPadding;

  /// Verifica se dovremmo mostrare animazioni
  bool get shouldShowAnimations => PlatformUtils.shouldShowAnimations;

  /// Ottiene la dimensione del touch target appropriata
  double get touchTargetSize => PlatformUtils.touchTargetSize;
}
