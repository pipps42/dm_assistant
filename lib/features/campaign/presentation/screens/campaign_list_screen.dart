// lib/features/campaign/presentation/screens/campaign_list_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dm_assistant/core/constants/strings.dart';
import 'package:dm_assistant/features/campaign/models/campaign.dart';
import 'package:dm_assistant/features/campaign/providers/campaign_provider.dart';
import 'package:dm_assistant/features/campaign/presentation/widgets/campaign_card.dart';
import 'package:dm_assistant/features/campaign/presentation/screens/create_campaign_dialog.dart';
import 'package:dm_assistant/shared/components/lists/base_list_view.dart';

class CampaignListScreen extends ConsumerWidget {
  const CampaignListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final campaignsAsync = ref.watch(campaignEntityProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.campaigns),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              // TODO: Navigate to settings
            },
          ),
        ],
      ),
      body: EntityListView<Campaign>(
        data: campaignsAsync,
        itemBuilder: (context, campaign, index) => CampaignCard(campaign: campaign),
        onRefresh: () => ref.refresh(campaignEntityProvider),
        emptyTitle: 'No campaigns yet',
        emptyMessage: 'Create your first campaign to get started',
        emptyIcon: Icons.campaign_outlined,
        onEmptyAction: () => _showCreateDialog(context, ref),
        emptyActionLabel: 'Create Campaign',
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showCreateDialog(context, ref),
        icon: const Icon(Icons.add),
        label: const Text(AppStrings.newCampaign),
      ),
    );
  }


  void _showCreateDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => const CreateCampaignDialog(),
    );
  }
}