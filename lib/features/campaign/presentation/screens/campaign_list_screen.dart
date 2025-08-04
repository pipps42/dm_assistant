// lib/features/campaign/presentation/screens/campaign_list_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dm_assistant/core/constants/strings.dart';
import 'package:dm_assistant/features/campaign/models/campaign.dart';
import 'package:dm_assistant/features/campaign/providers/campaign_provider.dart';
import 'package:dm_assistant/features/campaign/presentation/widgets/campaign_card.dart';
import 'package:dm_assistant/features/campaign/presentation/widgets/campaign_grid_card.dart';
import 'package:dm_assistant/features/campaign/presentation/screens/campaign_dialog.dart';
import 'package:dm_assistant/shared/layouts/entity_list_screen.dart';

class CampaignListScreen extends ConsumerWidget {
  const CampaignListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return EntityListScreen<Campaign>(
      data: ref.watch(campaignListProvider),
      listItemBuilder: (campaign) => CampaignCard(campaign: campaign),
      gridItemBuilder: (campaign) => CampaignGridCard(campaign: campaign),
      createDialogBuilder: () => const CampaignDialog(),
      onRefresh: () async => ref.invalidate(campaignListProvider),
      viewModeProvider: campaignViewModeProvider,
      title: 'Campaigns',
      emptyTitle: 'No campaigns yet',
      emptyMessage: 'Create your first campaign to get started',
      createButtonLabel: AppStrings.newCampaign,
      emptyIcon: Icons.campaign_outlined,
      gridCrossAxisCount: 3,
      gridChildAspectRatio: 5 / 4,
    );
  }
}
