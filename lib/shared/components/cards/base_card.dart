// lib/shared/components/cards/base_card.dart
import 'package:flutter/material.dart';
import 'package:dm_assistant/core/constants/dimens.dart';
import 'package:dm_assistant/shared/components/buttons/base_button.dart';

enum CardVariant { elevated, outlined, filled }

class BaseCard extends StatelessWidget {
  final Widget? header;
  final Widget content;
  final Widget? footer;
  final CardVariant variant;
  final EdgeInsets? padding;
  final EdgeInsets? margin;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final List<CardAction>? actions;
  final bool selected;
  final double? width;
  final double? height;

  const BaseCard({
    super.key,
    required this.content,
    this.header,
    this.footer,
    this.variant = CardVariant.elevated,
    this.padding,
    this.margin,
    this.onTap,
    this.onLongPress,
    this.actions,
    this.selected = false,
    this.width,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    Widget card = Container(
      width: width,
      height: height,
      margin: margin,
      decoration: _getDecoration(theme),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          onLongPress: onLongPress,
          borderRadius: BorderRadius.circular(AppDimens.radiusL),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (header != null) ...[
                Container(
                  padding: padding ?? const EdgeInsets.all(AppDimens.spacingM),
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(
                        color: theme.dividerColor.withOpacity(0.1),
                      ),
                    ),
                  ),
                  child: header!,
                ),
              ],
              Flexible(
                child: Container(
                  padding: padding ?? const EdgeInsets.all(AppDimens.spacingM),
                  child: content,
                ),
              ),
              if (footer != null ||
                  (actions != null && actions!.isNotEmpty)) ...[
                Container(
                  padding: padding ?? const EdgeInsets.all(AppDimens.spacingM),
                  decoration: BoxDecoration(
                    border: Border(
                      top: BorderSide(
                        color: theme.dividerColor.withOpacity(0.1),
                      ),
                    ),
                  ),
                  child: footer ?? _buildActions(context),
                ),
              ],
            ],
          ),
        ),
      ),
    );

    if (selected) {
      card = Stack(
        children: [
          card,
          Positioned(
            top: 8,
            right: 8,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.check,
                size: 16,
                color: theme.colorScheme.onPrimary,
              ),
            ),
          ),
        ],
      );
    }

    return card;
  }

  BoxDecoration _getDecoration(ThemeData theme) {
    switch (variant) {
      case CardVariant.elevated:
        return BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(AppDimens.radiusL),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        );

      case CardVariant.outlined:
        return BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(AppDimens.radiusL),
          border: Border.all(
            color: selected
                ? theme.colorScheme.primary
                : theme.dividerColor.withOpacity(0.2),
            width: selected ? 2 : 1,
          ),
        );

      case CardVariant.filled:
        return BoxDecoration(
          color: theme.colorScheme.surfaceVariant.withOpacity(0.3),
          borderRadius: BorderRadius.circular(AppDimens.radiusL),
        );
    }
  }

  Widget _buildActions(BuildContext context) {
    if (actions == null || actions!.isEmpty) return const SizedBox();

    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: actions!.map((action) {
        final index = actions!.indexOf(action);
        return Padding(
          padding: EdgeInsets.only(left: index > 0 ? AppDimens.spacingS : 0),
          child: BaseButton(
            label: action.label,
            onPressed: action.onPressed,
            type: action.isPrimary ? ButtonType.primary : ButtonType.text,
            size: ButtonSize.small,
            icon: action.icon,
          ),
        );
      }).toList(),
    );
  }
}

class CardAction {
  final String label;
  final VoidCallback onPressed;
  final IconData? icon;
  final bool isPrimary;

  const CardAction({
    required this.label,
    required this.onPressed,
    this.icon,
    this.isPrimary = false,
  });
}

// Specialized card for displaying entities (characters, campaigns, etc.)
class EntityCard extends StatelessWidget {
  final String title;
  final String? subtitle;
  final String? description;
  final String? imageUrl;
  final Widget? leading;
  final List<Widget>? tags;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final bool showActions;
  final Map<String, String>? metadata;

  const EntityCard({
    super.key,
    required this.title,
    this.subtitle,
    this.description,
    this.imageUrl,
    this.leading,
    this.tags,
    this.onTap,
    this.onEdit,
    this.onDelete,
    this.showActions = true,
    this.metadata,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BaseCard(
      onTap: onTap,
      variant: CardVariant.elevated,
      content: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (leading != null || imageUrl != null) ...[
            _buildLeading(theme),
            const SizedBox(width: AppDimens.spacingM),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    if (showActions && (onEdit != null || onDelete != null))
                      PopupMenuButton<String>(
                        itemBuilder: (context) => [
                          if (onEdit != null)
                            const PopupMenuItem(
                              value: 'edit',
                              child: ListTile(
                                leading: Icon(Icons.edit),
                                title: Text('Edit'),
                                contentPadding: EdgeInsets.zero,
                              ),
                            ),
                          if (onDelete != null)
                            const PopupMenuItem(
                              value: 'delete',
                              child: ListTile(
                                leading: Icon(Icons.delete, color: Colors.red),
                                title: Text(
                                  'Delete',
                                  style: TextStyle(color: Colors.red),
                                ),
                                contentPadding: EdgeInsets.zero,
                              ),
                            ),
                        ],
                        onSelected: (value) {
                          if (value == 'edit') onEdit?.call();
                          if (value == 'delete') onDelete?.call();
                        },
                        icon: const Icon(Icons.more_vert),
                      ),
                  ],
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
                if (description != null) ...[
                  const SizedBox(height: AppDimens.spacingS),
                  Text(
                    description!,
                    style: theme.textTheme.bodySmall,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
                if (tags != null && tags!.isNotEmpty) ...[
                  const SizedBox(height: AppDimens.spacingM),
                  Wrap(
                    spacing: AppDimens.spacingS,
                    runSpacing: AppDimens.spacingS,
                    children: tags!,
                  ),
                ],
                if (metadata != null && metadata!.isNotEmpty) ...[
                  const SizedBox(height: AppDimens.spacingM),
                  Row(
                    children: metadata!.entries.map((entry) {
                      final index = metadata!.entries.toList().indexOf(entry);
                      return Padding(
                        padding: EdgeInsets.only(
                          right: index < metadata!.length - 1
                              ? AppDimens.spacingM
                              : 0,
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              _getMetadataIcon(entry.key),
                              size: 16,
                              color: theme.colorScheme.onSurface.withOpacity(
                                0.5,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              entry.value,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurface.withOpacity(
                                  0.7,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLeading(ThemeData theme) {
    if (leading != null) return leading!;

    if (imageUrl != null) {
      return Container(
        width: 64,
        height: 64,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppDimens.radiusM),
          image: DecorationImage(
            image: NetworkImage(imageUrl!),
            fit: BoxFit.cover,
          ),
        ),
      );
    }

    return Container(
      width: 64,
      height: 64,
      decoration: BoxDecoration(
        color: theme.colorScheme.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppDimens.radiusM),
      ),
      child: Icon(Icons.image, color: theme.colorScheme.primary),
    );
  }

  IconData _getMetadataIcon(String key) {
    switch (key.toLowerCase()) {
      case 'date':
      case 'created':
      case 'updated':
        return Icons.calendar_today;
      case 'time':
      case 'duration':
        return Icons.access_time;
      case 'location':
      case 'place':
        return Icons.location_on;
      case 'players':
      case 'members':
        return Icons.group;
      default:
        return Icons.info_outline;
    }
  }
}
