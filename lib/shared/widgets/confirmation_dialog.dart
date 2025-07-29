// lib/shared/widgets/confirmation_dialog.dart
import 'package:flutter/material.dart';
import 'package:dm_assistant/core/constants/app_colors.dart';
import 'package:dm_assistant/core/constants/dimens.dart';
import 'package:dm_assistant/core/responsive/responsive_builder.dart';

/// Tipi di confirmation dialog
enum ConfirmationType { info, warning, danger, success }

/// Extension per ottenere colori e icone per ogni tipo
extension ConfirmationTypeExtension on ConfirmationType {
  Color get color {
    switch (this) {
      case ConfirmationType.info:
        return AppColors.info;
      case ConfirmationType.warning:
        return AppColors.warning;
      case ConfirmationType.danger:
        return AppColors.error;
      case ConfirmationType.success:
        return AppColors.success;
    }
  }

  IconData get icon {
    switch (this) {
      case ConfirmationType.info:
        return Icons.info_outline;
      case ConfirmationType.warning:
        return Icons.warning_amber_outlined;
      case ConfirmationType.danger:
        return Icons.error_outline;
      case ConfirmationType.success:
        return Icons.check_circle_outline;
    }
  }

  String get defaultTitle {
    switch (this) {
      case ConfirmationType.info:
        return 'Information';
      case ConfirmationType.warning:
        return 'Warning';
      case ConfirmationType.danger:
        return 'Confirm Action';
      case ConfirmationType.success:
        return 'Success';
    }
  }
}

/// Dialog di conferma riutilizzabile e personalizzabile
class ConfirmationDialog extends StatelessWidget {
  /// Tipo di dialog che determina colori e icona
  final ConfirmationType type;

  /// Titolo del dialog
  final String? title;

  /// Messaggio principale
  final String message;

  /// Messaggio di dettaglio opzionale
  final String? details;

  /// Widget personalizzato per il contenuto
  final Widget? customContent;

  /// Testo del pulsante di conferma
  final String? confirmText;

  /// Testo del pulsante di annullamento
  final String? cancelText;

  /// Callback per conferma
  final VoidCallback? onConfirm;

  /// Callback per annullamento
  final VoidCallback? onCancel;

  /// Se mostrare l'icona
  final bool showIcon;

  /// Icona personalizzata
  final IconData? customIcon;

  /// Se il pulsante di conferma deve essere evidenziato come pericoloso
  final bool isDangerous;

  /// Se disabilitare il pulsante di conferma inizialmente
  final bool confirmEnabled;

  /// Se richiedere una doppia conferma (es. digitare "DELETE")
  final String? requireConfirmationText;

  /// Se chiudere automaticamente il dialog dopo la conferma
  final bool autoClose;

  /// Se mostrare progress indicator durante l'azione
  final bool showProgress;

  /// Widget loading personalizzato
  final Widget? loadingWidget;

  const ConfirmationDialog({
    super.key,
    this.type = ConfirmationType.info,
    this.title,
    required this.message,
    this.details,
    this.customContent,
    this.confirmText,
    this.cancelText,
    this.onConfirm,
    this.onCancel,
    this.showIcon = true,
    this.customIcon,
    this.isDangerous = false,
    this.confirmEnabled = true,
    this.requireConfirmationText,
    this.autoClose = true,
    this.showProgress = false,
    this.loadingWidget,
  });

  /// Factory per dialog di eliminazione
  factory ConfirmationDialog.delete({
    required String itemName,
    required VoidCallback onConfirm,
    VoidCallback? onCancel,
    bool requireTyping = false,
  }) {
    return ConfirmationDialog(
      type: ConfirmationType.danger,
      title: 'Delete $itemName?',
      message:
          'This action cannot be undone. Are you sure you want to delete "$itemName"?',
      confirmText: 'Delete',
      cancelText: 'Cancel',
      onConfirm: onConfirm,
      onCancel: onCancel,
      isDangerous: true,
      requireConfirmationText: requireTyping ? 'DELETE' : null,
    );
  }

  /// Factory per dialog di conferma salvataggio
  factory ConfirmationDialog.save({
    required VoidCallback onConfirm,
    VoidCallback? onCancel,
    String? customMessage,
  }) {
    return ConfirmationDialog(
      type: ConfirmationType.info,
      title: 'Save Changes?',
      message: customMessage ?? 'Do you want to save your changes?',
      confirmText: 'Save',
      cancelText: 'Cancel',
      onConfirm: onConfirm,
      onCancel: onCancel,
    );
  }

  /// Factory per dialog di uscita senza salvare
  factory ConfirmationDialog.unsavedChanges({
    required VoidCallback onDiscard,
    VoidCallback? onSave,
    VoidCallback? onCancel,
  }) {
    return ConfirmationDialog(
      type: ConfirmationType.warning,
      title: 'Unsaved Changes',
      message: 'You have unsaved changes that will be lost if you continue.',
      confirmText: 'Discard Changes',
      cancelText: 'Cancel',
      onConfirm: onDiscard,
      onCancel: onCancel,
      isDangerous: true,
      customContent: onSave != null
          ? Padding(
              padding: const EdgeInsets.only(top: AppDimens.spacingM),
              child: SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: onSave,
                  icon: const Icon(Icons.save),
                  label: const Text('Save Changes'),
                ),
              ),
            )
          : null,
    );
  }

  /// Factory per dialog di logout/disconnessione
  factory ConfirmationDialog.logout({
    required VoidCallback onConfirm,
    VoidCallback? onCancel,
  }) {
    return ConfirmationDialog(
      type: ConfirmationType.warning,
      title: 'Sign Out',
      message: 'Are you sure you want to sign out?',
      confirmText: 'Sign Out',
      cancelText: 'Cancel',
      onConfirm: onConfirm,
      onCancel: onCancel,
    );
  }

  @override
  Widget build(BuildContext context) {
    return ResponsiveBuilder(
      mobile: _buildMobileDialog(context),
      desktop: _buildDesktopDialog(context),
    );
  }

  Widget _buildMobileDialog(BuildContext context) {
    return _ConfirmationDialogContent(
      type: type,
      title: title,
      message: message,
      details: details,
      customContent: customContent,
      confirmText: confirmText,
      cancelText: cancelText,
      onConfirm: onConfirm,
      onCancel: onCancel,
      showIcon: showIcon,
      customIcon: customIcon,
      isDangerous: isDangerous,
      confirmEnabled: confirmEnabled,
      requireConfirmationText: requireConfirmationText,
      autoClose: autoClose,
      showProgress: showProgress,
      loadingWidget: loadingWidget,
      compact: true,
    );
  }

  Widget _buildDesktopDialog(BuildContext context) {
    return _ConfirmationDialogContent(
      type: type,
      title: title,
      message: message,
      details: details,
      customContent: customContent,
      confirmText: confirmText,
      cancelText: cancelText,
      onConfirm: onConfirm,
      onCancel: onCancel,
      showIcon: showIcon,
      customIcon: customIcon,
      isDangerous: isDangerous,
      confirmEnabled: confirmEnabled,
      requireConfirmationText: requireConfirmationText,
      autoClose: autoClose,
      showProgress: showProgress,
      loadingWidget: loadingWidget,
      compact: false,
    );
  }
}

/// Content widget del dialog
class _ConfirmationDialogContent extends StatefulWidget {
  final ConfirmationType type;
  final String? title;
  final String message;
  final String? details;
  final Widget? customContent;
  final String? confirmText;
  final String? cancelText;
  final VoidCallback? onConfirm;
  final VoidCallback? onCancel;
  final bool showIcon;
  final IconData? customIcon;
  final bool isDangerous;
  final bool confirmEnabled;
  final String? requireConfirmationText;
  final bool autoClose;
  final bool showProgress;
  final Widget? loadingWidget;
  final bool compact;

  const _ConfirmationDialogContent({
    required this.type,
    this.title,
    required this.message,
    this.details,
    this.customContent,
    this.confirmText,
    this.cancelText,
    this.onConfirm,
    this.onCancel,
    required this.showIcon,
    this.customIcon,
    required this.isDangerous,
    required this.confirmEnabled,
    this.requireConfirmationText,
    required this.autoClose,
    required this.showProgress,
    this.loadingWidget,
    required this.compact,
  });

  @override
  State<_ConfirmationDialogContent> createState() =>
      _ConfirmationDialogContentState();
}

class _ConfirmationDialogContentState
    extends State<_ConfirmationDialogContent> {
  final TextEditingController _confirmationController = TextEditingController();
  bool _isLoading = false;
  bool get _canConfirm {
    if (!widget.confirmEnabled) return false;
    if (widget.requireConfirmationText != null) {
      return _confirmationController.text.trim() ==
          widget.requireConfirmationText;
    }
    return true;
  }

  @override
  void dispose() {
    _confirmationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      titlePadding: EdgeInsets.zero,
      contentPadding: EdgeInsets.zero,
      actionsPadding: EdgeInsets.zero,
      title: _buildTitle(context),
      content: _buildContent(context),
      actions: _isLoading && widget.showProgress
          ? null
          : _buildActions(context),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(
          widget.compact ? AppDimens.radiusM : AppDimens.radiusL,
        ),
      ),
    );
  }

  Widget? _buildTitle(BuildContext context) {
    final titleText = widget.title ?? widget.type.defaultTitle;

    return Container(
      padding: EdgeInsets.all(
        widget.compact ? AppDimens.spacingM : AppDimens.spacingL,
      ),
      decoration: BoxDecoration(
        color: widget.type.color.withOpacity(0.1),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(
            widget.compact ? AppDimens.radiusM : AppDimens.radiusL,
          ),
          topRight: Radius.circular(
            widget.compact ? AppDimens.radiusM : AppDimens.radiusL,
          ),
        ),
      ),
      child: Row(
        children: [
          if (widget.showIcon) ...[
            Icon(
              widget.customIcon ?? widget.type.icon,
              color: widget.type.color,
              size: widget.compact ? 24 : 28,
            ),
            SizedBox(
              width: widget.compact ? AppDimens.spacingS : AppDimens.spacingM,
            ),
          ],
          Expanded(
            child: Text(
              titleText,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
                color: widget.type.color,
                fontSize: widget.compact ? 18 : 20,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    if (_isLoading && widget.showProgress) {
      return Container(
        padding: EdgeInsets.all(
          widget.compact ? AppDimens.spacingL : AppDimens.spacingXL,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            widget.loadingWidget ??
                CircularProgressIndicator(color: widget.type.color),
            SizedBox(
              height: widget.compact ? AppDimens.spacingM : AppDimens.spacingL,
            ),
            Text(
              'Processing...',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      );
    }

    return Container(
      padding: EdgeInsets.all(
        widget.compact ? AppDimens.spacingM : AppDimens.spacingL,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Main message
          Text(
            widget.message,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              fontSize: widget.compact ? 14 : 16,
              height: 1.5,
            ),
          ),

          // Details
          if (widget.details != null) ...[
            SizedBox(
              height: widget.compact ? AppDimens.spacingS : AppDimens.spacingM,
            ),
            Container(
              padding: EdgeInsets.all(
                widget.compact ? AppDimens.spacingS : AppDimens.spacingM,
              ),
              decoration: BoxDecoration(
                color: AppColors.neutral100,
                borderRadius: BorderRadius.circular(AppDimens.radiusS),
                border: Border.all(color: AppColors.neutral300, width: 1),
              ),
              child: Text(
                widget.details!,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.neutral600,
                  fontSize: widget.compact ? 12 : 14,
                ),
              ),
            ),
          ],

          // Confirmation text input
          if (widget.requireConfirmationText != null) ...[
            SizedBox(
              height: widget.compact ? AppDimens.spacingM : AppDimens.spacingL,
            ),
            Text(
              'Type "${widget.requireConfirmationText}" to confirm:',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
                fontSize: widget.compact ? 13 : 15,
              ),
            ),
            SizedBox(
              height: widget.compact ? AppDimens.spacingS : AppDimens.spacingM,
            ),
            TextFormField(
              controller: _confirmationController,
              decoration: InputDecoration(
                hintText: widget.requireConfirmationText,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppDimens.radiusS),
                ),
                contentPadding: EdgeInsets.symmetric(
                  horizontal: widget.compact
                      ? AppDimens.spacingS
                      : AppDimens.spacingM,
                  vertical: widget.compact
                      ? AppDimens.spacingS
                      : AppDimens.spacingM,
                ),
              ),
              onChanged: (_) => setState(() {}),
              style: TextStyle(fontSize: widget.compact ? 14 : 16),
            ),
          ],

          // Custom content
          if (widget.customContent != null) ...[
            SizedBox(
              height: widget.compact ? AppDimens.spacingM : AppDimens.spacingL,
            ),
            widget.customContent!,
          ],
        ],
      ),
    );
  }

  List<Widget> _buildActions(BuildContext context) {
    return [
      Container(
        padding: EdgeInsets.all(
          widget.compact ? AppDimens.spacingM : AppDimens.spacingL,
        ),
        child: widget.compact
            ? _buildMobileActions(context)
            : _buildDesktopActions(context),
      ),
    ];
  }

  Widget _buildMobileActions(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (widget.onConfirm != null)
          ElevatedButton(
            onPressed: _canConfirm ? _handleConfirm : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: widget.isDangerous ? AppColors.error : null,
              foregroundColor: widget.isDangerous ? Colors.white : null,
            ),
            child: Text(widget.confirmText ?? 'Confirm'),
          ),

        if (widget.onCancel != null) ...[
          const SizedBox(height: AppDimens.spacingS),
          TextButton(
            onPressed: _handleCancel,
            child: Text(widget.cancelText ?? 'Cancel'),
          ),
        ],
      ],
    );
  }

  Widget _buildDesktopActions(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        if (widget.onCancel != null) ...[
          TextButton(
            onPressed: _handleCancel,
            child: Text(widget.cancelText ?? 'Cancel'),
          ),
          const SizedBox(width: AppDimens.spacingM),
        ],

        if (widget.onConfirm != null)
          ElevatedButton(
            onPressed: _canConfirm ? _handleConfirm : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: widget.isDangerous ? AppColors.error : null,
              foregroundColor: widget.isDangerous ? Colors.white : null,
            ),
            child: Text(widget.confirmText ?? 'Confirm'),
          ),
      ],
    );
  }

  void _handleConfirm() async {
    if (widget.showProgress) {
      setState(() {
        _isLoading = true;
      });
    }

    try {
      widget.onConfirm?.call();

      if (widget.autoClose && mounted) {
        Navigator.of(context).pop(true);
      }
    } finally {
      if (mounted && widget.showProgress) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _handleCancel() {
    widget.onCancel?.call();
    if (widget.autoClose && mounted) {
      Navigator.of(context).pop(false);
    }
  }
}

/// Utility functions per mostrare dialog di conferma
class ConfirmationDialogs {
  /// Mostra un dialog di conferma generico
  static Future<bool?> show(BuildContext context, ConfirmationDialog dialog) {
    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => dialog,
    );
  }

  /// Mostra dialog di eliminazione
  static Future<bool?> showDelete(
    BuildContext context, {
    required String itemName,
    required VoidCallback onConfirm,
    bool requireTyping = false,
  }) {
    return show(
      context,
      ConfirmationDialog.delete(
        itemName: itemName,
        onConfirm: onConfirm,
        requireTyping: requireTyping,
      ),
    );
  }

  /// Mostra dialog per modifiche non salvate
  static Future<bool?> showUnsavedChanges(
    BuildContext context, {
    required VoidCallback onDiscard,
    VoidCallback? onSave,
  }) {
    return show(
      context,
      ConfirmationDialog.unsavedChanges(onDiscard: onDiscard, onSave: onSave),
    );
  }

  /// Mostra dialog di logout
  static Future<bool?> showLogout(
    BuildContext context, {
    required VoidCallback onConfirm,
  }) {
    return show(context, ConfirmationDialog.logout(onConfirm: onConfirm));
  }

  /// Mostra dialog di successo
  static Future<void> showSuccess(
    BuildContext context, {
    required String message,
    String? title,
    String? details,
  }) {
    return showDialog<void>(
      context: context,
      builder: (context) => ConfirmationDialog(
        type: ConfirmationType.success,
        title: title ?? 'Success',
        message: message,
        details: details,
        confirmText: 'OK',
        onConfirm: () => Navigator.of(context).pop(),
      ),
    );
  }

  /// Mostra dialog di errore
  static Future<void> showError(
    BuildContext context, {
    required String message,
    String? title,
    String? details,
    VoidCallback? onRetry,
  }) {
    return showDialog<void>(
      context: context,
      builder: (context) => ConfirmationDialog(
        type: ConfirmationType.danger,
        title: title ?? 'Error',
        message: message,
        details: details,
        confirmText: onRetry != null ? 'Retry' : 'OK',
        cancelText: onRetry != null ? 'Cancel' : null,
        onConfirm: onRetry != null
            ? () {
                Navigator.of(context).pop();
                onRetry();
              }
            : () => Navigator.of(context).pop(),
        onCancel: onRetry != null ? () => Navigator.of(context).pop() : null,
      ),
    );
  }
}
