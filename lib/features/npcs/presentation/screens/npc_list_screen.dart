// lib/features/npcs/presentation/screens/npc_list_screen.dart
import 'package:dm_assistant/shared/providers/selected_campaign_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dm_assistant/features/npcs/models/npc.dart';
import 'package:dm_assistant/features/npcs/providers/npc_provider.dart';
import 'package:dm_assistant/features/npcs/presentation/widgets/npc_card.dart';
import 'package:dm_assistant/features/npcs/presentation/widgets/npc_grid_card.dart';
import 'package:dm_assistant/features/npcs/presentation/screens/npc_dialog.dart';
import 'package:dm_assistant/shared/layouts/entity_list_screen.dart';

class NpcListScreen extends ConsumerWidget {
  const NpcListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedCampaignId = ref.watch(selectedCampaignIdProvider);

    return EntityListScreen<Npc>(
      data: selectedCampaignId != null
          ? ref.watch(campaignNpcsProvider(selectedCampaignId))
          : const AsyncValue.data([]),
      listItemBuilder: (npc) => NpcCard(npc: npc),
      gridItemBuilder: (npc) => NpcGridCard(npc: npc),
      createDialogBuilder: () => const NpcDialog(),
      onRefresh: () async {
        if (selectedCampaignId != null) {
          ref.invalidate(campaignNpcsProvider(selectedCampaignId));
        }
      },
      viewModeProvider: npcViewModeProvider,
      title: 'NPCs',
      emptyTitle: 'No NPCs yet',
      emptyMessage: 'Create your first NPC to get started',
      createButtonLabel: 'New NPC',
      emptyIcon: Icons.people_outline,
      noSelectionWidget: selectedCampaignId == null
          ? const NoSelectionWidget(
              icon: Icons.campaign_outlined,
              title: 'No campaign selected',
              message:
                  'Please select a campaign from the Campaigns section first',
            )
          : null,
    );
  }
}