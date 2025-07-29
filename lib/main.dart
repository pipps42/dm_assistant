// lib/main.dart (versione completa aggiornata)
import 'package:dm_assistant/core/constants/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import 'package:dm_assistant/core/theme/theme_provider.dart';
import 'package:dm_assistant/core/navigation/app_router.dart';
import 'package:dm_assistant/features/campaign/models/campaign.dart';
import 'package:dm_assistant/features/campaign/providers/campaign_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Isar database
  final dir = await getApplicationDocumentsDirectory();
  final isar = await Isar.open([CampaignSchema], directory: dir.path);

  runApp(
    ProviderScope(
      overrides: [
        // Database provider override
        isarProvider.overrideWithValue(isar),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch theme providers
    final lightTheme = ref.watch(lightThemeProvider);
    final darkTheme = ref.watch(darkThemeProvider);
    final themeMode = ref.watch(flutterThemeModeProvider);

    return ThemeAwareApp(
      child: MaterialApp.router(
        title: 'DM Assistant',
        debugShowCheckedModeBanner: false,

        // Theme configuration
        theme: lightTheme,
        darkTheme: darkTheme,
        themeMode: themeMode,

        // Router configuration
        routerConfig: AppRouter.router,

        // App configuration
        builder: (context, child) {
          return MediaQuery(
            // Ensure text scale factor doesn't get too large
            data: MediaQuery.of(context).copyWith(
              textScaleFactor: MediaQuery.of(
                context,
              ).textScaleFactor.clamp(0.8, 1.2),
            ),
            child: child ?? const SizedBox.shrink(),
          );
        },

        // Localization (future implementation)
        // locale: const Locale('en', 'US'),
        // localizationsDelegates: const [
        //   GlobalMaterialLocalizations.delegate,
        //   GlobalWidgetsLocalizations.delegate,
        //   GlobalCupertinoLocalizations.delegate,
        // ],
        // supportedLocales: const [
        //   Locale('en', 'US'),
        //   Locale('it', 'IT'),
        // ],
      ),
    );
  }
}

/// Provider per informazioni sull'app
final appInfoProvider = Provider<AppInfo>((ref) {
  return const AppInfo(
    name: 'DM Assistant',
    version: '1.0.0',
    description: 'Your campaigns, perfectly managed',
  );
});

/// Modello per informazioni dell'app
class AppInfo {
  final String name;
  final String version;
  final String description;

  const AppInfo({
    required this.name,
    required this.version,
    required this.description,
  });
}

/// Provider per lo stato di inizializzazione dell'app
final appInitializationProvider = FutureProvider<bool>((ref) async {
  // Qui possiamo aggiungere logica di inizializzazione asincrona
  // come caricamento preferenze, autenticazione, ecc.

  // Simula un caricamento iniziale
  await Future.delayed(const Duration(milliseconds: 500));

  return true;
});

/// Widget wrapper per gestire lo stato di caricamento iniziale dell'app
class AppInitializer extends ConsumerWidget {
  final Widget child;

  const AppInitializer({super.key, required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final initialization = ref.watch(appInitializationProvider);

    return initialization.when(
      loading: () => const MaterialApp(
        home: AppLoadingScreen(),
        debugShowCheckedModeBanner: false,
      ),
      error: (error, stack) => MaterialApp(
        home: AppErrorScreen(error: error.toString()),
        debugShowCheckedModeBanner: false,
      ),
      data: (_) => child,
    );
  }
}

/// Schermata di caricamento iniziale
class AppLoadingScreen extends StatelessWidget {
  const AppLoadingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo dell'app
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(Icons.shield, size: 80, color: Colors.white),
            ),
            const SizedBox(height: 32),

            // Nome dell'app
            const Text(
              'DM Assistant',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),

            // Tagline
            const Text(
              'Your campaigns, perfectly managed',
              style: TextStyle(fontSize: 16, color: Colors.white70),
            ),
            const SizedBox(height: 48),

            // Loading indicator
            const SizedBox(
              width: 40,
              height: 40,
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                strokeWidth: 3,
              ),
            ),
            const SizedBox(height: 16),

            const Text(
              'Loading...',
              style: TextStyle(fontSize: 14, color: Colors.white70),
            ),
          ],
        ),
      ),
    );
  }
}

/// Schermata di errore iniziale
class AppErrorScreen extends StatelessWidget {
  final String error;

  const AppErrorScreen({super.key, required this.error});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.red.shade50,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Error icon
              Icon(Icons.error_outline, size: 80, color: AppColors.error),
              const SizedBox(height: 24),

              // Error title
              Text(
                'App Initialization Failed',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColors.error,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),

              // Error message
              Text(
                error,
                style: TextStyle(fontSize: 16, color: AppColors.error),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),

              // Retry button
              ElevatedButton.icon(
                onPressed: () {
                  // Restart the app
                  // In a real app, you might want to implement app restart logic
                },
                icon: const Icon(Icons.refresh),
                label: const Text('Retry'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.error,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
