// lib/shared/layouts/main_layout.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:dm_assistant/core/responsive/responsive_builder.dart';
import 'package:dm_assistant/core/constants/app_colors.dart';
import 'package:dm_assistant/core/constants/dimens.dart';
import 'package:dm_assistant/shared/widgets/app_sidebar.dart';
import 'package:dm_assistant/shared/widgets/breadcrumb_bar.dart';

/// Provider per l'indice corrente della bottom navigation
final bottomNavigationIndexProvider = StateProvider<int>((ref) => 0);

/// Layout principale dell'applicazione che si adatta a desktop e mobile
class MainLayout extends ConsumerWidget {
  final Widget child;
  final List<BreadcrumbItem>? breadcrumbs;
  final bool showBreadcrumb;
  final FloatingActionButton? floatingActionButton;
  final Widget? bottomSheet;

  const MainLayout({
    super.key,
    required this.child,
    this.breadcrumbs,
    this.showBreadcrumb = true,
    this.floatingActionButton,
    this.bottomSheet,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ResponsiveBuilder(
      mobile: _buildMobileLayout(context, ref),
      desktop: _buildDesktopLayout(context, ref),
    );
  }

  Widget _buildMobileLayout(BuildContext context, WidgetRef ref) {
    final currentIndex = ref.watch(bottomNavigationIndexProvider);

    return Scaffold(
      appBar: _buildMobileAppBar(context),
      drawer: _buildMobileDrawer(context),
      body: child,
      bottomNavigationBar: _buildBottomNavigationBar(
        context,
        ref,
        currentIndex,
      ),
      floatingActionButton: floatingActionButton,
      bottomSheet: bottomSheet,
    );
  }

  Widget _buildDesktopLayout(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: Row(
        children: [
          // Sidebar
          AppSidebar(
            items: DefaultSidebarItems.items,
            onItemTap: () {
              // Chiudi eventuali drawer aperti
              if (Scaffold.of(context).hasDrawer &&
                  Scaffold.of(context).isDrawerOpen) {
                Navigator.of(context).pop();
              }
            },
          ),

          // Contenuto principale
          Expanded(
            child: Column(
              children: [
                // Breadcrumb (solo desktop)
                if (showBreadcrumb && breadcrumbs != null)
                  BreadcrumbBar(items: breadcrumbs!),

                // Contenuto
                Expanded(
                  child: Container(
                    color: Theme.of(context).colorScheme.background,
                    child: child,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: floatingActionButton,
      bottomSheet: bottomSheet,
    );
  }

  PreferredSizeWidget _buildMobileAppBar(BuildContext context) {
    final title = _getTitleFromRoute(context);

    return AppBar(
      title: Row(
        children: [
          Icon(
            _getIconFromRoute(context),
            color: AppColors.primary,
            size: AppDimens.iconM,
          ),
          const SizedBox(width: AppDimens.spacingS),
          Text(title),
        ],
      ),
      backgroundColor: Theme.of(context).colorScheme.surface,
      elevation: 1,
      shadowColor: Colors.black.withOpacity(0.1),
      actions: [
        // Search button
        IconButton(
          icon: const Icon(Icons.search),
          onPressed: () {
            // TODO: Implementare ricerca globale
          },
        ),

        // Notification button
        IconButton(
          icon: Stack(
            children: [
              const Icon(Icons.notifications_outlined),
              Positioned(
                right: 0,
                top: 0,
                child: Container(
                  padding: const EdgeInsets.all(2),
                  decoration: const BoxDecoration(
                    color: AppColors.error,
                    shape: BoxShape.circle,
                  ),
                  constraints: const BoxConstraints(minWidth: 8, minHeight: 8),
                ),
              ),
            ],
          ),
          onPressed: () {
            // TODO: Implementare notifiche
          },
        ),

        // More options
        PopupMenuButton<String>(
          icon: const Icon(Icons.more_vert),
          onSelected: (value) {
            switch (value) {
              case 'settings':
                context.go('/settings');
                break;
              case 'help':
                // TODO: Implementare help
                break;
              case 'about':
                // TODO: Implementare about
                break;
            }
          },
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'settings',
              child: ListTile(
                leading: Icon(Icons.settings),
                title: Text('Settings'),
              ),
            ),
            const PopupMenuItem(
              value: 'help',
              child: ListTile(leading: Icon(Icons.help), title: Text('Help')),
            ),
            const PopupMenuItem(
              value: 'about',
              child: ListTile(leading: Icon(Icons.info), title: Text('About')),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMobileDrawer(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          // Header del drawer
          Container(
            padding: const EdgeInsets.fromLTRB(
              AppDimens.spacingL,
              AppDimens.spacingXL,
              AppDimens.spacingL,
              AppDimens.spacingL,
            ),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [AppColors.primary, AppColors.primary.withOpacity(0.8)],
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(AppDimens.spacingM),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(AppDimens.radiusM),
                  ),
                  child: const Icon(
                    Icons.shield,
                    color: Colors.white,
                    size: AppDimens.iconXL,
                  ),
                ),
                const SizedBox(height: AppDimens.spacingM),
                const Text(
                  'DM Assistant',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Text(
                  'Your campaigns, perfectly managed',
                  style: TextStyle(color: Colors.white70, fontSize: 14),
                ),
              ],
            ),
          ),

          // Lista menu
          Expanded(
            child: AppSidebar(
              items: DefaultSidebarItems.items,
              showToggle: false,
              onItemTap: () {
                // Chiudi il drawer dopo la navigazione
                Navigator.of(context).pop();
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNavigationBar(
    BuildContext context,
    WidgetRef ref,
    int currentIndex,
  ) {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      currentIndex: currentIndex,
      selectedItemColor: AppColors.primary,
      unselectedItemColor: AppColors.neutral500,
      backgroundColor: Theme.of(context).colorScheme.surface,
      elevation: 8,
      onTap: (index) {
        ref.read(bottomNavigationIndexProvider.notifier).state = index;

        // Navigazione basata sull'indice
        switch (index) {
          case 0:
            context.go('/campaigns');
            break;
          case 1:
            context.go('/characters');
            break;
          case 2:
            context.go('/sessions');
            break;
          case 3:
            context.go('/settings');
            break;
        }
      },
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.campaign),
          activeIcon: Icon(Icons.campaign),
          label: 'Campaigns',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.people_outline),
          activeIcon: Icon(Icons.people),
          label: 'Characters',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.event_outlined),
          activeIcon: Icon(Icons.event),
          label: 'Sessions',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.settings_outlined),
          activeIcon: Icon(Icons.settings),
          label: 'Settings',
        ),
      ],
    );
  }

  String _getTitleFromRoute(BuildContext context) {
    final location = GoRouterState.of(context).matchedLocation;

    switch (location) {
      case '/campaigns':
        return 'Campaigns';
      case '/characters':
        return 'Characters';
      case '/sessions':
        return 'Sessions';
      case '/maps':
        return 'Maps';
      case '/notes':
        return 'Notes';
      case '/settings':
        return 'Settings';
      default:
        if (location.startsWith('/campaigns/')) {
          return 'Campaign Details';
        } else if (location.startsWith('/characters/')) {
          return 'Character Details';
        } else if (location.startsWith('/sessions/')) {
          return 'Session Details';
        }
        return 'DM Assistant';
    }
  }

  IconData _getIconFromRoute(BuildContext context) {
    final location = GoRouterState.of(context).matchedLocation;

    switch (location) {
      case '/campaigns':
        return Icons.campaign;
      case '/characters':
        return Icons.people;
      case '/sessions':
        return Icons.event;
      case '/maps':
        return Icons.map;
      case '/notes':
        return Icons.note;
      case '/settings':
        return Icons.settings;
      default:
        if (location.startsWith('/campaigns/')) {
          return Icons.campaign;
        } else if (location.startsWith('/characters/')) {
          return Icons.people;
        } else if (location.startsWith('/sessions/')) {
          return Icons.event;
        }
        return Icons.shield;
    }
  }
}

/// Widget wrapper per schermate che necessitano del layout principale
class LayoutWrapper extends StatelessWidget {
  final Widget child;
  final List<BreadcrumbItem>? breadcrumbs;
  final bool showBreadcrumb;
  final FloatingActionButton? floatingActionButton;

  const LayoutWrapper({
    super.key,
    required this.child,
    this.breadcrumbs,
    this.showBreadcrumb = true,
    this.floatingActionButton,
  });

  @override
  Widget build(BuildContext context) {
    return MainLayout(
      breadcrumbs: breadcrumbs,
      showBreadcrumb: showBreadcrumb,
      floatingActionButton: floatingActionButton,
      child: child,
    );
  }
}

/// Extension per facilitare la creazione di layout con breadcrumb
extension LayoutExtensions on Widget {
  Widget withLayout({
    List<BreadcrumbItem>? breadcrumbs,
    bool showBreadcrumb = true,
    FloatingActionButton? floatingActionButton,
  }) {
    return LayoutWrapper(
      breadcrumbs: breadcrumbs,
      showBreadcrumb: showBreadcrumb,
      floatingActionButton: floatingActionButton,
      child: this,
    );
  }
}
