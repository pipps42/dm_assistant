// lib/features/campaign/presentation/widgets/campaign_card.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dm_assistant/features/campaign/models/campaign.dart';
import 'package:dm_assistant/features/campaign/providers/campaign_provider.dart';
import 'package:dm_assistant/features/campaign/presentation/screens/campaign_dialog.dart';
import 'package:dm_assistant/shared/components/tiles/entity_list_tile.dart';
import 'package:dm_assistant/shared/components/menus/context_menu.dart';
import 'package:dm_assistant/shared/components/dialogs/base_dialog.dart';
import 'package:dm_assistant/shared/providers/selected_campaign_provider.dart';

class CampaignCard extends ConsumerWidget {
  final Campaign campaign;

  const CampaignCard({super.key, required this.campaign});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedCampaignId = ref.watch(selectedCampaignIdProvider);
    final isSelected = selectedCampaignId == campaign.id;
    
    return CampaignContextMenu(
      onEdit: () => _handleEdit(context, ref),
      onDelete: () => _handleDelete(context, ref),
      child: CampaignListTile(
        title: campaign.name,
        description: campaign.description,
        createdAt: campaign.createdAt,
        lastPlayed: campaign.lastPlayed,
        isSelected: isSelected,
        // playerCount: campaign.playerCount,
        onTap: () {
          ref.read(selectedCampaignIdProvider.notifier).selectCampaign(campaign.id);
          // TODO: Navigate to campaign dashboard
        },
        onEdit: () => _handleEdit(context, ref),
        onDelete: () => _handleDelete(context, ref),
      ),
    );
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
