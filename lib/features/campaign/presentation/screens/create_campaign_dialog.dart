// lib/features/campaign/presentation/screens/create_campaign_dialog.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dm_assistant/core/constants/strings.dart';
import 'package:dm_assistant/features/campaign/providers/campaign_provider.dart';

class CreateCampaignDialog extends ConsumerStatefulWidget {
  const CreateCampaignDialog({super.key});

  @override
  ConsumerState<CreateCampaignDialog> createState() => _CreateCampaignDialogState();
}

class _CreateCampaignDialogState extends ConsumerState<CreateCampaignDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text(AppStrings.newCampaign),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: AppStrings.campaignName,
                hintText: 'Enter campaign name',
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter a campaign name';
                }
                return null;
              },
              autofocus: true,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: AppStrings.campaignDescription,
                hintText: 'Optional description',
              ),
              maxLines: 3,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _isLoading ? null : _createCampaign,
          child: const Text('Create'),
        ),
      ],
    );
  }

  Future<void> _createCampaign() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final notifier = ref.read(campaignNotifierProvider.notifier);
    await notifier.createCampaign(
      _nameController.text.trim(),
      _descriptionController.text.trim(),
    );

    if (mounted) {
      final state = ref.read(campaignNotifierProvider);
      state.when(
        data: (_) {
          Navigator.pop(context);
          ref.invalidate(campaignsProvider);
        },
        error: (error, _) {
          setState(() => _isLoading = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: $error')),
          );
        },
        loading: () {},
      );
    }
  }
}