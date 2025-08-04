// lib/shared/components/layouts/entity_detail_layout.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:dm_assistant/core/constants/dimens.dart';

class EntityDetailLayout extends StatelessWidget {
  final String entityName;
  final String? entitySubtitle;
  final String? avatarPath;
  final IconData fallbackIcon;
  final List<EntityDetailSection> sections;
  final EdgeInsets? padding;

  const EntityDetailLayout({
    super.key,
    required this.entityName,
    this.entitySubtitle,
    this.avatarPath,
    required this.fallbackIcon,
    required this.sections,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: padding ?? const EdgeInsets.all(AppDimens.spacingL),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Entity Header with Avatar and Basic Info
          _buildEntityHeader(context),
          
          const SizedBox(height: AppDimens.spacingXL),
          
          // Sections
          ...sections.map((section) => Column(
            children: [
              section,
              const SizedBox(height: AppDimens.spacingXL),
            ],
          )),
        ],
      ),
    );
  }

  Widget _buildEntityHeader(BuildContext context) {
    final theme = Theme.of(context);
    
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Avatar
        _buildAvatar(theme),
        
        const SizedBox(width: AppDimens.spacingL),
        
        // Entity Info
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                entityName,
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (entitySubtitle != null) ...[
                const SizedBox(height: AppDimens.spacingS),
                Text(
                  entitySubtitle!,
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.7),
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAvatar(ThemeData theme) {
    const double avatarSize = 120;
    
    return Container(
      width: avatarSize,
      height: avatarSize,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppDimens.radiusM),
        color: theme.colorScheme.surfaceContainerHighest,
      ),
      clipBehavior: Clip.antiAlias,
      child: avatarPath != null && avatarPath!.isNotEmpty
          ? _buildAvatarImage(avatarPath!, theme)
          : _buildFallbackAvatar(theme),
    );
  }

  Widget _buildAvatarImage(String path, ThemeData theme) {
    // Check if it's a local file path
    if (!path.startsWith('http')) {
      final file = File(path);
      if (file.existsSync()) {
        return Image.file(
          file,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => _buildFallbackAvatar(theme),
        );
      }
    } else {
      // Network image
      return Image.network(
        path,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => _buildFallbackAvatar(theme),
      );
    }
    
    // Fallback if file doesn't exist or path is invalid
    return _buildFallbackAvatar(theme);
  }

  Widget _buildFallbackAvatar(ThemeData theme) {
    return Container(
      color: theme.colorScheme.primary.withOpacity(0.1),
      child: Icon(
        fallbackIcon,
        size: 48,
        color: theme.colorScheme.primary,
      ),
    );
  }
}

// Base class for detail sections
abstract class EntityDetailSection extends StatelessWidget {
  final String title;
  final IconData? icon;
  final List<Widget>? actions;

  const EntityDetailSection({
    super.key,
    required this.title,
    this.icon,
    this.actions,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppDimens.spacingL),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Section Header
            Row(
              children: [
                if (icon != null) ...[
                  Icon(icon, size: 20, color: theme.colorScheme.primary),
                  const SizedBox(width: AppDimens.spacingS),
                ],
                Expanded(
                  child: Text(
                    title,
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                if (actions != null) ...actions!,
              ],
            ),
            
            const SizedBox(height: AppDimens.spacingL),
            
            // Section Content
            buildContent(context),
          ],
        ),
      ),
    );
  }

  Widget buildContent(BuildContext context);
}

// Editable section with inline editing capability
abstract class EditableEntityDetailSection extends EntityDetailSection {
  final bool isEditing;
  final VoidCallback? onEdit;
  final VoidCallback? onSave;
  final VoidCallback? onCancel;

  const EditableEntityDetailSection({
    super.key,
    required super.title,
    super.icon,
    this.isEditing = false,
    this.onEdit,
    this.onSave,
    this.onCancel,
  }) : super(actions: null);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppDimens.spacingL),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Section Header
            Row(
              children: [
                if (icon != null) ...[
                  Icon(icon, size: 20, color: theme.colorScheme.primary),
                  const SizedBox(width: AppDimens.spacingS),
                ],
                Expanded(
                  child: Text(
                    title,
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                if (!isEditing && onEdit != null)
                  IconButton(
                    onPressed: onEdit,
                    icon: const Icon(Icons.edit),
                    tooltip: 'Edit $title',
                  ),
              ],
            ),
            
            const SizedBox(height: AppDimens.spacingL),
            
            // Section Content
            buildContent(context),
            
            // Edit Actions (when editing)
            if (isEditing) ...[
              const SizedBox(height: AppDimens.spacingL),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: onCancel,
                    child: const Text('Cancel'),
                  ),
                  const SizedBox(width: AppDimens.spacingS),
                  FilledButton(
                    onPressed: onSave,
                    child: const Text('Save'),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// Info field widget for consistent display
class InfoField extends StatelessWidget {
  final String label;
  final String? value;
  final IconData? icon;
  final Widget? customValue;
  
  const InfoField({
    super.key,
    required this.label,
    this.value,
    this.icon,
    this.customValue,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Padding(
      padding: const EdgeInsets.only(bottom: AppDimens.spacingM),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (icon != null) ...[
            Icon(
              icon,
              size: 16,
              color: theme.colorScheme.onSurface.withOpacity(0.6),
            ),
            const SizedBox(width: AppDimens.spacingS),
          ],
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
                color: theme.colorScheme.onSurface.withOpacity(0.8),
              ),
            ),
          ),
          const SizedBox(width: AppDimens.spacingM),
          Expanded(
            flex: 3,
            child: customValue ?? Text(
              value ?? '—',
              style: theme.textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }
}