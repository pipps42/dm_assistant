// lib/features/campaign/presentation/screens/campaign_list_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dm_assistant/core/constants/strings.dart';
import 'package:dm_assistant/features/campaign/models/campaign.dart';
import 'package:dm_assistant/features/campaign/providers/campaign_provider.dart';
import 'package:dm_assistant/features/campaign/presentation/widgets/campaign_card.dart';
import 'package:dm_assistant/features/campaign/presentation/widgets/campaign_grid_card.dart';
import 'package:dm_assistant/features/campaign/presentation/screens/campaign_dialog.dart';
import 'package:dm_assistant/shared/components/lists/base_list_view.dart';

class CampaignListScreen extends ConsumerWidget {
  const CampaignListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final campaignsAsync = ref.watch(campaignEntityProvider);
    final viewMode = ref.watch(campaignViewModeProvider);

    return Scaffold(
      body: Column(
        children: [
          // View toggle
          _buildViewToggle(context, ref, viewMode),
          
          // Content
          Expanded(
            child: campaignsAsync.when(
              data: (campaigns) => campaigns.isEmpty 
                ? _buildEmptyState(context, ref)
                : viewMode == CampaignViewMode.list
                  ? _buildListView(campaigns, ref)
                  : _buildGridView(campaigns),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) => Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline, size: 64, color: Colors.red),
                    const SizedBox(height: 16),
                    Text('Error: $error'),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => ref.refresh(campaignEntityProvider),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showCreateDialog(context, ref),
        icon: const Icon(Icons.add),
        label: const Text(AppStrings.newCampaign),
      ),
    );
  }


  Widget _buildViewToggle(BuildContext context, WidgetRef ref, CampaignViewMode viewMode) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          SegmentedButton<CampaignViewMode>(
            segments: const [
              ButtonSegment(
                value: CampaignViewMode.list,
                icon: Icon(Icons.list),
                label: Text('List'),
              ),
              ButtonSegment(
                value: CampaignViewMode.grid,
                icon: Icon(Icons.grid_view),
                label: Text('Grid'),
              ),
            ],
            selected: {viewMode},
            onSelectionChanged: (Set<CampaignViewMode> selected) {
              ref.read(campaignViewModeProvider.notifier).state = selected.first;
            },
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, WidgetRef ref) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.campaign_outlined, size: 64, color: Colors.grey),
          const SizedBox(height: 16),
          const Text(
            'No campaigns yet',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 8),
          const Text(
            'Create your first campaign to get started',
            style: TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => _showCreateDialog(context, ref),
            icon: const Icon(Icons.add),
            label: const Text('Create Campaign'),
          ),
        ],
      ),
    );
  }

  Widget _buildListView(List<Campaign> campaigns, WidgetRef ref) {
    return RefreshIndicator(
      onRefresh: () async => ref.refresh(campaignEntityProvider),
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: campaigns.length,
        itemBuilder: (context, index) => CampaignCard(campaign: campaigns[index]),
      ),
    );
  }

  Widget _buildGridView(List<Campaign> campaigns) {
    return RefreshIndicator(
      onRefresh: () async {},
      child: GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          childAspectRatio: 5 / 4,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
        ),
        itemCount: campaigns.length,
        itemBuilder: (context, index) => CampaignGridCard(campaign: campaigns[index]),
      ),
    );
  }

  void _showCreateDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => const CampaignDialog(),
    );
  }
}