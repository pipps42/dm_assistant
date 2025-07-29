// lib/features/campaign/presentation/widgets/campaign_card.dart
import 'package:dm_assistant/features/campaign/presentation/widgets/edit_campaign_dialog.dart';
import 'package:dm_assistant/shared/widgets/generic_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dm_assistant/features/campaign/models/campaign.dart';
import 'package:dm_assistant/features/campaign/providers/campaign_provider.dart';
import 'package:dm_assistant/core/constants/app_colors.dart';
import 'package:intl/intl.dart';

class CampaignCard extends ConsumerWidget {
  final Campaign campaign;

  const CampaignCard({
    super.key,
    required this.campaign,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      elevation: 2,
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        title: Text(
          campaign.name,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (campaign.description != null) ...[
              const SizedBox(height: 4),
              Text(
                campaign.description!,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(
                  Icons.calendar_today,
                  size: 16,
                  color: AppColors.neutral500,
                ),
                const SizedBox(width: 4),
                Text(
                  _formatDate(campaign.createdAt),
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.neutral500,
                  ),
                ),
                if (campaign.lastPlayed != null) ...[
                  const SizedBox(width: 16),
                  const Icon(
                    Icons.access_time,
                    size: 16,
                    color: AppColors.neutral500,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Last played: ${_formatDate(campaign.lastPlayed!)}',
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.neutral500,
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
        trailing: PopupMenuButton(
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'edit',
              child: ListTile(
                leading: Icon(Icons.edit),
                title: Text('Edit'),
              ),
            ),
            const PopupMenuItem(
              value: 'delete',
              child: ListTile(
                leading: Icon(Icons.delete, color: AppColors.error),
                title: Text('Delete', style: TextStyle(color: AppColors.error)),
              ),
            ),
          ],
          onSelected: (value) => _handleMenuAction(context, ref, value),
        ),
        onTap: () {
          ref.read(selectedCampaignIdProvider.notifier).state = campaign.id;
          // TODO: Navigate to campaign dashboard
        },
      ),
    );
  }

  String _formatDate(DateTime date) {
    return DateFormat('MMM d, y').format(date);
  }

  // In campaign_card.dart, sostituisci _handleMenuAction
  Future<void> _handleMenuAction(BuildContext context, WidgetRef ref, String action) async {
    switch (action) {
      case 'edit':
        final updated = await showDialog<Campaign>(
          context: context,
          builder: (_) => CampaignFormDialog(existing: campaign),
        );
        if (updated != null) {
          await ref.read(campaignNotifierProvider.notifier).updateCampaign(updated);
          ref.invalidate(campaignsProvider);
        }
        break;
      case 'delete':
        final confirmed = await showDialog<bool>(
          context: context,
          builder: (_) => GenericDialog(
            title: 'Delete Campaign?',
            content: Text('Delete “${campaign.name}”? This cannot be undone.'),
            confirmText: 'Delete',
            cancelText: 'Cancel',
            onConfirm: () => Navigator.pop(context, true),
          ),
        );
        if (confirmed == true) {
          await ref.read(campaignNotifierProvider.notifier).deleteCampaign(campaign.id);
          ref.invalidate(campaignsProvider);
        }
        break;
    }
  }
}