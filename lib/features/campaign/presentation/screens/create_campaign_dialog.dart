// lib/features/campaign/presentation/screens/create_campaign_dialog.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dm_assistant/core/constants/strings.dart';
import 'package:dm_assistant/features/campaign/providers/campaign_provider.dart';
import 'package:dm_assistant/shared/components/dialogs/base_dialog.dart';
import 'package:dm_assistant/shared/components/forms/form_builder.dart';

class CreateCampaignDialog extends ConsumerWidget {
  const CreateCampaignDialog({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return BaseDialog(
      title: AppStrings.newCampaign,
      content: FormBuilder(
        fields: [
          FormFieldConfig(
            name: 'name',
            label: AppStrings.campaignName,
            type: FormFieldType.text,
            hint: 'Enter campaign name',
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
            maxLines: 3,
          ),
        ],
        onSubmit: (values) => _createCampaign(context, ref, values),
        submitLabel: 'Create',
        cancelLabel: 'Cancel',
        onCancel: () => Navigator.pop(context),
      ),
    );
  }

  Future<void> _createCampaign(BuildContext context, WidgetRef ref, Map<String, dynamic> values) async {
    try {
      final notifier = ref.read(campaignEntityNotifierProvider.notifier);
      await notifier.createCampaign(
        values['name'].toString().trim(),
        values['description']?.toString().trim(),
      );

      if (context.mounted) {
        Navigator.pop(context);
      }
    } catch (error) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $error')),
        );
      }
    }
  }
}