// lib/core/widgets/entity_card.dart
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:dm_assistant/core/constants/app_colors.dart';
import 'package:dm_assistant/core/constants/dimens.dart';

class EntityCard extends StatelessWidget {
  final String name;
  final String? avatarPath;
  final List<Widget> details;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final bool showMenu;
  final List<PopupMenuEntry> menuItems;
  
  const EntityCard({
    super.key,
    required this.name,
    this.avatarPath,
    this.details = const [],
    this.onTap,
    this.onLongPress,
    this.showMenu = false,
    this.menuItems = const [],
  });

  @override
  Widget build(BuildContext context) {
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
              _buildAvatar(context),
              const SizedBox(width: AppDimens.spacingM),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (details.isNotEmpty) ...[
                      const SizedBox(height: AppDimens.spacingXS),
                      ...details,
                    ],
                  ],
                ),
              ),
              if (showMenu)
                PopupMenuButton(
                  itemBuilder: (context) => menuItems,
                  icon: const Icon(Icons.more_vert),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAvatar(BuildContext context) {
    if (avatarPath == null) {
      return CircleAvatar(
        radius: 24,
        backgroundColor: AppColors.primary.withOpacity(0.1),
        child: const Icon(Icons.person, color: AppColors.primary),
      );
    }

    return CircleAvatar(
      radius: 24,
      backgroundImage: avatarPath!.startsWith('http')
          ? CachedNetworkImageProvider(avatarPath!)
          : AssetImage(avatarPath!) as ImageProvider,
    );
  }
}