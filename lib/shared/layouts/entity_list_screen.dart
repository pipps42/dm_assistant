// lib/shared/layouts/entity_list_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dm_assistant/core/constants/dimens.dart';
import 'package:dm_assistant/shared/components/lists/base_list_view.dart';
import 'package:dm_assistant/shared/components/grids/base_grid_view.dart';
import 'package:dm_assistant/features/campaign/providers/campaign_provider.dart';
import 'package:dm_assistant/features/character/providers/character_provider.dart';
import 'package:dm_assistant/features/npcs/providers/npc_provider.dart';

// Remove EntityViewMode enum - use provider-specific enums directly

typedef EntityBuilder<T> = Widget Function(T entity);
typedef EntityDialogBuilder = Widget Function();

class EntityListScreen<T> extends ConsumerWidget {
  final AsyncValue<List<T>> data;
  final EntityBuilder<T> listItemBuilder;
  final EntityBuilder<T> gridItemBuilder;
  final EntityDialogBuilder createDialogBuilder;
  final VoidCallback onRefresh;
  final dynamic viewModeProvider; // Can be StateProvider<CampaignViewMode> or StateProvider<CharacterViewMode>
  final Function(dynamic)? onViewModeChanged;
  final String title;
  final String emptyTitle;
  final String emptyMessage;
  final String createButtonLabel;
  final IconData emptyIcon;
  final Widget? noSelectionWidget;
  final bool showViewToggle;
  final bool showCreateButton;
  final int gridCrossAxisCount;
  final double gridChildAspectRatio;

  const EntityListScreen({
    super.key,
    required this.data,
    required this.listItemBuilder,
    required this.gridItemBuilder,
    required this.createDialogBuilder,
    required this.onRefresh,
    required this.viewModeProvider,
    this.onViewModeChanged,
    required this.title,
    required this.emptyTitle,
    required this.emptyMessage,
    required this.createButtonLabel,
    required this.emptyIcon,
    this.noSelectionWidget,
    this.showViewToggle = true,
    this.showCreateButton = true,
    this.gridCrossAxisCount = 3,
    this.gridChildAspectRatio = 5 / 4,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final viewMode = ref.watch(viewModeProvider);
    final isListMode = viewMode.toString().contains('list');

    // Show no selection widget if provided
    if (noSelectionWidget != null) {
      return Scaffold(body: noSelectionWidget!);
    }

    return Scaffold(
      body: Column(
        children: [
          // View toggle
          if (showViewToggle) _buildViewToggle(context, ref, viewMode),

          // Content
          Expanded(
            child: isListMode
                ? _buildListView(ref)
                : _buildGridView(ref),
          ),
        ],
      ),
      floatingActionButton: showCreateButton
          ? FloatingActionButton.extended(
              onPressed: () => _showCreateDialog(context),
              icon: const Icon(Icons.add),
              label: Text(createButtonLabel),
            )
          : null,
    );
  }

  Widget _buildViewToggle(
    BuildContext context,
    WidgetRef ref,
    dynamic viewMode,
  ) {
    final isListMode = viewMode.toString().contains('list');
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimens.spacingM,
        vertical: AppDimens.spacingS,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          SegmentedButton<bool>(
            segments: const [
              ButtonSegment(
                value: true,
                icon: Icon(Icons.list),
                label: Text('List'),
              ),
              ButtonSegment(
                value: false,
                icon: Icon(Icons.grid_view),
                label: Text('Grid'),
              ),
            ],
            selected: {isListMode},
            onSelectionChanged: (Set<bool> selected) {
              final isListSelected = selected.first;
              // Determine the correct enum values dynamically
              final currentViewMode = ref.read(viewModeProvider);
              final newMode = _getViewModeForType(currentViewMode.runtimeType, isListSelected);
              
              if (onViewModeChanged != null) {
                onViewModeChanged!(newMode);
              } else {
                ref.read(viewModeProvider.notifier).state = newMode;
              }
            },
          ),
        ],
      ),
    );
  }
  
  dynamic _getViewModeForType(Type enumType, bool isList) {
    // Handle different enum types directly
    if (enumType.toString().contains('CampaignViewMode')) {
      return isList ? CampaignViewMode.list : CampaignViewMode.grid;
    } else if (enumType.toString().contains('CharacterViewMode')) {
      return isList ? CharacterViewMode.list : CharacterViewMode.grid;
    } else if (enumType.toString().contains('NpcViewMode')) {
      return isList ? NpcViewMode.list : NpcViewMode.grid;
    }
    // Fallback - this shouldn't happen
    return isList;
  }

  Widget _buildListView(WidgetRef ref) {
    return EntityListView<T>(
      data: data,
      itemBuilder: (context, entity, index) => listItemBuilder(entity),
      onRefresh: onRefresh,
      emptyTitle: emptyTitle,
      emptyMessage: emptyMessage,
      emptyIcon: emptyIcon,
      onEmptyAction: showCreateButton ? () => _showCreateDialog(ref.context) : null,
      emptyActionLabel: showCreateButton ? createButtonLabel : null,
    );
  }

  Widget _buildGridView(WidgetRef ref) {
    return EntityGridView<T>(
      data: data,
      itemBuilder: (context, entity, index) => gridItemBuilder(entity),
      onRefresh: onRefresh,
      crossAxisCount: gridCrossAxisCount,
      childAspectRatio: gridChildAspectRatio,
      emptyTitle: emptyTitle,
      emptyMessage: emptyMessage,
      emptyIcon: emptyIcon,
      onEmptyAction: showCreateButton ? () => _showCreateDialog(ref.context) : null,
      emptyActionLabel: showCreateButton ? createButtonLabel : null,
    );
  }

  void _showCreateDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => createDialogBuilder(),
    );
  }
}

// Widget for when no selection is made (e.g., no campaign selected)
class NoSelectionWidget extends StatelessWidget {
  final String title;
  final String message;
  final IconData icon;
  final String? actionLabel;
  final VoidCallback? onAction;

  const NoSelectionWidget({
    super.key,
    required this.title,
    required this.message,
    required this.icon,
    this.actionLabel,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppDimens.spacingXL),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: AppDimens.iconXL * 1.5, color: Colors.grey),
            const SizedBox(height: AppDimens.spacingL),
            Text(
              title,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppDimens.spacingS),
            Text(
              message,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey,
              ),
              textAlign: TextAlign.center,
            ),
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: AppDimens.spacingL),
              ElevatedButton(
                onPressed: onAction,
                child: Text(actionLabel!),
              ),
            ],
          ],
        ),
      ),
    );
  }
}