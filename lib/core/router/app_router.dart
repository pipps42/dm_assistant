// lib/core/router/app_router.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:dm_assistant/features/campaign/presentation/screens/campaign_list_screen.dart';
import 'package:dm_assistant/features/character/presentation/screens/character_list_screen.dart';
import 'package:dm_assistant/features/character/presentation/screens/character_detail_screen.dart';
import 'package:dm_assistant/features/character/providers/character_provider.dart';
import 'package:dm_assistant/shared/layouts/desktop_shell.dart';
import 'package:dm_assistant/shared/components/navigation/breadcrumb_widget.dart';

final appRouter = GoRouter(
  initialLocation: '/campaigns',
  routes: [
    ShellRoute(
      builder: (context, state, child) => child,
      routes: [
        GoRoute(
          path: '/campaigns',
          pageBuilder: (context, state) => NoTransitionPage(
            key: state.pageKey,
            child: DesktopShell(
              breadcrumbs: BreadcrumbBuilder.forSection('Campaigns'),
              child: const CampaignListScreen(),
            ),
          ),
        ),
        GoRoute(
          path: '/characters',
          pageBuilder: (context, state) => NoTransitionPage(
            key: state.pageKey,
            child: DesktopShell(
              breadcrumbs: BreadcrumbBuilder.forSection('Characters'),
              child: const CharacterListScreen(),
            ),
          ),
          routes: [
            GoRoute(
              path: '/:characterId',
              pageBuilder: (context, state) {
                final characterId = int.parse(state.pathParameters['characterId']!);
                return NoTransitionPage(
                  key: state.pageKey,
                  child: _CharacterDetailShell(characterId: characterId),
                );
              },
            ),
          ],
        ),
        GoRoute(
          path: '/sessions',
          pageBuilder: (context, state) => NoTransitionPage(
            key: state.pageKey,
            child: DesktopShell(
              breadcrumbs: BreadcrumbBuilder.forSection('Sessions'),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.event, size: 64, color: Colors.grey.shade400),
                    const SizedBox(height: 16),
                    Text(
                      'Sessions feature coming soon',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        GoRoute(
          path: '/maps',
          pageBuilder: (context, state) => NoTransitionPage(
            key: state.pageKey,
            child: DesktopShell(
              breadcrumbs: BreadcrumbBuilder.forSection('Maps'),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.map, size: 64, color: Colors.grey.shade400),
                    const SizedBox(height: 16),
                    Text(
                      'Maps feature coming soon',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        GoRoute(
          path: '/dice',
          pageBuilder: (context, state) => NoTransitionPage(
            key: state.pageKey,
            child: DesktopShell(
              breadcrumbs: BreadcrumbBuilder.forSection('Dice Roller'),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.casino, size: 64, color: Colors.grey.shade400),
                    const SizedBox(height: 16),
                    Text(
                      'Dice Roller coming soon',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        GoRoute(
          path: '/compendium',
          pageBuilder: (context, state) => NoTransitionPage(
            key: state.pageKey,
            child: DesktopShell(
              breadcrumbs: BreadcrumbBuilder.forSection('Compendium'),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.auto_stories,
                      size: 64,
                      color: Colors.grey.shade400,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Compendium coming soon',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        GoRoute(
          path: '/initiative',
          pageBuilder: (context, state) => NoTransitionPage(
            key: state.pageKey,
            child: DesktopShell(
              breadcrumbs: BreadcrumbBuilder.forSection('Initiative Tracker'),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.timeline, size: 64, color: Colors.grey.shade400),
                    const SizedBox(height: 16),
                    Text(
                      'Initiative Tracker coming soon',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        GoRoute(
          path: '/settings',
          pageBuilder: (context, state) => NoTransitionPage(
            key: state.pageKey,
            child: DesktopShell(
              breadcrumbs: BreadcrumbBuilder.forSection('Settings'),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.settings, size: 64, color: Colors.grey.shade400),
                    const SizedBox(height: 16),
                    Text(
                      'Settings coming soon',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    ),
  ],
);

// Widget wrapper to provide character name for breadcrumb
class _CharacterDetailShell extends ConsumerWidget {
  final int characterId;

  const _CharacterDetailShell({required this.characterId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final characterAsync = ref.watch(characterProvider(characterId));

    return characterAsync.when(
      data: (character) => DesktopShell(
        breadcrumbs: BreadcrumbBuilder.forEntityDetail(
          sectionName: 'Characters',
          sectionRoute: '/characters',
          entityName: character?.name ?? 'Unknown Character',
        ),
        child: CharacterDetailScreen(characterId: characterId),
      ),
      loading: () => DesktopShell(
        breadcrumbs: BreadcrumbBuilder.forEntityDetail(
          sectionName: 'Characters',
          sectionRoute: '/characters',
          entityName: 'Loading...',
        ),
        child: const Center(child: CircularProgressIndicator()),
      ),
      error: (error, stack) => DesktopShell(
        breadcrumbs: BreadcrumbBuilder.forEntityDetail(
          sectionName: 'Characters',
          sectionRoute: '/characters',
          entityName: 'Error',
        ),
        child: const Center(child: Text('Failed to load character')),
      ),
    );
  }
}
