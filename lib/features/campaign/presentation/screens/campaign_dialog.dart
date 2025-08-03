// lib/features/campaign/presentation/screens/campaign_dialog.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:dm_assistant/core/constants/strings.dart';
import 'package:dm_assistant/features/campaign/models/campaign.dart';
import 'package:dm_assistant/features/campaign/providers/campaign_provider.dart';
import 'package:dm_assistant/shared/components/dialogs/base_dialog.dart';
import 'package:dm_assistant/shared/components/forms/form_builder.dart';

class CampaignDialog extends ConsumerStatefulWidget {
  final Campaign? campaign;
  
  const CampaignDialog({super.key, this.campaign});

  @override
  ConsumerState<CampaignDialog> createState() => _CampaignDialogState();
}

class _CampaignDialogState extends ConsumerState<CampaignDialog> {
  final ImagePicker _picker = ImagePicker();
  String? _selectedImagePath;

  @override
  void initState() {
    super.initState();
    _selectedImagePath = widget.campaign?.coverImagePath;
  }

  bool get isEditing => widget.campaign != null;

  @override
  Widget build(BuildContext context) {
    return BaseDialog(
      title: isEditing ? AppStrings.editCampaign : AppStrings.newCampaign,
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Image picker section
          _buildImagePicker(),
          const SizedBox(height: 16),
          
          // Form fields
          FormBuilder(
            fields: [
              FormFieldConfig(
                name: 'name',
                label: AppStrings.campaignName,
                type: FormFieldType.text,
                hint: 'Enter campaign name',
                initialValue: widget.campaign?.name,
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
                initialValue: widget.campaign?.description,
                maxLines: 3,
              ),
            ],
            onSubmit: (values) => _saveCampaign(context, values),
            submitLabel: isEditing ? 'Save' : 'Create',
            cancelLabel: 'Cancel',
            onCancel: () => context.pop(),
          ),
        ],
      ),
    );
  }

  Widget _buildImagePicker() {
    return Container(
      width: double.infinity,
      height: 120,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
      child: _selectedImagePath != null
          ? Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.file(
                    File(_selectedImagePath!),
                    width: double.infinity,
                    height: 120,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => _buildPlaceholder(),
                  ),
                ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: CircleAvatar(
                    radius: 16,
                    backgroundColor: Colors.black54,
                    child: IconButton(
                      icon: const Icon(Icons.close, size: 16, color: Colors.white),
                      onPressed: () => setState(() => _selectedImagePath = null),
                      padding: EdgeInsets.zero,
                    ),
                  ),
                ),
              ],
            )
          : _buildPlaceholder(),
    );
  }

  Widget _buildPlaceholder() {
    return InkWell(
      onTap: _pickImage,
      child: Container(
        width: double.infinity,
        height: 120,
        decoration: BoxDecoration(
          color: Colors.grey.shade50,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add_photo_alternate, size: 32, color: Colors.grey.shade600),
            const SizedBox(height: 8),
            Text(
              'Add Cover Image',
              style: TextStyle(color: Colors.grey.shade600),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickImage() async {
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        setState(() {
          _selectedImagePath = image.path;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error picking image: $e')),
        );
      }
    }
  }

  Future<void> _saveCampaign(BuildContext context, Map<String, dynamic> values) async {
    try {
      final notifier = ref.read(campaignEntityNotifierProvider.notifier);
      
      if (isEditing) {
        await notifier.updateCampaign(
          widget.campaign!.id,
          values['name'].toString().trim(),
          values['description']?.toString().trim(),
          _selectedImagePath,
        );
      } else {
        await notifier.createCampaign(
          values['name'].toString().trim(),
          values['description']?.toString().trim(),
          _selectedImagePath,
        );
      }

      if (context.mounted) {
        context.pop();
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