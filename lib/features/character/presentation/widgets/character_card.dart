// lib/features/character/presentation/widgets/character_card.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:dm_assistant/features/character/models/character.dart';
import 'package:dm_assistant/features/character/providers/character_provider.dart';
import 'package:dm_assistant/features/character/presentation/screens/character_dialog.dart';
import 'package:dm_assistant/shared/components/cards/entity_card.dart';
import 'package:dm_assistant/shared/components/cards/entity_configs.dart';
import 'package:dm_assistant/shared/components/dialogs/base_dialog.dart';

class CharacterCard extends ConsumerWidget {
  final Character character;

  const CharacterCard({super.key, required this.character});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return EntityCard<Character>.list(
      entity: character,
      config: EntityConfigs.character,
      onTap: () {
        context.go('/characters/${character.id}');
      },
      onEdit: () => _handleEdit(context, ref),
      onDelete: () => _handleDelete(context, ref),
    );
  }

  Future<void> _handleEdit(BuildContext context, WidgetRef ref) async {
    showDialog(
      context: context,
      builder: (context) => CharacterDialog(character: character),
    );
  }

  Future<void> _handleDelete(BuildContext context, WidgetRef ref) async {
    final confirmed = await BaseDialog.show<bool>(
      context: context,
      dialog: BaseDialog.confirm(
        title: 'Delete Character?',
        content: Text('Delete "${character.name}"? This cannot be undone.'),
        confirmText: 'Delete',
        cancelText: 'Cancel',
      ),
    );

    if (confirmed == true) {
      await ref.read(characterCrudProvider.notifier).deleteById(character.id);
    }
  }
}