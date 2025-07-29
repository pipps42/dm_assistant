// lib/shared/widgets/breadcrumb_bar.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:dm_assistant/core/constants/app_colors.dart';
import 'package:dm_assistant/core/constants/dimens.dart';

/// Modello per un item del breadcrumb
class BreadcrumbItem {
  final String label;
  final String? route;
  final IconData? icon;
  final bool isClickable;

  const BreadcrumbItem({
    required this.label,
    this.route,
    this.icon,
    this.isClickable = true,
  });

  factory BreadcrumbItem.home() {
    return const BreadcrumbItem(label: 'Home', route: '/', icon: Icons.home);
  }

  factory BreadcrumbItem.current(String label, {IconData? icon}) {
    return BreadcrumbItem(label: label, icon: icon, isClickable: false);
  }
}

/// Widget per la barra breadcrumb
class BreadcrumbBar extends StatelessWidget {
  final List<BreadcrumbItem> items;
  final bool showBackground;
  final EdgeInsets? padding;
  final String separator;
  final IconData separatorIcon;

  const BreadcrumbBar({
    super.key,
    required this.items,
    this.showBackground = true,
    this.padding,
    this.separator = '/',
    this.separatorIcon = Icons.chevron_right,
  });

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) return const SizedBox.shrink();

    return Container(
      padding:
          padding ??
          const EdgeInsets.symmetric(
            horizontal: AppDimens.spacingL,
            vertical: AppDimens.spacingM,
          ),
      decoration: showBackground
          ? BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              border: Border(
                bottom: BorderSide(
                  color: Theme.of(context).dividerColor,
                  width: 1,
                ),
              ),
            )
          : null,
      child: Row(
        children: [
          Expanded(child: Wrap(children: _buildBreadcrumbWidgets(context))),
        ],
      ),
    );
  }

  List<Widget> _buildBreadcrumbWidgets(BuildContext context) {
    final widgets = <Widget>[];

    for (int i = 0; i < items.length; i++) {
      final item = items[i];
      final isLast = i == items.length - 1;

      // Aggiungi l'item del breadcrumb
      widgets.add(
        isLast
            ? _buildCurrentItem(context, item)
            : _buildClickableItem(context, item),
      );

      // Aggiungi il separatore se non è l'ultimo item
      if (!isLast) {
        widgets.add(_buildSeparator(context));
      }
    }

    return widgets;
  }

  Widget _buildClickableItem(BuildContext context, BreadcrumbItem item) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: item.isClickable && item.route != null
            ? () => context.go(item.route!)
            : null,
        borderRadius: BorderRadius.circular(AppDimens.radiusS),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimens.spacingS,
            vertical: AppDimens.spacingXS,
          ),
          child: _buildItemContent(context, item, false),
        ),
      ),
    );
  }

  Widget _buildCurrentItem(BuildContext context, BreadcrumbItem item) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimens.spacingS,
        vertical: AppDimens.spacingXS,
      ),
      child: _buildItemContent(context, item, true),
    );
  }

  Widget _buildItemContent(
    BuildContext context,
    BreadcrumbItem item,
    bool isLast,
  ) {
    final textStyle = isLast
        ? Theme.of(context).textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: Theme.of(context).colorScheme.onSurface,
          )
        : Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: AppColors.primary,
            fontWeight: FontWeight.w500,
          );

    final iconColor = isLast
        ? Theme.of(context).colorScheme.onSurface
        : AppColors.primary;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (item.icon != null) ...[
          Icon(item.icon, size: 16, color: iconColor),
          const SizedBox(width: AppDimens.spacingXS),
        ],
        Flexible(
          child: Text(
            item.label,
            style: textStyle,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildSeparator(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppDimens.spacingS),
      child: Icon(separatorIcon, size: 14, color: AppColors.neutral400),
    );
  }
}

/// Utility class per generare breadcrumb da route
class BreadcrumbGenerator {
  /// Genera breadcrumb automaticamente dalla route corrente
  static List<BreadcrumbItem> fromRoute(String route) {
    final segments = route.split('/').where((s) => s.isNotEmpty).toList();
    final breadcrumbs = <BreadcrumbItem>[];

    // Aggiungi sempre home come primo item
    breadcrumbs.add(BreadcrumbItem.home());

    String currentPath = '';
    for (int i = 0; i < segments.length; i++) {
      currentPath += '/${segments[i]}';
      final isLast = i == segments.length - 1;

      breadcrumbs.add(
        BreadcrumbItem(
          label: _getLabelFromSegment(segments[i]),
          route: isLast ? null : currentPath,
          icon: _getIconFromSegment(segments[i]),
          isClickable: !isLast,
        ),
      );
    }

    return breadcrumbs;
  }

  /// Genera breadcrumb personalizzato per route specifiche
  static List<BreadcrumbItem> forCampaign({
    required String campaignName,
    String? section,
  }) {
    final items = <BreadcrumbItem>[
      BreadcrumbItem.home(),
      const BreadcrumbItem(
        label: 'Campaigns',
        route: '/campaigns',
        icon: Icons.campaign,
      ),
      BreadcrumbItem(
        label: campaignName,
        route: section != null ? '/campaigns/campaign' : null,
        icon: Icons.folder,
        isClickable: section != null,
      ),
    ];

    if (section != null) {
      items.add(
        BreadcrumbItem.current(
          section,
          icon: _getIconFromSegment(section.toLowerCase()),
        ),
      );
    }

    return items;
  }

  /// Genera breadcrumb per caratteri
  static List<BreadcrumbItem> forCharacter({
    required String characterName,
    String? section,
  }) {
    final items = <BreadcrumbItem>[
      BreadcrumbItem.home(),
      const BreadcrumbItem(
        label: 'Characters',
        route: '/characters',
        icon: Icons.people,
      ),
      BreadcrumbItem(
        label: characterName,
        route: section != null ? '/characters/character' : null,
        icon: Icons.person,
        isClickable: section != null,
      ),
    ];

    if (section != null) {
      items.add(
        BreadcrumbItem.current(
          section,
          icon: _getIconFromSegment(section.toLowerCase()),
        ),
      );
    }

    return items;
  }

  /// Genera breadcrumb per sessioni
  static List<BreadcrumbItem> forSession({
    required String sessionName,
    String? section,
  }) {
    final items = <BreadcrumbItem>[
      BreadcrumbItem.home(),
      const BreadcrumbItem(
        label: 'Sessions',
        route: '/sessions',
        icon: Icons.event,
      ),
      BreadcrumbItem(
        label: sessionName,
        route: section != null ? '/sessions/session' : null,
        icon: Icons.event_note,
        isClickable: section != null,
      ),
    ];

    if (section != null) {
      items.add(
        BreadcrumbItem.current(
          section,
          icon: _getIconFromSegment(section.toLowerCase()),
        ),
      );
    }

    return items;
  }

  static String _getLabelFromSegment(String segment) {
    // Converti da kebab-case a Title Case
    return segment
        .split('-')
        .map(
          (word) => word.isEmpty
              ? ''
              : '${word[0].toUpperCase()}${word.substring(1)}',
        )
        .join(' ');
  }

  static IconData? _getIconFromSegment(String segment) {
    switch (segment.toLowerCase()) {
      case 'campaigns':
        return Icons.campaign;
      case 'characters':
        return Icons.people;
      case 'sessions':
        return Icons.event;
      case 'maps':
        return Icons.map;
      case 'notes':
        return Icons.note;
      case 'settings':
        return Icons.settings;
      case 'edit':
        return Icons.edit;
      case 'create':
        return Icons.add;
      case 'details':
        return Icons.info;
      case 'stats':
        return Icons.bar_chart;
      case 'inventory':
        return Icons.inventory;
      case 'spells':
        return Icons.auto_fix_high;
      case 'abilities':
        return Icons.fitness_center;
      default:
        return null;
    }
  }
}

/// Widget wrapper che aggiunge automaticamente breadcrumb a uno schermo
class ScreenWithBreadcrumb extends StatelessWidget {
  final Widget child;
  final List<BreadcrumbItem>? customBreadcrumbs;
  final bool showBreadcrumb;

  const ScreenWithBreadcrumb({
    super.key,
    required this.child,
    this.customBreadcrumbs,
    this.showBreadcrumb = true,
  });

  @override
  Widget build(BuildContext context) {
    if (!showBreadcrumb) return child;

    final breadcrumbs =
        customBreadcrumbs ??
        BreadcrumbGenerator.fromRoute(
          GoRouterState.of(context).matchedLocation,
        );

    return Column(
      children: [
        BreadcrumbBar(items: breadcrumbs),
        Expanded(child: child),
      ],
    );
  }
}
