// lib/features/character/presentation/widgets/character_grid_card.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dm_assistant/features/character/models/character.dart';
import 'package:dm_assistant/features/character/providers/character_provider.dart';
import 'package:dm_assistant/features/character/presentation/screens/character_dialog.dart';
import 'package:dm_assistant/shared/components/menus/context_menu.dart';
import 'package:dm_assistant/shared/components/cards/entity_card.dart';
import 'package:dm_assistant/shared/components/dialogs/base_dialog.dart';
import 'package:go_router/go_router.dart';

class CharacterGridCard extends ConsumerWidget {
  final Character character;

  const CharacterGridCard({super.key, required this.character});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return CharacterContextMenu(
      onEdit: () => _handleEdit(context, ref),
      onDelete: () => _handleDelete(context, ref),
      child: EntityCard.grid(
        title: character.name,
        subtitle: _buildSubtitle(),
        imagePath: character.avatarPath,
        details: _buildDetails(),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit, color: Colors.white, size: 20),
            onPressed: () => _handleEdit(context, ref),
            tooltip: 'Edit Character',
          ),
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.white, size: 20),
            onPressed: () => _handleDelete(context, ref),
            tooltip: 'Delete Character',
          ),
        ],
        onTap: () {
          ref.read(selectedCharacterIdProvider.notifier).state = character.id;
          // TODO: Navigate to character detail view
        },
      ),
    );
  }

  String _buildSubtitle() {
    return 'Level ${character.level} ${_formatEnumName(character.race.name)} ${_formatEnumName(character.characterClass.name)}';
  }

  List<Widget> _buildDetails() {
    final details = <Widget>[];

    if (character.background != null) {
      details.add(
        _buildDetailRow(
          icon: Icons.history_edu,
          label: 'Background',
          value: _formatEnumName(character.background!.name),
        ),
      );
    }

    if (character.alignment != null) {
      details.add(
        _buildDetailRow(
          icon: Icons.balance,
          label: 'Alignment',
          value: _formatEnumName(character.alignment!.name),
        ),
      );
    }

    // Add campaign info if needed
    details.add(
      _buildDetailRow(
        icon: Icons.campaign,
        label: 'Campaign ID',
        value: character.campaignId.toString(),
      ),
    );

    return details;
  }

  Widget _buildDetailRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 12, color: Colors.white.withOpacity(0.8)),
        const SizedBox(width: 4),
        Flexible(
          child: Text(
            '$label: $value',
            style: const TextStyle(fontSize: 11),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  String _formatEnumName(String enumName) {
    return enumName
        .replaceAllMapped(RegExp(r'([A-Z])'), (match) => ' ${match.group(1)}')
        .trim()
        .split(' ')
        .map((word) => word[0].toUpperCase() + word.substring(1).toLowerCase())
        .join(' ');
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
        onConfirm: () => context.pop(true),
        onCancel: () => context.pop(false),
        confirmText: 'Delete',
        cancelText: 'Cancel',
      ),
    );

    if (confirmed == true) {
      await ref.read(characterCrudProvider.notifier).deleteById(character.id);
    }
  }
}
