// lib/shared/components/dialogs/base_dialog.dart
import 'package:flutter/material.dart';
import 'package:dm_assistant/core/constants/dimens.dart';
import 'package:dm_assistant/shared/components/buttons/base_button.dart';

enum DialogType { info, warning, error, success, confirm }

class BaseDialog extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget? content;
  final DialogType type;
  final List<DialogAction>? actions;
  final bool dismissible;
  final double? maxWidth;
  final EdgeInsets? contentPadding;

  const BaseDialog({
    super.key,
    required this.title,
    this.subtitle,
    this.content,
    this.type = DialogType.info,
    this.actions,
    this.dismissible = true,
    this.maxWidth = 480,
    this.contentPadding,
  });

  // Convenience constructors
  factory BaseDialog.confirm({
    required String title,
    String? subtitle,
    Widget? content,
    VoidCallback? onConfirm,
    VoidCallback? onCancel,
    String confirmText = 'Confirm',
    String cancelText = 'Cancel',
  }) {
    return BaseDialog(
      title: title,
      subtitle: subtitle,
      content: content,
      type: DialogType.confirm,
      actions: [
        DialogAction(
          label: cancelText,
          onPressed: onCancel ?? () {},
          isDefault: true,
        ),
        DialogAction(
          label: confirmText,
          onPressed: onConfirm ?? () {},
          isPrimary: true,
        ),
      ],
    );
  }

  factory BaseDialog.error({
    required String title,
    String? subtitle,
    Widget? content,
    VoidCallback? onClose,
  }) {
    return BaseDialog(
      title: title,
      subtitle: subtitle,
      content: content,
      type: DialogType.error,
      actions: [
        DialogAction(
          label: 'Close',
          onPressed: onClose ?? () {},
          isPrimary: true,
        ),
      ],
    );
  }

  IconData get _typeIcon {
    switch (type) {
      case DialogType.info:
        return Icons.info_outline;
      case DialogType.warning:
        return Icons.warning_amber_rounded;
      case DialogType.error:
        return Icons.error_outline;
      case DialogType.success:
        return Icons.check_circle_outline;
      case DialogType.confirm:
        return Icons.help_outline;
    }
  }

  Color _typeColor(BuildContext context) {
    final theme = Theme.of(context);
    switch (type) {
      case DialogType.info:
        return theme.colorScheme.primary;
      case DialogType.warning:
        return const Color(0xFFF59E0B);
      case DialogType.error:
        return theme.colorScheme.error;
      case DialogType.success:
        return const Color(0xFF10B981);
      case DialogType.confirm:
        return theme.colorScheme.primary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final typeColor = _typeColor(context);

    return Dialog(
      backgroundColor: theme.colorScheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimens.radiusXL),
      ),
      child: Container(
        constraints: BoxConstraints(maxWidth: maxWidth ?? 480),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(AppDimens.spacingL),
              decoration: BoxDecoration(
                color: typeColor.withOpacity(0.1),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(AppDimens.radiusXL),
                  topRight: Radius.circular(AppDimens.radiusXL),
                ),
              ),
              child: Row(
                children: [
                  Icon(_typeIcon, color: typeColor, size: 28),
                  const SizedBox(width: AppDimens.spacingM),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        if (subtitle != null) ...[
                          const SizedBox(height: 4),
                          Text(
                            subtitle!,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.onSurface.withOpacity(
                                0.7,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  if (dismissible)
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.of(context).pop(),
                      color: theme.colorScheme.onSurface.withOpacity(0.5),
                    ),
                ],
              ),
            ),

            // Content
            if (content != null)
              Flexible(
                child: SingleChildScrollView(
                  padding:
                      contentPadding ??
                      const EdgeInsets.all(AppDimens.spacingL),
                  child: content!,
                ),
              ),

            // Actions
            if (actions != null && actions!.isNotEmpty)
              Container(
                padding: const EdgeInsets.all(AppDimens.spacingL),
                decoration: BoxDecoration(
                  border: Border(
                    top: BorderSide(color: theme.dividerColor.withOpacity(0.1)),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: actions!.map((action) {
                    final index = actions!.indexOf(action);
                    return Padding(
                      padding: EdgeInsets.only(
                        left: index > 0 ? AppDimens.spacingS : 0,
                      ),
                      child: _buildActionButton(context, action),
                    );
                  }).toList(),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton(BuildContext context, DialogAction action) {
    if (action.isPrimary) {
      return BaseButton(
        label: action.label,
        onPressed: () {
          action.onPressed();
          if (action.shouldClose) {
            Navigator.of(context).pop();
          }
        },
        type: ButtonType.primary,
      );
    } else if (action.isDefault) {
      return BaseButton(
        label: action.label,
        onPressed: () {
          action.onPressed();
          if (action.shouldClose) {
            Navigator.of(context).pop();
          }
        },
        type: ButtonType.secondary,
      );
    } else {
      return BaseButton(
        label: action.label,
        onPressed: () {
          action.onPressed();
          if (action.shouldClose) {
            Navigator.of(context).pop();
          }
        },
        type: ButtonType.text,
      );
    }
  }

  static Future<T?> show<T>({
    required BuildContext context,
    required BaseDialog dialog,
  }) {
    return showDialog<T>(
      context: context,
      barrierDismissible: dialog.dismissible,
      builder: (context) => dialog,
    );
  }
}

class DialogAction {
  final String label;
  final VoidCallback onPressed;
  final bool isPrimary;
  final bool isDefault;
  final bool shouldClose;

  const DialogAction({
    required this.label,
    required this.onPressed,
    this.isPrimary = false,
    this.isDefault = false,
    this.shouldClose = true,
  });
}
