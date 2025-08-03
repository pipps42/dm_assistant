// lib/features/campaign/presentation/widgets/campaign_grid_card.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dm_assistant/features/campaign/models/campaign.dart';
import 'package:dm_assistant/features/campaign/providers/campaign_provider.dart';
import 'package:dm_assistant/features/campaign/presentation/screens/campaign_dialog.dart';
import 'package:dm_assistant/shared/components/cards/entity_card.dart';
import 'package:dm_assistant/shared/components/menus/context_menu.dart';
import 'package:dm_assistant/shared/components/dialogs/base_dialog.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

class CampaignGridCard extends ConsumerWidget {
  final Campaign campaign;

  const CampaignGridCard({super.key, required this.campaign});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return CampaignContextMenu(
      onEdit: () => _handleEdit(context, ref),
      onDelete: () => _handleDelete(context, ref),
      child: EntityCard.grid(
        title: campaign.name,
        subtitle: campaign.description,
        imagePath: campaign.coverImagePath,
        details: [
          _buildDetailRow(
            icon: Icons.calendar_today,
            label: 'Created',
            value: DateFormat('MMM d, y').format(campaign.createdAt),
          ),
          if (campaign.lastPlayed != null)
            _buildDetailRow(
              icon: Icons.play_circle_outline,
              label: 'Last played',
              value: DateFormat('MMM d, y').format(campaign.lastPlayed!),
            ),
        ],
        actions: [
          IconButton(
            icon: const Icon(Icons.edit, color: Colors.white, size: 20),
            onPressed: () => _handleEdit(context, ref),
            tooltip: 'Edit Campaign',
          ),
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.white, size: 20),
            onPressed: () => _handleDelete(context, ref),
            tooltip: 'Delete Campaign',
          ),
        ],
        onTap: () {
          ref.read(selectedCampaignIdProvider.notifier).state = campaign.id;
          // TODO: Navigate to campaign dashboard
        },
      ),
    );
  }

  Widget _buildDetailRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: 12,
          color: Colors.white.withOpacity(0.8),
        ),
        const SizedBox(width: 4),
        Flexible(
          child: Text(
            '$label: $value',
            style: const TextStyle(fontSize: 11),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
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
        onConfirm: () => context.pop(true),
        onCancel: () => context.pop(false),
        confirmText: 'Delete',
        cancelText: 'Cancel',
      ),
    );

    if (confirmed == true) {
      await ref
          .read(campaignEntityNotifierProvider.notifier)
          .deleteById(campaign.id);
    }
  }
}