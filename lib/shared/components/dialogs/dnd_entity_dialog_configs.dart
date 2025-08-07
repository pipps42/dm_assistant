// lib/shared/components/dialogs/dnd_entity_dialog_configs.dart
import 'package:flutter/material.dart';
import 'package:dm_assistant/features/character/models/character.dart';
import 'package:dm_assistant/features/character/providers/character_provider.dart';
import 'package:dm_assistant/features/npcs/models/npc.dart';
import 'package:dm_assistant/features/npcs/providers/npc_provider.dart';
import 'package:dm_assistant/shared/components/forms/form_builder.dart';
import 'package:dm_assistant/shared/components/forms/dnd_enum_field.dart';
import 'package:dm_assistant/shared/components/dialogs/dnd_entity_dialog_config.dart';

/// Pre-configured dialog configurations for D&D entities
class DndEntityDialogConfigs {
  /// Configuration for Character dialogs
  static DndEntityDialogConfig<Character> get character {
    return DndEntityDialogConfig<Character>(
      entityName: 'Character',
      createTitle: 'New Character',
      editTitle: 'Edit Character',
      imagePickerLabel: 'Add Avatar',

      // Regular form fields
      regularFields: [
        FormFieldConfig(
          name: 'name',
          label: 'Character Name',
          type: FormFieldType.text,
          hint: 'Enter character name',
          validator: (value) {
            if (value == null || value.toString().trim().isEmpty) {
              return 'Please enter a character name';
            }
            return null;
          },
          prefixIcon: Icons.person,
        ),
        FormFieldConfig(
          name: 'level',
          label: 'Level',
          type: FormFieldType.number,
          hint: 'Character level (1-20)',
          validator: (value) {
            final level = int.tryParse(value?.toString() ?? '');
            if (level == null || level < 1 || level > 20) {
              return 'Level must be between 1 and 20';
            }
            return null;
          },
          prefixIcon: Icons.trending_up,
        ),
      ],

      // D&D enum fields
      enumFields: [
        DndEnumFieldBuilder.race,
        DndEnumFieldBuilder.characterClass,
        DndEnumFieldBuilder.background,
        DndEnumFieldBuilder.alignment,
      ],

      getImagePath: (character) => character?.avatarPath,

      createEntity: (values, imagePath, campaignId) {
        final now = DateTime.now();
        return Character(
          name: values['name'].toString().trim(),
          avatarPath: imagePath,
          createdAt: now,
          updatedAt: now,
          campaignId: campaignId,
          race: values['race'],
          characterClass: values['characterClass'],
          level: int.parse(values['level'].toString()),
          background: values['background'],
          alignment: values['alignment'],
        );
      },

      updateEntity: (ref, character, values, imagePath, campaignId) async {
        final notifier = ref.read(characterCrudProvider.notifier);
        await notifier.updateCharacter(
          campaignId: campaignId,
          id: character.id,
          name: values['name'].toString().trim(),
          race: values['race'],
          characterClass: values['characterClass'],
          level: int.parse(values['level'].toString()),
          background: values['background'],
          alignment: values['alignment'],
          avatarPath: imagePath,
        );
      },

      createEntityViaProvider: (ref, character, campaignId) async {
        final notifier = ref.read(characterCrudProvider.notifier);
        await notifier.createCharacter(
          campaignId: campaignId,
          name: character.name,
          race: character.race,
          characterClass: character.characterClass,
          level: character.level,
          background: character.background,
          alignment: character.alignment,
          avatarPath: character.avatarPath,
        );
      },

      listProviderToInvalidate: null, // Will be set dynamically in dialog usage
    );
  }

  /// Configuration for NPC dialogs
  static DndEntityDialogConfig<Npc> get npc {
    return DndEntityDialogConfig<Npc>(
      entityName: 'NPC',
      createTitle: 'New NPC',
      editTitle: 'Edit NPC',
      imagePickerLabel: 'Add Avatar',

      // Regular form fields
      regularFields: [
        FormFieldConfig(
          name: 'name',
          label: 'NPC Name',
          type: FormFieldType.text,
          hint: 'Enter NPC name',
          validator: (value) {
            if (value == null || value.toString().trim().isEmpty) {
              return 'Please enter an NPC name';
            }
            return null;
          },
          prefixIcon: Icons.person,
        ),
        FormFieldConfig(
          name: 'description',
          label: 'Description (optional)',
          type: FormFieldType.multiline,
          hint: 'Describe the NPC...',
          prefixIcon: Icons.description,
          maxLines: 4,
        ),
      ],

      // D&D enum fields
      enumFields: [
        DndEnumFieldBuilder.race,
        DndEnumFieldBuilder.creatureType,
        DndEnumFieldBuilder.npcRole,
        DndEnumFieldBuilder.npcAttitude,
        // Optional fields
        DndEnumField(
          name: 'characterClass',
          label: 'Class (optional)',
          enumType: DndEnumType.dndClass,
          icon: Icons.shield,
          isRequired: false,
        ),
        DndEnumFieldBuilder.alignment,
      ],

      getImagePath: (npc) => npc?.avatarPath,

      createEntity: (values, imagePath, campaignId) {
        final now = DateTime.now();
        return Npc(
          name: values['name'].toString().trim(),
          avatarPath: imagePath,
          createdAt: now,
          updatedAt: now,
          campaignId: campaignId,
          race: values['race'],
          creatureType: values['creatureType'],
          role: values['role'],
          attitude: values['attitude'],
          characterClass: values['characterClass'],
          alignment: values['alignment'],
          description: values['description']?.toString().trim(),
        );
      },

      updateEntity: (ref, npc, values, imagePath, campaignId) async {
        final notifier = ref.read(npcCrudProvider.notifier);
        await notifier.updateNpc(
          campaignId: campaignId,
          id: npc.id,
          name: values['name'].toString().trim(),
          race: values['race'],
          creatureType: values['creatureType'],
          role: values['role'],
          attitude: values['attitude'],
          characterClass: values['characterClass'],
          alignment: values['alignment'],
          description: values['description']?.toString().trim(),
          avatarPath: imagePath,
        );
      },

      createEntityViaProvider: (ref, npc, campaignId) async {
        final notifier = ref.read(npcCrudProvider.notifier);
        await notifier.createNpc(
          campaignId: campaignId,
          name: npc.name,
          race: npc.race,
          creatureType: npc.creatureType,
          role: npc.role,
          attitude: npc.attitude,
          characterClass: npc.characterClass,
          alignment: npc.alignment,
          description: npc.description,
          avatarPath: npc.avatarPath,
        );
      },

      listProviderToInvalidate: null, // Will be set dynamically in dialog usage
    );
  }
}
