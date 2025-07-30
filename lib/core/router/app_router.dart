// lib/core/router/app_router.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:dm_assistant/features/campaign/presentation/screens/campaign_list_screen.dart';
import 'package:dm_assistant/shared/layouts/desktop_shell.dart';

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
              title: 'Campaigns',
              child: const CampaignListScreen(),
              floatingActionButton: FloatingActionButton.extended(
                onPressed: () {
                  // This will be handled by the screen
                },
                icon: const Icon(Icons.add),
                label: const Text('New Campaign'),
              ),
            ),
          ),
        ),
        GoRoute(
          path: '/characters',
          pageBuilder: (context, state) => NoTransitionPage(
            key: state.pageKey,
            child: DesktopShell(
              title: 'Characters',
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.people, size: 64, color: Colors.grey.shade400),
                    const SizedBox(height: 16),
                    Text(
                      'Characters feature coming soon',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        GoRoute(
          path: '/sessions',
          pageBuilder: (context, state) => NoTransitionPage(
            key: state.pageKey,
            child: DesktopShell(
              title: 'Sessions',
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
              title: 'Maps',
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
              title: 'Dice Roller',
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
              title: 'Compendium',
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
              title: 'Initiative Tracker',
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
              title: 'Settings',
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
