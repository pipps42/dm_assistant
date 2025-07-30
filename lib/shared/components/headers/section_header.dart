// lib/shared/components/headers/section_header.dart
import 'package:flutter/material.dart';
import 'package:dm_assistant/core/constants/dimens.dart';
import 'package:dm_assistant/shared/components/buttons/base_button.dart';

enum SectionHeaderSize { small, medium, large }

class SectionHeader extends StatelessWidget {
  final String title;
  final String? subtitle;
  final String? description;
  final IconData? icon;
  final Widget? leading;
  final List<Widget>? actions;
  final VoidCallback? onAction;
  final String? actionLabel;
  final IconData? actionIcon;
  final SectionHeaderSize size;
  final EdgeInsets padding;
  final bool showDivider;
  final Color? backgroundColor;
  final CrossAxisAlignment alignment;

  const SectionHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.description,
    this.icon,
    this.leading,
    this.actions,
    this.onAction,
    this.actionLabel,
    this.actionIcon,
    this.size = SectionHeaderSize.medium,
    this.padding = const EdgeInsets.all(AppDimens.spacingM),
    this.showDivider = true,
    this.backgroundColor,
    this.alignment = CrossAxisAlignment.start,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      padding: padding,
      decoration: BoxDecoration(
        color: backgroundColor,
        border: showDivider
            ? Border(
                bottom: BorderSide(
                  color: theme.dividerColor.withOpacity(0.1),
                  width: 1,
                ),
              )
            : null,
      ),
      child: Column(
        crossAxisAlignment: alignment,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              if (leading != null) ...[
                leading!,
                const SizedBox(width: AppDimens.spacingM),
              ] else if (icon != null) ...[
                Icon(
                  icon!,
                  size: _getIconSize(),
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(width: AppDimens.spacingM),
              ],
              Expanded(
                child: Column(
                  crossAxisAlignment: alignment,
                  children: [
                    Text(
                      title,
                      style: _getTitleStyle(theme),
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        subtitle!,
                        style: _getSubtitleStyle(theme),
                      ),
                    ],
                  ],
                ),
              ),
              if (actions != null) ...[
                const SizedBox(width: AppDimens.spacingM),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: actions!,
                ),
              ] else if (onAction != null && actionLabel != null) ...[
                const SizedBox(width: AppDimens.spacingM),
                BaseButton(
                  label: actionLabel!,
                  onPressed: onAction,
                  icon: actionIcon,
                  type: ButtonType.primary,
                  size: _getButtonSize(),
                ),
              ],
            ],
          ),
          if (description != null) ...[
            const SizedBox(height: AppDimens.spacingS),
            Text(
              description!,
              style: _getDescriptionStyle(theme),
            ),
          ],
        ],
      ),
    );
  }

  TextStyle _getTitleStyle(ThemeData theme) {
    switch (size) {
      case SectionHeaderSize.small:
        return theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ) ??
            const TextStyle();
      case SectionHeaderSize.medium:
        return theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w600,
            ) ??
            const TextStyle();
      case SectionHeaderSize.large:
        return theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w600,
            ) ??
            const TextStyle();
    }
  }

  TextStyle _getSubtitleStyle(ThemeData theme) {
    switch (size) {
      case SectionHeaderSize.small:
        return theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.7),
            ) ??
            const TextStyle();
      case SectionHeaderSize.medium:
        return theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.7),
            ) ??
            const TextStyle();
      case SectionHeaderSize.large:
        return theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.7),
            ) ??
            const TextStyle();
    }
  }

  TextStyle _getDescriptionStyle(ThemeData theme) {
    return theme.textTheme.bodyMedium?.copyWith(
          color: theme.colorScheme.onSurface.withOpacity(0.8),
        ) ??
        const TextStyle();
  }

  double _getIconSize() {
    switch (size) {
      case SectionHeaderSize.small:
        return 20;
      case SectionHeaderSize.medium:
        return 24;
      case SectionHeaderSize.large:
        return 32;
    }
  }

  ButtonSize _getButtonSize() {
    switch (size) {
      case SectionHeaderSize.small:
        return ButtonSize.small;
      case SectionHeaderSize.medium:
        return ButtonSize.medium;
      case SectionHeaderSize.large:
        return ButtonSize.large;
    }
  }
}

// Specialized section headers for common D&D scenarios
class CampaignSectionHeader extends SectionHeader {
  const CampaignSectionHeader({
    super.key,
    required super.title,
    super.subtitle,
    super.description,
    super.actions,
    super.onAction,
    super.actionLabel,
    super.size = SectionHeaderSize.medium,
    super.padding,
    super.showDivider = true,
  }) : super(
          icon: Icons.campaign,
        );
}

class CharacterSectionHeader extends SectionHeader {
  const CharacterSectionHeader({
    super.key,
    required super.title,
    super.subtitle,
    super.description,
    super.actions,
    super.onAction,
    super.actionLabel,
    super.size = SectionHeaderSize.medium,
    super.padding,
    super.showDivider = true,
  }) : super(
          icon: Icons.people,
        );
}

class SessionSectionHeader extends SectionHeader {
  const SessionSectionHeader({
    super.key,
    required super.title,
    super.subtitle,
    super.description,
    super.actions,
    super.onAction,
    super.actionLabel,
    super.size = SectionHeaderSize.medium,
    super.padding,
    super.showDivider = true,
  }) : super(
          icon: Icons.event,
        );
}

class QuestSectionHeader extends SectionHeader {
  const QuestSectionHeader({
    super.key,
    required super.title,
    super.subtitle,
    super.description,
    super.actions,
    super.onAction,
    super.actionLabel,
    super.size = SectionHeaderSize.medium,
    super.padding,
    super.showDivider = true,
  }) : super(
          icon: Icons.auto_stories,
        );
}

// Collapsible section header
class CollapsibleSectionHeader extends StatefulWidget {
  final String title;
  final String? subtitle;
  final String? description;
  final IconData? icon;
  final Widget? leading;
  final List<Widget>? actions;
  final Widget child;
  final bool initiallyExpanded;
  final SectionHeaderSize size;
  final EdgeInsets padding;
  final Color? backgroundColor;
  final ValueChanged<bool>? onExpansionChanged;

  const CollapsibleSectionHeader({
    super.key,
    required this.title,
    required this.child,
    this.subtitle,
    this.description,
    this.icon,
    this.leading,
    this.actions,
    this.initiallyExpanded = true,
    this.size = SectionHeaderSize.medium,
    this.padding = const EdgeInsets.all(AppDimens.spacingM),
    this.backgroundColor,
    this.onExpansionChanged,
  });

  @override
  State<CollapsibleSectionHeader> createState() => _CollapsibleSectionHeaderState();
}

class _CollapsibleSectionHeaderState extends State<CollapsibleSectionHeader>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _expandAnimation;
  bool _isExpanded = true;

  @override
  void initState() {
    super.initState();
    _isExpanded = widget.initiallyExpanded;
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _expandAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );

    if (_isExpanded) {
      _controller.value = 1;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggleExpansion() {
    setState(() {
      _isExpanded = !_isExpanded;
      if (_isExpanded) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    });
    widget.onExpansionChanged?.call(_isExpanded);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        InkWell(
          onTap: _toggleExpansion,
          child: SectionHeader(
            title: widget.title,
            subtitle: widget.subtitle,
            description: widget.description,
            icon: widget.icon,
            leading: widget.leading,
            size: widget.size,
            padding: widget.padding,
            backgroundColor: widget.backgroundColor,
            showDivider: false,
            actions: [
              ...?widget.actions,
              AnimatedRotation(
                turns: _isExpanded ? 0.5 : 0,
                duration: const Duration(milliseconds: 300),
                child: const Icon(Icons.expand_more),
              ),
            ],
          ),
        ),
        SizeTransition(
          sizeFactor: _expandAnimation,
          child: widget.child,
        ),
      ],
    );
  }
}

// Stats section header with numeric values
class StatsSectionHeader extends StatelessWidget {
  final String title;
  final Map<String, dynamic> stats;
  final List<Widget>? actions;
  final EdgeInsets padding;

  const StatsSectionHeader({
    super.key,
    required this.title,
    required this.stats,
    this.actions,
    this.padding = const EdgeInsets.all(AppDimens.spacingM),
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      padding: padding,
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: theme.dividerColor.withOpacity(0.1),
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
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
          const SizedBox(height: AppDimens.spacingS),
          Wrap(
            spacing: AppDimens.spacingL,
            runSpacing: AppDimens.spacingS,
            children: stats.entries.map((entry) {
              return Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '${entry.key}:',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.7),
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    entry.value.toString(),
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}