// lib/shared/components/cards/entity_display_config.dart
import 'package:flutter/material.dart';

/// Configuration class that defines how an entity should be displayed in cards
class EntityDisplayConfig<T> {
  /// Extract the main title from the entity
  final String Function(T entity) titleExtractor;
  
  /// Extract the subtitle from the entity (optional)
  final String? Function(T entity)? subtitleExtractor;
  
  /// Extract the image path from the entity (optional)
  final String? Function(T entity)? imagePathExtractor;
  
  /// Generate detail widgets for list/grid view
  final List<Widget> Function(T entity, BuildContext context)? detailsBuilder;
  
  /// Generate badge widgets for the entity
  final List<Widget> Function(T entity, BuildContext context)? badgesBuilder;
  
  /// Extract metadata as key-value pairs
  final Map<String, String> Function(T entity)? metadataExtractor;
  
  /// Get the fallback icon when no image is available
  final IconData fallbackIcon;
  
  /// Get the fallback color for the entity
  final Color? Function(T entity, BuildContext context)? fallbackColorExtractor;
  
  /// Custom actions for grid cards
  final List<Widget> Function(T entity, BuildContext context, VoidCallback onEdit, VoidCallback onDelete)? actionsBuilder;
  
  /// Context menu items
  final List<PopupMenuEntry<String>> Function(T entity, VoidCallback onEdit, VoidCallback onDelete)? contextMenuBuilder;

  const EntityDisplayConfig({
    required this.titleExtractor,
    this.subtitleExtractor,
    this.imagePathExtractor,
    this.detailsBuilder,
    this.badgesBuilder,
    this.metadataExtractor,
    this.fallbackIcon = Icons.circle,
    this.fallbackColorExtractor,
    this.actionsBuilder,
    this.contextMenuBuilder,
  });

  /// Factory method for creating display configurations for D&D entities
  factory EntityDisplayConfig.dndEntity({
    required String Function(T entity) titleExtractor,
    String? Function(T entity)? subtitleExtractor,
    String? Function(T entity)? imagePathExtractor,
    List<Widget> Function(T entity, BuildContext context)? detailsBuilder,
    List<Widget> Function(T entity, BuildContext context)? badgesBuilder,
    Map<String, String> Function(T entity)? metadataExtractor,
    IconData fallbackIcon = Icons.person,
    Color? Function(T entity, BuildContext context)? fallbackColorExtractor,
  }) {
    return EntityDisplayConfig<T>(
      titleExtractor: titleExtractor,
      subtitleExtractor: subtitleExtractor,
      imagePathExtractor: imagePathExtractor,
      detailsBuilder: detailsBuilder,
      badgesBuilder: badgesBuilder,
      metadataExtractor: metadataExtractor,
      fallbackIcon: fallbackIcon,
      fallbackColorExtractor: fallbackColorExtractor,
      actionsBuilder: _defaultActionsBuilder,
      contextMenuBuilder: _defaultContextMenuBuilder,
    );
  }

  /// Default actions builder for grid cards (edit + delete)
  static List<Widget> _defaultActionsBuilder<T>(
    T entity,
    BuildContext context,
    VoidCallback onEdit,
    VoidCallback onDelete,
  ) {
    return [
      IconButton(
        icon: const Icon(Icons.edit, color: Colors.white, size: 20),
        onPressed: onEdit,
        tooltip: 'Edit',
      ),
      IconButton(
        icon: const Icon(Icons.delete, color: Colors.white, size: 20),
        onPressed: onDelete,
        tooltip: 'Delete',
      ),
    ];
  }

  /// Default context menu builder (edit + delete)
  static List<PopupMenuEntry<String>> _defaultContextMenuBuilder<T>(
    T entity,
    VoidCallback onEdit,
    VoidCallback onDelete,
  ) {
    return [
      PopupMenuItem<String>(
        value: 'edit',
        child: ListTile(
          leading: const Icon(Icons.edit),
          title: const Text('Edit'),
          contentPadding: EdgeInsets.zero,
          onTap: onEdit,
        ),
      ),
      PopupMenuItem<String>(
        value: 'delete',
        child: ListTile(
          leading: const Icon(Icons.delete, color: Colors.red),
          title: const Text('Delete', style: TextStyle(color: Colors.red)),
          contentPadding: EdgeInsets.zero,
          onTap: onDelete,
        ),
      ),
    ];
  }
}

/// Utility class for building common detail widgets
class EntityDetailWidgetBuilder {
  /// Creates a chip with icon and label
  static Widget chip({
    required IconData icon,
    required String label,
    required Color color,
    double fontSize = 12,
    double iconSize = 16,
  }) {
    return Chip(
      avatar: Icon(icon, size: iconSize, color: color),
      label: Text(label, style: TextStyle(fontSize: fontSize, color: color)),
      backgroundColor: color.withOpacity(0.1),
      side: BorderSide(color: color.withOpacity(0.3)),
    );
  }

  /// Creates a simple detail row with icon and text
  static Widget detailRow({
    required IconData icon,
    required String text,
    Color? color,
    double iconSize = 12,
    double fontSize = 11,
  }) {
    return Builder(
      builder: (context) {
        final theme = Theme.of(context);
        final effectiveColor = color ?? Colors.white.withOpacity(0.8);
        
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: iconSize, color: effectiveColor),
            const SizedBox(width: 4),
            Flexible(
              child: Text(
                text,
                style: TextStyle(fontSize: fontSize, color: effectiveColor),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        );
      },
    );
  }

  /// Formats enum names from camelCase to Title Case
  static String formatEnumName(String enumName) {
    return enumName
        .replaceAllMapped(RegExp(r'([A-Z])'), (match) => ' ${match.group(1)}')
        .trim()
        .split(' ')
        .map((word) => word[0].toUpperCase() + word.substring(1).toLowerCase())
        .join(' ');
  }

  /// Formats date to readable string
  static String formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  /// Gets attitude color based on common D&D attitude types
  static Color getAttitudeColor(String attitude) {
    switch (attitude.toLowerCase()) {
      case 'friendly':
      case 'helpful':
        return Colors.green;
      case 'hostile':
        return Colors.red;
      case 'suspicious':
      case 'fearful':
        return Colors.orange;
      case 'neutral':
      case 'indifferent':
      case 'respectful':
      default:
        return Colors.grey;
    }
  }
}