// lib/shared/components/cards/entity_card.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:dm_assistant/core/constants/dimens.dart';
import 'package:dm_assistant/shared/components/cards/entity_display_config.dart';

enum EntityCardLayout { list, grid }

/// Universal card component for displaying any type of entity
/// Uses EntityDisplayConfig to customize rendering for different entity types
class EntityCard<T> extends StatelessWidget {
  final T entity;
  final EntityDisplayConfig<T> config;
  final EntityCardLayout layout;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final bool isSelected;
  final Color? selectionColor;
  final double aspectRatio;

  const EntityCard({
    super.key,
    required this.entity,
    required this.config,
    this.layout = EntityCardLayout.list,
    this.onTap,
    this.onEdit,
    this.onDelete,
    this.isSelected = false,
    this.selectionColor,
    this.aspectRatio = 5 / 4,
  });

  // Factory constructors for convenience
  const EntityCard.list({
    super.key,
    required this.entity,
    required this.config,
    this.onTap,
    this.onEdit,
    this.onDelete,
    this.isSelected = false,
    this.selectionColor,
  }) : layout = EntityCardLayout.list,
       aspectRatio = 1.0;

  const EntityCard.grid({
    super.key,
    required this.entity,
    required this.config,
    this.onTap,
    this.onEdit,
    this.onDelete,
    this.isSelected = false,
    this.selectionColor,
    this.aspectRatio = 5 / 4,
  }) : layout = EntityCardLayout.grid;

  @override
  Widget build(BuildContext context) {
    return layout == EntityCardLayout.grid 
        ? _buildGridCard(context)
        : _buildListCard(context);
  }

  Widget _buildListCard(BuildContext context) {
    final theme = Theme.of(context);
    final selectedColor = selectionColor ?? theme.colorScheme.primary;
    final title = config.titleExtractor(entity);
    final subtitle = config.subtitleExtractor?.call(entity);
    final imagePath = config.imagePathExtractor?.call(entity);
    final badges = config.badgesBuilder?.call(entity, context) ?? [];
    final metadata = config.metadataExtractor?.call(entity) ?? {};
    
    return Card(
      elevation: isSelected ? AppDimens.elevationM : AppDimens.elevationS,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimens.radiusM),
        side: isSelected 
          ? BorderSide(color: selectedColor, width: 2)
          : BorderSide.none,
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppDimens.radiusM),
        child: Padding(
          padding: const EdgeInsets.all(AppDimens.spacingM),
          child: Row(
            children: [
              _buildListAvatar(context, imagePath),
              const SizedBox(width: AppDimens.spacingM),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (subtitle != null && subtitle.isNotEmpty) ...[
                      const SizedBox(height: AppDimens.spacingXS),
                      Text(
                        subtitle,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurface.withOpacity(0.7),
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                    if (badges.isNotEmpty) ...[
                      const SizedBox(height: AppDimens.spacingXS),
                      Wrap(
                        spacing: AppDimens.spacingXS,
                        runSpacing: AppDimens.spacingXS,
                        children: badges,
                      ),
                    ],
                  ],
                ),
              ),
              if (metadata.isNotEmpty) ...[
                const SizedBox(width: AppDimens.spacingS),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: metadata.entries.map((entry) => 
                    Padding(
                      padding: const EdgeInsets.only(bottom: 2),
                      child: Text(
                        entry.value,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurface.withOpacity(0.6),
                        ),
                      ),
                    ),
                  ).toList(),
                ),
              ],
              if (isSelected) ...[
                const SizedBox(width: AppDimens.spacingS),
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: selectedColor,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check,
                    color: Colors.white,
                    size: 16,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGridCard(BuildContext context) {
    final theme = Theme.of(context);
    final selectedColor = selectionColor ?? theme.colorScheme.primary;
    final title = config.titleExtractor(entity);
    final subtitle = config.subtitleExtractor?.call(entity);
    final imagePath = config.imagePathExtractor?.call(entity);
    final details = config.detailsBuilder?.call(entity, context) ?? [];
    final fallbackColor = config.fallbackColorExtractor?.call(entity, context) 
        ?? theme.colorScheme.surfaceContainerHighest;
    final actions = config.actionsBuilder?.call(
      entity, 
      context, 
      onEdit ?? () {}, 
      onDelete ?? () {}
    ) ?? [];

    return Card(
      clipBehavior: Clip.antiAlias,
      elevation: isSelected ? AppDimens.elevationM : AppDimens.elevationS,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimens.radiusM),
        side: isSelected 
          ? BorderSide(color: selectedColor, width: 3)
          : BorderSide.none,
      ),
      child: InkWell(
        onTap: onTap,
        child: AspectRatio(
          aspectRatio: aspectRatio,
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Background image or fallback
              _buildGridBackground(context, imagePath, fallbackColor),
              
              // Gradient overlay
              _buildGradientOverlay(),
              
              // Content
              _buildGridContent(context, title, subtitle, details),
              
              // Selection checkmark (top-left corner)
              if (isSelected)
                Positioned(
                  top: AppDimens.spacingS,
                  left: AppDimens.spacingS,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: selectedColor,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.3),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.check,
                      color: Colors.white,
                      size: 16,
                    ),
                  ),
                ),
              
              // Actions (if any)
              if (actions.isNotEmpty)
                _buildGridActions(actions),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildListAvatar(BuildContext context, String? imagePath) {
    final theme = Theme.of(context);
    
    if (imagePath == null || imagePath.isEmpty) {
      return CircleAvatar(
        radius: 24,
        backgroundColor: theme.colorScheme.primary.withOpacity(0.1),
        child: Icon(config.fallbackIcon, color: theme.colorScheme.primary),
      );
    }

    return CircleAvatar(
      radius: 24,
      backgroundImage: imagePath.startsWith('http')
          ? CachedNetworkImageProvider(imagePath)
          : FileImage(File(imagePath)) as ImageProvider,
      onBackgroundImageError: (exception, stackTrace) {},
      child: imagePath.startsWith('http')
          ? null
          : (!File(imagePath).existsSync()
              ? Icon(config.fallbackIcon, color: theme.colorScheme.primary)
              : null),
    );
  }

  Widget _buildGridBackground(BuildContext context, String? imagePath, Color fallbackColor) {
    if (imagePath != null && imagePath.isNotEmpty) {
      if (imagePath.startsWith('http')) {
        return CachedNetworkImage(
          imageUrl: imagePath,
          fit: BoxFit.cover,
          errorWidget: (context, url, error) => _buildGridFallbackBackground(fallbackColor),
          placeholder: (context, url) => _buildGridFallbackBackground(fallbackColor),
        );
      } else {
        final file = File(imagePath);
        if (file.existsSync()) {
          return Image.file(
            file,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) => _buildGridFallbackBackground(fallbackColor),
          );
        }
      }
    }
    return _buildGridFallbackBackground(fallbackColor);
  }

  Widget _buildGridFallbackBackground(Color color) {
    return Container(
      color: color,
      child: Center(
        child: Icon(
          config.fallbackIcon,
          size: 48,
          color: Colors.white.withOpacity(0.3),
        ),
      ),
    );
  }

  Widget _buildGradientOverlay() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.transparent,
            Colors.black.withOpacity(0.3),
            Colors.black.withOpacity(0.7),
          ],
          stops: const [0.0, 0.5, 1.0],
        ),
      ),
    );
  }

  Widget _buildGridContent(BuildContext context, String title, String? subtitle, List<Widget> details) {
    final theme = Theme.of(context);
    
    return Padding(
      padding: const EdgeInsets.all(AppDimens.spacingM),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Spacer(),
          
          // Title
          Text(
            title,
            style: theme.textTheme.titleMedium?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w600,
              shadows: [
                Shadow(
                  offset: const Offset(0, 1),
                  blurRadius: 2,
                  color: Colors.black.withOpacity(0.8),
                ),
              ],
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          
          // Subtitle
          if (subtitle != null && subtitle.isNotEmpty) ...[
            const SizedBox(height: AppDimens.spacingXS),
            Text(
              subtitle,
              style: theme.textTheme.bodySmall?.copyWith(
                color: Colors.white.withOpacity(0.9),
                shadows: [
                  Shadow(
                    offset: const Offset(0, 1),
                    blurRadius: 2,
                    color: Colors.black.withOpacity(0.8),
                  ),
                ],
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
          
          // Details
          if (details.isNotEmpty) ...[
            const SizedBox(height: AppDimens.spacingS),
            ...details.map((detail) => Padding(
              padding: const EdgeInsets.only(bottom: AppDimens.spacingXS),
              child: detail,
            )),
          ],
        ],
      ),
    );
  }

  Widget _buildGridActions(List<Widget> actions) {
    return Positioned(
      top: AppDimens.spacingS,
      right: AppDimens.spacingS,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.3),
          borderRadius: BorderRadius.circular(AppDimens.radiusM),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: actions,
        ),
      ),
    );
  }
}