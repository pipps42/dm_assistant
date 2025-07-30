// lib/shared/components/lists/base_list_view.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dm_assistant/core/constants/dimens.dart';
import 'package:dm_assistant/core/widgets/loading_widget.dart';
import 'package:dm_assistant/core/widgets/error_widget.dart';
import 'package:dm_assistant/shared/components/states/empty_state.dart';

enum ListViewType { list, grid, staggered }

class BaseListView<T> extends ConsumerWidget {
  final AsyncValue<List<T>> data;
  final Widget Function(BuildContext, T, int) itemBuilder;
  final Widget? emptyState;
  final Widget? loadingWidget;
  final Widget Function(String error, VoidCallback? onRetry)? errorBuilder;
  final VoidCallback? onRefresh;
  final ListViewType type;
  final EdgeInsets? padding;
  final ScrollController? controller;
  final bool shrinkWrap;
  final ScrollPhysics? physics;
  final String? emptyTitle;
  final String? emptyMessage;
  final IconData? emptyIcon;
  final VoidCallback? onEmptyAction;
  final String? emptyActionLabel;
  
  // Grid-specific properties
  final int crossAxisCount;
  final double crossAxisSpacing;
  final double mainAxisSpacing;
  final double childAspectRatio;
  
  // List-specific properties
  final Widget Function(BuildContext, int)? separatorBuilder;
  final bool addAutomaticKeepAlives;
  final bool addRepaintBoundaries;

  const BaseListView({
    super.key,
    required this.data,
    required this.itemBuilder,
    this.emptyState,
    this.loadingWidget,
    this.errorBuilder,
    this.onRefresh,
    this.type = ListViewType.list,
    this.padding,
    this.controller,
    this.shrinkWrap = false,
    this.physics,
    this.emptyTitle,
    this.emptyMessage,
    this.emptyIcon,
    this.onEmptyAction,
    this.emptyActionLabel,
    this.crossAxisCount = 2,
    this.crossAxisSpacing = AppDimens.spacingM,
    this.mainAxisSpacing = AppDimens.spacingM,
    this.childAspectRatio = 1.0,
    this.separatorBuilder,
    this.addAutomaticKeepAlives = true,
    this.addRepaintBoundaries = true,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return data.when(
      loading: () => loadingWidget ?? const AppLoadingWidget(),
      error: (error, stackTrace) => _buildError(context, error.toString()),
      data: (items) => _buildContent(context, items),
    );
  }

  Widget _buildError(BuildContext context, String error) {
    if (errorBuilder != null) {
      return errorBuilder!(error, onRefresh);
    }
    
    return AppErrorWidget(
      message: error,
      onRetry: onRefresh,
    );
  }

  Widget _buildContent(BuildContext context, List<T> items) {
    if (items.isEmpty) {
      return _buildEmptyState(context);
    }

    Widget listWidget = _buildList(context, items);

    if (onRefresh != null) {
      listWidget = RefreshIndicator(
        onRefresh: () async => onRefresh!(),
        child: listWidget,
      );
    }

    return listWidget;
  }

  Widget _buildList(BuildContext context, List<T> items) {
    switch (type) {
      case ListViewType.list:
        return _buildListView(context, items);
      case ListViewType.grid:
        return _buildGridView(context, items);
      case ListViewType.staggered:
        return _buildStaggeredGridView(context, items);
    }
  }

  Widget _buildListView(BuildContext context, List<T> items) {
    if (separatorBuilder != null) {
      return ListView.separated(
        padding: padding ?? const EdgeInsets.all(AppDimens.spacingM),
        controller: controller,
        shrinkWrap: shrinkWrap,
        physics: physics,
        itemCount: items.length,
        itemBuilder: (context, index) => itemBuilder(context, items[index], index),
        separatorBuilder: separatorBuilder!,
        addAutomaticKeepAlives: addAutomaticKeepAlives,
        addRepaintBoundaries: addRepaintBoundaries,
      );
    }

    return ListView.builder(
      padding: padding ?? const EdgeInsets.all(AppDimens.spacingM),
      controller: controller,
      shrinkWrap: shrinkWrap,
      physics: physics,
      itemCount: items.length,
      itemBuilder: (context, index) => itemBuilder(context, items[index], index),
      addAutomaticKeepAlives: addAutomaticKeepAlives,
      addRepaintBoundaries: addRepaintBoundaries,
    );
  }

  Widget _buildGridView(BuildContext context, List<T> items) {
    return GridView.builder(
      padding: padding ?? const EdgeInsets.all(AppDimens.spacingM),
      controller: controller,
      shrinkWrap: shrinkWrap,
      physics: physics,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: crossAxisSpacing,
        mainAxisSpacing: mainAxisSpacing,
        childAspectRatio: childAspectRatio,
      ),
      itemCount: items.length,
      itemBuilder: (context, index) => itemBuilder(context, items[index], index),
      addAutomaticKeepAlives: addAutomaticKeepAlives,
      addRepaintBoundaries: addRepaintBoundaries,
    );
  }

  Widget _buildStaggeredGridView(BuildContext context, List<T> items) {
    // For now, fallback to regular grid
    // Can be enhanced with flutter_staggered_grid_view
    return _buildGridView(context, items);
  }

  Widget _buildEmptyState(BuildContext context) {
    if (emptyState != null) {
      return emptyState!;
    }

    return EmptyStateWidget(
      title: emptyTitle,
      message: emptyMessage,
      icon: emptyIcon,
      onAction: onEmptyAction,
      actionLabel: emptyActionLabel,
    );
  }
}

// Specialized list views for common use cases
class EntityListView<T> extends BaseListView<T> {
  const EntityListView({
    super.key,
    required super.data,
    required super.itemBuilder,
    super.onRefresh,
    super.padding,
    super.controller,
    super.shrinkWrap = false,
    super.physics,
    String? emptyTitle,
    String? emptyMessage,
    IconData? emptyIcon,
    super.onEmptyAction,
    super.emptyActionLabel,
  }) : super(
          type: ListViewType.list,
          emptyTitle: emptyTitle ?? 'No items found',
          emptyMessage: emptyMessage ?? 'Create your first item to get started',
          emptyIcon: emptyIcon ?? Icons.inbox_outlined,
          separatorBuilder: _defaultSeparator,
        );

  static Widget _defaultSeparator(BuildContext context, int index) {
    return const SizedBox(height: AppDimens.spacingS);
  }
}



// Extension for AsyncValue to easily use with BaseListView
extension AsyncValueListViewExt<T> on AsyncValue<List<T>> {
  Widget toListView({
    required Widget Function(BuildContext, T, int) itemBuilder,
    Widget? emptyState,
    VoidCallback? onRefresh,
    ListViewType type = ListViewType.list,
    EdgeInsets? padding,
    ScrollController? controller,
    bool shrinkWrap = false,
    ScrollPhysics? physics,
    String? emptyTitle,
    String? emptyMessage,
    IconData? emptyIcon,
    VoidCallback? onEmptyAction,
    String? emptyActionLabel,
  }) {
    return BaseListView<T>(
      data: this,
      itemBuilder: itemBuilder,
      emptyState: emptyState,
      onRefresh: onRefresh,
      type: type,
      padding: padding,
      controller: controller,
      shrinkWrap: shrinkWrap,
      physics: physics,
      emptyTitle: emptyTitle,
      emptyMessage: emptyMessage,
      emptyIcon: emptyIcon,
      onEmptyAction: onEmptyAction,
      emptyActionLabel: emptyActionLabel,
    );
  }
}