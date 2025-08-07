// lib/shared/components/dialogs/dnd_entity_dialog_config.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dm_assistant/shared/components/forms/form_builder.dart';
import 'package:dm_assistant/shared/components/forms/dnd_enum_field.dart';

/// Configuration for D&D entity dialogs
class DndEntityDialogConfig<T> {
  /// Name of the entity (used for titles and error messages)
  final String entityName;

  /// Title for create mode
  final String createTitle;

  /// Title for edit mode
  final String editTitle;

  /// Label for image picker
  final String imagePickerLabel;

  /// Regular form fields (text, number, etc.)
  final List<FormFieldConfig> regularFields;

  /// D&D enum fields (automatically handled)
  final List<DndEnumField> enumFields;

  /// Function to extract image path from entity
  final String? Function(T?) getImagePath;

  /// Function to create a new entity from form values
  final T Function(
    Map<String, dynamic> values,
    String? imagePath,
    int campaignId,
  )
  createEntity;

  /// Function to update an existing entity from form values
  final Future<void> Function(
    WidgetRef ref,
    T entity,
    Map<String, dynamic> values,
    String? imagePath,
    int campaignId,
  )
  updateEntity;

  /// Function to create a new entity via provider
  final Future<void> Function(WidgetRef ref, T entity, int campaignId)
  createEntityViaProvider;

  /// Additional custom validation
  final String? Function(Map<String, dynamic> values, int campaignId)?
  customValidator;

  /// Provider to invalidate after creation (for list refresh)
  final ProviderBase? listProviderToInvalidate;

  const DndEntityDialogConfig({
    required this.entityName,
    required this.createTitle,
    required this.editTitle,
    required this.imagePickerLabel,
    required this.regularFields,
    required this.enumFields,
    required this.getImagePath,
    required this.createEntity,
    required this.updateEntity,
    required this.createEntityViaProvider,
    this.customValidator,
    this.listProviderToInvalidate,
  });

  /// Gets all form fields (regular + enum fields combined)
  List<FormFieldConfig> getAllFormFields(T? entity) {
    final allFields = <FormFieldConfig>[];

    // Add regular fields
    allFields.addAll(regularFields);

    // Add enum fields converted to FormFieldConfig
    for (final enumField in enumFields) {
      // Extract initial value from entity if editing
      String? initialValue;
      if (entity != null) {
        initialValue = _getEnumValueFromEntity(entity, enumField.name);
      }

      final formFieldConfig = DndEnumFieldBuilder.buildEnumField(
        DndEnumField(
          name: enumField.name,
          label: enumField.label,
          enumType: enumField.enumType,
          icon: enumField.icon,
          isRequired: enumField.isRequired,
          initialValue: initialValue ?? enumField.initialValue,
        ),
      );

      allFields.add(formFieldConfig);
    }

    return allFields;
  }

  /// Parses enum values from form data
  Map<String, dynamic> parseEnumValues(Map<String, dynamic> formValues) {
    final parsedValues = Map<String, dynamic>.from(formValues);

    for (final enumField in enumFields) {
      final rawValue = formValues[enumField.name]?.toString();
      if (rawValue != null && rawValue.isNotEmpty) {
        // Parse the enum value based on its type
        final parsedValue = DndEnumFieldBuilder.parseEnumValue(
          rawValue,
          enumField.enumType,
        );
        parsedValues[enumField.name] = parsedValue;
      } else if (!enumField.isRequired) {
        parsedValues[enumField.name] = null;
      }
    }

    return parsedValues;
  }

  /// Validates all enum fields have required values
  String? validateEnumFields(Map<String, dynamic> formValues) {
    for (final enumField in enumFields) {
      if (enumField.isRequired) {
        final value = formValues[enumField.name]?.toString();
        if (value == null || value.trim().isEmpty) {
          return '${enumField.label} is required';
        }
      }
    }
    return null;
  }

  /// Helper method to extract enum values from entity
  String? _getEnumValueFromEntity(T entity, String fieldName) {
    // Use reflection-like approach via toString() on the entity
    // This is a simplified approach - in a real app you might use more sophisticated reflection
    try {
      switch (fieldName) {
        case 'race':
          return (entity as dynamic).race?.name;
        case 'characterClass':
          return (entity as dynamic).characterClass?.name;
        case 'alignment':
          return (entity as dynamic).alignment?.name;
        case 'background':
          return (entity as dynamic).background?.name;
        case 'creatureType':
          return (entity as dynamic).creatureType?.name;
        case 'role':
          return (entity as dynamic).role?.name;
        case 'attitude':
          return (entity as dynamic).attitude?.name;
        default:
          return null;
      }
    } catch (e) {
      // If we can't extract the value, return null
      return null;
    }
  }
}
