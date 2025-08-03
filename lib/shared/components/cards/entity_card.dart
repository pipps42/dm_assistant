// lib/shared/components/cards/entity_card.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:dm_assistant/core/constants/dimens.dart';

enum EntityCardLayout { list, grid }

class EntityCard extends StatelessWidget {
  final String title;
  final String? subtitle;
  final String? imagePath;
  final List<Widget> details;
  final List<Widget>? actions;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final EntityCardLayout layout;
  final double aspectRatio;
  final Color? fallbackColor;
  final bool showMenu;
  final List<PopupMenuEntry>? menuItems;

  const EntityCard({
    super.key,
    required this.title,
    this.subtitle,
    this.imagePath,
    this.details = const [],
    this.actions,
    this.onTap,
    this.onLongPress,
    this.layout = EntityCardLayout.list,
    this.aspectRatio = 5 / 4, // Default 5:4 ratio for grid
    this.fallbackColor,
    this.showMenu = false,
    this.menuItems,
  });

  // Factory constructors for convenience
  const EntityCard.list({
    super.key,
    required this.title,
    this.subtitle,
    this.imagePath,
    this.details = const [],
    this.onTap,
    this.onLongPress,
    this.showMenu = false,
    this.menuItems,
  }) : layout = EntityCardLayout.list,
       actions = null,
       aspectRatio = 1.0,
       fallbackColor = null;

  const EntityCard.grid({
    super.key,
    required this.title,
    this.subtitle,
    this.imagePath,
    this.details = const [],
    this.actions,
    this.onTap,
    this.onLongPress,
    this.aspectRatio = 5 / 4,
    this.fallbackColor,
  }) : layout = EntityCardLayout.grid,
       showMenu = false,
       menuItems = null;

  @override
  Widget build(BuildContext context) {
    return layout == EntityCardLayout.grid 
        ? _buildGridCard(context)
        : _buildListCard(context);
  }

  Widget _buildListCard(BuildContext context) {
    final theme = Theme.of(context);
    
    return Card(
      elevation: AppDimens.elevationS,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimens.radiusM),
      ),
      child: InkWell(
        onTap: onTap,
        onLongPress: onLongPress,
        borderRadius: BorderRadius.circular(AppDimens.radiusM),
        child: Padding(
          padding: const EdgeInsets.all(AppDimens.spacingM),
          child: Row(
            children: [
              _buildListAvatar(context),
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
                    if (subtitle != null && subtitle!.isNotEmpty) ...[
                      const SizedBox(height: AppDimens.spacingXS),
                      Text(
                        subtitle!,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurface.withOpacity(0.7),
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                    if (details.isNotEmpty) ...[
                      const SizedBox(height: AppDimens.spacingXS),
                      ...details,
                    ],
                  ],
                ),
              ),
              if (showMenu && menuItems != null)
                PopupMenuButton(
                  itemBuilder: (context) => menuItems!,
                  icon: const Icon(Icons.more_vert),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGridCard(BuildContext context) {
    final theme = Theme.of(context);
    final fallback = fallbackColor ?? theme.colorScheme.surfaceContainerHighest;

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        onLongPress: onLongPress,
        child: AspectRatio(
          aspectRatio: aspectRatio,
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Background image or fallback
              _buildGridBackground(context, fallback),
              
              // Gradient overlay
              _buildGradientOverlay(),
              
              // Content
              _buildGridContent(context),
              
              // Actions (if any)
              if (actions != null && actions!.isNotEmpty)
                _buildGridActions(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildListAvatar(BuildContext context) {
    final theme = Theme.of(context);
    
    if (imagePath == null || imagePath!.isEmpty) {
      return CircleAvatar(
        radius: 24,
        backgroundColor: theme.colorScheme.primary.withOpacity(0.1),
        child: Icon(Icons.person, color: theme.colorScheme.primary),
      );
    }

    return CircleAvatar(
      radius: 24,
      backgroundImage: imagePath!.startsWith('http')
          ? CachedNetworkImageProvider(imagePath!)
          : FileImage(File(imagePath!)) as ImageProvider,
    );
  }

  Widget _buildGridBackground(BuildContext context, Color fallback) {
    if (imagePath != null && imagePath!.isNotEmpty) {
      return Image.file(
        File(imagePath!),
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => _buildGridFallbackBackground(fallback),
      );
    }
    return _buildGridFallbackBackground(fallback);
  }

  Widget _buildGridFallbackBackground(Color color) {
    return Container(
      color: color,
      child: Center(
        child: Icon(
          Icons.image_outlined,
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

  Widget _buildGridContent(BuildContext context) {
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
          if (subtitle != null && subtitle!.isNotEmpty) ...[
            const SizedBox(height: AppDimens.spacingXS),
            Text(
              subtitle!,
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
              child: DefaultTextStyle(
                style: theme.textTheme.bodySmall?.copyWith(
                  color: Colors.white.withOpacity(0.8),
                  shadows: [
                    Shadow(
                      offset: const Offset(0, 1),
                      blurRadius: 2,
                      color: Colors.black.withOpacity(0.8),
                    ),
                  ],
                ) ?? const TextStyle(),
                child: detail,
              ),
            )),
          ],
        ],
      ),
    );
  }

  Widget _buildGridActions(BuildContext context) {
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
          children: actions!,
        ),
      ),
    );
  }
}