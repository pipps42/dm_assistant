// lib/features/character/presentation/screens/character_dialog.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dm_assistant/features/character/models/character.dart';
import 'package:dm_assistant/shared/components/dialogs/dnd_entity_dialog.dart';
import 'package:dm_assistant/shared/components/dialogs/dnd_entity_dialog_configs.dart';

class CharacterDialog extends ConsumerWidget {
  final Character? character;

  const CharacterDialog({super.key, this.character});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Create configuration with dynamic list provider invalidation
    final config = DndEntityDialogConfigs.character;
    
    return DndEntityDialog<Character>(
      entity: character,
      config: config,
    );
  }
}
