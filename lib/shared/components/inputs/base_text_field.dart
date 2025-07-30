// lib/shared/components/inputs/base_text_field.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:dm_assistant/core/constants/dimens.dart';

class BaseTextField extends StatelessWidget {
  final String label;
  final String? hint;
  final String? helperText;
  final String? initialValue;
  final TextEditingController? controller;
  final FormFieldValidator<String>? validator;
  final ValueChanged<String>? onChanged;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final bool obscureText;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final int? maxLines;
  final int? minLines;
  final int? maxLength;
  final bool enabled;
  final bool readOnly;
  final bool autofocus;
  final FocusNode? focusNode;
  final VoidCallback? onTap;
  final TextCapitalization textCapitalization;
  final TextInputAction? textInputAction;
  final ValueChanged<String>? onFieldSubmitted;

  const BaseTextField({
    super.key,
    required this.label,
    this.hint,
    this.helperText,
    this.initialValue,
    this.controller,
    this.validator,
    this.onChanged,
    this.keyboardType,
    this.inputFormatters,
    this.obscureText = false,
    this.prefixIcon,
    this.suffixIcon,
    this.maxLines = 1,
    this.minLines,
    this.maxLength,
    this.enabled = true,
    this.readOnly = false,
    this.autofocus = false,
    this.focusNode,
    this.onTap,
    this.textCapitalization = TextCapitalization.none,
    this.textInputAction,
    this.onFieldSubmitted,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return TextFormField(
      controller: controller,
      initialValue: controller == null ? initialValue : null,
      validator: validator,
      onChanged: onChanged,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      obscureText: obscureText,
      maxLines: obscureText ? 1 : maxLines,
      minLines: minLines,
      maxLength: maxLength,
      enabled: enabled,
      readOnly: readOnly,
      autofocus: autofocus,
      focusNode: focusNode,
      onTap: onTap,
      textCapitalization: textCapitalization,
      textInputAction: textInputAction,
      onFieldSubmitted: onFieldSubmitted,
      style: theme.textTheme.bodyLarge,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        helperText: helperText,
        helperMaxLines: 2,
        prefixIcon: prefixIcon,
        suffixIcon: suffixIcon,
        filled: true,
        fillColor: theme.colorScheme.surface,
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
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimens.radiusM),
          borderSide: BorderSide(color: theme.colorScheme.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimens.radiusM),
          borderSide: BorderSide(color: theme.colorScheme.error, width: 2),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimens.radiusM),
          borderSide: BorderSide(
            color: theme.colorScheme.outline.withOpacity(0.1),
          ),
        ),
      ),
    );
  }
}
