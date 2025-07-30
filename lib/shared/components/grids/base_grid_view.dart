// lib/shared/components/grids/base_grid_view.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dm_assistant/core/constants/dimens.dart';
import 'package:dm_assistant/shared/components/lists/base_list_view.dart';

class BaseGridView<T> extends BaseListView<T> {
  const BaseGridView({
    super.key,
    required super.data,
    required super.itemBuilder,
    super.onRefresh,
    super.padding,
    super.controller,
    super.shrinkWrap = false,
    super.physics,
    super.crossAxisCount = 2,
    super.crossAxisSpacing = AppDimens.spacingM,
    super.mainAxisSpacing = AppDimens.spacingM,
    super.childAspectRatio = 1.0,
    super.emptyTitle,
    super.emptyMessage,
    super.emptyIcon,
    super.onEmptyAction,
    super.emptyActionLabel,
  }) : super(type: ListViewType.grid);
}

class EntityGridView<T> extends BaseGridView<T> {
  const EntityGridView({
    super.key,
    required super.data,
    required super.itemBuilder,
    super.onRefresh,
    super.padding,
    super.controller,
    super.shrinkWrap = false,
    super.physics,
    super.crossAxisCount = 2,
    super.crossAxisSpacing = AppDimens.spacingM,
    super.mainAxisSpacing = AppDimens.spacingM,
    super.childAspectRatio = 1.0,
    String? emptyTitle,
    String? emptyMessage,
    IconData? emptyIcon,
    super.onEmptyAction,
    super.emptyActionLabel,
  }) : super(
          emptyTitle: emptyTitle ?? 'No items found',
          emptyMessage: emptyMessage ?? 'Create your first item to get started',
          emptyIcon: emptyIcon ?? Icons.grid_view_outlined,
        );
}

// Responsive grid that adapts column count based on screen width
class ResponsiveGridView<T> extends StatelessWidget {
  final AsyncValue<List<T>> data;
  final Widget Function(BuildContext, T, int) itemBuilder;
  final VoidCallback? onRefresh;
  final EdgeInsets? padding;
  final ScrollController? controller;
  final bool shrinkWrap;
  final ScrollPhysics? physics;
  final String? emptyTitle;
  final String? emptyMessage;
  final IconData? emptyIcon;
  final VoidCallback? onEmptyAction;
  final String? emptyActionLabel;
  final double crossAxisSpacing;
  final double mainAxisSpacing;
  final double childAspectRatio;
  final double itemMinWidth;

  const ResponsiveGridView({
    super.key,
    required this.data,
    required this.itemBuilder,
    this.onRefresh,
    this.padding,
    this.controller,
    this.shrinkWrap = false,
    this.physics,
    this.emptyTitle,
    this.emptyMessage,
    this.emptyIcon,
    this.onEmptyAction,
    this.emptyActionLabel,
    this.crossAxisSpacing = AppDimens.spacingM,
    this.mainAxisSpacing = AppDimens.spacingM,
    this.childAspectRatio = 1.0,
    this.itemMinWidth = 200.0,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final crossAxisCount = _calculateCrossAxisCount(constraints.maxWidth);
        
        return BaseGridView<T>(
          data: data,
          itemBuilder: itemBuilder,
          onRefresh: onRefresh,
          padding: padding,
          controller: controller,
          shrinkWrap: shrinkWrap,
          physics: physics,
          crossAxisCount: crossAxisCount,
          crossAxisSpacing: crossAxisSpacing,
          mainAxisSpacing: mainAxisSpacing,
          childAspectRatio: childAspectRatio,
          emptyTitle: emptyTitle,
          emptyMessage: emptyMessage,
          emptyIcon: emptyIcon,
          onEmptyAction: onEmptyAction,
          emptyActionLabel: emptyActionLabel,
        );
      },
    );
  }

  int _calculateCrossAxisCount(double width) {
    final availableWidth = width - (padding?.horizontal ?? AppDimens.spacingM * 2);
    final itemsPerRow = (availableWidth / (itemMinWidth + crossAxisSpacing)).floor();
    return itemsPerRow.clamp(1, 6); // Min 1, max 6 columns
  }
}