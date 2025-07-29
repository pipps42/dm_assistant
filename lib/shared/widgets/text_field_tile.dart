// lib/shared/widgets/text_field_tile.dart
import 'package:flutter/material.dart';

class TextFieldTile extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String? hint;
  final int? maxLines;
  final FormFieldValidator<String>? validator;

  const TextFieldTile({
    super.key,
    required this.controller,
    required this.label,
    this.hint,
    this.maxLines,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
        ),
        maxLines: maxLines,
        validator: validator,
      ),
    );
  }
}