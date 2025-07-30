// lib/shared/components/buttons/base_button.dart
import 'package:flutter/material.dart';
import 'package:dm_assistant/core/constants/dimens.dart';

enum ButtonType { primary, secondary, text, danger }

enum ButtonSize { small, medium, large }

class BaseButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final ButtonType type;
  final ButtonSize size;
  final IconData? icon;
  final bool loading;
  final bool fullWidth;
  final EdgeInsets? margin;

  const BaseButton({
    super.key,
    required this.label,
    this.onPressed,
    this.type = ButtonType.primary,
    this.size = ButtonSize.medium,
    this.icon,
    this.loading = false,
    this.fullWidth = false,
    this.margin,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDisabled = onPressed == null || loading;

    final button = _buildButton(context, theme, isDisabled);

    if (fullWidth) {
      return Container(margin: margin, width: double.infinity, child: button);
    }

    return Container(margin: margin, child: button);
  }

  Widget _buildButton(BuildContext context, ThemeData theme, bool isDisabled) {
    final content = _buildContent(theme);

    switch (type) {
      case ButtonType.primary:
        return ElevatedButton(
          onPressed: isDisabled ? null : onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: theme.colorScheme.primary,
            foregroundColor: theme.colorScheme.onPrimary,
            padding: _getPadding(),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppDimens.radiusM),
            ),
          ),
          child: content,
        );

      case ButtonType.secondary:
        return OutlinedButton(
          onPressed: isDisabled ? null : onPressed,
          style: OutlinedButton.styleFrom(
            foregroundColor: theme.colorScheme.primary,
            padding: _getPadding(),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppDimens.radiusM),
            ),
            side: BorderSide(
              color: theme.colorScheme.primary.withOpacity(
                isDisabled ? 0.3 : 1,
              ),
            ),
          ),
          child: content,
        );

      case ButtonType.text:
        return TextButton(
          onPressed: isDisabled ? null : onPressed,
          style: TextButton.styleFrom(
            foregroundColor: theme.colorScheme.primary,
            padding: _getPadding(),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppDimens.radiusM),
            ),
          ),
          child: content,
        );

      case ButtonType.danger:
        return ElevatedButton(
          onPressed: isDisabled ? null : onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: theme.colorScheme.error,
            foregroundColor: theme.colorScheme.onError,
            padding: _getPadding(),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppDimens.radiusM),
            ),
          ),
          child: content,
        );
    }
  }

  Widget _buildContent(ThemeData theme) {
    if (loading) {
      return SizedBox(
        height: _getIconSize(),
        width: _getIconSize(),
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(
            type == ButtonType.primary || type == ButtonType.danger
                ? theme.colorScheme.onPrimary
                : theme.colorScheme.primary,
          ),
        ),
      );
    }

    if (icon != null) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: _getIconSize()),
          const SizedBox(width: AppDimens.spacingS),
          Text(label, style: _getTextStyle(theme)),
        ],
      );
    }

    return Text(label, style: _getTextStyle(theme));
  }

  EdgeInsets _getPadding() {
    switch (size) {
      case ButtonSize.small:
        return const EdgeInsets.symmetric(
          horizontal: AppDimens.spacingM,
          vertical: AppDimens.spacingS,
        );
      case ButtonSize.medium:
        return const EdgeInsets.symmetric(
          horizontal: AppDimens.spacingL,
          vertical: AppDimens.spacingM,
        );
      case ButtonSize.large:
        return const EdgeInsets.symmetric(
          horizontal: AppDimens.spacingXL,
          vertical: AppDimens.spacingM + 4,
        );
    }
  }

  double _getIconSize() {
    switch (size) {
      case ButtonSize.small:
        return 16;
      case ButtonSize.medium:
        return 20;
      case ButtonSize.large:
        return 24;
    }
  }

  TextStyle? _getTextStyle(ThemeData theme) {
    switch (size) {
      case ButtonSize.small:
        return theme.textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w600);
      case ButtonSize.medium:
        return theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600);
      case ButtonSize.large:
        return theme.textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.w600,
        );
    }
  }
}

// Icon Button variant
class BaseIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onPressed;
  final ButtonType type;
  final ButtonSize size;
  final String? tooltip;
  final bool loading;

  const BaseIconButton({
    super.key,
    required this.icon,
    this.onPressed,
    this.type = ButtonType.primary,
    this.size = ButtonSize.medium,
    this.tooltip,
    this.loading = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDisabled = onPressed == null || loading;

    final color = _getColor(theme);
    final iconSize = _getIconSize();

    final iconButton = IconButton(
      icon: loading
          ? SizedBox(
              width: iconSize,
              height: iconSize,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(color),
              ),
            )
          : Icon(icon),
      onPressed: isDisabled ? null : onPressed,
      iconSize: iconSize,
      color: color,
      padding: _getPadding(),
      splashRadius: iconSize + 8,
    );

    if (tooltip != null && !loading) {
      return Tooltip(message: tooltip!, child: iconButton);
    }

    return iconButton;
  }

  Color _getColor(ThemeData theme) {
    switch (type) {
      case ButtonType.primary:
        return theme.colorScheme.primary;
      case ButtonType.secondary:
        return theme.colorScheme.onSurface;
      case ButtonType.text:
        return theme.colorScheme.onSurface.withOpacity(0.7);
      case ButtonType.danger:
        return theme.colorScheme.error;
    }
  }

  double _getIconSize() {
    switch (size) {
      case ButtonSize.small:
        return 18;
      case ButtonSize.medium:
        return 24;
      case ButtonSize.large:
        return 32;
    }
  }

  EdgeInsets _getPadding() {
    switch (size) {
      case ButtonSize.small:
        return const EdgeInsets.all(4);
      case ButtonSize.medium:
        return const EdgeInsets.all(8);
      case ButtonSize.large:
        return const EdgeInsets.all(12);
    }
  }
}
