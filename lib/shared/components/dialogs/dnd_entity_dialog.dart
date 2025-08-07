// lib/shared/components/dialogs/dnd_entity_dialog.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:dm_assistant/shared/providers/selected_campaign_provider.dart';
import 'package:dm_assistant/features/campaign/providers/campaign_provider.dart';
import 'package:dm_assistant/features/campaign/models/campaign.dart';
import 'package:dm_assistant/shared/components/dialogs/base_dialog.dart';
import 'package:dm_assistant/shared/components/dialogs/entity_form_dialog.dart';
import 'package:dm_assistant/shared/components/dialogs/dnd_entity_dialog_config.dart';
import 'package:dm_assistant/core/constants/dimens.dart';

/// Universal dialog for all D&D entities (Character, NPC, etc.)
class DndEntityDialog<T> extends ConsumerWidget {
  /// The entity being edited (null for create mode)
  final T? entity;

  /// Configuration for this entity type
  final DndEntityDialogConfig<T> config;

  const DndEntityDialog({super.key, this.entity, required this.config});

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
          ? BaseDialog(title: 'Error', content: Text('Campaign not found'))
          : _buildEntityForm(
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

  Widget _buildEntityForm(
    BuildContext context,
    WidgetRef ref,
    Campaign selectedCampaign,
    int selectedCampaignId,
  ) {
    return EntityFormDialog<T>(
      entity: entity,
      createTitle: config.createTitle,
      editTitle: config.editTitle,
      hasImagePicker: true,
      imagePickerLabel: config.imagePickerLabel,
      getImagePath: config.getImagePath,
      customValidator: (values) => _validateEntity(values, selectedCampaignId),
      fields: config.getAllFormFields(entity),
      onSave: (context, values, imagePath) => _saveEntity(
        context,
        ref,
        entity,
        values,
        imagePath,
        selectedCampaignId,
      ),
    );
  }

  String? _validateEntity(Map<String, dynamic> values, int campaignId) {
    // First, validate enum fields
    final enumValidationError = config.validateEnumFields(values);
    if (enumValidationError != null) {
      return enumValidationError;
    }

    // Then, run custom validation if provided
    if (config.customValidator != null) {
      return config.customValidator!(values, campaignId);
    }

    return null;
  }

  Future<void> _saveEntity(
    BuildContext context,
    WidgetRef ref,
    T? entity,
    Map<String, dynamic> values,
    String? imagePath,
    int campaignId,
  ) async {
    final isEditing = entity != null;

    try {
      // Parse enum values from form data
      final parsedValues = config.parseEnumValues(values);

      if (isEditing) {
        // Update existing entity
        await config.updateEntity(
          ref,
          entity,
          parsedValues,
          imagePath,
          campaignId,
        );
      } else {
        // Create new entity
        final newEntity = config.createEntity(
          parsedValues,
          imagePath,
          campaignId,
        );
        await config.createEntityViaProvider(ref, newEntity, campaignId);

        // Invalidate list provider if specified
        if (config.listProviderToInvalidate != null) {
          ref.invalidate(config.listProviderToInvalidate!);
        }
      }
    } catch (error) {
      throw Exception(
        'Failed to save ${config.entityName.toLowerCase()}: $error',
      );
    }
  }
}
