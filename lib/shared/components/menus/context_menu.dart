// lib/shared/components/menus/context_menu.dart
import 'package:flutter/material.dart';
import 'package:dm_assistant/core/constants/dimens.dart';

enum ContextMenuStyle { dropdown, popup, inline }

class ContextMenu extends StatelessWidget {
  final List<ContextMenuItem> items;
  final Widget child;
  final ContextMenuStyle style;
  final EdgeInsets padding;
  final double? width;
  final Color? backgroundColor;
  final double elevation;
  final BorderRadius? borderRadius;

  const ContextMenu({
    super.key,
    required this.items,
    required this.child,
    this.style = ContextMenuStyle.dropdown,
    this.padding = const EdgeInsets.symmetric(vertical: AppDimens.spacingS),
    this.width,
    this.backgroundColor,
    this.elevation = 8,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    switch (style) {
      case ContextMenuStyle.dropdown:
        return _buildDropdownMenu(context);
      case ContextMenuStyle.popup:
        return _buildPopupMenu(context);
      case ContextMenuStyle.inline:
        return _buildInlineMenu(context);
    }
  }

  Widget _buildDropdownMenu(BuildContext context) {
    return PopupMenuButton<String>(
      itemBuilder: (context) => items.map<PopupMenuEntry<String>>((item) {
        if (item.isDivider) {
          return const PopupMenuDivider();
        }
        
        return PopupMenuItem<String>(
          value: item.id,
          enabled: item.enabled,
          child: _ContextMenuTile(item: item),
        );
      }).toList(),
      onSelected: (value) {
        final item = items.firstWhere((item) => item.id == value);
        item.onPressed?.call();
      },
      child: child,
      padding: padding,
      elevation: elevation,
      color: backgroundColor,
      shape: RoundedRectangleBorder(
        borderRadius: borderRadius ?? BorderRadius.circular(AppDimens.radiusM),
      ),
    );
  }

  Widget _buildPopupMenu(BuildContext context) {
    return GestureDetector(
      onSecondaryTapUp: (details) => _showPopupMenu(context, details.globalPosition),
      onLongPress: () => _showPopupMenu(context, null),
      child: child,
    );
  }

  Widget _buildInlineMenu(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: items.where((item) => !item.isDivider).take(3).map((item) {
        return Padding(
          padding: const EdgeInsets.only(right: AppDimens.spacingXS),
          child: IconButton(
            icon: Icon(item.icon),
            onPressed: item.enabled ? item.onPressed : null,
            tooltip: item.title,
            iconSize: 20,
          ),
        );
      }).toList(),
    );
  }

  void _showPopupMenu(BuildContext context, Offset? position) async {
    final RenderBox overlay = Overlay.of(context).context.findRenderObject() as RenderBox;
    final RenderBox button = context.findRenderObject() as RenderBox;
    final Offset targetPosition = position ?? 
        button.localToGlobal(button.size.center(Offset.zero));

    await showMenu<String>(
      context: context,
      position: RelativeRect.fromLTRB(
        targetPosition.dx,
        targetPosition.dy,
        overlay.size.width - targetPosition.dx,
        overlay.size.height - targetPosition.dy,
      ),
      items: items.map<PopupMenuEntry<String>>((item) {
        if (item.isDivider) {
          return const PopupMenuDivider();
        }
        
        return PopupMenuItem<String>(
          value: item.id,
          enabled: item.enabled,
          child: _ContextMenuTile(item: item),
        );
      }).toList(),
      elevation: elevation,
      color: backgroundColor,
      shape: RoundedRectangleBorder(
        borderRadius: borderRadius ?? BorderRadius.circular(AppDimens.radiusM),
      ),
    ).then((value) {
      if (value != null) {
        final item = items.firstWhere((item) => item.id == value);
        item.onPressed?.call();
      }
    });
  }
}

class _ContextMenuTile extends StatelessWidget {
  final ContextMenuItem item;

  const _ContextMenuTile({required this.item});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (item.icon != null) ...[
          Icon(
            item.icon,
            size: 20,
            color: item.isDestructive
                ? theme.colorScheme.error
                : theme.colorScheme.onSurface.withOpacity(item.enabled ? 1 : 0.38),
          ),
          const SizedBox(width: AppDimens.spacingM),
        ],
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                item.title,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: item.isDestructive
                      ? theme.colorScheme.error
                      : theme.colorScheme.onSurface.withOpacity(item.enabled ? 1 : 0.38),
                  fontWeight: item.isDestructive ? FontWeight.w500 : FontWeight.normal,
                ),
              ),
              if (item.subtitle != null) ...[
                const SizedBox(height: 2),
                Text(
                  item.subtitle!,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.6),
                  ),
                ),
              ],
            ],
          ),
        ),
        if (item.shortcut != null) ...[
          const SizedBox(width: AppDimens.spacingM),
          Text(
            item.shortcut!,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.6),
            ),
          ),
        ],
        if (item.trailing != null) ...[
          const SizedBox(width: AppDimens.spacingM),
          item.trailing!,
        ],
      ],
    );
  }
}

class ContextMenuItem {
  final String id;
  final String title;
  final String? subtitle;
  final IconData? icon;
  final String? shortcut;
  final Widget? trailing;
  final VoidCallback? onPressed;
  final bool enabled;
  final bool isDestructive;
  final bool isDivider;

  const ContextMenuItem({
    required this.id,
    required this.title,
    this.subtitle,
    this.icon,
    this.shortcut,
    this.trailing,
    this.onPressed,
    this.enabled = true,
    this.isDestructive = false,
    this.isDivider = false,
  });

  // Divider constructor
  const ContextMenuItem.divider()
      : id = '',
        title = '',
        subtitle = null,
        icon = null,
        shortcut = null,
        trailing = null,
        onPressed = null,
        enabled = true,
        isDestructive = false,
        isDivider = true;

  // Convenience constructors
  factory ContextMenuItem.edit({
    required VoidCallback onPressed,
    String title = 'Edit',
    String? shortcut,
  }) {
    return ContextMenuItem(
      id: 'edit',
      title: title,
      icon: Icons.edit,
      shortcut: shortcut,
      onPressed: onPressed,
    );
  }

  factory ContextMenuItem.delete({
    required VoidCallback onPressed,
    String title = 'Delete',
    String? shortcut,
  }) {
    return ContextMenuItem(
      id: 'delete',
      title: title,
      icon: Icons.delete,
      shortcut: shortcut,
      onPressed: onPressed,
      isDestructive: true,
    );
  }

  factory ContextMenuItem.copy({
    required VoidCallback onPressed,
    String title = 'Copy',
    String? shortcut = 'Ctrl+C',
  }) {
    return ContextMenuItem(
      id: 'copy',
      title: title,
      icon: Icons.copy,
      shortcut: shortcut,
      onPressed: onPressed,
    );
  }

  factory ContextMenuItem.duplicate({
    required VoidCallback onPressed,
    String title = 'Duplicate',
    String? shortcut,
  }) {
    return ContextMenuItem(
      id: 'duplicate',
      title: title,
      icon: Icons.content_copy,
      shortcut: shortcut,
      onPressed: onPressed,
    );
  }

  factory ContextMenuItem.share({
    required VoidCallback onPressed,
    String title = 'Share',
    String? shortcut,
  }) {
    return ContextMenuItem(
      id: 'share',
      title: title,
      icon: Icons.share,
      shortcut: shortcut,
      onPressed: onPressed,
    );
  }

  factory ContextMenuItem.favorite({
    required VoidCallback onPressed,
    required bool isFavorite,
    String? shortcut,
  }) {
    return ContextMenuItem(
      id: 'favorite',
      title: isFavorite ? 'Remove from Favorites' : 'Add to Favorites',
      icon: isFavorite ? Icons.favorite : Icons.favorite_border,
      shortcut: shortcut,
      onPressed: onPressed,
    );
  }

  factory ContextMenuItem.info({
    required VoidCallback onPressed,
    String title = 'Info',
    String? shortcut,
  }) {
    return ContextMenuItem(
      id: 'info',
      title: title,
      icon: Icons.info_outline,
      shortcut: shortcut,
      onPressed: onPressed,
    );
  }
}

// Quick context menu for common actions
class QuickContextMenu extends StatelessWidget {
  final VoidCallback? onEdit;
  final VoidCallback? onDuplicate;
  final VoidCallback? onShare;
  final VoidCallback? onDelete;
  final VoidCallback? onFavorite;
  final bool isFavorite;
  final Widget child;
  final ContextMenuStyle style;

  const QuickContextMenu({
    super.key,
    required this.child,
    this.onEdit,
    this.onDuplicate,
    this.onShare,
    this.onDelete,
    this.onFavorite,
    this.isFavorite = false,
    this.style = ContextMenuStyle.dropdown,
  });

  @override
  Widget build(BuildContext context) {
    final items = <ContextMenuItem>[];

    if (onEdit != null) items.add(ContextMenuItem.edit(onPressed: onEdit!));
    if (onDuplicate != null) items.add(ContextMenuItem.duplicate(onPressed: onDuplicate!));
    if (onShare != null) items.add(ContextMenuItem.share(onPressed: onShare!));
    if (onFavorite != null) {
      items.add(ContextMenuItem.favorite(
        onPressed: onFavorite!,
        isFavorite: isFavorite,
      ));
    }

    if (onDelete != null) {
      if (items.isNotEmpty) items.add(const ContextMenuItem.divider());
      items.add(ContextMenuItem.delete(onPressed: onDelete!));
    }

    return ContextMenu(
      items: items,
      style: style,
      child: child,
    );
  }
}

// D&D specific context menus
class CampaignContextMenu extends StatelessWidget {
  final Widget child;
  final VoidCallback? onEdit;
  final VoidCallback? onDuplicate;
  final VoidCallback? onExport;
  final VoidCallback? onArchive;
  final VoidCallback? onDelete;
  final bool isArchived;

  const CampaignContextMenu({
    super.key,
    required this.child,
    this.onEdit,
    this.onDuplicate,
    this.onExport,
    this.onArchive,
    this.onDelete,
    this.isArchived = false,
  });

  @override
  Widget build(BuildContext context) {
    final items = <ContextMenuItem>[
      if (onEdit != null) ContextMenuItem.edit(onPressed: onEdit!),
      if (onDuplicate != null) ContextMenuItem.duplicate(onPressed: onDuplicate!),
      if (onExport != null)
        ContextMenuItem(
          id: 'export',
          title: 'Export',
          icon: Icons.download,
          onPressed: onExport!,
        ),
      if (onArchive != null)
        ContextMenuItem(
          id: 'archive',
          title: isArchived ? 'Unarchive' : 'Archive',
          icon: isArchived ? Icons.unarchive : Icons.archive,
          onPressed: onArchive!,
        ),
      if (onDelete != null) ...[
        const ContextMenuItem.divider(),
        ContextMenuItem.delete(onPressed: onDelete!),
      ],
    ];

    return ContextMenu(
      items: items,
      child: child,
    );
  }
}

class CharacterContextMenu extends StatelessWidget {
  final Widget child;
  final VoidCallback? onEdit;
  final VoidCallback? onDuplicate;
  final VoidCallback? onAddToParty;
  final VoidCallback? onRemoveFromParty;
  final VoidCallback? onLevelUp;
  final VoidCallback? onExport;
  final VoidCallback? onDelete;
  final bool inParty;

  const CharacterContextMenu({
    super.key,
    required this.child,
    this.onEdit,
    this.onDuplicate,
    this.onAddToParty,
    this.onRemoveFromParty,
    this.onLevelUp,
    this.onExport,
    this.onDelete,
    this.inParty = false,
  });

  @override
  Widget build(BuildContext context) {
    final items = <ContextMenuItem>[
      if (onEdit != null) ContextMenuItem.edit(onPressed: onEdit!),
      if (onLevelUp != null)
        ContextMenuItem(
          id: 'levelup',
          title: 'Level Up',
          icon: Icons.trending_up,
          onPressed: onLevelUp!,
        ),
      if (onDuplicate != null) ContextMenuItem.duplicate(onPressed: onDuplicate!),
      if (onAddToParty != null && !inParty)
        ContextMenuItem(
          id: 'addtoparty',
          title: 'Add to Party',
          icon: Icons.group_add,
          onPressed: onAddToParty!,
        ),
      if (onRemoveFromParty != null && inParty)
        ContextMenuItem(
          id: 'removefromparty',
          title: 'Remove from Party',
          icon: Icons.group_remove,
          onPressed: onRemoveFromParty!,
        ),
      if (onExport != null)
        ContextMenuItem(
          id: 'export',
          title: 'Export',
          icon: Icons.download,
          onPressed: onExport!,
        ),
      if (onDelete != null) ...[
        const ContextMenuItem.divider(),
        ContextMenuItem.delete(onPressed: onDelete!),
      ],
    ];

    return ContextMenu(
      items: items,
      child: child,
    );
  }
}

class SessionContextMenu extends StatelessWidget {
  final Widget child;
  final VoidCallback? onEdit;
  final VoidCallback? onDuplicate;
  final VoidCallback? onStart;
  final VoidCallback? onPause;
  final VoidCallback? onEnd;
  final VoidCallback? onExportNotes;
  final VoidCallback? onDelete;
  final bool isActive;
  final bool isPaused;

  const SessionContextMenu({
    super.key,
    required this.child,
    this.onEdit,
    this.onDuplicate,
    this.onStart,
    this.onPause,
    this.onEnd,
    this.onExportNotes,
    this.onDelete,
    this.isActive = false,
    this.isPaused = false,
  });

  @override
  Widget build(BuildContext context) {
    final items = <ContextMenuItem>[
      if (onStart != null && !isActive)
        ContextMenuItem(
          id: 'start',
          title: 'Start Session',
          icon: Icons.play_arrow,
          onPressed: onStart!,
        ),
      if (onPause != null && isActive && !isPaused)
        ContextMenuItem(
          id: 'pause',
          title: 'Pause Session',
          icon: Icons.pause,
          onPressed: onPause!,
        ),
      if (onStart != null && isActive && isPaused)
        ContextMenuItem(
          id: 'resume',
          title: 'Resume Session',
          icon: Icons.play_arrow,
          onPressed: onStart!,
        ),
      if (onEnd != null && isActive)
        ContextMenuItem(
          id: 'end',
          title: 'End Session',
          icon: Icons.stop,
          onPressed: onEnd!,
        ),
      if (onEdit != null) ContextMenuItem.edit(onPressed: onEdit!),
      if (onDuplicate != null) ContextMenuItem.duplicate(onPressed: onDuplicate!),
      if (onExportNotes != null)
        ContextMenuItem(
          id: 'exportnotes',
          title: 'Export Notes',
          icon: Icons.download,
          onPressed: onExportNotes!,
        ),
      if (onDelete != null) ...[
        const ContextMenuItem.divider(),
        ContextMenuItem.delete(onPressed: onDelete!),
      ],
    ];

    return ContextMenu(
      items: items,
      child: child,
    );
  }
}