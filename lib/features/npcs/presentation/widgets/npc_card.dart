// lib/features/npcs/presentation/widgets/npc_card.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dm_assistant/features/npcs/models/npc.dart';
import 'package:dm_assistant/features/npcs/providers/npc_provider.dart';
import 'package:dm_assistant/features/npcs/presentation/screens/npc_dialog.dart';
import 'package:dm_assistant/shared/components/cards/entity_card.dart';
import 'package:dm_assistant/shared/components/cards/entity_configs.dart';
import 'package:dm_assistant/shared/components/dialogs/base_dialog.dart';

class NpcCard extends ConsumerWidget {
  final Npc npc;

  const NpcCard({super.key, required this.npc});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return EntityCard<Npc>.list(
      entity: npc,
      config: EntityConfigs.npc,
      onTap: () {
        // Future: Navigate to NPC detail screen
        // context.go('/npcs/${npc.id}');
      },
      onEdit: () => _handleEdit(context, ref),
      onDelete: () => _handleDelete(context, ref),
    );
  }

  Future<void> _handleEdit(BuildContext context, WidgetRef ref) async {
    showDialog(
      context: context,
      builder: (context) => NpcDialog(npc: npc),
    );
  }

  Future<void> _handleDelete(BuildContext context, WidgetRef ref) async {
    final confirmed = await BaseDialog.show<bool>(
      context: context,
      dialog: BaseDialog.confirm(
        title: 'Delete NPC?',
        content: Text('Delete "${npc.name}"? This cannot be undone.'),
        confirmText: 'Delete',
        cancelText: 'Cancel',
      ),
    );

    if (confirmed == true) {
      await ref.read(npcCrudProvider.notifier).deleteById(npc.id);
    }
  }
}