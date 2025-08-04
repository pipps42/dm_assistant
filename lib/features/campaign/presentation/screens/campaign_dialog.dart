// lib/features/campaign/presentation/screens/campaign_dialog.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dm_assistant/core/constants/strings.dart';
import 'package:dm_assistant/features/campaign/models/campaign.dart';
import 'package:dm_assistant/features/campaign/providers/campaign_provider.dart';
import 'package:dm_assistant/shared/components/dialogs/entity_form_dialog.dart';
import 'package:dm_assistant/shared/components/forms/form_builder.dart';

class CampaignDialog extends ConsumerWidget {
  final Campaign? campaign;

  const CampaignDialog({super.key, this.campaign});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return EntityFormDialog<Campaign>(
      entity: campaign,
      createTitle: AppStrings.newCampaign,
      editTitle: AppStrings.editCampaign,
      hasImagePicker: true,
      imagePickerLabel: 'Add Cover Image',
      getImagePath: (campaign) => campaign?.coverImagePath,
      fields: [
        FormFieldConfig(
          name: 'name',
          label: AppStrings.campaignName,
          type: FormFieldType.text,
          hint: 'Enter campaign name',
          initialValue: campaign?.name,
          validator: (value) {
            if (value == null || value.toString().trim().isEmpty) {
              return 'Please enter a campaign name';
            }
            return null;
          },
          prefixIcon: Icons.campaign,
        ),
        FormFieldConfig(
          name: 'description',
          label: AppStrings.campaignDescription,
          type: FormFieldType.multiline,
          hint: 'Optional description',
          initialValue: campaign?.description,
          maxLines: 3,
        ),
      ],
      onSave: (context, values, imagePath) => _saveCampaign(
        context,
        ref,
        campaign,
        values,
        imagePath,
      ),
    );
  }

  Future<void> _saveCampaign(
    BuildContext context,
    WidgetRef ref,
    Campaign? campaign,
    Map<String, dynamic> values,
    String? imagePath,
  ) async {
    final notifier = ref.read(campaignCrudProvider.notifier);
    final isEditing = campaign != null;

    if (isEditing) {
      await notifier.updateCampaign(
        campaign.id,
        values['name'].toString().trim(),
        values['description']?.toString().trim(),
        imagePath,
      );
    } else {
      await notifier.createCampaign(
        values['name'].toString().trim(),
        values['description']?.toString().trim(),
        imagePath,
      );
    }
  }
}
