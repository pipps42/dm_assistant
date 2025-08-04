// lib/features/character/presentation/screens/character_dialog.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dm_assistant/features/character/models/character.dart';
import 'package:dm_assistant/features/character/providers/character_provider.dart';
import 'package:dm_assistant/features/campaign/providers/campaign_provider.dart';
import 'package:dm_assistant/features/campaign/models/campaign.dart';
import 'package:dm_assistant/shared/models/dnd_enums.dart';
import 'package:dm_assistant/shared/components/dialogs/base_dialog.dart';
import 'package:dm_assistant/shared/components/dialogs/entity_form_dialog.dart';
import 'package:dm_assistant/shared/components/forms/form_builder.dart';
import 'package:dm_assistant/core/constants/dimens.dart';
import 'package:dm_assistant/core/utils/formatting_utils.dart';
import 'package:go_router/go_router.dart';

class CharacterDialog extends ConsumerWidget {
  final Character? character;

  const CharacterDialog({super.key, this.character});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedCampaignId = ref.watch(selectedCampaignIdProvider);

    // If no campaign is selected, show error
    if (selectedCampaignId == null) {
      return BaseDialog(
        title: 'Error',
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error, size: AppDimens.iconXL, color: Colors.red),
            const SizedBox(height: 16),
            const Text('No campaign selected. Please select a campaign first.'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => context.pop(),
              child: const Text('Close'),
            ),
          ],
        ),
      );
    }

    final selectedCampaignAsync = ref.watch(
      campaignProvider(selectedCampaignId),
    );

    return selectedCampaignAsync.when(
      data: (selectedCampaign) => selectedCampaign == null
          ? const BaseDialog(
              title: 'Error',
              content: Text('Campaign not found'),
            )
          : _buildCharacterForm(
              context,
              ref,
              selectedCampaign,
              selectedCampaignId,
            ),
      loading: () => const BaseDialog(
        title: 'Loading...',
        content: CircularProgressIndicator(),
      ),
      error: (error, _) => BaseDialog(
        title: 'Error',
        content: Text('Error loading campaign: $error'),
      ),
    );
  }

  Widget _buildCharacterForm(
    BuildContext context,
    WidgetRef ref,
    Campaign selectedCampaign,
    int selectedCampaignId,
  ) {
    return EntityFormDialog<Character>(
      entity: character,
      createTitle: 'New Character',
      editTitle: 'Edit Character',
      hasImagePicker: true,
      imagePickerLabel: 'Add Avatar',
      getImagePath: (character) => character?.avatarPath,
      customValidator: (values) =>
          _validateCharacter(values, selectedCampaignId),
      fields: [
        // Character fields
        FormFieldConfig(
          name: 'name',
          label: 'Character Name',
          type: FormFieldType.text,
          hint: 'Enter character name',
          initialValue: character?.name,
          validator: (value) {
            if (value == null || value.toString().trim().isEmpty) {
              return 'Please enter a character name';
            }
            return null;
          },
          prefixIcon: Icons.person,
        ),

        FormFieldConfig(
          name: 'race',
          label: 'Race',
          type: FormFieldType.dropdown,
          initialValue: character?.race.name,
          options: DndRace.values
              .map(
                (race) => FormOption(
                  value: race.name,
                  label: FormattingUtils.formatEnumName(race.name),
                ),
              )
              .toList(),
          validator: (value) {
            if (value == null || value.toString().trim().isEmpty) {
              return 'Please select a race';
            }
            return null;
          },
          prefixIcon: Icons.groups,
        ),

        FormFieldConfig(
          name: 'characterClass',
          label: 'Class',
          type: FormFieldType.dropdown,
          initialValue: character?.characterClass.name,
          options: DndClass.values
              .map(
                (cls) => FormOption(
                  value: cls.name,
                  label: FormattingUtils.formatEnumName(cls.name),
                ),
              )
              .toList(),
          validator: (value) {
            if (value == null || value.toString().trim().isEmpty) {
              return 'Please select a class';
            }
            return null;
          },
          prefixIcon: Icons.shield,
        ),

        FormFieldConfig(
          name: 'level',
          label: 'Level',
          type: FormFieldType.number,
          hint: 'Character level (1-20)',
          initialValue: character?.level.toString() ?? '1',
          validator: (value) {
            final level = int.tryParse(value?.toString() ?? '');
            if (level == null || level < 1 || level > 20) {
              return 'Level must be between 1 and 20';
            }
            return null;
          },
          prefixIcon: Icons.trending_up,
        ),

        FormFieldConfig(
          name: 'background',
          label: 'Background (optional)',
          type: FormFieldType.dropdown,
          initialValue: character?.background?.name,
          options: DndBackground.values
              .map(
                (bg) => FormOption(
                  value: bg.name,
                  label: FormattingUtils.formatEnumName(bg.name),
                ),
              )
              .toList(),
          prefixIcon: Icons.history_edu,
        ),

        FormFieldConfig(
          name: 'alignment',
          label: 'Alignment (optional)',
          type: FormFieldType.dropdown,
          initialValue: character?.alignment?.name,
          options: DndAlignment.values
              .map(
                (alignment) => FormOption(
                  value: alignment.name,
                  label: FormattingUtils.formatEnumName(alignment.name),
                ),
              )
              .toList(),
          prefixIcon: Icons.balance,
        ),
      ],
      onSave: (context, values, imagePath) => _saveCharacter(
        context,
        ref,
        character,
        values,
        imagePath,
        selectedCampaignId,
      ),
    );
  }

  String? _validateCharacter(Map<String, dynamic> values, int campaignId) {
    // Additional validation can be added here
    return null;
  }

  Future<void> _saveCharacter(
    BuildContext context,
    WidgetRef ref,
    Character? character,
    Map<String, dynamic> values,
    String? imagePath,
    int campaignId,
  ) async {
    final notifier = ref.read(characterCrudProvider.notifier);
    final isEditing = character != null;

    // Parse enum values
    final raceValue = values['race']?.toString();
    if (raceValue == null || raceValue.isEmpty) {
      throw Exception('Race is required');
    }
    final race = DndRace.values.firstWhere(
      (r) => r.name == raceValue,
    );

    final classValue = values['characterClass']?.toString();
    if (classValue == null || classValue.isEmpty) {
      throw Exception('Class is required');
    }
    final characterClass = DndClass.values.firstWhere(
      (c) => c.name == classValue,
    );

    final backgroundValue = values['background']?.toString();
    final background = backgroundValue != null && backgroundValue.isNotEmpty
        ? DndBackground.values.firstWhere(
            (b) => b.name == backgroundValue,
          )
        : null;

    final alignmentValue = values['alignment']?.toString();
    final alignment = alignmentValue != null && alignmentValue.isNotEmpty
        ? DndAlignment.values.firstWhere(
            (a) => a.name == alignmentValue,
          )
        : null;

    if (isEditing) {
      await notifier.updateCharacter(
        campaignId: campaignId,
        id: character.id,
        name: values['name'].toString().trim(),
        race: race,
        characterClass: characterClass,
        level: int.parse(values['level'].toString()),
        background: background,
        alignment: alignment,
        avatarPath: imagePath,
      );
    } else {
      await notifier.createCharacter(
        campaignId: campaignId,
        name: values['name'].toString().trim(),
        race: race,
        characterClass: characterClass,
        level: int.parse(values['level'].toString()),
        background: background,
        alignment: alignment,
        avatarPath: imagePath,
      );
      // Force refresh of campaign characters list
      ref.invalidate(campaignCharactersProvider(campaignId));
    }
  }
}
