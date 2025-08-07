// lib/features/npcs/presentation/screens/npc_dialog.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dm_assistant/features/npcs/models/npc.dart';
import 'package:dm_assistant/shared/components/dialogs/dnd_entity_dialog.dart';
import 'package:dm_assistant/shared/components/dialogs/dnd_entity_dialog_configs.dart';

class NpcDialog extends ConsumerWidget {
  final Npc? npc;

  const NpcDialog({super.key, this.npc});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Create configuration with dynamic list provider invalidation
    final config = DndEntityDialogConfigs.npc;
    
    return DndEntityDialog<Npc>(
      entity: npc,
      config: config,
    );
  }
}