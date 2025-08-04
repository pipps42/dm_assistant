// lib/shared/components/dialogs/entity_form_dialog.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:dm_assistant/shared/components/dialogs/base_dialog.dart';
import 'package:dm_assistant/shared/components/forms/form_builder.dart';
import 'package:dm_assistant/shared/components/inputs/entity_image_picker.dart';

/// Generic dialog for entity creation/editing with optional image picker
class EntityFormDialog<T> extends ConsumerStatefulWidget {
  /// The entity being edited (null for create mode)
  final T? entity;
  
  /// Title for create mode
  final String createTitle;
  
  /// Title for edit mode
  final String editTitle;
  
  /// Form field configurations
  final List<FormFieldConfig> fields;
  
  /// Whether to show image picker
  final bool hasImagePicker;
  
  /// Label for image picker placeholder
  final String imagePickerLabel;
  
  /// Height of image picker
  final double imagePickerHeight;
  
  /// Icon for image picker placeholder
  final IconData imagePickerIcon;
  
  /// Function to get image path from entity
  final String? Function(T?)? getImagePath;
  
  /// Function called when form is submitted
  /// Parameters: context, form values, selected image path
  final Future<void> Function(BuildContext, Map<String, dynamic>, String?) onSave;
  
  /// Submit button label (defaults based on mode)
  final String? submitLabel;
  
  /// Cancel button label
  final String cancelLabel;
  
  /// Custom validation before form submission
  final String? Function(Map<String, dynamic>)? customValidator;

  const EntityFormDialog({
    super.key,
    this.entity,
    required this.createTitle,
    required this.editTitle,
    required this.fields,
    this.hasImagePicker = false,
    this.imagePickerLabel = 'Add Image',
    this.imagePickerHeight = 120,
    this.imagePickerIcon = Icons.add_photo_alternate,
    this.getImagePath,
    required this.onSave,
    this.submitLabel,
    this.cancelLabel = 'Cancel',
    this.customValidator,
  });

  @override
  ConsumerState<EntityFormDialog<T>> createState() => _EntityFormDialogState<T>();
}

class _EntityFormDialogState<T> extends ConsumerState<EntityFormDialog<T>> {
  String? _selectedImagePath;

  @override
  void initState() {
    super.initState();
    if (widget.hasImagePicker && widget.getImagePath != null) {
      _selectedImagePath = widget.getImagePath!(widget.entity);
    }
  }

  bool get isEditing => widget.entity != null;

  @override
  Widget build(BuildContext context) {
    return BaseDialog(
      title: isEditing ? widget.editTitle : widget.createTitle,
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Image picker section
          if (widget.hasImagePicker) ...[
            EntityImagePicker(
              initialImagePath: _selectedImagePath,
              placeholderText: widget.imagePickerLabel,
              placeholderIcon: widget.imagePickerIcon,
              height: widget.imagePickerHeight,
              onImageChanged: (imagePath) {
                setState(() {
                  _selectedImagePath = imagePath;
                });
              },
            ),
            const SizedBox(height: 16),
          ],

          // Form fields
          FormBuilder(
            fields: widget.fields,
            onSubmit: (values) => _handleSubmit(context, values),
            submitLabel: widget.submitLabel ?? (isEditing ? 'Save' : 'Create'),
            cancelLabel: widget.cancelLabel,
            onCancel: () => context.pop(),
          ),
        ],
      ),
    );
  }

  Future<void> _handleSubmit(
    BuildContext context,
    Map<String, dynamic> values,
  ) async {
    // Run custom validation if provided
    if (widget.customValidator != null) {
      final validationError = widget.customValidator!(values);
      if (validationError != null) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(validationError)),
          );
        }
        return;
      }
    }

    try {
      await widget.onSave(context, values, _selectedImagePath);
      
      if (context.mounted) {
        context.pop();
      }
    } catch (error) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $error')),
        );
      }
    }
  }
}