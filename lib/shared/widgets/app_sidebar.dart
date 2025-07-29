// lib/shared/widgets/app_sidebar.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:dm_assistant/core/constants/app_colors.dart';
import 'package:dm_assistant/core/constants/dimens.dart';
import 'package:dm_assistant/core/constants/strings.dart';

/// Provider per lo stato collapsed della sidebar
final sidebarCollapsedProvider = StateProvider<bool>((ref) => false);

/// Modello per un item della sidebar
class SidebarItem {
  final String label;
  final IconData icon;
  final String route;
  final List<SidebarItem>? children;
  final bool isExpanded;
  final String? badge;

  const SidebarItem({
    required this.label,
    required this.icon,
    required this.route,
    this.children,
    this.isExpanded = false,
    this.badge,
  });

  SidebarItem copyWith({
    String? label,
    IconData? icon,
    String? route,
    List<SidebarItem>? children,
    bool? isExpanded,
    String? badge,
  }) {
    return SidebarItem(
      label: label ?? this.label,
      icon: icon ?? this.icon,
      route: route ?? this.route,
      children: children ?? this.children,
      isExpanded: isExpanded ?? this.isExpanded,
      badge: badge ?? this.badge,
    );
  }
}

/// Sidebar principale dell'applicazione
class AppSidebar extends ConsumerWidget {
  final List<SidebarItem> items;
  final bool showToggle;
  final VoidCallback? onItemTap;

  const AppSidebar({
    super.key,
    required this.items,
    this.showToggle = true,
    this.onItemTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isCollapsed = ref.watch(sidebarCollapsedProvider);
    final currentLocation = GoRouterState.of(context).matchedLocation;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: isCollapsed ? 70 : 260,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(
          right: BorderSide(color: Theme.of(context).dividerColor, width: 1),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            offset: const Offset(2, 0),
            blurRadius: 8,
          ),
        ],
      ),
      child: Column(
        children: [
          _buildHeader(context, isCollapsed),
          Expanded(
            child: _buildItemsList(context, currentLocation, isCollapsed),
          ),
          if (showToggle) _buildToggleButton(context, ref, isCollapsed),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, bool isCollapsed) {
    return Container(
      padding: EdgeInsets.all(
        isCollapsed ? AppDimens.spacingM : AppDimens.spacingL,
      ),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Theme.of(context).dividerColor, width: 1),
        ),
      ),
      child: Row(
        mainAxisAlignment: isCollapsed
            ? MainAxisAlignment.center
            : MainAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(AppDimens.spacingS),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(AppDimens.radiusS),
            ),
            child: Icon(
              Icons.shield,
              color: AppColors.primary,
              size: isCollapsed ? AppDimens.iconM : AppDimens.iconL,
            ),
          ),
          if (!isCollapsed) ...[
            const SizedBox(width: AppDimens.spacingM),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppStrings.appName,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                  Text(
                    AppStrings.appTagline,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.neutral500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildItemsList(
    BuildContext context,
    String currentLocation,
    bool isCollapsed,
  ) {
    return ListView.separated(
      padding: EdgeInsets.all(
        isCollapsed ? AppDimens.spacingS : AppDimens.spacingM,
      ),
      itemCount: items.length,
      separatorBuilder: (context, index) =>
          const SizedBox(height: AppDimens.spacingXS),
      itemBuilder: (context, index) {
        return _buildSidebarItem(
          context,
          items[index],
          currentLocation,
          isCollapsed,
        );
      },
    );
  }

  Widget _buildSidebarItem(
    BuildContext context,
    SidebarItem item,
    String currentLocation,
    bool isCollapsed,
  ) {
    final isActive = _isRouteActive(currentLocation, item.route);
    final hasChildren = item.children?.isNotEmpty == true;

    return Column(
      children: [
        // Item principale
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => _handleItemTap(context, item),
            borderRadius: BorderRadius.circular(AppDimens.radiusM),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              padding: EdgeInsets.symmetric(
                horizontal: isCollapsed
                    ? AppDimens.spacingS
                    : AppDimens.spacingM,
                vertical: AppDimens.spacingM,
              ),
              decoration: BoxDecoration(
                color: isActive
                    ? AppColors.primary.withOpacity(0.1)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(AppDimens.radiusM),
                border: isActive
                    ? Border.all(
                        color: AppColors.primary.withOpacity(0.2),
                        width: 1,
                      )
                    : null,
              ),
              child: Row(
                children: [
                  // Icona
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    padding: const EdgeInsets.all(AppDimens.spacingXS),
                    decoration: BoxDecoration(
                      color: isActive
                          ? AppColors.primary.withOpacity(0.1)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(AppDimens.radiusS),
                    ),
                    child: Icon(
                      item.icon,
                      color: isActive
                          ? AppColors.primary
                          : Theme.of(context).iconTheme.color,
                      size: AppDimens.iconM,
                    ),
                  ),

                  if (!isCollapsed) ...[
                    const SizedBox(width: AppDimens.spacingM),

                    // Label
                    Expanded(
                      child: Text(
                        item.label,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: isActive
                              ? AppColors.primary
                              : Theme.of(context).textTheme.bodyMedium?.color,
                          fontWeight: isActive
                              ? FontWeight.w600
                              : FontWeight.w400,
                        ),
                      ),
                    ),

                    // Badge (se presente)
                    if (item.badge != null) ...[
                      const SizedBox(width: AppDimens.spacingS),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppDimens.spacingS,
                          vertical: AppDimens.spacingXS,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(
                            AppDimens.radiusXL,
                          ),
                        ),
                        child: Text(
                          item.badge!,
                          style: Theme.of(context).textTheme.labelSmall
                              ?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                      ),
                    ],

                    // Freccia per submenu
                    if (hasChildren) ...[
                      const SizedBox(width: AppDimens.spacingS),
                      AnimatedRotation(
                        turns: item.isExpanded ? 0.5 : 0,
                        duration: const Duration(milliseconds: 200),
                        child: Icon(
                          Icons.keyboard_arrow_down,
                          size: AppDimens.iconS,
                          color: Theme.of(
                            context,
                          ).iconTheme.color?.withOpacity(0.7),
                        ),
                      ),
                    ],
                  ],
                ],
              ),
            ),
          ),
        ),

        // Submenu (se presente e non collapsed)
        if (hasChildren && !isCollapsed)
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            height: item.isExpanded ? null : 0,
            child: item.isExpanded
                ? Padding(
                    padding: const EdgeInsets.only(
                      left: AppDimens.spacingXL,
                      top: AppDimens.spacingS,
                    ),
                    child: Column(
                      children: item.children!
                          .map(
                            (child) => _buildSubMenuItem(
                              context,
                              child,
                              currentLocation,
                            ),
                          )
                          .toList(),
                    ),
                  )
                : const SizedBox.shrink(),
          ),
      ],
    );
  }

  Widget _buildSubMenuItem(
    BuildContext context,
    SidebarItem item,
    String currentLocation,
  ) {
    final isActive = _isRouteActive(currentLocation, item.route);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _handleItemTap(context, item),
        borderRadius: BorderRadius.circular(AppDimens.radiusS),
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimens.spacingM,
            vertical: AppDimens.spacingS,
          ),
          margin: const EdgeInsets.only(bottom: AppDimens.spacingXS),
          decoration: BoxDecoration(
            color: isActive
                ? AppColors.primary.withOpacity(0.05)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(AppDimens.radiusS),
          ),
          child: Row(
            children: [
              Container(
                width: 4,
                height: 4,
                decoration: BoxDecoration(
                  color: isActive ? AppColors.primary : AppColors.neutral400,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: AppDimens.spacingM),
              Expanded(
                child: Text(
                  item.label,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: isActive
                        ? AppColors.primary
                        : Theme.of(context).textTheme.bodySmall?.color,
                    fontWeight: isActive ? FontWeight.w500 : FontWeight.w400,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildToggleButton(
    BuildContext context,
    WidgetRef ref,
    bool isCollapsed,
  ) {
    return Container(
      padding: const EdgeInsets.all(AppDimens.spacingM),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(color: Theme.of(context).dividerColor, width: 1),
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            ref.read(sidebarCollapsedProvider.notifier).state = !isCollapsed;
          },
          borderRadius: BorderRadius.circular(AppDimens.radiusS),
          child: Container(
            padding: const EdgeInsets.all(AppDimens.spacingS),
            child: Row(
              mainAxisAlignment: isCollapsed
                  ? MainAxisAlignment.center
                  : MainAxisAlignment.start,
              children: [
                Icon(
                  isCollapsed ? Icons.menu_open : Icons.menu,
                  size: AppDimens.iconM,
                  color: Theme.of(context).iconTheme.color?.withOpacity(0.7),
                ),
                if (!isCollapsed) ...[
                  const SizedBox(width: AppDimens.spacingM),
                  Text(
                    'Collapse',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(
                        context,
                      ).textTheme.bodySmall?.color?.withOpacity(0.7),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  bool _isRouteActive(String currentLocation, String itemRoute) {
    // Controllo esatto per route principali
    if (currentLocation == itemRoute) return true;

    // Controllo per sottorotte
    if (itemRoute != '/' && currentLocation.startsWith('$itemRoute/')) {
      return true;
    }

    return false;
  }

  void _handleItemTap(BuildContext context, SidebarItem item) {
    // Callback personalizzato
    onItemTap?.call();

    // Navigazione
    if (item.children?.isEmpty ?? true) {
      context.go(item.route);
    }
  }
}

/// Lista predefinita degli item della sidebar
class DefaultSidebarItems {
  static List<SidebarItem> get items => [
    const SidebarItem(
      label: AppStrings.campaigns,
      icon: Icons.campaign,
      route: '/campaigns',
    ),
    const SidebarItem(
      label: AppStrings.characters,
      icon: Icons.people,
      route: '/characters',
    ),
    const SidebarItem(label: 'Sessions', icon: Icons.event, route: '/sessions'),
    const SidebarItem(label: 'Maps', icon: Icons.map, route: '/maps'),
    const SidebarItem(label: 'Notes', icon: Icons.note, route: '/notes'),
    const SidebarItem(
      label: 'Settings',
      icon: Icons.settings,
      route: '/settings',
    ),
  ];
}
