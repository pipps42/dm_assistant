// lib/features/campaign/presentation/widgets/campaign_form_dialog.dart
import 'package:dm_assistant/core/constants/strings.dart';
import 'package:flutter/material.dart';
import 'package:dm_assistant/features/campaign/models/campaign.dart';
import 'package:dm_assistant/shared/widgets/generic_dialog.dart';
import 'package:dm_assistant/shared/widgets/text_field_tile.dart';

class CampaignFormDialog extends StatefulWidget {
  final Campaign? existing;
  const CampaignFormDialog({super.key, this.existing});

  @override
  State<CampaignFormDialog> createState() => _CampaignFormDialogState();
}

class _CampaignFormDialogState extends State<CampaignFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late final _nameCtrl = TextEditingController(text: widget.existing?.name ?? '');
  late final _descCtrl = TextEditingController(text: widget.existing?.description ?? '');

  Campaign _buildResult() => (widget.existing ?? Campaign.create(name: '')).copyWith(
        name: _nameCtrl.text.trim(),
        description: _descCtrl.text.trim(),
      );

  @override
  Widget build(BuildContext context) {
    return GenericDialog(
      title: widget.existing == null ? AppStrings.newCampaign : AppStrings.editCampaign,
      confirmText: AppStrings.save,
      onConfirm: () {
        if (_formKey.currentState!.validate()) {
          Navigator.pop(context, _buildResult());
        }
      },
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFieldTile(
              controller: _nameCtrl,
              label: AppStrings.campaignName,
              validator: (v) => v?.trim().isEmpty == true ? AppStrings.nameRequired : null,
            ),
            TextFieldTile(
              controller: _descCtrl,
              label: AppStrings.campaignDescription,
              maxLines: 3,
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }
}