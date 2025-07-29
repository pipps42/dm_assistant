// lib/core/theme/theme_provider.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dm_assistant/core/theme/app_theme.dart';

/// Enum per i temi disponibili
enum AppThemeMode { light, dark, system }

/// Provider per lo stato del tema
final themeProvider = StateNotifierProvider<ThemeNotifier, AppThemeMode>((ref) {
  return ThemeNotifier();
});

/// Provider per il tema corrente basato sulle impostazioni di sistema
final currentThemeProvider = Provider<ThemeData>((ref) {
  final themeMode = ref.watch(themeProvider);
  final platformBrightness = ref.watch(platformBrightnessProvider);

  switch (themeMode) {
    case AppThemeMode.light:
      return AppTheme.lightTheme;
    case AppThemeMode.dark:
      return AppTheme.darkTheme;
    case AppThemeMode.system:
      return platformBrightness == Brightness.dark
          ? AppTheme.darkTheme
          : AppTheme.lightTheme;
  }
});

/// Provider per il dark theme
final darkThemeProvider = Provider<ThemeData>((ref) {
  return AppTheme.darkTheme;
});

/// Provider per il light theme
final lightThemeProvider = Provider<ThemeData>((ref) {
  return AppTheme.lightTheme;
});

/// Provider per il ThemeMode di Flutter
final flutterThemeModeProvider = Provider<ThemeMode>((ref) {
  final appThemeMode = ref.watch(themeProvider);

  switch (appThemeMode) {
    case AppThemeMode.light:
      return ThemeMode.light;
    case AppThemeMode.dark:
      return ThemeMode.dark;
    case AppThemeMode.system:
      return ThemeMode.system;
  }
});

/// Provider per la luminosità della piattaforma
final platformBrightnessProvider = StateProvider<Brightness>((ref) {
  return WidgetsBinding.instance.platformDispatcher.platformBrightness;
});

/// Provider per sapere se il tema corrente è dark
final isDarkThemeProvider = Provider<bool>((ref) {
  final themeMode = ref.watch(themeProvider);
  final platformBrightness = ref.watch(platformBrightnessProvider);

  switch (themeMode) {
    case AppThemeMode.light:
      return false;
    case AppThemeMode.dark:
      return true;
    case AppThemeMode.system:
      return platformBrightness == Brightness.dark;
  }
});

/// Notifier per gestire il tema dell'applicazione
class ThemeNotifier extends StateNotifier<AppThemeMode> {
  ThemeNotifier() : super(AppThemeMode.system) {
    _loadThemeFromPreferences();
  }

  /// Carica il tema salvato dalle preferenze
  Future<void> _loadThemeFromPreferences() async {
    // TODO: Implementare il caricamento dalle SharedPreferences
    // Per ora usiamo il tema di sistema come default
    state = AppThemeMode.system;
  }

  /// Imposta il tema light
  Future<void> setLightTheme() async {
    state = AppThemeMode.light;
    await _saveThemeToPreferences();
  }

  /// Imposta il tema dark
  Future<void> setDarkTheme() async {
    state = AppThemeMode.dark;
    await _saveThemeToPreferences();
  }

  /// Imposta il tema di sistema
  Future<void> setSystemTheme() async {
    state = AppThemeMode.system;
    await _saveThemeToPreferences();
  }

  /// Cambia tra light e dark (ignora system)
  Future<void> toggleTheme() async {
    switch (state) {
      case AppThemeMode.light:
        await setDarkTheme();
        break;
      case AppThemeMode.dark:
      case AppThemeMode.system:
        await setLightTheme();
        break;
    }
  }

  /// Imposta il tema tramite enum
  Future<void> setTheme(AppThemeMode themeMode) async {
    state = themeMode;
    await _saveThemeToPreferences();
  }

  /// Salva il tema nelle preferenze
  Future<void> _saveThemeToPreferences() async {
    // TODO: Implementare il salvataggio nelle SharedPreferences
    // final prefs = await SharedPreferences.getInstance();
    // await prefs.setString('theme_mode', state.name);
  }

  /// Ottiene il nome leggibile del tema corrente
  String get currentThemeName {
    switch (state) {
      case AppThemeMode.light:
        return 'Light';
      case AppThemeMode.dark:
        return 'Dark';
      case AppThemeMode.system:
        return 'System';
    }
  }

  /// Ottiene l'icona per il tema corrente
  IconData get currentThemeIcon {
    switch (state) {
      case AppThemeMode.light:
        return Icons.light_mode;
      case AppThemeMode.dark:
        return Icons.dark_mode;
      case AppThemeMode.system:
        return Icons.auto_mode;
    }
  }
}

/// Widget helper per reagire ai cambiamenti di tema
class ThemeBuilder extends ConsumerWidget {
  final Widget Function(BuildContext context, ThemeData theme, bool isDark)
  builder;

  const ThemeBuilder({super.key, required this.builder});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref.watch(currentThemeProvider);
    final isDark = ref.watch(isDarkThemeProvider);

    return builder(context, theme, isDark);
  }
}

/// Widget per il toggle del tema con icona
class ThemeToggleButton extends ConsumerWidget {
  final bool showLabel;
  final String? tooltip;

  const ThemeToggleButton({super.key, this.showLabel = false, this.tooltip});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeNotifier = ref.read(themeProvider.notifier);
    final currentTheme = ref.watch(themeProvider);
    final isDark = ref.watch(isDarkThemeProvider);

    if (showLabel) {
      return TextButton.icon(
        onPressed: () => _showThemeDialog(context, ref),
        icon: Icon(themeNotifier.currentThemeIcon),
        label: Text(themeNotifier.currentThemeName),
      );
    }

    return IconButton(
      onPressed: () => _showThemeDialog(context, ref),
      icon: Icon(themeNotifier.currentThemeIcon),
      tooltip: tooltip ?? 'Change theme',
    );
  }

  void _showThemeDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => const ThemeSelectionDialog(),
    );
  }
}

/// Dialog per la selezione del tema
class ThemeSelectionDialog extends ConsumerWidget {
  const ThemeSelectionDialog({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentTheme = ref.watch(themeProvider);
    final themeNotifier = ref.read(themeProvider.notifier);

    return AlertDialog(
      title: const Text('Choose Theme'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildThemeOption(
            context: context,
            title: 'Light',
            subtitle: 'Light theme with bright colors',
            icon: Icons.light_mode,
            isSelected: currentTheme == AppThemeMode.light,
            onTap: () {
              themeNotifier.setLightTheme();
              Navigator.of(context).pop();
            },
          ),
          _buildThemeOption(
            context: context,
            title: 'Dark',
            subtitle: 'Dark theme with muted colors',
            icon: Icons.dark_mode,
            isSelected: currentTheme == AppThemeMode.dark,
            onTap: () {
              themeNotifier.setDarkTheme();
              Navigator.of(context).pop();
            },
          ),
          _buildThemeOption(
            context: context,
            title: 'System',
            subtitle: 'Follow system settings',
            icon: Icons.auto_mode,
            isSelected: currentTheme == AppThemeMode.system,
            onTap: () {
              themeNotifier.setSystemTheme();
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
      ],
    );
  }

  Widget _buildThemeOption({
    required BuildContext context,
    required String title,
    required String subtitle,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: isSelected
          ? const Icon(Icons.check, color: Colors.green)
          : null,
      onTap: onTap,
      selected: isSelected,
    );
  }
}

/// Mixin per widget che devono reagire ai cambiamenti di tema
mixin ThemeAware<T extends ConsumerStatefulWidget> on ConsumerState<T> {
  /// Ottiene il tema corrente
  ThemeData get currentTheme => ref.read(currentThemeProvider);

  /// Verifica se il tema corrente è dark
  bool get isDarkTheme => ref.read(isDarkThemeProvider);

  /// Ottiene il ColorScheme corrente
  ColorScheme get colorScheme => currentTheme.colorScheme;

  /// Ottiene il TextTheme corrente
  TextTheme get textTheme => currentTheme.textTheme;

  /// Ascolta i cambiamenti del tema
  void listenToThemeChanges() {
    ref.listen<AppThemeMode>(themeProvider, (previous, next) {
      onThemeChanged(previous, next);
    });
  }

  /// Callback chiamato quando il tema cambia
  void onThemeChanged(AppThemeMode? previous, AppThemeMode current) {
    // Override in implementazioni specifiche
  }
}

/// Extension per BuildContext per accesso rapido al tema
extension ThemeExtension on BuildContext {
  /// Ottiene il tema corrente dal context
  ThemeData get theme => Theme.of(this);

  /// Ottiene il ColorScheme corrente
  ColorScheme get colorScheme => theme.colorScheme;

  /// Ottiene il TextTheme corrente
  TextTheme get textTheme => theme.textTheme;

  /// Verifica se il tema corrente è dark
  bool get isDarkTheme => theme.brightness == Brightness.dark;

  /// Ottiene i colori primari
  Color get primaryColor => colorScheme.primary;
  Color get secondaryColor => colorScheme.secondary;
  Color get backgroundColor => colorScheme.background;
  Color get surfaceColor => colorScheme.surface;
  Color get errorColor => colorScheme.error;

  /// Ottiene i colori per il testo
  Color get onPrimaryColor => colorScheme.onPrimary;
  Color get onSecondaryColor => colorScheme.onSecondary;
  Color get onBackgroundColor => colorScheme.onBackground;
  Color get onSurfaceColor => colorScheme.onSurface;
  Color get onErrorColor => colorScheme.onError;
}

/// Provider per listener di sistema che aggiorna la luminosità
final platformBrightnessListenerProvider = Provider<void>((ref) {
  // Listener per i cambiamenti di luminosità del sistema
  WidgetsBinding.instance.platformDispatcher.onPlatformBrightnessChanged = () {
    final brightness =
        WidgetsBinding.instance.platformDispatcher.platformBrightness;
    ref.read(platformBrightnessProvider.notifier).state = brightness;
  };
});

/// Widget root che inizializza il listener per i cambiamenti di tema di sistema
class ThemeAwareApp extends ConsumerWidget {
  final Widget child;

  const ThemeAwareApp({super.key, required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Inizializza il listener per i cambiamenti di luminosità
    ref.watch(platformBrightnessListenerProvider);

    return child;
  }
}
