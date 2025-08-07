// lib/features/campaign/presentation/widgets/campaign_grid_card.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dm_assistant/features/campaign/models/campaign.dart';
import 'package:dm_assistant/features/campaign/providers/campaign_provider.dart';
import 'package:dm_assistant/features/campaign/presentation/screens/campaign_dialog.dart';
import 'package:dm_assistant/shared/components/cards/entity_card.dart';
import 'package:dm_assistant/shared/components/cards/entity_configs.dart';
import 'package:dm_assistant/shared/components/dialogs/base_dialog.dart';
import 'package:dm_assistant/shared/providers/selected_campaign_provider.dart';

class CampaignGridCard extends ConsumerWidget {
  final Campaign campaign;

  const CampaignGridCard({super.key, required this.campaign});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedCampaignId = ref.watch(selectedCampaignIdProvider);
    final isSelected = selectedCampaignId == campaign.id;

    return EntityCard<Campaign>.grid(
      entity: campaign,
      config: EntityConfigs.campaign,
      isSelected: isSelected,
      onTap: () => _handleSelect(ref),
      onEdit: () => _handleEdit(context, ref),
      onDelete: () => _handleDelete(context, ref),
    );
  }

  void _handleSelect(WidgetRef ref) {
    ref.read(selectedCampaignIdProvider.notifier).state = campaign.id;
  }

  Future<void> _handleEdit(BuildContext context, WidgetRef ref) async {
    showDialog(
      context: context,
      builder: (context) => CampaignDialog(campaign: campaign),
    );
  }

  Future<void> _handleDelete(BuildContext context, WidgetRef ref) async {
    final confirmed = await BaseDialog.show<bool>(
      context: context,
      dialog: BaseDialog.confirm(
        title: 'Delete Campaign?',
        content: Text('Delete "${campaign.name}"? This cannot be undone.'),
        confirmText: 'Delete',
        cancelText: 'Cancel',
      ),
    );

    if (confirmed == true) {
      await ref.read(campaignCrudProvider.notifier).deleteById(campaign.id);
    }
  }
}