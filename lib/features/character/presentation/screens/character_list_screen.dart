// lib/features/character/presentation/screens/character_list_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dm_assistant/features/character/models/character.dart';
import 'package:dm_assistant/features/character/providers/character_provider.dart';
import 'package:dm_assistant/features/character/presentation/widgets/character_card.dart';
import 'package:dm_assistant/features/character/presentation/widgets/character_grid_card.dart';
import 'package:dm_assistant/features/character/presentation/screens/character_dialog.dart';
import 'package:dm_assistant/features/campaign/providers/campaign_provider.dart';
import 'package:dm_assistant/shared/layouts/entity_list_screen.dart';

class CharacterListScreen extends ConsumerWidget {
  const CharacterListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedCampaignId = ref.watch(selectedCampaignIdProvider);

    return EntityListScreen<Character>(
      data: selectedCampaignId != null
          ? ref.watch(campaignCharactersProvider(selectedCampaignId))
          : const AsyncValue.data([]),
      listItemBuilder: (character) => CharacterCard(character: character),
      gridItemBuilder: (character) => CharacterGridCard(character: character),
      createDialogBuilder: () => const CharacterDialog(),
      onRefresh: () {
        if (selectedCampaignId != null) {
          ref.refresh(campaignCharactersProvider(selectedCampaignId));
        }
      },
      viewModeProvider: characterViewModeProvider,
      title: 'Characters',
      emptyTitle: 'No characters yet',
      emptyMessage: 'Create your first character to get started',
      createButtonLabel: 'New Character',
      emptyIcon: Icons.person_outline,
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

