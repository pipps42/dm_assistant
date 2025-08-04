// lib/features/character/presentation/widgets/character_card.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:dm_assistant/features/character/models/character.dart';
import 'package:dm_assistant/features/character/providers/character_provider.dart';
import 'package:dm_assistant/features/character/presentation/screens/character_dialog.dart';
import 'package:dm_assistant/shared/components/menus/context_menu.dart';
import 'package:dm_assistant/shared/components/tiles/entity_list_tile.dart';
import 'package:dm_assistant/shared/components/dialogs/base_dialog.dart';
import 'package:intl/intl.dart';

class CharacterCard extends ConsumerWidget {
  final Character character;

  const CharacterCard({super.key, required this.character});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return CharacterContextMenu(
      onEdit: () => _handleEdit(context, ref),
      onDelete: () => _handleDelete(context, ref),
      child: EntityListTile(
        title: character.name,
        subtitle: _buildSubtitle(),
        imageUrl: character.avatarPath,
        fallbackIcon: Icons.person,
        badges: _buildDetails(),
        metadata: {
          'created': _formatDate(character.createdAt),
          'level': character.level.toString(),
        },
        onTap: () {
          ref.read(selectedCharacterIdProvider.notifier).state = character.id;
          // TODO: Navigate to character detail view
        },
        onEdit: () => _handleEdit(context, ref),
        onDelete: () => _handleDelete(context, ref),
      ),
    );
  }

  String _buildSubtitle() {
    final parts = <String>[];
    parts.add('Level ${character.level}');
    parts.add(_formatEnumName(character.race.name));
    parts.add(_formatEnumName(character.characterClass.name));
    return parts.join(' • ');
  }

  List<Widget> _buildDetails() {
    final details = <Widget>[];

    if (character.background != null) {
      details.add(
        _buildDetailChip(
          icon: Icons.history_edu,
          label: _formatEnumName(character.background!.name),
          color: Colors.blue,
        ),
      );
    }

    if (character.alignment != null) {
      details.add(
        _buildDetailChip(
          icon: Icons.balance,
          label: _formatEnumName(character.alignment!.name),
          color: Colors.green,
        ),
      );
    }

    return details;
  }

  Widget _buildDetailChip({
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return Chip(
      avatar: Icon(icon, size: 16, color: color),
      label: Text(label, style: TextStyle(fontSize: 12, color: color)),
      backgroundColor: color.withOpacity(0.1),
      side: BorderSide(color: color.withOpacity(0.3)),
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

  String _formatDate(DateTime date) {
    return DateFormat('MMM d, y').format(date);
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
