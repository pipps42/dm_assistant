// lib/core/navigation/app_router.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:dm_assistant/shared/layouts/main_layout.dart';
import 'package:dm_assistant/shared/widgets/breadcrumb_bar.dart';
import 'package:dm_assistant/features/campaign/presentation/screens/campaign_list_screen.dart';

/// Route names per type safety
class AppRoutes {
  static const String home = '/';
  static const String campaigns = '/campaigns';
  static const String campaignDetails = '/campaigns/:id';
  static const String campaignEdit = '/campaigns/:id/edit';
  static const String campaignCreate = '/campaigns/create';
  static const String characters = '/characters';
  static const String characterDetails = '/characters/:id';
  static const String characterEdit = '/characters/:id/edit';
  static const String characterCreate = '/characters/create';
  static const String sessions = '/sessions';
  static const String sessionDetails = '/sessions/:id';
  static const String sessionEdit = '/sessions/:id/edit';
  static const String sessionCreate = '/sessions/create';
  static const String maps = '/maps';
  static const String mapDetails = '/maps/:id';
  static const String notes = '/notes';
  static const String noteDetails = '/notes/:id';
  static const String settings = '/settings';
}

/// Configurazione del router dell'applicazione
class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: AppRoutes.campaigns,
    debugLogDiagnostics: true,
    routes: [
      // Shell route che wrappa tutte le route principali con MainLayout
      ShellRoute(
        builder: (context, state, child) {
          return MainLayout(
            breadcrumbs: _getBreadcrumbsForRoute(state),
            child: child,
          );
        },
        routes: [
          // Home redirect
          GoRoute(
            path: AppRoutes.home,
            redirect: (context, state) => AppRoutes.campaigns,
          ),

          // CAMPAIGNS ROUTES
          GoRoute(
            path: AppRoutes.campaigns,
            name: 'campaigns',
            builder: (context, state) => const CampaignListScreen(),
            routes: [
              // Create campaign
              GoRoute(
                path: 'create',
                name: 'campaign-create',
                builder: (context, state) =>
                    const Placeholder(), // TODO: CreateCampaignScreen
              ),

              // Campaign details and sub-routes
              GoRoute(
                path: ':id',
                name: 'campaign-details',
                builder: (context, state) {
                  final id = state.pathParameters['id']!;
                  return Placeholder(); // TODO: CampaignDetailsScreen(id: id)
                },
                routes: [
                  GoRoute(
                    path: 'edit',
                    name: 'campaign-edit',
                    builder: (context, state) {
                      final id = state.pathParameters['id']!;
                      return Placeholder(); // TODO: EditCampaignScreen(id: id)
                    },
                  ),
                  GoRoute(
                    path: 'characters',
                    name: 'campaign-characters',
                    builder: (context, state) {
                      final id = state.pathParameters['id']!;
                      return Placeholder(); // TODO: CampaignCharactersScreen(id: id)
                    },
                  ),
                  GoRoute(
                    path: 'sessions',
                    name: 'campaign-sessions',
                    builder: (context, state) {
                      final id = state.pathParameters['id']!;
                      return Placeholder(); // TODO: CampaignSessionsScreen(id: id)
                    },
                  ),
                ],
              ),
            ],
          ),

          // CHARACTERS ROUTES
          GoRoute(
            path: AppRoutes.characters,
            name: 'characters',
            builder: (context, state) =>
                const Placeholder(), // TODO: CharacterListScreen
            routes: [
              GoRoute(
                path: 'create',
                name: 'character-create',
                builder: (context, state) =>
                    const Placeholder(), // TODO: CreateCharacterScreen
              ),
              GoRoute(
                path: ':id',
                name: 'character-details',
                builder: (context, state) {
                  final id = state.pathParameters['id']!;
                  return Placeholder(); // TODO: CharacterDetailsScreen(id: id)
                },
                routes: [
                  GoRoute(
                    path: 'edit',
                    name: 'character-edit',
                    builder: (context, state) {
                      final id = state.pathParameters['id']!;
                      return Placeholder(); // TODO: EditCharacterScreen(id: id)
                    },
                  ),
                ],
              ),
            ],
          ),

          // SESSIONS ROUTES
          GoRoute(
            path: AppRoutes.sessions,
            name: 'sessions',
            builder: (context, state) =>
                const Placeholder(), // TODO: SessionListScreen
            routes: [
              GoRoute(
                path: 'create',
                name: 'session-create',
                builder: (context, state) =>
                    const Placeholder(), // TODO: CreateSessionScreen
              ),
              GoRoute(
                path: ':id',
                name: 'session-details',
                builder: (context, state) {
                  final id = state.pathParameters['id']!;
                  return Placeholder(); // TODO: SessionDetailsScreen(id: id)
                },
                routes: [
                  GoRoute(
                    path: 'edit',
                    name: 'session-edit',
                    builder: (context, state) {
                      final id = state.pathParameters['id']!;
                      return Placeholder(); // TODO: EditSessionScreen(id: id)
                    },
                  ),
                  GoRoute(
                    path: 'play',
                    name: 'session-play',
                    builder: (context, state) {
                      final id = state.pathParameters['id']!;
                      return Placeholder(); // TODO: PlaySessionScreen(id: id)
                    },
                  ),
                ],
              ),
            ],
          ),

          // MAPS ROUTES
          GoRoute(
            path: AppRoutes.maps,
            name: 'maps',
            builder: (context, state) =>
                const Placeholder(), // TODO: MapListScreen
            routes: [
              GoRoute(
                path: ':id',
                name: 'map-details',
                builder: (context, state) {
                  final id = state.pathParameters['id']!;
                  return Placeholder(); // TODO: MapDetailsScreen(id: id)
                },
              ),
            ],
          ),

          // NOTES ROUTES
          GoRoute(
            path: AppRoutes.notes,
            name: 'notes',
            builder: (context, state) =>
                const Placeholder(), // TODO: NotesScreen
            routes: [
              GoRoute(
                path: ':id',
                name: 'note-details',
                builder: (context, state) {
                  final id = state.pathParameters['id']!;
                  return Placeholder(); // TODO: NoteDetailsScreen(id: id)
                },
              ),
            ],
          ),

          // SETTINGS ROUTES
          GoRoute(
            path: AppRoutes.settings,
            name: 'settings',
            builder: (context, state) =>
                const Placeholder(), // TODO: SettingsScreen
          ),
        ],
      ),
    ],

    // Error handling
    errorBuilder: (context, state) => MainLayout(
      child: Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.grey),
              const SizedBox(height: 16),
              Text(
                'Page not found',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 8),
              Text(
                'The page you are looking for does not exist.',
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(color: Colors.grey),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => context.go(AppRoutes.campaigns),
                child: const Text('Go to Campaigns'),
              ),
            ],
          ),
        ),
      ),
    ),
  );

  /// Genera breadcrumb basati sulla route corrente
  static List<BreadcrumbItem> _getBreadcrumbsForRoute(GoRouterState state) {
    final location = state.matchedLocation;
    final pathSegments = location
        .split('/')
        .where((s) => s.isNotEmpty)
        .toList();

    if (pathSegments.isEmpty) {
      return [BreadcrumbItem.home()];
    }

    final breadcrumbs = <BreadcrumbItem>[BreadcrumbItem.home()];

    // CAMPAIGNS
    if (pathSegments[0] == 'campaigns') {
      breadcrumbs.add(
        const BreadcrumbItem(
          label: 'Campaigns',
          route: '/campaigns',
          icon: Icons.campaign,
        ),
      );

      if (pathSegments.length > 1) {
        final campaignId = pathSegments[1];

        if (campaignId == 'create') {
          breadcrumbs.add(
            BreadcrumbItem.current('Create Campaign', icon: Icons.add),
          );
        } else {
          // Campaign details
          breadcrumbs.add(
            BreadcrumbItem(
              label: 'Campaign Details', // TODO: Get actual campaign name
              route: '/campaigns/$campaignId',
              icon: Icons.folder,
            ),
          );

          // Sub-sections
          if (pathSegments.length > 2) {
            final section = pathSegments[2];
            String sectionLabel;
            IconData? sectionIcon;

            switch (section) {
              case 'edit':
                sectionLabel = 'Edit';
                sectionIcon = Icons.edit;
                break;
              case 'characters':
                sectionLabel = 'Characters';
                sectionIcon = Icons.people;
                break;
              case 'sessions':
                sectionLabel = 'Sessions';
                sectionIcon = Icons.event;
                break;
              default:
                sectionLabel =
                    section.substring(0, 1).toUpperCase() +
                    section.substring(1);
                sectionIcon = Icons.folder;
            }

            breadcrumbs.add(
              BreadcrumbItem.current(sectionLabel, icon: sectionIcon),
            );
          }
        }
      }
    }
    // CHARACTERS
    else if (pathSegments[0] == 'characters') {
      breadcrumbs.add(
        const BreadcrumbItem(
          label: 'Characters',
          route: '/characters',
          icon: Icons.people,
        ),
      );

      if (pathSegments.length > 1) {
        final characterId = pathSegments[1];

        if (characterId == 'create') {
          breadcrumbs.add(
            BreadcrumbItem.current('Create Character', icon: Icons.add),
          );
        } else {
          breadcrumbs.add(
            BreadcrumbItem(
              label: 'Character Details', // TODO: Get actual character name
              route: '/characters/$characterId',
              icon: Icons.person,
            ),
          );

          if (pathSegments.length > 2 && pathSegments[2] == 'edit') {
            breadcrumbs.add(BreadcrumbItem.current('Edit', icon: Icons.edit));
          }
        }
      }
    }
    // SESSIONS
    else if (pathSegments[0] == 'sessions') {
      breadcrumbs.add(
        const BreadcrumbItem(
          label: 'Sessions',
          route: '/sessions',
          icon: Icons.event,
        ),
      );

      if (pathSegments.length > 1) {
        final sessionId = pathSegments[1];

        if (sessionId == 'create') {
          breadcrumbs.add(
            BreadcrumbItem.current('Create Session', icon: Icons.add),
          );
        } else {
          breadcrumbs.add(
            BreadcrumbItem(
              label: 'Session Details', // TODO: Get actual session name
              route: '/sessions/$sessionId',
              icon: Icons.event_note,
            ),
          );

          if (pathSegments.length > 2) {
            final section = pathSegments[2];
            String sectionLabel;
            IconData? sectionIcon;

            switch (section) {
              case 'edit':
                sectionLabel = 'Edit';
                sectionIcon = Icons.edit;
                break;
              case 'play':
                sectionLabel = 'Play';
                sectionIcon = Icons.play_arrow;
                break;
              default:
                sectionLabel =
                    section.substring(0, 1).toUpperCase() +
                    section.substring(1);
                sectionIcon = Icons.folder;
            }

            breadcrumbs.add(
              BreadcrumbItem.current(sectionLabel, icon: sectionIcon),
            );
          }
        }
      }
    }
    // OTHER ROUTES
    else {
      final section = pathSegments[0];
      String sectionLabel;
      IconData? sectionIcon;

      switch (section) {
        case 'maps':
          sectionLabel = 'Maps';
          sectionIcon = Icons.map;
          break;
        case 'notes':
          sectionLabel = 'Notes';
          sectionIcon = Icons.note;
          break;
        case 'settings':
          sectionLabel = 'Settings';
          sectionIcon = Icons.settings;
          break;
        default:
          sectionLabel =
              section.substring(0, 1).toUpperCase() + section.substring(1);
          sectionIcon = Icons.folder;
      }

      breadcrumbs.add(BreadcrumbItem.current(sectionLabel, icon: sectionIcon));
    }

    return breadcrumbs;
  }
}

/// Extension per facilitare la navigazione
extension GoRouterExtension on GoRouter {
  /// Naviga alla lista campaigns
  void goToCampaigns() => go(AppRoutes.campaigns);

  /// Naviga ai dettagli di una campaign
  void goToCampaignDetails(String id) => go('/campaigns/$id');

  /// Naviga alla modifica di una campaign
  void goToCampaignEdit(String id) => go('/campaigns/$id/edit');

  /// Naviga alla creazione di una campaign
  void goToCampaignCreate() => go('/campaigns/create');

  /// Naviga alla lista characters
  void goToCharacters() => go(AppRoutes.characters);

  /// Naviga ai dettagli di un character
  void goToCharacterDetails(String id) => go('/characters/$id');

  /// Naviga alla lista sessions
  void goToSessions() => go(AppRoutes.sessions);

  /// Naviga ai dettagli di una session
  void goToSessionDetails(String id) => go('/sessions/$id');

  /// Naviga alle impostazioni
  void goToSettings() => go(AppRoutes.settings);
}

/// Extension per BuildContext
extension ContextGoRouterExtension on BuildContext {
  /// Riferimento al router corrente
  GoRouter get router => GoRouter.of(this);

  /// Naviga alla lista campaigns
  void goToCampaigns() => go(AppRoutes.campaigns);

  /// Naviga ai dettagli di una campaign
  void goToCampaignDetails(String id) => go('/campaigns/$id');

  /// Naviga alla modifica di una campaign
  void goToCampaignEdit(String id) => go('/campaigns/$id/edit');

  /// Naviga alla creazione di una campaign
  void goToCampaignCreate() => go('/campaigns/create');
}
