// lib/shared/providers/form_provider.dart
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Form state class
class FormState {
  final Map<String, dynamic> values;
  final Map<String, String> errors;
  final Set<String> dirtyFields;
  final bool isSubmitting;
  final bool isValid;
  final String? submitError;

  const FormState({
    this.values = const {},
    this.errors = const {},
    this.dirtyFields = const {},
    this.isSubmitting = false,
    this.isValid = true,
    this.submitError,
  });

  FormState copyWith({
    Map<String, dynamic>? values,
    Map<String, String>? errors,
    Set<String>? dirtyFields,
    bool? isSubmitting,
    bool? isValid,
    String? submitError,
  }) {
    return FormState(
      values: values ?? this.values,
      errors: errors ?? this.errors,
      dirtyFields: dirtyFields ?? this.dirtyFields,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      isValid: isValid ?? this.isValid,
      submitError: submitError ?? this.submitError,
    );
  }

  // Get value for field
  T? getValue<T>(String fieldName) {
    final value = values[fieldName];
    return value is T ? value : null;
  }

  // Check if field has error
  bool hasError(String fieldName) => errors.containsKey(fieldName);

  // Get error for field
  String? getError(String fieldName) => errors[fieldName];

  // Check if field is dirty
  bool isDirty(String fieldName) => dirtyFields.contains(fieldName);

  // Check if form is dirty
  bool get isDirtyForm => dirtyFields.isNotEmpty;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FormState &&
          runtimeType == other.runtimeType &&
          mapEquals(values, other.values) &&
          mapEquals(errors, other.errors) &&
          setEquals(dirtyFields, other.dirtyFields) &&
          isSubmitting == other.isSubmitting &&
          isValid == other.isValid &&
          submitError == other.submitError;

  @override
  int get hashCode =>
      values.hashCode ^
      errors.hashCode ^
      dirtyFields.hashCode ^
      isSubmitting.hashCode ^
      isValid.hashCode ^
      submitError.hashCode;
}

// Form field configuration
class FormFieldConfig {
  final String name;
  final dynamic initialValue;
  final String? Function(dynamic)? validator;
  final bool required;
  final dynamic defaultValue;

  const FormFieldConfig({
    required this.name,
    this.initialValue,
    this.validator,
    this.required = false,
    this.defaultValue,
  });
}

// Form provider class
class FormProvider extends StateNotifier<FormState> {
  final Map<String, FormFieldConfig> _fieldConfigs;
  final Future<void> Function(Map<String, dynamic>)? _onSubmit;

  FormProvider({
    List<FormFieldConfig> fields = const [],
    Future<void> Function(Map<String, dynamic>)? onSubmit,
    Map<String, dynamic>? initialValues,
  }) : _fieldConfigs = {for (var field in fields) field.name: field},
       _onSubmit = onSubmit,
       super(FormState(values: _buildInitialValues(fields, initialValues)));

  static Map<String, dynamic> _buildInitialValues(
    List<FormFieldConfig> fields,
    Map<String, dynamic>? initialValues,
  ) {
    final values = <String, dynamic>{};
    for (final field in fields) {
      if (initialValues?.containsKey(field.name) == true) {
        values[field.name] = initialValues![field.name];
      } else if (field.initialValue != null) {
        values[field.name] = field.initialValue;
      } else if (field.defaultValue != null) {
        values[field.name] = field.defaultValue;
      }
    }
    return values;
  }

  // Set field value
  void setValue(String fieldName, dynamic value) {
    final newValues = {...state.values};
    newValues[fieldName] = value;

    final newDirtyFields = {...state.dirtyFields};
    newDirtyFields.add(fieldName);

    // Clear error for this field if it exists
    final newErrors = {...state.errors};
    newErrors.remove(fieldName);

    // Validate field
    final config = _fieldConfigs[fieldName];
    if (config?.validator != null) {
      final error = config!.validator!(value);
      if (error != null) {
        newErrors[fieldName] = error;
      }
    }

    final isValid = newErrors.isEmpty;

    state = state.copyWith(
      values: newValues,
      dirtyFields: newDirtyFields,
      errors: newErrors,
      isValid: isValid,
      submitError: null, // Clear submit error when form changes
    );
  }

  // Set multiple values
  void setValues(Map<String, dynamic> values) {
    final newValues = {...state.values};
    final newDirtyFields = {...state.dirtyFields};
    final newErrors = {...state.errors};

    for (final entry in values.entries) {
      newValues[entry.key] = entry.value;
      newDirtyFields.add(entry.key);
      newErrors.remove(entry.key);

      // Validate field
      final config = _fieldConfigs[entry.key];
      if (config?.validator != null) {
        final error = config!.validator!(entry.value);
        if (error != null) {
          newErrors[entry.key] = error;
        }
      }
    }

    final isValid = newErrors.isEmpty;

    state = state.copyWith(
      values: newValues,
      dirtyFields: newDirtyFields,
      errors: newErrors,
      isValid: isValid,
      submitError: null,
    );
  }

  // Clear field value
  void clearValue(String fieldName) {
    final newValues = {...state.values};
    newValues.remove(fieldName);

    final newDirtyFields = {...state.dirtyFields};
    newDirtyFields.remove(fieldName);

    final newErrors = {...state.errors};
    newErrors.remove(fieldName);

    state = state.copyWith(
      values: newValues,
      dirtyFields: newDirtyFields,
      errors: newErrors,
      isValid: newErrors.isEmpty,
    );
  }

  // Set field error
  void setError(String fieldName, String error) {
    final newErrors = {...state.errors};
    newErrors[fieldName] = error;

    state = state.copyWith(errors: newErrors, isValid: false);
  }

  // Clear field error
  void clearError(String fieldName) {
    final newErrors = {...state.errors};
    newErrors.remove(fieldName);

    state = state.copyWith(errors: newErrors, isValid: newErrors.isEmpty);
  }

  // Set multiple errors
  void setErrors(Map<String, String> errors) {
    final newErrors = {...state.errors};
    newErrors.addAll(errors);

    state = state.copyWith(errors: newErrors, isValid: newErrors.isEmpty);
  }

  // Clear all errors
  void clearErrors() {
    state = state.copyWith(errors: {}, isValid: true);
  }

  // Validate all fields
  bool validate() {
    final newErrors = <String, String>{};

    for (final entry in _fieldConfigs.entries) {
      final fieldName = entry.key;
      final config = entry.value;
      final value = state.values[fieldName];

      // Check required
      if (config.required &&
          (value == null || value.toString().trim().isEmpty)) {
        newErrors[fieldName] = 'This field is required';
        continue;
      }

      // Run custom validator
      if (config.validator != null && value != null) {
        final error = config.validator!(value);
        if (error != null) {
          newErrors[fieldName] = error;
        }
      }
    }

    state = state.copyWith(errors: newErrors, isValid: newErrors.isEmpty);

    return newErrors.isEmpty;
  }

  // Submit form
  Future<void> submit() async {
    if (_onSubmit == null) return;

    state = state.copyWith(isSubmitting: true, submitError: null);

    try {
      if (!validate()) {
        state = state.copyWith(isSubmitting: false);
        return;
      }

      await _onSubmit(state.values);
      state = state.copyWith(isSubmitting: false);
    } catch (error) {
      state = state.copyWith(
        isSubmitting: false,
        submitError: error.toString(),
      );
    }
  }

  // Reset form
  void reset() {
    final initialValues = _buildInitialValues(
      _fieldConfigs.values.toList(),
      null,
    );

    state = FormState(values: initialValues);
  }

  // Reset to initial values with custom values
  void resetWith(Map<String, dynamic> values) {
    state = FormState(values: values);
  }

  // Mark field as touched
  void touch(String fieldName) {
    final newDirtyFields = {...state.dirtyFields};
    newDirtyFields.add(fieldName);

    state = state.copyWith(dirtyFields: newDirtyFields);
  }

  // Mark all fields as touched
  void touchAll() {
    final newDirtyFields = _fieldConfigs.keys.toSet();
    state = state.copyWith(dirtyFields: newDirtyFields);
  }
}

// Global form provider factory
class FormProviderFactory {
  static StateNotifierProvider<FormProvider, FormState> create({
    required String formId,
    required List<FormFieldConfig> fields,
    Future<void> Function(Map<String, dynamic>)? onSubmit,
    Map<String, dynamic>? initialValues,
  }) {
    return StateNotifierProvider<FormProvider, FormState>(
      (ref) => FormProvider(
        fields: fields,
        onSubmit: onSubmit,
        initialValues: initialValues,
      ),
      name: 'form_$formId',
    );
  }

  // Create form provider with automatic disposal
  static AutoDisposeStateNotifierProvider<FormProvider, FormState>
  createAutoDispose({
    required List<FormFieldConfig> fields,
    Future<void> Function(Map<String, dynamic>)? onSubmit,
    Map<String, dynamic>? initialValues,
  }) {
    return StateNotifierProvider.autoDispose<FormProvider, FormState>(
      (ref) => FormProvider(
        fields: fields,
        onSubmit: onSubmit,
        initialValues: initialValues,
      ),
    );
  }
}

// Form field provider for individual fields
class FormFieldProvider extends StateNotifier<dynamic> {
  final FormProvider _formProvider;
  final String _fieldName;

  FormFieldProvider(this._formProvider, this._fieldName)
    : super(_formProvider.state.values[_fieldName]);

  void setValue(dynamic value) {
    _formProvider.setValue(_fieldName, value);
    state = value;
  }

  void clearValue() {
    _formProvider.clearValue(_fieldName);
    state = null;
  }

  void setError(String error) {
    _formProvider.setError(_fieldName, error);
  }

  void clearError() {
    _formProvider.clearError(_fieldName);
  }

  bool get hasError => _formProvider.state.hasError(_fieldName);
  String? get error => _formProvider.state.getError(_fieldName);
  bool get isDirty => _formProvider.state.isDirty(_fieldName);
}

// Specialized form providers for D&D
class CampaignFormProvider extends FormProvider {
  CampaignFormProvider({super.onSubmit, super.initialValues})
    : super(
        fields: [
          FormFieldConfig(
            name: 'name',
            required: true,
            validator: (value) {
              if (value == null || value.toString().trim().isEmpty) {
                return 'Campaign name is required';
              }
              if (value.toString().length < 3) {
                return 'Campaign name must be at least 3 characters';
              }
              return null;
            },
          ),
          FormFieldConfig(
            name: 'description',
            validator: (value) {
              if (value != null && value.toString().length > 500) {
                return 'Description must be less than 500 characters';
              }
              return null;
            },
          ),
        ],
      );
}

class CharacterFormProvider extends FormProvider {
  CharacterFormProvider({super.onSubmit, super.initialValues})
    : super(
        fields: [
          FormFieldConfig(
            name: 'name',
            required: true,
            validator: (value) {
              if (value == null || value.toString().trim().isEmpty) {
                return 'Character name is required';
              }
              return null;
            },
          ),
          FormFieldConfig(
            name: 'class',
            required: true,
            validator: (value) {
              if (value == null || value.toString().trim().isEmpty) {
                return 'Character class is required';
              }
              return null;
            },
          ),
          FormFieldConfig(
            name: 'level',
            required: true,
            initialValue: 1,
            validator: (value) {
              if (value == null) return 'Level is required';
              final level = int.tryParse(value.toString());
              if (level == null || level < 1 || level > 20) {
                return 'Level must be between 1 and 20';
              }
              return null;
            },
          ),
          FormFieldConfig(
            name: 'race',
            required: true,
            validator: (value) {
              if (value == null || value.toString().trim().isEmpty) {
                return 'Character race is required';
              }
              return null;
            },
          ),
        ],
      );
}

// Global form registry for managing multiple forms
final formRegistryProvider = StateProvider<Map<String, FormProvider>>(
  (ref) => {},
);

// Extension methods for easier form management
extension FormStateExtensions on FormState {
  // Get string value
  String? getString(String fieldName) => getValue<String>(fieldName);

  // Get int value
  int? getInt(String fieldName) {
    final value = getValue(fieldName);
    if (value is int) return value;
    if (value is String) return int.tryParse(value);
    return null;
  }

  // Get double value
  double? getDouble(String fieldName) {
    final value = getValue(fieldName);
    if (value is double) return value;
    if (value is String) return double.tryParse(value);
    if (value is int) return value.toDouble();
    return null;
  }

  // Get bool value
  bool? getBool(String fieldName) {
    final value = getValue(fieldName);
    if (value is bool) return value;
    if (value is String) {
      return value.toLowerCase() == 'true' || value == '1';
    }
    return null;
  }

  // Get DateTime value
  DateTime? getDateTime(String fieldName) {
    final value = getValue(fieldName);
    if (value is DateTime) return value;
    if (value is String) return DateTime.tryParse(value);
    return null;
  }
}
