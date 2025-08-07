// lib/shared/components/forms/dnd_enum_field.dart
import 'package:dm_assistant/shared/models/dnd_enums.dart';
import 'package:dm_assistant/shared/components/forms/form_builder.dart';
import 'package:dm_assistant/core/utils/formatting_utils.dart';
import 'package:flutter/material.dart';

/// Represents a D&D enum field configuration for forms
class DndEnumField {
  /// The name of the field in the form
  final String name;

  /// Display label for the field
  final String label;

  /// Icon to show in the field
  final IconData? icon;

  /// Whether this field is required
  final bool isRequired;

  /// The type of D&D enum this field represents
  final DndEnumType enumType;

  /// Initial value (enum name as string)
  final String? initialValue;

  const DndEnumField({
    required this.name,
    required this.label,
    required this.enumType,
    this.icon,
    this.isRequired = true,
    this.initialValue,
  });
}

/// Enum types supported by the D&D system
enum DndEnumType {
  race,
  dndClass,
  alignment,
  background,
  creatureType,
  npcRole,
  npcAttitude,
}

/// Builder class for creating D&D enum fields automatically
class DndEnumFieldBuilder {
  /// Creates a FormFieldConfig for a D&D enum field
  static FormFieldConfig buildEnumField(DndEnumField enumField) {
    return FormFieldConfig(
      name: enumField.name,
      label: enumField.label,
      type: FormFieldType.dropdown,
      initialValue: enumField.initialValue,
      options: _getEnumOptions(enumField.enumType),
      validator: enumField.isRequired
          ? (value) {
              if (value == null || value.toString().trim().isEmpty) {
                return 'Please select a ${enumField.label.toLowerCase()}';
              }
              return null;
            }
          : null,
      prefixIcon: enumField.icon,
    );
  }

  /// Parses a form value back to the appropriate enum
  static T? parseEnumValue<T>(String? value, DndEnumType enumType) {
    if (value == null || value.isEmpty) return null;

    switch (enumType) {
      case DndEnumType.race:
        return DndRace.values.firstWhere(
              (e) => e.name == value,
              orElse: () => throw ArgumentError('Invalid race value: $value'),
            )
            as T;

      case DndEnumType.dndClass:
        return DndClass.values.firstWhere(
              (e) => e.name == value,
              orElse: () => throw ArgumentError('Invalid class value: $value'),
            )
            as T;

      case DndEnumType.alignment:
        return DndAlignment.values.firstWhere(
              (e) => e.name == value,
              orElse: () =>
                  throw ArgumentError('Invalid alignment value: $value'),
            )
            as T;

      case DndEnumType.background:
        return DndBackground.values.firstWhere(
              (e) => e.name == value,
              orElse: () =>
                  throw ArgumentError('Invalid background value: $value'),
            )
            as T;

      case DndEnumType.creatureType:
        return DndCreatureType.values.firstWhere(
              (e) => e.name == value,
              orElse: () =>
                  throw ArgumentError('Invalid creature type value: $value'),
            )
            as T;

      case DndEnumType.npcRole:
        return NpcRole.values.firstWhere(
              (e) => e.name == value,
              orElse: () =>
                  throw ArgumentError('Invalid NPC role value: $value'),
            )
            as T;

      case DndEnumType.npcAttitude:
        return NpcAttitude.values.firstWhere(
              (e) => e.name == value,
              orElse: () =>
                  throw ArgumentError('Invalid NPC attitude value: $value'),
            )
            as T;
    }
  }

  /// Gets the list of FormOption for the specified enum type
  static List<FormOption> _getEnumOptions(DndEnumType enumType) {
    switch (enumType) {
      case DndEnumType.race:
        return DndRace.values
            .map(
              (race) => FormOption(
                value: race.name,
                label: FormattingUtils.formatEnumName(race.name),
              ),
            )
            .toList();

      case DndEnumType.dndClass:
        return DndClass.values
            .map(
              (cls) => FormOption(
                value: cls.name,
                label: FormattingUtils.formatEnumName(cls.name),
              ),
            )
            .toList();

      case DndEnumType.alignment:
        return DndAlignment.values
            .map(
              (alignment) => FormOption(
                value: alignment.name,
                label: FormattingUtils.formatEnumName(alignment.name),
              ),
            )
            .toList();

      case DndEnumType.background:
        return DndBackground.values
            .map(
              (bg) => FormOption(
                value: bg.name,
                label: FormattingUtils.formatEnumName(bg.name),
              ),
            )
            .toList();

      case DndEnumType.creatureType:
        return DndCreatureType.values
            .map(
              (type) => FormOption(
                value: type.name,
                label: FormattingUtils.formatEnumName(type.name),
              ),
            )
            .toList();

      case DndEnumType.npcRole:
        return NpcRole.values
            .map(
              (role) => FormOption(
                value: role.name,
                label: FormattingUtils.formatEnumName(role.name),
              ),
            )
            .toList();

      case DndEnumType.npcAttitude:
        return NpcAttitude.values
            .map(
              (attitude) => FormOption(
                value: attitude.name,
                label: FormattingUtils.formatEnumName(attitude.name),
              ),
            )
            .toList();
    }
  }

  /// Common D&D enum fields for quick access
  static const DndEnumField race = DndEnumField(
    name: 'race',
    label: 'Race',
    enumType: DndEnumType.race,
    icon: Icons.groups,
  );

  static const DndEnumField characterClass = DndEnumField(
    name: 'characterClass',
    label: 'Class',
    enumType: DndEnumType.dndClass,
    icon: Icons.shield,
  );

  static const DndEnumField alignment = DndEnumField(
    name: 'alignment',
    label: 'Alignment',
    enumType: DndEnumType.alignment,
    icon: Icons.balance,
    isRequired: false,
  );

  static const DndEnumField background = DndEnumField(
    name: 'background',
    label: 'Background',
    enumType: DndEnumType.background,
    icon: Icons.history_edu,
    isRequired: false,
  );

  static const DndEnumField creatureType = DndEnumField(
    name: 'creatureType',
    label: 'Creature Type',
    enumType: DndEnumType.creatureType,
    icon: Icons.category,
  );

  static const DndEnumField npcRole = DndEnumField(
    name: 'role',
    label: 'Role',
    enumType: DndEnumType.npcRole,
    icon: Icons.work,
  );

  static const DndEnumField npcAttitude = DndEnumField(
    name: 'attitude',
    label: 'Attitude towards Party',
    enumType: DndEnumType.npcAttitude,
    icon: Icons.mood,
  );
}
