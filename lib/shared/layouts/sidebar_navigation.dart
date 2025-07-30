// lib/shared/layouts/sidebar_navigation.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:dm_assistant/core/constants/app_colors.dart';
import 'package:dm_assistant/core/constants/dimens.dart';
import 'package:dm_assistant/core/constants/strings.dart';

// Provider for current navigation index
final navigationIndexProvider = StateProvider<int>((ref) => 0);

class SidebarNavigation extends ConsumerWidget {
  const SidebarNavigation({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedIndex = ref.watch(navigationIndexProvider);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      width: 280,
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurfaceVariant : AppColors.neutral50,
        border: Border(
          right: BorderSide(color: theme.dividerColor.withOpacity(0.1)),
        ),
      ),
      child: Column(
        children: [
          // App Header
          Container(
            height: 64,
            padding: const EdgeInsets.symmetric(horizontal: AppDimens.spacingL),
            child: Row(
              children: [
                Icon(Icons.shield, size: 32, color: theme.colorScheme.primary),
                const SizedBox(width: AppDimens.spacingM),
                Text(
                  AppStrings.appName,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),

          const Divider(height: 1),

          // Navigation Items
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: AppDimens.spacingM),
              children: [
                _NavigationSection(
                  title: 'MAIN',
                  items: [
                    NavigationItem(
                      icon: Icons.campaign,
                      label: AppStrings.campaigns,
                      route: '/campaigns',
                      index: 0,
                    ),
                    NavigationItem(
                      icon: Icons.people,
                      label: AppStrings.characters,
                      route: '/characters',
                      index: 1,
                    ),
                    NavigationItem(
                      icon: Icons.event,
                      label: 'Sessions',
                      route: '/sessions',
                      index: 2,
                    ),
                    NavigationItem(
                      icon: Icons.map,
                      label: 'Maps',
                      route: '/maps',
                      index: 3,
                    ),
                  ],
                ),

                const SizedBox(height: AppDimens.spacingL),

                _NavigationSection(
                  title: 'TOOLS',
                  items: [
                    NavigationItem(
                      icon: Icons.casino,
                      label: 'Dice Roller',
                      route: '/dice',
                      index: 4,
                    ),
                    NavigationItem(
                      icon: Icons.auto_stories,
                      label: 'Compendium',
                      route: '/compendium',
                      index: 5,
                    ),
                    NavigationItem(
                      icon: Icons.timeline,
                      label: 'Initiative Tracker',
                      route: '/initiative',
                      index: 6,
                    ),
                  ],
                ),
              ],
            ),
          ),

          const Divider(height: 1),

          // Bottom section
          Padding(
            padding: const EdgeInsets.all(AppDimens.spacingM),
            child: Column(
              children: [
                _NavigationTile(
                  icon: Icons.settings,
                  label: 'Settings',
                  route: '/settings',
                  index: 99,
                  selected: selectedIndex == 99,
                  onTap: () {
                    ref.read(navigationIndexProvider.notifier).state = 99;
                    context.go('/settings');
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _NavigationSection extends StatelessWidget {
  final String title;
  final List<NavigationItem> items;

  const _NavigationSection({required this.title, required this.items});

  @override
  Widget build(BuildContext context) {
    final selectedIndex = ProviderScope.containerOf(
      context,
      listen: false,
    ).read(navigationIndexProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(
            AppDimens.spacingL,
            AppDimens.spacingS,
            AppDimens.spacingL,
            AppDimens.spacingS,
          ),
          child: Text(
            title,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
            ),
          ),
        ),
        ...items.map(
          (item) => Consumer(
            builder: (context, ref, _) {
              final selected = ref.watch(navigationIndexProvider) == item.index;
              return _NavigationTile(
                icon: item.icon,
                label: item.label,
                route: item.route,
                index: item.index,
                selected: selected,
                onTap: () {
                  ref.read(navigationIndexProvider.notifier).state = item.index;
                  GoRouter.of(context).go(item.route);
                },
              );
            },
          ),
        ),
      ],
    );
  }
}

class _NavigationTile extends ConsumerWidget {
  final IconData icon;
  final String label;
  final String route;
  final int index;
  final bool selected;
  final VoidCallback onTap;

  const _NavigationTile({
    required this.icon,
    required this.label,
    required this.route,
    required this.index,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: AppDimens.spacingM,
        vertical: 2,
      ),
      child: Material(
        color: selected
            ? theme.colorScheme.primary.withOpacity(0.1)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(AppDimens.radiusM),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppDimens.radiusM),
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppDimens.spacingM,
              vertical: AppDimens.spacingS + 4,
            ),
            child: Row(
              children: [
                Icon(
                  icon,
                  size: 20,
                  color: selected
                      ? theme.colorScheme.primary
                      : theme.colorScheme.onSurface.withOpacity(0.7),
                ),
                const SizedBox(width: AppDimens.spacingM),
                Expanded(
                  child: Text(
                    label,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: selected
                          ? theme.colorScheme.primary
                          : theme.colorScheme.onSurface.withOpacity(0.8),
                      fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class NavigationItem {
  final IconData icon;
  final String label;
  final String route;
  final int index;

  const NavigationItem({
    required this.icon,
    required this.label,
    required this.route,
    required this.index,
  });
}
