// lib/shared/widgets/form_builder.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:dm_assistant/core/constants/app_colors.dart';
import 'package:dm_assistant/core/constants/dimens.dart';
import 'package:dm_assistant/core/utils/validators.dart';
import 'package:dm_assistant/core/responsive/responsive_builder.dart';

/// Callback per quando il form viene submitted
typedef FormSubmitCallback = void Function(Map<String, dynamic> formData);

/// Callback per quando il form cambia
typedef FormChangeCallback = void Function(Map<String, dynamic> formData);

/// Modello base per un campo del form
abstract class FormField {
  final String key;
  final String label;
  final String? hint;
  final bool required;
  final bool enabled;
  final String? Function(String?)? validator;
  final dynamic initialValue;
  final int? flex;
  final bool fullWidth;

  const FormField({
    required this.key,
    required this.label,
    this.hint,
    this.required = false,
    this.enabled = true,
    this.validator,
    this.initialValue,
    this.flex,
    this.fullWidth = false,
  });

  Widget build(
    BuildContext context,
    Map<String, dynamic> formData,
    Function(String key, dynamic value) onChanged,
  );
}

/// Campo di testo
class TextFormField extends FormField {
  final int? maxLines;
  final int? maxLength;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final bool obscureText;
  final Widget? suffixIcon;
  final Widget? prefixIcon;

  const TextFormField({
    required super.key,
    required super.label,
    super.hint,
    super.required,
    super.enabled,
    super.validator,
    super.initialValue,
    super.flex,
    super.fullWidth,
    this.maxLines = 1,
    this.maxLength,
    this.keyboardType,
    this.inputFormatters,
    this.obscureText = false,
    this.suffixIcon,
    this.prefixIcon,
  });

  @override
  Widget build(
    BuildContext context,
    Map<String, dynamic> formData,
    Function(String key, dynamic value) onChanged,
  ) {
    return AppTextFormField(
      key: ValueKey(key),
      label: label,
      hint: hint,
      initialValue: formData[key]?.toString() ?? initialValue?.toString() ?? '',
      maxLines: maxLines,
      maxLength: maxLength,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      obscureText: obscureText,
      suffixIcon: suffixIcon,
      prefixIcon: prefixIcon,
      enabled: enabled,
      validator: validator ?? (required ? AppValidators.required : null),
      onChanged: (value) => onChanged(key, value),
    );
  }
}

/// Campo numerico
class NumberFormField extends FormField {
  final double? min;
  final double? max;
  final int? decimals;
  final bool allowNegative;

  const NumberFormField({
    required super.key,
    required super.label,
    super.hint,
    super.required,
    super.enabled,
    super.validator,
    super.initialValue,
    super.flex,
    super.fullWidth,
    this.min,
    this.max,
    this.decimals,
    this.allowNegative = true,
  });

  @override
  Widget build(
    BuildContext context,
    Map<String, dynamic> formData,
    Function(String key, dynamic value) onChanged,
  ) {
    return AppTextFormField(
      key: ValueKey(key),
      label: label,
      hint: hint,
      initialValue: formData[key]?.toString() ?? initialValue?.toString() ?? '',
      keyboardType: TextInputType.numberWithOptions(
        decimal: decimals != null && decimals! > 0,
        signed: allowNegative,
      ),
      inputFormatters: [
        if (!allowNegative) FilteringTextInputFormatter.deny(RegExp(r'-')),
        if (decimals == null || decimals == 0)
          FilteringTextInputFormatter.digitsOnly
        else
          FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
      ],
      enabled: enabled,
      validator: validator ?? _buildNumberValidator(),
      onChanged: (value) {
        final numValue = double.tryParse(value);
        onChanged(key, numValue);
      },
    );
  }

  String? Function(String?) _buildNumberValidator() {
    return (value) {
      if (required && (value == null || value.trim().isEmpty)) {
        return AppValidators.required(value, label);
      }

      if (value != null && value.trim().isNotEmpty) {
        final numValue = double.tryParse(value);
        if (numValue == null) {
          return '$label must be a valid number';
        }

        if (min != null && numValue < min!) {
          return '$label must be at least $min';
        }

        if (max != null && numValue > max!) {
          return '$label must be at most $max';
        }
      }

      return null;
    };
  }
}

/// Campo dropdown
class DropdownFormField<T> extends FormField {
  final List<DropdownOption<T>> options;
  final bool allowClear;

  const DropdownFormField({
    required super.key,
    required super.label,
    required this.options,
    super.hint,
    super.required,
    super.enabled,
    super.validator,
    super.initialValue,
    super.flex,
    super.fullWidth,
    this.allowClear = false,
  });

  @override
  Widget build(
    BuildContext context,
    Map<String, dynamic> formData,
    Function(String key, dynamic value) onChanged,
  ) {
    return AppDropdownFormField<T>(
      key: ValueKey(key),
      label: label,
      hint: hint,
      options: options,
      value: formData[key] ?? initialValue,
      allowClear: allowClear,
      enabled: enabled,
      validator:
          validator ??
          (required
              ? (value) => value == null ? '$label is required' : null
              : null),
      onChanged: (value) => onChanged(key, value),
    );
  }
}

/// Campo checkbox
class CheckboxFormField extends FormField {
  final String? subtitle;

  const CheckboxFormField({
    required super.key,
    required super.label,
    super.enabled,
    super.initialValue,
    super.flex,
    super.fullWidth,
    this.subtitle,
  });

  @override
  Widget build(
    BuildContext context,
    Map<String, dynamic> formData,
    Function(String key, dynamic value) onChanged,
  ) {
    final isChecked = formData[key] ?? initialValue ?? false;

    return CheckboxListTile(
      key: ValueKey(key),
      title: Text(label),
      subtitle: subtitle != null ? Text(subtitle!) : null,
      value: isChecked,
      enabled: enabled,
      onChanged: (value) => onChanged(key, value ?? false),
      controlAffinity: ListTileControlAffinity.leading,
      contentPadding: EdgeInsets.zero,
    );
  }
}

/// Campo radio group
class RadioGroupFormField<T> extends FormField {
  final List<RadioOption<T>> options;
  final bool horizontal;

  const RadioGroupFormField({
    required super.key,
    required super.label,
    required this.options,
    super.required,
    super.enabled,
    super.initialValue,
    super.flex,
    super.fullWidth,
    this.horizontal = false,
  });

  @override
  Widget build(
    BuildContext context,
    Map<String, dynamic> formData,
    Function(String key, dynamic value) onChanged,
  ) {
    final selectedValue = formData[key] ?? initialValue;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: AppDimens.spacingS),
        horizontal
            ? Wrap(
                spacing: AppDimens.spacingM,
                children: options
                    .map(
                      (option) => _buildRadio(
                        context,
                        option,
                        selectedValue,
                        onChanged,
                      ),
                    )
                    .toList(),
              )
            : Column(
                children: options
                    .map(
                      (option) => _buildRadio(
                        context,
                        option,
                        selectedValue,
                        onChanged,
                      ),
                    )
                    .toList(),
              ),
      ],
    );
  }

  Widget _buildRadio(
    BuildContext context,
    RadioOption<T> option,
    T? selectedValue,
    Function(String key, dynamic value) onChanged,
  ) {
    return RadioListTile<T>(
      title: Text(option.label),
      subtitle: option.subtitle != null ? Text(option.subtitle!) : null,
      value: option.value,
      groupValue: selectedValue,
      enabled: enabled,
      onChanged: (value) => onChanged(key, value),
      contentPadding: EdgeInsets.zero,
      dense: true,
    );
  }
}

/// Campo data
class DateFormField extends FormField {
  final DateTime? firstDate;
  final DateTime? lastDate;
  final bool showTime;

  const DateFormField({
    required super.key,
    required super.label,
    super.hint,
    super.required,
    super.enabled,
    super.validator,
    super.initialValue,
    super.flex,
    super.fullWidth,
    this.firstDate,
    this.lastDate,
    this.showTime = false,
  });

  @override
  Widget build(
    BuildContext context,
    Map<String, dynamic> formData,
    Function(String key, dynamic value) onChanged,
  ) {
    return AppDateFormField(
      key: ValueKey(key),
      label: label,
      hint: hint,
      value: formData[key] ?? initialValue,
      firstDate: firstDate,
      lastDate: lastDate,
      showTime: showTime,
      enabled: enabled,
      validator:
          validator ??
          (required
              ? (value) => value == null ? '$label is required' : null
              : null),
      onChanged: (value) => onChanged(key, value),
    );
  }
}

/// Form builder principale
class AppFormBuilder extends StatefulWidget {
  final List<FormField> fields;
  final FormSubmitCallback? onSubmit;
  final FormChangeCallback? onChanged;
  final Map<String, dynamic>? initialData;
  final String? submitButtonText;
  final bool showSubmitButton;
  final bool enableAutovalidate;
  final int crossAxisCount;
  final double crossAxisSpacing;
  final double mainAxisSpacing;

  const AppFormBuilder({
    super.key,
    required this.fields,
    this.onSubmit,
    this.onChanged,
    this.initialData,
    this.submitButtonText,
    this.showSubmitButton = true,
    this.enableAutovalidate = false,
    this.crossAxisCount = 1,
    this.crossAxisSpacing = AppDimens.spacingM,
    this.mainAxisSpacing = AppDimens.spacingM,
  });

  @override
  State<AppFormBuilder> createState() => _AppFormBuilderState();
}

class _AppFormBuilderState extends State<AppFormBuilder> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late Map<String, dynamic> _formData;

  @override
  void initState() {
    super.initState();
    _formData = Map<String, dynamic>.from(widget.initialData ?? {});

    // Inizializza con i valori di default dei campi
    for (final field in widget.fields) {
      if (!_formData.containsKey(field.key) && field.initialValue != null) {
        _formData[field.key] = field.initialValue;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return ResponsiveBuilder(
      mobile: _buildMobileForm(context),
      desktop: _buildDesktopForm(context),
    );
  }

  Widget _buildMobileForm(BuildContext context) {
    return _buildForm(context, useSingleColumn: true);
  }

  Widget _buildDesktopForm(BuildContext context) {
    return _buildForm(context, useSingleColumn: widget.crossAxisCount <= 1);
  }

  Widget _buildForm(BuildContext context, {required bool useSingleColumn}) {
    return Form(
      key: _formKey,
      autovalidateMode: widget.enableAutovalidate
          ? AutovalidateMode.onUserInteraction
          : AutovalidateMode.disabled,
      child: Column(
        children: [
          if (useSingleColumn)
            ..._buildSingleColumnFields(context)
          else
            _buildGridFields(context),

          if (widget.showSubmitButton) ...[
            const SizedBox(height: AppDimens.spacingL),
            _buildSubmitButton(context),
          ],
        ],
      ),
    );
  }

  List<Widget> _buildSingleColumnFields(BuildContext context) {
    return widget.fields
        .map(
          (field) => Padding(
            padding: const EdgeInsets.only(bottom: AppDimens.spacingM),
            child: field.build(context, _formData, _onFieldChanged),
          ),
        )
        .toList();
  }

  Widget _buildGridFields(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: widget.crossAxisCount,
        crossAxisSpacing: widget.crossAxisSpacing,
        mainAxisSpacing: widget.mainAxisSpacing,
        childAspectRatio: 3.0, // Adjust based on field height
      ),
      itemCount: widget.fields.length,
      itemBuilder: (context, index) {
        final field = widget.fields[index];
        return field.build(context, _formData, _onFieldChanged);
      },
    );
  }

  Widget _buildSubmitButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _submitForm,
        child: Text(widget.submitButtonText ?? 'Submit'),
      ),
    );
  }

  void _onFieldChanged(String key, dynamic value) {
    setState(() {
      _formData[key] = value;
    });
    widget.onChanged?.call(_formData);
  }

  void _submitForm() {
    if (_formKey.currentState?.validate() ?? false) {
      widget.onSubmit?.call(_formData);
    }
  }
}

/// Modello per opzioni dropdown
class DropdownOption<T> {
  final T value;
  final String label;
  final IconData? icon;
  final bool enabled;

  const DropdownOption({
    required this.value,
    required this.label,
    this.icon,
    this.enabled = true,
  });
}

/// Modello per opzioni radio
class RadioOption<T> {
  final T value;
  final String label;
  final String? subtitle;

  const RadioOption({required this.value, required this.label, this.subtitle});
}

/// Widget text form field personalizzato
class AppTextFormField extends StatelessWidget {
  final String label;
  final String? hint;
  final String? initialValue;
  final int? maxLines;
  final int? maxLength;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final bool obscureText;
  final Widget? suffixIcon;
  final Widget? prefixIcon;
  final bool enabled;
  final String? Function(String?)? validator;
  final ValueChanged<String>? onChanged;

  const AppTextFormField({
    super.key,
    required this.label,
    this.hint,
    this.initialValue,
    this.maxLines,
    this.maxLength,
    this.keyboardType,
    this.inputFormatters,
    this.obscureText = false,
    this.suffixIcon,
    this.prefixIcon,
    this.enabled = true,
    this.validator,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      initialValue: initialValue,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        suffixIcon: suffixIcon,
        prefixIcon: prefixIcon,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimens.radiusM),
        ),
      ),
      maxLines: maxLines,
      maxLength: maxLength,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      obscureText: obscureText,
      enabled: enabled,
      validator: validator,
      onChanged: onChanged,
    );
  }
}

/// Widget dropdown form field personalizzato
class AppDropdownFormField<T> extends StatelessWidget {
  final String label;
  final String? hint;
  final List<DropdownOption<T>> options;
  final T? value;
  final bool allowClear;
  final bool enabled;
  final String? Function(T?)? validator;
  final ValueChanged<T?>? onChanged;

  const AppDropdownFormField({
    super.key,
    required this.label,
    this.hint,
    required this.options,
    this.value,
    this.allowClear = false,
    this.enabled = true,
    this.validator,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<T>(
      value: value,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimens.radiusM),
        ),
        suffixIcon: allowClear && value != null
            ? IconButton(
                icon: const Icon(Icons.clear),
                onPressed: enabled ? () => onChanged?.call(null) : null,
              )
            : null,
      ),
      items: options
          .map(
            (option) => DropdownMenuItem<T>(
              value: option.value,
              enabled: option.enabled,
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

/// Widget date form field personalizzato
class AppDateFormField extends StatelessWidget {
  final String label;
  final String? hint;
  final DateTime? value;
  final DateTime? firstDate;
  final DateTime? lastDate;
  final bool showTime;
  final bool enabled;
  final String? Function(DateTime?)? validator;
  final ValueChanged<DateTime?>? onChanged;

  const AppDateFormField({
    super.key,
    required this.label,
    this.hint,
    this.value,
    this.firstDate,
    this.lastDate,
    this.showTime = false,
    this.enabled = true,
    this.validator,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return FormField<DateTime>(
      initialValue: value,
      validator: validator,
      builder: (field) {
        return InputDecorator(
          decoration: InputDecoration(
            labelText: label,
            hintText: hint,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppDimens.radiusM),
            ),
            suffixIcon: const Icon(Icons.calendar_today),
            errorText: field.errorText,
          ),
          child: InkWell(
            onTap: enabled ? () => _selectDate(context, field) : null,
            child: Text(
              value != null
                  ? (showTime
                        ? '${value!.day}/${value!.month}/${value!.year} ${value!.hour}:${value!.minute.toString().padLeft(2, '0')}'
                        : '${value!.day}/${value!.month}/${value!.year}')
                  : hint ?? 'Select date',
              style: TextStyle(
                color: value != null
                    ? Theme.of(context).textTheme.bodyLarge?.color
                    : Theme.of(context).hintColor,
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _selectDate(
    BuildContext context,
    FormFieldState<DateTime> field,
  ) async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: value ?? DateTime.now(),
      firstDate: firstDate ?? DateTime(1900),
      lastDate: lastDate ?? DateTime(2100),
    );

    if (pickedDate != null) {
      DateTime finalDate = pickedDate;

      if (showTime) {
        final pickedTime = await showTimePicker(
          context: context,
          initialTime: value != null
              ? TimeOfDay.fromDateTime(value!)
              : TimeOfDay.now(),
        );

        if (pickedTime != null) {
          finalDate = DateTime(
            pickedDate.year,
            pickedDate.month,
            pickedDate.day,
            pickedTime.hour,
            pickedTime.minute,
          );
        }
      }

      field.didChange(finalDate);
      onChanged?.call(finalDate);
    }
  }
}

/// Utility per creare form comuni nell'app
class DMFormBuilders {
  /// Form per creare/modificare campagna
  static List<FormField> campaignForm() {
    return [
      const TextFormField(
        key: 'name',
        label: 'Campaign Name',
        hint: 'Enter campaign name',
        required: true,
        validator: AppValidators.campaignName,
      ),
      const TextFormField(
        key: 'description',
        label: 'Description',
        hint: 'Describe your campaign',
        maxLines: 3,
      ),
      DropdownFormField<String>(
        key: 'setting',
        label: 'Setting',
        options: const [
          DropdownOption(value: 'forgotten_realms', label: 'Forgotten Realms'),
          DropdownOption(value: 'homebrew', label: 'Homebrew'),
          DropdownOption(value: 'eberron', label: 'Eberron'),
          DropdownOption(value: 'other', label: 'Other'),
        ],
      ),
      const NumberFormField(
        key: 'max_players',
        label: 'Max Players',
        min: 1,
        max: 10,
        decimals: 0,
        allowNegative: false,
      ),
    ];
  }

  /// Form per creare/modificare personaggio
  static List<FormField> characterForm() {
    return [
      const TextFormField(
        key: 'name',
        label: 'Character Name',
        required: true,
        validator: AppValidators.characterName,
      ),
      DropdownFormField<String>(
        key: 'race',
        label: 'Race',
        required: true,
        options: const [
          DropdownOption(value: 'human', label: 'Human'),
          DropdownOption(value: 'elf', label: 'Elf'),
          DropdownOption(value: 'dwarf', label: 'Dwarf'),
          DropdownOption(value: 'halfling', label: 'Halfling'),
          DropdownOption(value: 'dragonborn', label: 'Dragonborn'),
          DropdownOption(value: 'gnome', label: 'Gnome'),
          DropdownOption(value: 'half_elf', label: 'Half-Elf'),
          DropdownOption(value: 'half_orc', label: 'Half-Orc'),
          DropdownOption(value: 'tiefling', label: 'Tiefling'),
        ],
      ),
      DropdownFormField<String>(
        key: 'class',
        label: 'Class',
        required: true,
        options: const [
          DropdownOption(value: 'barbarian', label: 'Barbarian'),
          DropdownOption(value: 'bard', label: 'Bard'),
          DropdownOption(value: 'cleric', label: 'Cleric'),
          DropdownOption(value: 'druid', label: 'Druid'),
          DropdownOption(value: 'fighter', label: 'Fighter'),
          DropdownOption(value: 'monk', label: 'Monk'),
          DropdownOption(value: 'paladin', label: 'Paladin'),
          DropdownOption(value: 'ranger', label: 'Ranger'),
          DropdownOption(value: 'rogue', label: 'Rogue'),
          DropdownOption(value: 'sorcerer', label: 'Sorcerer'),
          DropdownOption(value: 'warlock', label: 'Warlock'),
          DropdownOption(value: 'wizard', label: 'Wizard'),
        ],
      ),
      const NumberFormField(
        key: 'level',
        label: 'Level',
        min: 1,
        max: 20,
        decimals: 0,
        allowNegative: false,
        initialValue: 1,
      ),
    ];
  }
}
