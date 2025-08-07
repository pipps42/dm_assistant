// lib/features/npcs/presentation/screens/npc_dialog.dart
import 'package:dm_assistant/shared/providers/selected_campaign_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dm_assistant/features/npcs/models/npc.dart';
import 'package:dm_assistant/features/npcs/providers/npc_provider.dart';
import 'package:dm_assistant/features/campaign/providers/campaign_provider.dart';
import 'package:dm_assistant/features/campaign/models/campaign.dart';
import 'package:dm_assistant/shared/models/dnd_enums.dart';
import 'package:dm_assistant/shared/components/dialogs/base_dialog.dart';
import 'package:dm_assistant/shared/components/dialogs/entity_form_dialog.dart';
import 'package:dm_assistant/shared/components/forms/form_builder.dart';
import 'package:dm_assistant/core/constants/dimens.dart';
import 'package:dm_assistant/core/utils/formatting_utils.dart';
import 'package:go_router/go_router.dart';

class NpcDialog extends ConsumerWidget {
  final Npc? npc;

  const NpcDialog({super.key, this.npc});

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
          : _buildNpcForm(
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

  Widget _buildNpcForm(
    BuildContext context,
    WidgetRef ref,
    Campaign selectedCampaign,
    int selectedCampaignId,
  ) {
    return EntityFormDialog<Npc>(
      entity: npc,
      createTitle: 'New NPC',
      editTitle: 'Edit NPC',
      hasImagePicker: true,
      imagePickerLabel: 'Add Avatar',
      getImagePath: (npc) => npc?.avatarPath,
      customValidator: (values) => _validateNpc(values, selectedCampaignId),
      fields: [
        // NPC basic fields
        FormFieldConfig(
          name: 'name',
          label: 'NPC Name',
          type: FormFieldType.text,
          hint: 'Enter NPC name',
          initialValue: npc?.name,
          validator: (value) {
            if (value == null || value.toString().trim().isEmpty) {
              return 'Please enter an NPC name';
            }
            return null;
          },
          prefixIcon: Icons.person,
        ),

        FormFieldConfig(
          name: 'race',
          label: 'Race',
          type: FormFieldType.dropdown,
          initialValue: npc?.race.name,
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
          name: 'creatureType',
          label: 'Creature Type',
          type: FormFieldType.dropdown,
          initialValue: npc?.creatureType.name,
          options: DndCreatureType.values
              .map(
                (type) => FormOption(
                  value: type.name,
                  label: FormattingUtils.formatEnumName(type.name),
                ),
              )
              .toList(),
          validator: (value) {
            if (value == null || value.toString().trim().isEmpty) {
              return 'Please select a creature type';
            }
            return null;
          },
          prefixIcon: Icons.category,
        ),

        FormFieldConfig(
          name: 'role',
          label: 'Role',
          type: FormFieldType.dropdown,
          initialValue: npc?.role.name,
          options: NpcRole.values
              .map(
                (role) => FormOption(
                  value: role.name,
                  label: FormattingUtils.formatEnumName(role.name),
                ),
              )
              .toList(),
          validator: (value) {
            if (value == null || value.toString().trim().isEmpty) {
              return 'Please select a role';
            }
            return null;
          },
          prefixIcon: Icons.work,
        ),

        FormFieldConfig(
          name: 'attitude',
          label: 'Attitude towards Party',
          type: FormFieldType.dropdown,
          initialValue: npc?.attitude.name,
          options: NpcAttitude.values
              .map(
                (attitude) => FormOption(
                  value: attitude.name,
                  label: FormattingUtils.formatEnumName(attitude.name),
                ),
              )
              .toList(),
          validator: (value) {
            if (value == null || value.toString().trim().isEmpty) {
              return 'Please select an attitude';
            }
            return null;
          },
          prefixIcon: Icons.mood,
        ),

        FormFieldConfig(
          name: 'characterClass',
          label: 'Class (optional)',
          type: FormFieldType.dropdown,
          initialValue: npc?.characterClass?.name,
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
          name: 'alignment',
          label: 'Alignment (optional)',
          type: FormFieldType.dropdown,
          initialValue: npc?.alignment?.name,
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

        FormFieldConfig(
          name: 'description',
          label: 'Description (optional)',
          type: FormFieldType.multiline,
          hint: 'Describe the NPC...',
          initialValue: npc?.description,
          prefixIcon: Icons.description,
          maxLines: 4,
        ),
      ],
      onSave: (context, values, imagePath) => _saveNpc(
        context,
        ref,
        npc,
        values,
        imagePath,
        selectedCampaignId,
      ),
    );
  }

  String? _validateNpc(Map<String, dynamic> values, int campaignId) {
    // Additional validation can be added here
    return null;
  }

  Future<void> _saveNpc(
    BuildContext context,
    WidgetRef ref,
    Npc? npc,
    Map<String, dynamic> values,
    String? imagePath,
    int campaignId,
  ) async {
    final notifier = ref.read(npcCrudProvider.notifier);
    final isEditing = npc != null;

    // Parse enum values
    final raceValue = values['race']?.toString();
    if (raceValue == null || raceValue.isEmpty) {
      throw Exception('Race is required');
    }
    final race = DndRace.values.firstWhere((r) => r.name == raceValue);

    final creatureTypeValue = values['creatureType']?.toString();
    if (creatureTypeValue == null || creatureTypeValue.isEmpty) {
      throw Exception('Creature type is required');
    }
    final creatureType = DndCreatureType.values.firstWhere(
      (c) => c.name == creatureTypeValue,
    );

    final roleValue = values['role']?.toString();
    if (roleValue == null || roleValue.isEmpty) {
      throw Exception('Role is required');
    }
    final role = NpcRole.values.firstWhere((r) => r.name == roleValue);

    final attitudeValue = values['attitude']?.toString();
    if (attitudeValue == null || attitudeValue.isEmpty) {
      throw Exception('Attitude is required');
    }
    final attitude = NpcAttitude.values.firstWhere(
      (a) => a.name == attitudeValue,
    );

    final classValue = values['characterClass']?.toString();
    final characterClass = classValue != null && classValue.isNotEmpty
        ? DndClass.values.firstWhere((c) => c.name == classValue)
        : null;

    final alignmentValue = values['alignment']?.toString();
    final alignment = alignmentValue != null && alignmentValue.isNotEmpty
        ? DndAlignment.values.firstWhere((a) => a.name == alignmentValue)
        : null;

    if (isEditing) {
      await notifier.updateNpc(
        campaignId: campaignId,
        id: npc.id,
        name: values['name'].toString().trim(),
        race: race,
        creatureType: creatureType,
        role: role,
        attitude: attitude,
        characterClass: characterClass,
        alignment: alignment,
        description: values['description']?.toString().trim(),
        avatarPath: imagePath,
      );
    } else {
      await notifier.createNpc(
        campaignId: campaignId,
        name: values['name'].toString().trim(),
        race: race,
        creatureType: creatureType,
        role: role,
        attitude: attitude,
        characterClass: characterClass,
        alignment: alignment,
        description: values['description']?.toString().trim(),
        avatarPath: imagePath,
      );
      // Force refresh of campaign NPCs list
      ref.invalidate(campaignNpcsProvider(campaignId));
    }
  }
}