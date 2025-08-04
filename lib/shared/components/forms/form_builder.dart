// lib/shared/components/forms/form_builder.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dm_assistant/core/constants/dimens.dart';
import 'package:dm_assistant/shared/components/inputs/base_text_field.dart';
import 'package:dm_assistant/shared/components/buttons/base_button.dart';

typedef FormSubmitCallback = Future<void> Function(Map<String, dynamic> values);

class FormBuilder extends ConsumerStatefulWidget {
  final List<FormFieldConfig> fields;
  final FormSubmitCallback? onSubmit;
  final String submitLabel;
  final String? cancelLabel;
  final VoidCallback? onCancel;
  final bool showActions;
  final double spacing;
  final EdgeInsets? padding;

  const FormBuilder({
    super.key,
    required this.fields,
    this.onSubmit,
    this.submitLabel = 'Submit',
    this.cancelLabel,
    this.onCancel,
    this.showActions = true,
    this.spacing = AppDimens.spacingM,
    this.padding,
  });

  @override
  ConsumerState<FormBuilder> createState() => _FormBuilderState();
}

class _FormBuilderState extends ConsumerState<FormBuilder> {
  final _formKey = GlobalKey<FormState>();
  final Map<String, dynamic> _values = {};
  final Map<String, TextEditingController> _controllers = {};
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    for (final field in widget.fields) {
      if (field.type == FormFieldType.text ||
          field.type == FormFieldType.number ||
          field.type == FormFieldType.email ||
          field.type == FormFieldType.multiline) {
        _controllers[field.name] = TextEditingController(
          text: field.initialValue?.toString() ?? '',
        );
        _values[field.name] = field.initialValue;
      } else {
        _values[field.name] = field.initialValue;
      }
    }
  }

  @override
  void dispose() {
    for (final controller in _controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    if (widget.onSubmit == null) return;

    setState(() => _isSubmitting = true);

    try {
      // Collect values from controllers
      for (final entry in _controllers.entries) {
        _values[entry.key] = entry.value.text;
      }

      await widget.onSubmit!(_values);
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ...widget.fields.map(
            (field) => Padding(
              padding: EdgeInsets.only(bottom: widget.spacing),
              child: _buildField(field),
            ),
          ),
          if (widget.showActions) ...[
            const SizedBox(height: AppDimens.spacingM),
            _buildActions(),
          ],
        ],
      ),
    );
  }

  Widget _buildField(FormFieldConfig field) {
    switch (field.type) {
      case FormFieldType.text:
      case FormFieldType.email:
      case FormFieldType.number:
      case FormFieldType.multiline:
        return BaseTextField(
          label: field.label,
          hint: field.hint,
          controller: _controllers[field.name],
          validator: field.validator,
          enabled: field.enabled && !_isSubmitting,
          keyboardType: _getKeyboardType(field.type),
          maxLines: field.type == FormFieldType.multiline
              ? field.maxLines ?? 3
              : 1,
          prefixIcon: field.prefixIcon != null ? Icon(field.prefixIcon) : null,
          suffixIcon: field.suffixIcon != null ? Icon(field.suffixIcon) : null,
        );

      case FormFieldType.dropdown:
        return _DropdownField(
          label: field.label,
          value: _values[field.name],
          items: field.options ?? [],
          onChanged: (value) {
            setState(() {
              _values[field.name] = value;
            });
          },
          validator: field.validator,
          enabled: field.enabled && !_isSubmitting,
          hint: field.hint,
          prefixIcon: field.prefixIcon,
        );

      case FormFieldType.checkbox:
        return _CheckboxField(
          label: field.label,
          value: _values[field.name] ?? false,
          onChanged: (value) {
            setState(() {
              _values[field.name] = value;
            });
          },
          enabled: field.enabled && !_isSubmitting,
        );

      case FormFieldType.radio:
        return _RadioGroupField(
          label: field.label,
          value: _values[field.name],
          options: field.options ?? [],
          onChanged: (value) {
            setState(() {
              _values[field.name] = value;
            });
          },
          validator: field.validator,
          enabled: field.enabled && !_isSubmitting,
        );

      case FormFieldType.date:
        return _DateField(
          label: field.label,
          value: _values[field.name],
          onChanged: (value) {
            setState(() {
              _values[field.name] = value;
            });
          },
          validator: field.validator,
          enabled: field.enabled && !_isSubmitting,
          hint: field.hint,
        );

      case FormFieldType.custom:
        return field.customBuilder?.call(context, _values[field.name], (value) {
              setState(() {
                _values[field.name] = value;
              });
            }) ??
            const SizedBox();
    }
  }

  TextInputType? _getKeyboardType(FormFieldType type) {
    switch (type) {
      case FormFieldType.email:
        return TextInputType.emailAddress;
      case FormFieldType.number:
        return TextInputType.number;
      case FormFieldType.multiline:
        return TextInputType.multiline;
      default:
        return TextInputType.text;
    }
  }

  Widget _buildActions() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        if (widget.onCancel != null) ...[
          BaseButton(
            label: widget.cancelLabel ?? 'Cancel',
            onPressed: _isSubmitting ? null : widget.onCancel,
            type: ButtonType.secondary,
          ),
          const SizedBox(width: AppDimens.spacingS),
        ],
        BaseButton(
          label: widget.submitLabel,
          onPressed: _isSubmitting ? null : _handleSubmit,
          loading: _isSubmitting,
        ),
      ],
    );
  }
}

// Field type enum
enum FormFieldType {
  text,
  email,
  number,
  multiline,
  dropdown,
  checkbox,
  radio,
  date,
  custom,
}

// Field configuration
class FormFieldConfig {
  final String name;
  final String label;
  final FormFieldType type;
  final String? hint;
  final dynamic initialValue;
  final List<FormOption>? options;
  final FormFieldValidator<dynamic>? validator;
  final bool enabled;
  final IconData? prefixIcon;
  final IconData? suffixIcon;
  final int? maxLines;
  final Widget Function(BuildContext, dynamic, ValueChanged<dynamic>)?
  customBuilder;

  const FormFieldConfig({
    required this.name,
    required this.label,
    required this.type,
    this.hint,
    this.initialValue,
    this.options,
    this.validator,
    this.enabled = true,
    this.prefixIcon,
    this.suffixIcon,
    this.maxLines,
    this.customBuilder,
  });
}

// Option for dropdowns and radio buttons
class FormOption {
  final String value;
  final String label;
  final IconData? icon;

  const FormOption({required this.value, required this.label, this.icon});
}

// Custom field widgets
class _DropdownField extends StatelessWidget {
  final String label;
  final String? value;
  final String? hint;
  final List<FormOption> items;
  final ValueChanged<String?>? onChanged;
  final FormFieldValidator<String?>? validator;
  final bool enabled;
  final IconData? prefixIcon;

  const _DropdownField({
    required this.label,
    this.value,
    this.hint,
    required this.items,
    this.onChanged,
    this.validator,
    this.enabled = true,
    this.prefixIcon,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return DropdownButtonFormField<String>(
      value: value,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        filled: true,
        fillColor: theme.colorScheme.surface,
        prefixIcon: prefixIcon != null ? Icon(prefixIcon) : null,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppDimens.spacingM,
          vertical: AppDimens.spacingM,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimens.radiusM),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimens.radiusM),
          borderSide: BorderSide(
            color: theme.colorScheme.outline.withOpacity(0.2),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimens.radiusM),
          borderSide: BorderSide(color: theme.colorScheme.primary, width: 2),
        ),
      ),
      items: items
          .map(
            (option) => DropdownMenuItem(
              value: option.value,
              child: Row(
                children: [
                  if (option.icon != null) ...[
                    Icon(option.icon, size: 20),
                    const SizedBox(width: AppDimens.spacingS),
                  ],
                  Text(option.label),
                ],
              ),
            ),
          )
          .toList(),
      onChanged: enabled ? onChanged : null,
      validator: validator,
    );
  }
}

class _CheckboxField extends StatelessWidget {
  final String label;
  final bool value;
  final ValueChanged<bool?>? onChanged;
  final bool enabled;

  const _CheckboxField({
    required this.label,
    required this.value,
    this.onChanged,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return CheckboxListTile(
      title: Text(label),
      value: value,
      onChanged: enabled ? onChanged : null,
      contentPadding: EdgeInsets.zero,
      controlAffinity: ListTileControlAffinity.leading,
    );
  }
}

class _RadioGroupField extends StatelessWidget {
  final String label;
  final String? value;
  final List<FormOption> options;
  final ValueChanged<String?>? onChanged;
  final FormFieldValidator<String?>? validator;
  final bool enabled;

  const _RadioGroupField({
    required this.label,
    this.value,
    required this.options,
    this.onChanged,
    this.validator,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return FormField<String>(
      initialValue: value,
      validator: validator,
      builder: (field) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: theme.textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: AppDimens.spacingS),
            ...options.map(
              (option) => RadioListTile<String>(
                title: Text(option.label),
                value: option.value,
                groupValue: field.value,
                onChanged: enabled
                    ? (value) {
                        field.didChange(value);
                        onChanged?.call(value);
                      }
                    : null,
                contentPadding: EdgeInsets.zero,
                dense: true,
              ),
            ),
            if (field.hasError) ...[
              const SizedBox(height: AppDimens.spacingXS),
              Text(
                field.errorText!,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.error,
                ),
              ),
            ],
          ],
        );
      },
    );
  }
}

class _DateField extends StatelessWidget {
  final String label;
  final DateTime? value;
  final String? hint;
  final ValueChanged<DateTime?>? onChanged;
  final FormFieldValidator<DateTime?>? validator;
  final bool enabled;

  const _DateField({
    required this.label,
    this.value,
    this.hint,
    this.onChanged,
    this.validator,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    final controller = TextEditingController(
      text: value != null ? '${value!.day}/${value!.month}/${value!.year}' : '',
    );

    return BaseTextField(
      label: label,
      hint: hint,
      controller: controller,
      readOnly: true,
      enabled: enabled,
      onTap: enabled
          ? () async {
              final picked = await showDatePicker(
                context: context,
                initialDate: value ?? DateTime.now(),
                firstDate: DateTime(1900),
                lastDate: DateTime(2100),
              );
              if (picked != null) {
                onChanged?.call(picked);
              }
            }
          : null,
      suffixIcon: const Icon(Icons.calendar_today),
      validator: validator != null ? (value) => validator!(this.value) : null,
    );
  }
}
