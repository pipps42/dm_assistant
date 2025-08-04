// lib/shared/components/navigation/breadcrumb_widget.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:dm_assistant/core/constants/dimens.dart';

/// Represents a single breadcrumb item
class BreadcrumbItem {
  /// The label to display for this breadcrumb item
  final String label;
  
  /// The route to navigate to when clicked (null for non-clickable items, usually the last one)
  final String? route;
  
  /// Whether this item is currently active/selected
  final bool isActive;

  const BreadcrumbItem({
    required this.label,
    this.route,
    this.isActive = false,
  });

  /// Creates a clickable breadcrumb item
  factory BreadcrumbItem.clickable({
    required String label,
    required String route,
  }) {
    return BreadcrumbItem(
      label: label,
      route: route,
      isActive: false,
    );
  }

  /// Creates a non-clickable breadcrumb item (usually the current/last item)
  factory BreadcrumbItem.current({
    required String label,
  }) {
    return BreadcrumbItem(
      label: label,
      route: null,
      isActive: true,
    );
  }
}

/// A reusable breadcrumb navigation widget
class BreadcrumbWidget extends StatelessWidget {
  /// List of breadcrumb items to display
  final List<BreadcrumbItem> items;
  
  /// Optional separator between breadcrumb items
  final Widget? separator;
  
  /// Style for clickable breadcrumb items
  final TextStyle? clickableStyle;
  
  /// Style for the current (non-clickable) breadcrumb item
  final TextStyle? currentStyle;
  
  /// Color for the separator icons
  final Color? separatorColor;

  const BreadcrumbWidget({
    super.key,
    required this.items,
    this.separator,
    this.clickableStyle,
    this.currentStyle,
    this.separatorColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    if (items.isEmpty) {
      return const SizedBox.shrink();
    }

    // If only one item, display it as a simple title (no breadcrumb style)
    if (items.length == 1) {
      return Text(
        items.first.label,
        style: theme.textTheme.headlineSmall,
      );
    }

    return Row(
      children: _buildBreadcrumbItems(theme),
    );
  }

  List<Widget> _buildBreadcrumbItems(ThemeData theme) {
    final List<Widget> widgets = [];
    
    for (int i = 0; i < items.length; i++) {
      final item = items[i];
      final isLast = i == items.length - 1;
      
      // Add the breadcrumb item
      widgets.add(_buildBreadcrumbItem(item, theme));
      
      // Add separator (except for the last item)
      if (!isLast) {
        widgets.add(_buildSeparator(theme));
      }
    }
    
    return widgets;
  }

  Widget _buildBreadcrumbItem(BreadcrumbItem item, ThemeData theme) {
    final style = item.isActive || item.route == null
        ? currentStyle ?? theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: theme.colorScheme.onSurface,
          )
        : clickableStyle ?? theme.textTheme.titleMedium?.copyWith(
            color: theme.colorScheme.primary,
            fontWeight: FontWeight.w500,
          );

    final widget = Text(
      item.label,
      style: style,
      overflow: TextOverflow.ellipsis,
    );

    // If the item has a route and is not the current item, make it clickable
    if (item.route != null && !item.isActive) {
      return Builder(
        builder: (context) => InkWell(
          onTap: () => context.go(item.route!),
          borderRadius: BorderRadius.circular(AppDimens.radiusS),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppDimens.spacingXS,
              vertical: AppDimens.spacingXS,
            ),
            child: widget,
          ),
        ),
      );
    }

    return Flexible(child: widget);
  }

  Widget _buildSeparator(ThemeData theme) {
    return separator ?? Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppDimens.spacingS),
      child: Icon(
        Icons.chevron_right,
        size: 18,
        color: separatorColor ?? theme.colorScheme.onSurface.withOpacity(0.5),
      ),
    );
  }

}

/// Helper class to build common breadcrumb patterns
class BreadcrumbBuilder {
  /// Creates breadcrumbs for a main section (e.g., "Campaigns")
  static List<BreadcrumbItem> forSection(String sectionName) {
    return [BreadcrumbItem.current(label: sectionName)];
  }

  /// Creates breadcrumbs for an entity detail page (e.g., "Characters > Gandalf")
  static List<BreadcrumbItem> forEntityDetail({
    required String sectionName,
    required String sectionRoute,
    required String entityName,
  }) {
    return [
      BreadcrumbItem.clickable(label: sectionName, route: sectionRoute),
      BreadcrumbItem.current(label: entityName),
    ];
  }

  /// Creates breadcrumbs for a nested entity detail (e.g., "Campaigns > LotR > Session 1")
  static List<BreadcrumbItem> forNestedDetail({
    required String parentSectionName,
    required String parentSectionRoute,
    required String parentEntityName,
    required String parentEntityRoute,
    required String currentEntityName,
  }) {
    return [
      BreadcrumbItem.clickable(label: parentSectionName, route: parentSectionRoute),
      BreadcrumbItem.clickable(label: parentEntityName, route: parentEntityRoute),
      BreadcrumbItem.current(label: currentEntityName),
    ];
  }

  /// Creates custom breadcrumbs from a list of (label, route) pairs
  /// The last item will automatically be set as current (non-clickable)
  static List<BreadcrumbItem> custom(List<(String label, String? route)> items) {
    if (items.isEmpty) return [];

    final breadcrumbs = <BreadcrumbItem>[];
    
    for (int i = 0; i < items.length; i++) {
      final (label, route) = items[i];
      final isLast = i == items.length - 1;
      
      if (isLast) {
        breadcrumbs.add(BreadcrumbItem.current(label: label));
      } else {
        breadcrumbs.add(BreadcrumbItem.clickable(
          label: label,
          route: route ?? '',
        ));
      }
    }
    
    return breadcrumbs;
  }
}