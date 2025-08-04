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
        // Campaign info display
        // FormFieldConfig(
        //   name: 'campaign_info',
        //   label: 'Campaign',
        //   type: FormFieldType.custom,
        //   customWidget: Container(
        //     padding: const EdgeInsets.all(AppDimens.spacingM),
        //     decoration: BoxDecoration(
        //       color: Theme.of(
        //         context,
        //       ).colorScheme.surfaceVariant.withOpacity(0.3),
        //       borderRadius: BorderRadius.circular(AppDimens.radiusM),
        //     ),
        //     child: Row(
        //       children: [
        //         Icon(
        //           Icons.campaign,
        //           size: AppDimens.iconM,
        //           color: Theme.of(context).colorScheme.primary,
        //         ),
        //         const SizedBox(width: AppDimens.spacingS),
        //         Expanded(
        //           child: Column(
        //             crossAxisAlignment: CrossAxisAlignment.start,
        //             children: [
        //               Text(
        //                 'Campaign',
        //                 style: Theme.of(context).textTheme.labelSmall,
        //               ),
        //               Text(
        //                 selectedCampaign.name,
        //                 style: Theme.of(context).textTheme.bodyMedium?.copyWith(
        //                   fontWeight: FontWeight.w500,
        //                 ),
        //               ),
        //             ],
        //           ),
        //         ),
        //       ],
        //     ),
        //   ),
        // ),

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
          prefixIcon: Icons.shield,
        ),

        FormFieldConfig(
          name: 'level',
          label: 'Level',
          type: FormFieldType.number,
          hint: 'Character level (1-20)',
          initialValue: character?.level.toString(),
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
          label: 'Background',
          type: FormFieldType.dropdown,
          initialValue: character?.background?.name,
          options: [
            const FormOption(value: '', label: 'Select background (optional)'),
            ...DndBackground.values.map(
              (bg) => FormOption(
                value: bg.name,
                label: FormattingUtils.formatEnumName(bg.name),
              ),
            ),
          ],
          prefixIcon: Icons.history_edu,
        ),

        FormFieldConfig(
          name: 'alignment',
          label: 'Alignment',
          type: FormFieldType.dropdown,
          initialValue: character?.alignment?.name,
          options: [
            const FormOption(value: '', label: 'Select alignment (optional)'),
            ...DndAlignment.values.map(
              (alignment) => FormOption(
                value: alignment.name,
                label: FormattingUtils.formatEnumName(alignment.name),
              ),
            ),
          ],
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
    final race = DndRace.values.firstWhere(
      (r) => r.name == values['race'],
      orElse: () => DndRace.human,
    );

    final characterClass = DndClass.values.firstWhere(
      (c) => c.name == values['characterClass'],
      orElse: () => DndClass.fighter,
    );

    final background = values['background']?.toString().isNotEmpty == true
        ? DndBackground.values.firstWhere(
            (b) => b.name == values['background'],
            orElse: () => DndBackground.acolyte,
          )
        : null;

    final alignment = values['alignment']?.toString().isNotEmpty == true
        ? DndAlignment.values.firstWhere(
            (a) => a.name == values['alignment'],
            orElse: () => DndAlignment.lawfulGood,
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
    }
  }
}
