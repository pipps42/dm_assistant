// lib/shared/components/actions/action_sheet.dart
import 'package:flutter/material.dart';
import 'package:dm_assistant/core/constants/dimens.dart';

enum ActionSheetStyle { material, cupertino, custom }

class ActionSheet extends StatelessWidget {
  final String? title;
  final String? subtitle;
  final List<ActionSheetItem> actions;
  final ActionSheetItem? cancelAction;
  final ActionSheetStyle style;
  final bool showDragHandle;
  final EdgeInsets padding;
  final double? maxHeight;

  const ActionSheet({
    super.key,
    this.title,
    this.subtitle,
    required this.actions,
    this.cancelAction,
    this.style = ActionSheetStyle.material,
    this.showDragHandle = true,
    this.padding = const EdgeInsets.all(AppDimens.spacingM),
    this.maxHeight,
  });

  static Future<T?> show<T>({
    required BuildContext context,
    String? title,
    String? subtitle,
    required List<ActionSheetItem> actions,
    ActionSheetItem? cancelAction,
    ActionSheetStyle style = ActionSheetStyle.material,
    bool showDragHandle = true,
    EdgeInsets padding = const EdgeInsets.all(AppDimens.spacingM),
    double? maxHeight,
    bool isDismissible = true,
    bool enableDrag = true,
  }) {
    return showModalBottomSheet<T>(
      context: context,
      isDismissible: isDismissible,
      enableDrag: enableDrag,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => ActionSheet(
        title: title,
        subtitle: subtitle,
        actions: actions,
        cancelAction: cancelAction,
        style: style,
        showDragHandle: showDragHandle,
        padding: padding,
        maxHeight: maxHeight,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final screenHeight = MediaQuery.of(context).size.height;
    final calculatedMaxHeight = maxHeight ?? screenHeight * 0.8;

    return Container(
      constraints: BoxConstraints(maxHeight: calculatedMaxHeight),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(AppDimens.radiusXL),
          topRight: Radius.circular(AppDimens.radiusXL),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (showDragHandle) _buildDragHandle(theme),
          if (title != null || subtitle != null) _buildHeader(context, theme),
          Flexible(
            child: _buildActions(context, theme),
          ),
          if (cancelAction != null) _buildCancelAction(context, theme),
          SizedBox(height: MediaQuery.of(context).padding.bottom),
        ],
      ),
    );
  }

  Widget _buildDragHandle(ThemeData theme) {
    return Container(
      margin: const EdgeInsets.only(top: AppDimens.spacingS),
      width: 32,
      height: 4,
      decoration: BoxDecoration(
        color: theme.colorScheme.onSurface.withOpacity(0.3),
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, ThemeData theme) {
    return Container(
      width: double.infinity,
      padding: padding.copyWith(bottom: AppDimens.spacingS),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (title != null)
            Text(
              title!,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          if (subtitle != null) ...[
            const SizedBox(height: 4),
            Text(
              subtitle!,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.7),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildActions(BuildContext context, ThemeData theme) {
    return ListView.separated(
      shrinkWrap: true,
      padding: padding.copyWith(top: 0, bottom: AppDimens.spacingS),
      itemCount: actions.length,
      separatorBuilder: (context, index) => const SizedBox(height: AppDimens.spacingXS),
      itemBuilder: (context, index) {
        final action = actions[index];
        return _ActionTile(
          action: action,
          style: style,
          onTap: () {
            Navigator.of(context).pop();
            action.onPressed?.call();
          },
        );
      },
    );
  }

  Widget _buildCancelAction(BuildContext context, ThemeData theme) {
    return Container(
      width: double.infinity,
      padding: padding.copyWith(top: 0),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: theme.dividerColor.withOpacity(0.2),
          ),
        ),
      ),
      child: _ActionTile(
        action: cancelAction!,
        style: style,
        isCancel: true,
        onTap: () {
          Navigator.of(context).pop();
          cancelAction!.onPressed?.call();
        },
      ),
    );
  }
}

class _ActionTile extends StatelessWidget {
  final ActionSheetItem action;
  final ActionSheetStyle style;
  final bool isCancel;
  final VoidCallback onTap;

  const _ActionTile({
    required this.action,
    required this.style,
    this.isCancel = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: action.enabled ? onTap : null,
      borderRadius: BorderRadius.circular(AppDimens.radiusM),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimens.spacingM,
          vertical: AppDimens.spacingM,
        ),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppDimens.radiusM),
          color: action.backgroundColor,
        ),
        child: Row(
          children: [
            if (action.leading != null) ...[
              action.leading!,
              const SizedBox(width: AppDimens.spacingM),
            ] else if (action.icon != null) ...[
              Icon(
                action.icon,
                color: _getIconColor(theme),
                size: 24,
              ),
              const SizedBox(width: AppDimens.spacingM),
            ],
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    action.title,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: _getTextColor(theme),
                      fontWeight: isCancel ? FontWeight.w600 : FontWeight.normal,
                    ),
                  ),
                  if (action.subtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      action.subtitle!,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: _getTextColor(theme).withOpacity(0.7),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            if (action.trailing != null) ...[
              const SizedBox(width: AppDimens.spacingM),
              action.trailing!,
            ],
          ],
        ),
      ),
    );
  }

  Color _getTextColor(ThemeData theme) {
    if (!action.enabled) {
      return theme.colorScheme.onSurface.withOpacity(0.38);
    }
    
    if (action.isDestructive) {
      return theme.colorScheme.error;
    }
    
    if (action.textColor != null) {
      return action.textColor!;
    }
    
    return theme.colorScheme.onSurface;
  }

  Color _getIconColor(ThemeData theme) {
    if (!action.enabled) {
      return theme.colorScheme.onSurface.withOpacity(0.38);
    }
    
    if (action.isDestructive) {
      return theme.colorScheme.error;
    }
    
    if (action.iconColor != null) {
      return action.iconColor!;
    }
    
    return theme.colorScheme.onSurface.withOpacity(0.7);
  }
}

class ActionSheetItem {
  final String title;
  final String? subtitle;
  final IconData? icon;
  final Widget? leading;
  final Widget? trailing;
  final VoidCallback? onPressed;
  final bool enabled;
  final bool isDestructive;
  final Color? textColor;
  final Color? iconColor;
  final Color? backgroundColor;

  const ActionSheetItem({
    required this.title,
    this.subtitle,
    this.icon,
    this.leading,
    this.trailing,
    this.onPressed,
    this.enabled = true,
    this.isDestructive = false,
    this.textColor,
    this.iconColor,
    this.backgroundColor,
  });

  // Convenience constructors
  factory ActionSheetItem.edit({
    required VoidCallback onPressed,
    String title = 'Edit',
  }) {
    return ActionSheetItem(
      title: title,
      icon: Icons.edit,
      onPressed: onPressed,
    );
  }

  factory ActionSheetItem.delete({
    required VoidCallback onPressed,
    String title = 'Delete',
  }) {
    return ActionSheetItem(
      title: title,
      icon: Icons.delete,
      onPressed: onPressed,
      isDestructive: true,
    );
  }

  factory ActionSheetItem.share({
    required VoidCallback onPressed,
    String title = 'Share',
  }) {
    return ActionSheetItem(
      title: title,
      icon: Icons.share,
      onPressed: onPressed,
    );
  }

  factory ActionSheetItem.duplicate({
    required VoidCallback onPressed,
    String title = 'Duplicate',
  }) {
    return ActionSheetItem(
      title: title,
      icon: Icons.copy,
      onPressed: onPressed,
    );
  }

  factory ActionSheetItem.favorite({
    required VoidCallback onPressed,
    required bool isFavorite,
  }) {
    return ActionSheetItem(
      title: isFavorite ? 'Remove from Favorites' : 'Add to Favorites',
      icon: isFavorite ? Icons.favorite : Icons.favorite_border,
      onPressed: onPressed,
    );
  }

  factory ActionSheetItem.cancel({
    VoidCallback? onPressed,
    String title = 'Cancel',
  }) {
    return ActionSheetItem(
      title: title,
      onPressed: onPressed,
    );
  }
}

// D&D specific action sheets
class CampaignActionSheet {
  static Future<void> show({
    required BuildContext context,
    required String campaignName,
    VoidCallback? onEdit,
    VoidCallback? onDuplicate,
    VoidCallback? onExport,
    VoidCallback? onDelete,
  }) {
    return ActionSheet.show(
      context: context,
      title: campaignName,
      subtitle: 'Choose an action',
      actions: [
        if (onEdit != null) ActionSheetItem.edit(onPressed: onEdit),
        if (onDuplicate != null) ActionSheetItem.duplicate(onPressed: onDuplicate),
        if (onExport != null)
          ActionSheetItem(
            title: 'Export',
            icon: Icons.download,
            onPressed: onExport,
          ),
        if (onDelete != null) ActionSheetItem.delete(onPressed: onDelete),
      ],
      cancelAction: ActionSheetItem.cancel(),
    );
  }
}

class CharacterActionSheet {
  static Future<void> show({
    required BuildContext context,
    required String characterName,
    VoidCallback? onEdit,
    VoidCallback? onDuplicate,
    VoidCallback? onAddToParty,
    VoidCallback? onRemoveFromParty,
    VoidCallback? onDelete,
  }) {
    return ActionSheet.show(
      context: context,
      title: characterName,
      subtitle: 'Character actions',
      actions: [
        if (onEdit != null) ActionSheetItem.edit(onPressed: onEdit),
        if (onDuplicate != null) ActionSheetItem.duplicate(onPressed: onDuplicate),
        if (onAddToParty != null)
          ActionSheetItem(
            title: 'Add to Party',
            icon: Icons.group_add,
            onPressed: onAddToParty,
          ),
        if (onRemoveFromParty != null)
          ActionSheetItem(
            title: 'Remove from Party',
            icon: Icons.group_remove,
            onPressed: onRemoveFromParty,
          ),
        if (onDelete != null) ActionSheetItem.delete(onPressed: onDelete),
      ],
      cancelAction: ActionSheetItem.cancel(),
    );
  }
}

class SessionActionSheet {
  static Future<void> show({
    required BuildContext context,
    required String sessionName,
    VoidCallback? onEdit,
    VoidCallback? onDuplicate,
    VoidCallback? onStart,
    VoidCallback? onEnd,
    VoidCallback? onDelete,
  }) {
    return ActionSheet.show(
      context: context,
      title: sessionName,
      subtitle: 'Session actions',
      actions: [
        if (onStart != null)
          ActionSheetItem(
            title: 'Start Session',
            icon: Icons.play_arrow,
            onPressed: onStart,
          ),
        if (onEnd != null)
          ActionSheetItem(
            title: 'End Session',
            icon: Icons.stop,
            onPressed: onEnd,
          ),
        if (onEdit != null) ActionSheetItem.edit(onPressed: onEdit),
        if (onDuplicate != null) ActionSheetItem.duplicate(onPressed: onDuplicate),
        if (onDelete != null) ActionSheetItem.delete(onPressed: onDelete),
      ],
      cancelAction: ActionSheetItem.cancel(),
    );
  }
}