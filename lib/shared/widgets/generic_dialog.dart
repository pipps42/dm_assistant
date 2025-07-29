// lib/shared/widgets/generic_dialog.dart
import 'package:flutter/material.dart';

class GenericDialog extends StatelessWidget {
  final String title;
  final Widget content;
  final String confirmText;
  final String cancelText;
  final VoidCallback? onConfirm;

  const GenericDialog({
    super.key,
    required this.title,
    required this.content,
    this.confirmText = 'Save',
    this.cancelText = 'Cancel',
    this.onConfirm,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(title),
      content: content,
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(cancelText),
        ),
        if (onConfirm != null)
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              onConfirm!();
            },
            child: Text(confirmText),
          ),
      ],
    );
  }
}