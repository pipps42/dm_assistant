// lib/shared/components/tiles/entity_list_tile.dart
import 'package:flutter/material.dart';
import 'package:dm_assistant/core/constants/dimens.dart';
import 'package:dm_assistant/shared/components/buttons/base_button.dart';

enum EntityTileVariant { standard, compact, detailed }

class EntityListTile extends StatelessWidget {
  final String title;
  final String? subtitle;
  final String? description;
  final Widget? leading;
  final String? imageUrl;
  final IconData? fallbackIcon;
  final List<Widget>? badges;
  final Map<String, String>? metadata;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final VoidCallback? onFavorite;
  final List<EntityAction>? customActions;
  final bool showActions;
  final bool isFavorite;
  final bool isSelected;
  final EntityTileVariant variant;
  final EdgeInsets? contentPadding;

  const EntityListTile({
    super.key,
    required this.title,
    this.subtitle,
    this.description,
    this.leading,
    this.imageUrl,
    this.fallbackIcon,
    this.badges,
    this.metadata,
    this.onTap,
    this.onEdit,
    this.onDelete,
    this.onFavorite,
    this.customActions,
    this.showActions = true,
    this.isFavorite = false,
    this.isSelected = false,
    this.variant = EntityTileVariant.standard,
    this.contentPadding,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: isSelected ? 4 : 1,
      color: isSelected ? theme.colorScheme.primaryContainer : null,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppDimens.radiusM),
        child: Padding(
          padding: contentPadding ?? const EdgeInsets.all(AppDimens.spacingM),
          child: _buildContent(context, theme),
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context, ThemeData theme) {
    switch (variant) {
      case EntityTileVariant.compact:
        return _buildCompactContent(theme);
      case EntityTileVariant.detailed:
        return _buildDetailedContent(theme);
      case EntityTileVariant.standard:
        return _buildStandardContent(theme);
    }
  }

  Widget _buildStandardContent(ThemeData theme) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (leading != null || imageUrl != null || fallbackIcon != null) ...[
          _buildLeading(theme),
          const SizedBox(width: AppDimens.spacingM),
        ],
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(theme),
              if (subtitle != null) ...[
                const SizedBox(height: 4),
                _buildSubtitle(theme),
              ],
              if (description != null) ...[
                const SizedBox(height: AppDimens.spacingS),
                _buildDescription(theme),
              ],
              if (badges != null && badges!.isNotEmpty) ...[
                const SizedBox(height: AppDimens.spacingS),
                _buildBadges(),
              ],
              if (metadata != null && metadata!.isNotEmpty) ...[
                const SizedBox(height: AppDimens.spacingS),
                _buildMetadata(theme),
              ],
            ],
          ),
        ),
        if (showActions) _buildActions(theme),
      ],
    );
  }

  Widget _buildCompactContent(ThemeData theme) {
    return Row(
      children: [
        if (leading != null || imageUrl != null || fallbackIcon != null) ...[
          _buildLeading(theme, size: 40),
          const SizedBox(width: AppDimens.spacingS),
        ],
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(theme),
              if (subtitle != null) _buildSubtitle(theme),
            ],
          ),
        ),
        if (badges != null && badges!.isNotEmpty) ...[
          const SizedBox(width: AppDimens.spacingS),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: badges!.take(2).toList(),
          ),
        ],
        if (showActions) _buildActions(theme, compact: true),
      ],
    );
  }

  Widget _buildDetailedContent(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (leading != null ||
                imageUrl != null ||
                fallbackIcon != null) ...[
              _buildLeading(theme, size: 80),
              const SizedBox(width: AppDimens.spacingM),
            ],
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(theme),
                  if (subtitle != null) ...[
                    const SizedBox(height: 4),
                    _buildSubtitle(theme),
                  ],
                ],
              ),
            ),
            if (showActions) _buildActions(theme),
          ],
        ),
        if (description != null) ...[
          const SizedBox(height: AppDimens.spacingM),
          _buildDescription(theme),
        ],
        if (badges != null && badges!.isNotEmpty) ...[
          const SizedBox(height: AppDimens.spacingM),
          _buildBadges(),
        ],
        if (metadata != null && metadata!.isNotEmpty) ...[
          const SizedBox(height: AppDimens.spacingM),
          _buildMetadata(theme),
        ],
      ],
    );
  }

  Widget _buildLeading(ThemeData theme, {double size = 56}) {
    if (leading != null)
      return SizedBox(width: size, height: size, child: leading!);

    if (imageUrl != null) {
      return Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppDimens.radiusS),
          image: DecorationImage(
            image: NetworkImage(imageUrl!),
            fit: BoxFit.cover,
          ),
        ),
      );
    }

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: theme.colorScheme.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppDimens.radiusS),
      ),
      child: Icon(
        fallbackIcon ?? Icons.auto_awesome,
        color: theme.colorScheme.primary,
        size: size * 0.5,
      ),
    );
  }

  Widget _buildHeader(ThemeData theme) {
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: isSelected ? theme.colorScheme.onPrimaryContainer : null,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        if (isFavorite)
          Icon(Icons.favorite, size: 16, color: theme.colorScheme.error),
      ],
    );
  }

  Widget _buildSubtitle(ThemeData theme) {
    return Text(
      subtitle!,
      style: theme.textTheme.bodyMedium?.copyWith(
        color:
            (isSelected
                    ? theme.colorScheme.onPrimaryContainer
                    : theme.colorScheme.onSurface)
                .withOpacity(0.7),
      ),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget _buildDescription(ThemeData theme) {
    return Text(
      description!,
      style: theme.textTheme.bodySmall?.copyWith(
        color:
            (isSelected
                    ? theme.colorScheme.onPrimaryContainer
                    : theme.colorScheme.onSurface)
                .withOpacity(0.8),
      ),
      maxLines: variant == EntityTileVariant.detailed ? 4 : 2,
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget _buildBadges() {
    return Wrap(
      spacing: AppDimens.spacingXS,
      runSpacing: AppDimens.spacingXS,
      children: badges!,
    );
  }

  Widget _buildMetadata(ThemeData theme) {
    return Wrap(
      spacing: AppDimens.spacingM,
      runSpacing: AppDimens.spacingXS,
      children: metadata!.entries.map((entry) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              _getMetadataIcon(entry.key),
              size: 14,
              color:
                  (isSelected
                          ? theme.colorScheme.onPrimaryContainer
                          : theme.colorScheme.onSurface)
                      .withOpacity(0.5),
            ),
            const SizedBox(width: 4),
            Text(
              entry.value,
              style: theme.textTheme.bodySmall?.copyWith(
                color:
                    (isSelected
                            ? theme.colorScheme.onPrimaryContainer
                            : theme.colorScheme.onSurface)
                        .withOpacity(0.7),
              ),
            ),
          ],
        );
      }).toList(),
    );
  }

  Widget _buildActions(ThemeData theme, {bool compact = false}) {
    final actions = <Widget>[];

    if (onFavorite != null) {
      actions.add(
        BaseIconButton(
          icon: isFavorite ? Icons.favorite : Icons.favorite_border,
          onPressed: onFavorite,
          type: ButtonType.text,
          size: compact ? ButtonSize.small : ButtonSize.medium,
          tooltip: isFavorite ? 'Remove from favorites' : 'Add to favorites',
        ),
      );
    }

    if (customActions != null) {
      for (final action in customActions!) {
        actions.add(
          BaseIconButton(
            icon: action.icon,
            onPressed: action.onPressed,
            type: ButtonType.text,
            size: compact ? ButtonSize.small : ButtonSize.medium,
            tooltip: action.tooltip,
          ),
        );
      }
    }

    if (onEdit != null || onDelete != null) {
      actions.add(
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
                  title: Text('Delete', style: TextStyle(color: Colors.red)),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
          ],
          onSelected: (value) {
            if (value == 'edit') onEdit?.call();
            if (value == 'delete') onDelete?.call();
          },
          icon: Icon(Icons.more_vert, size: compact ? 20 : 24),
        ),
      );
    }

    if (actions.isEmpty) return const SizedBox();

    return Row(mainAxisSize: MainAxisSize.min, children: actions);
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
      case 'party':
        return Icons.group;
      case 'level':
        return Icons.star;
      case 'hp':
      case 'health':
        return Icons.favorite;
      case 'ac':
      case 'armor':
        return Icons.shield;
      case 'cr':
      case 'challenge':
        return Icons.warning;
      default:
        return Icons.info_outline;
    }
  }
}

// Action class for custom actions
class EntityAction {
  final String tooltip;
  final IconData icon;
  final VoidCallback onPressed;
  final Color? color;

  const EntityAction({
    required this.tooltip,
    required this.icon,
    required this.onPressed,
    this.color,
  });
}

// Specialized tiles for D&D entities
class CampaignListTile extends EntityListTile {
  CampaignListTile({
    super.key,
    required String title,
    String? description,
    DateTime? createdAt,
    DateTime? lastPlayed,
    int? playerCount,
    super.onTap,
    super.onEdit,
    super.onDelete,
    super.onFavorite,
    super.isFavorite = false,
    super.isSelected = false,
  }) : super(
         title: title,
         description: description,
         fallbackIcon: Icons.campaign,
         metadata: {
           if (createdAt != null) 'created': _formatDate(createdAt),
           if (lastPlayed != null) 'last played': _formatDate(lastPlayed),
           if (playerCount != null) 'players': playerCount.toString(),
         },
       );

  static String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) return 'Today';
    if (difference.inDays == 1) return 'Yesterday';
    if (difference.inDays < 7) return '${difference.inDays} days ago';
    if (difference.inDays < 30)
      return '${(difference.inDays / 7).floor()} weeks ago';
    return '${date.day}/${date.month}/${date.year}';
  }
}

class CharacterListTile extends EntityListTile {
  CharacterListTile({
    super.key,
    required String name,
    String? characterClass,
    int? level,
    String? race,
    String? imageUrl,
    super.onTap,
    super.onEdit,
    super.onDelete,
    super.onFavorite,
    super.isFavorite = false,
    super.isSelected = false,
  }) : super(
         title: name,
         subtitle: characterClass != null && level != null
             ? 'Level $level $characterClass'
             : characterClass ?? race,
         imageUrl: imageUrl,
         fallbackIcon: Icons.person,
         metadata: {
           if (race != null && characterClass != null) 'race': race,
           if (level != null) 'level': level.toString(),
         },
       );
}
