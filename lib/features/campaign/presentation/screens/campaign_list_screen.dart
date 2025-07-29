// lib/features/campaign/presentation/screens/campaign_list_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dm_assistant/core/constants/strings.dart';
import 'package:dm_assistant/core/widgets/loading_widget.dart';
import 'package:dm_assistant/core/widgets/error_widget.dart';
import 'package:dm_assistant/features/campaign/models/campaign.dart';
import 'package:dm_assistant/features/campaign/providers/campaign_provider.dart';
import 'package:dm_assistant/features/campaign/presentation/widgets/campaign_card.dart';
import 'package:dm_assistant/features/campaign/presentation/screens/create_campaign_dialog.dart';

class CampaignListScreen extends ConsumerWidget {
  const CampaignListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final campaignsAsync = ref.watch(campaignsProvider);

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
      body: campaignsAsync.when(
        loading: () => const AppLoadingWidget(),
        error: (error, stack) => AppErrorWidget(
          message: error.toString(),
          onRetry: () => ref.refresh(campaignsProvider),
        ),
        data: (campaigns) => _buildCampaignList(context, campaigns, ref),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showCreateDialog(context, ref),
        icon: const Icon(Icons.add),
        label: const Text(AppStrings.newCampaign),
      ),
    );
  }

  Widget _buildCampaignList(BuildContext context, List<Campaign> campaigns, WidgetRef ref) {
    if (campaigns.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.campaign_outlined,
              size: 64,
              color: Colors.grey,
            ),
            const SizedBox(height: 16),
            Text(
              'No campaigns yet',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              'Create your first campaign to get started',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: campaigns.length,
      itemBuilder: (context, index) {
        final campaign = campaigns[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: CampaignCard(campaign: campaign),
        );
      },
    );
  }

  void _showCreateDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => const CreateCampaignDialog(),
    );
  }
}