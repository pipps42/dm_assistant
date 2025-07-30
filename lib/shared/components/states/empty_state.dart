// lib/shared/components/states/empty_state.dart
import 'package:flutter/material.dart';
import 'package:dm_assistant/core/constants/dimens.dart';
import 'package:dm_assistant/shared/components/buttons/base_button.dart';

class EmptyStateWidget extends StatelessWidget {
  final String? title;
  final String? message;
  final IconData? icon;
  final VoidCallback? onAction;
  final String? actionLabel;
  final Widget? customAction;
  final Color? iconColor;
  final TextStyle? titleStyle;
  final TextStyle? messageStyle;
  final double iconSize;
  final EdgeInsets padding;

  const EmptyStateWidget({
    super.key,
    this.title,
    this.message,
    this.icon,
    this.onAction,
    this.actionLabel,
    this.customAction,
    this.iconColor,
    this.titleStyle,
    this.messageStyle,
    this.iconSize = 64,
    this.padding = const EdgeInsets.all(AppDimens.spacingXL),
  });

  // Preset constructors for common scenarios
  factory EmptyStateWidget.noItems({
    String title = 'No items found',
    String message = 'Create your first item to get started',
    IconData icon = Icons.inbox_outlined,
    VoidCallback? onAction,
    String actionLabel = 'Create Item',
  }) {
    return EmptyStateWidget(
      title: title,
      message: message,
      icon: icon,
      onAction: onAction,
      actionLabel: actionLabel,
    );
  }

  factory EmptyStateWidget.noCampaigns({
    VoidCallback? onCreateCampaign,
  }) {
    return EmptyStateWidget(
      title: 'No campaigns yet',
      message: 'Create your first campaign to get started',
      icon: Icons.campaign_outlined,
      onAction: onCreateCampaign,
      actionLabel: 'Create Campaign',
    );
  }

  factory EmptyStateWidget.noCharacters({
    VoidCallback? onCreateCharacter,
  }) {
    return EmptyStateWidget(
      title: 'No characters yet',
      message: 'Add characters to start managing your party',
      icon: Icons.people_outline,
      onAction: onCreateCharacter,
      actionLabel: 'Add Character',
    );
  }

  factory EmptyStateWidget.noSessions({
    VoidCallback? onCreateSession,
  }) {
    return EmptyStateWidget(
      title: 'No sessions yet',
      message: 'Plan your first gaming session',
      icon: Icons.event_outlined,
      onAction: onCreateSession,
      actionLabel: 'Create Session',
    );
  }

  factory EmptyStateWidget.noMaps({
    VoidCallback? onAddMap,
  }) {
    return EmptyStateWidget(
      title: 'No maps yet',
      message: 'Add maps to enhance your campaigns',
      icon: Icons.map_outlined,
      onAction: onAddMap,
      actionLabel: 'Add Map',
    );
  }

  factory EmptyStateWidget.noQuests({
    VoidCallback? onCreateQuest,
  }) {
    return EmptyStateWidget(
      title: 'No quests yet',
      message: 'Create quests to guide your adventures',
      icon: Icons.auto_stories_outlined,
      onAction: onCreateQuest,
      actionLabel: 'Create Quest',
    );
  }

  factory EmptyStateWidget.error({
    String title = 'Something went wrong',
    String message = 'Please try again later',
    IconData icon = Icons.error_outline,
    VoidCallback? onRetry,
    String actionLabel = 'Retry',
  }) {
    return EmptyStateWidget(
      title: title,
      message: message,
      icon: icon,
      onAction: onRetry,
      actionLabel: actionLabel,
      iconColor: Colors.red,
    );
  }

  factory EmptyStateWidget.loading({
    String title = 'Loading...',
    String? message,
    IconData icon = Icons.hourglass_empty,
  }) {
    return EmptyStateWidget(
      title: title,
      message: message,
      icon: icon,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: padding,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (icon != null)
              Icon(
                icon!,
                size: iconSize,
                color: iconColor ?? theme.colorScheme.onSurface.withOpacity(0.3),
              ),
            if (icon != null && (title != null || message != null))
              const SizedBox(height: AppDimens.spacingL),
            if (title != null)
              Text(
                title!,
                style: titleStyle ??
                    theme.textTheme.titleLarge?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.8),
                    ),
                textAlign: TextAlign.center,
              ),
            if (title != null && message != null)
              const SizedBox(height: AppDimens.spacingS),
            if (message != null)
              Text(
                message!,
                style: messageStyle ??
                    theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.6),
                    ),
                textAlign: TextAlign.center,
              ),
            if (customAction != null) ...[
              const SizedBox(height: AppDimens.spacingL),
              customAction!,
            ] else if (onAction != null && actionLabel != null) ...[
              const SizedBox(height: AppDimens.spacingL),
              BaseButton(
                label: actionLabel!,
                onPressed: onAction,
                icon: Icons.add,
                type: ButtonType.primary,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// Compact version for smaller spaces
class CompactEmptyState extends StatelessWidget {
  final String title;
  final IconData icon;
  final VoidCallback? onAction;
  final String? actionLabel;

  const CompactEmptyState({
    super.key,
    required this.title,
    required this.icon,
    this.onAction,
    this.actionLabel,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(AppDimens.spacingL),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 32,
            color: theme.colorScheme.onSurface.withOpacity(0.4),
          ),
          const SizedBox(height: AppDimens.spacingS),
          Text(
            title,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.6),
            ),
            textAlign: TextAlign.center,
          ),
          if (onAction != null && actionLabel != null) ...[
            const SizedBox(height: AppDimens.spacingM),
            BaseButton(
              label: actionLabel!,
              onPressed: onAction,
              type: ButtonType.text,
              size: ButtonSize.small,
            ),
          ],
        ],
      ),
    );
  }
}