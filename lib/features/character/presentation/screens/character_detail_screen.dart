// lib/features/character/presentation/screens/character_detail_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';
import 'package:dm_assistant/features/character/models/character.dart';
import 'package:dm_assistant/features/character/providers/character_provider.dart';
import 'package:dm_assistant/shared/components/layouts/entity_detail_layout.dart';
import 'package:dm_assistant/shared/components/states/empty_state.dart';
import 'package:dm_assistant/shared/models/dnd_enums.dart';
import 'package:dm_assistant/core/constants/dimens.dart';

class CharacterDetailScreen extends ConsumerStatefulWidget {
  final Id characterId;

  const CharacterDetailScreen({super.key, required this.characterId});

  @override
  ConsumerState<CharacterDetailScreen> createState() =>
      _CharacterDetailScreenState();
}

class _CharacterDetailScreenState extends ConsumerState<CharacterDetailScreen> {
  bool _isEditing = false;

  // Edit controllers
  late TextEditingController _nameController;
  late TextEditingController _backgroundTextController;
  DndRace? _selectedRace;
  DndClass? _selectedClass;
  int? _selectedLevel;
  DndBackground? _selectedBackground;
  DndAlignment? _selectedAlignment;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _backgroundTextController = TextEditingController();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _backgroundTextController.dispose();
    super.dispose();
  }

  void _initializeEditControllers(Character character) {
    _nameController.text = character.name;
    _backgroundTextController.text = character.backgroundText ?? '';
    _selectedRace = character.race;
    _selectedClass = character.characterClass;
    _selectedLevel = character.level;
    _selectedBackground = character.background;
    _selectedAlignment = character.alignment;
  }

  @override
  Widget build(BuildContext context) {
    final characterAsync = ref.watch(characterProvider(widget.characterId));

    return characterAsync.when(
      data: (character) {
        if (character == null) {
          return const EmptyStateWidget(
            icon: Icons.person_off,
            title: 'Character not found',
            message: 'The character you are looking for does not exist.',
          );
        }

        return EntityDetailLayout(
          entityName: character.name,
          entitySubtitle: _buildSubtitle(character),
          avatarPath: character.avatarPath,
          fallbackIcon: Icons.person,
          sections: [
            _BasicInfoSection(
              character: character,
              isEditing: _isEditing,
              nameController: _nameController,
              backgroundTextController: _backgroundTextController,
              selectedRace: _selectedRace,
              selectedClass: _selectedClass,
              selectedLevel: _selectedLevel,
              selectedBackground: _selectedBackground,
              selectedAlignment: _selectedAlignment,
              onEdit: () {
                _initializeEditControllers(character);
                setState(() => _isEditing = true);
              },
              onSave: () => _handleSave(character),
              onCancel: () => setState(() => _isEditing = false),
              onRaceChanged: (race) => setState(() => _selectedRace = race),
              onClassChanged: (characterClass) =>
                  setState(() => _selectedClass = characterClass),
              onLevelChanged: (level) => setState(() => _selectedLevel = level),
              onBackgroundChanged: (background) =>
                  setState(() => _selectedBackground = background),
              onAlignmentChanged: (alignment) =>
                  setState(() => _selectedAlignment = alignment),
            ),
          ],
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => EmptyStateWidget.error(
        title: 'Error loading character',
        message: error.toString(),
        icon: Icons.error_outline,
      ),
    );
  }

  String _buildSubtitle(Character character) {
    final parts = <String>[];
    parts.add('Level ${character.level}');
    parts.add(_formatEnumName(character.race.name));
    parts.add(_formatEnumName(character.characterClass.name));
    return parts.join(' • ');
  }

  String _formatEnumName(String enumName) {
    return enumName
        .replaceAllMapped(RegExp(r'([A-Z])'), (match) => ' ${match.group(1)}')
        .trim()
        .split(' ')
        .map((word) => word[0].toUpperCase() + word.substring(1).toLowerCase())
        .join(' ');
  }

  Future<void> _handleSave(Character character) async {
    if (_nameController.text.trim().isEmpty ||
        _selectedRace == null ||
        _selectedClass == null ||
        _selectedLevel == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill in all required fields'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    try {
      final updatedCharacter = character.copyWith(
        name: _nameController.text.trim(),
        race: _selectedRace!,
        characterClass: _selectedClass!,
        level: _selectedLevel!,
        background: _selectedBackground,
        alignment: _selectedAlignment,
        backgroundText: _backgroundTextController.text.trim().isEmpty
            ? null
            : _backgroundTextController.text.trim(),
      );

      await ref.read(characterCrudProvider.notifier).update(updatedCharacter);

      // Invalidate the character provider to refresh the data
      ref.invalidate(characterProvider(widget.characterId));
      
      // Invalidate the character list provider to refresh the characters list
      ref.invalidate(characterListProvider);
      
      // Invalidate the campaign-specific characters provider if applicable  
      ref.invalidate(campaignCharactersProvider(updatedCharacter.campaignId));
      
      setState(() => _isEditing = false);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Character updated successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error updating character: $error'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}

class _BasicInfoSection extends EditableEntityDetailSection {
  final Character character;
  final TextEditingController nameController;
  final TextEditingController backgroundTextController;
  final DndRace? selectedRace;
  final DndClass? selectedClass;
  final int? selectedLevel;
  final DndBackground? selectedBackground;
  final DndAlignment? selectedAlignment;
  final ValueChanged<DndRace?> onRaceChanged;
  final ValueChanged<DndClass?> onClassChanged;
  final ValueChanged<int?> onLevelChanged;
  final ValueChanged<DndBackground?> onBackgroundChanged;
  final ValueChanged<DndAlignment?> onAlignmentChanged;

  const _BasicInfoSection({
    required this.character,
    required bool isEditing,
    required VoidCallback? onEdit,
    required VoidCallback? onSave,
    required VoidCallback? onCancel,
    required this.nameController,
    required this.backgroundTextController,
    required this.selectedRace,
    required this.selectedClass,
    required this.selectedLevel,
    required this.selectedBackground,
    required this.selectedAlignment,
    required this.onRaceChanged,
    required this.onClassChanged,
    required this.onLevelChanged,
    required this.onBackgroundChanged,
    required this.onAlignmentChanged,
  }) : super(
         title: 'Basic Information',
         icon: Icons.info_outline,
         isEditing: isEditing,
         onEdit: onEdit,
         onSave: onSave,
         onCancel: onCancel,
       );

  @override
  Widget buildContent(BuildContext context) {
    if (isEditing) {
      return _buildEditingContent(context);
    } else {
      return _buildViewContent(context);
    }
  }

  Widget _buildViewContent(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: InfoField(
                label: 'Name',
                value: character.name,
                icon: Icons.person,
              ),
            ),
            Expanded(
              child: InfoField(
                label: 'Level',
                value: character.level.toString(),
                icon: Icons.star,
              ),
            ),
          ],
        ),
        Row(
          children: [
            Expanded(
              child: InfoField(
                label: 'Race',
                value: _formatEnumName(character.race.name),
                icon: Icons.face,
              ),
            ),
            Expanded(
              child: InfoField(
                label: 'Class',
                value: _formatEnumName(character.characterClass.name),
                icon: Icons.work,
              ),
            ),
          ],
        ),
        if (character.background != null)
          Row(
            children: [
              Expanded(
                child: InfoField(
                  label: 'Background',
                  value: _formatEnumName(character.background!.name),
                  icon: Icons.history_edu,
                ),
              ),
              Expanded(
                child: InfoField(
                  label: 'Alignment',
                  value: character.alignment != null
                      ? _formatEnumName(character.alignment!.name)
                      : null,
                  icon: Icons.balance,
                ),
              ),
            ],
          ),
        if (character.backgroundText != null &&
            character.backgroundText!.isNotEmpty)
          InfoField(
            label: 'Background Story',
            customValue: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppDimens.spacingM),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(AppDimens.radiusS),
              ),
              child: Text(
                character.backgroundText!,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
            icon: Icons.auto_stories,
          ),
      ],
    );
  }

  Widget _buildEditingContent(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Name *',
                  prefixIcon: Icon(Icons.person),
                ),
              ),
            ),
            const SizedBox(width: AppDimens.spacingM),
            Expanded(
              child: DropdownButtonFormField<int>(
                value: selectedLevel,
                decoration: const InputDecoration(
                  labelText: 'Level *',
                  prefixIcon: Icon(Icons.star),
                ),
                items: List.generate(20, (index) => index + 1)
                    .map(
                      (level) => DropdownMenuItem(
                        value: level,
                        child: Text(level.toString()),
                      ),
                    )
                    .toList(),
                onChanged: onLevelChanged,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppDimens.spacingM),
        Row(
          children: [
            Expanded(
              child: DropdownButtonFormField<DndRace>(
                value: selectedRace,
                decoration: const InputDecoration(
                  labelText: 'Race *',
                  prefixIcon: Icon(Icons.face),
                ),
                items: DndRace.values
                    .map(
                      (race) => DropdownMenuItem(
                        value: race,
                        child: Text(_formatEnumName(race.name)),
                      ),
                    )
                    .toList(),
                onChanged: onRaceChanged,
              ),
            ),
            const SizedBox(width: AppDimens.spacingM),
            Expanded(
              child: DropdownButtonFormField<DndClass>(
                value: selectedClass,
                decoration: const InputDecoration(
                  labelText: 'Class *',
                  prefixIcon: Icon(Icons.work),
                ),
                items: DndClass.values
                    .map(
                      (characterClass) => DropdownMenuItem(
                        value: characterClass,
                        child: Text(_formatEnumName(characterClass.name)),
                      ),
                    )
                    .toList(),
                onChanged: onClassChanged,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppDimens.spacingM),
        Row(
          children: [
            Expanded(
              child: DropdownButtonFormField<DndBackground>(
                value: selectedBackground,
                decoration: const InputDecoration(
                  labelText: 'Background',
                  prefixIcon: Icon(Icons.history_edu),
                ),
                items: [
                  const DropdownMenuItem<DndBackground>(
                    value: null,
                    child: Text('None'),
                  ),
                  ...DndBackground.values.map(
                    (background) => DropdownMenuItem(
                      value: background,
                      child: Text(_formatEnumName(background.name)),
                    ),
                  ),
                ],
                onChanged: onBackgroundChanged,
              ),
            ),
            const SizedBox(width: AppDimens.spacingM),
            Expanded(
              child: DropdownButtonFormField<DndAlignment>(
                value: selectedAlignment,
                decoration: const InputDecoration(
                  labelText: 'Alignment',
                  prefixIcon: Icon(Icons.balance),
                ),
                items: [
                  const DropdownMenuItem<DndAlignment>(
                    value: null,
                    child: Text('None'),
                  ),
                  ...DndAlignment.values.map(
                    (alignment) => DropdownMenuItem(
                      value: alignment,
                      child: Text(_formatEnumName(alignment.name)),
                    ),
                  ),
                ],
                onChanged: onAlignmentChanged,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppDimens.spacingM),
        TextFormField(
          controller: backgroundTextController,
          decoration: const InputDecoration(
            labelText: 'Background Story',
            prefixIcon: Icon(Icons.auto_stories),
            alignLabelWithHint: true,
          ),
          maxLines: 6,
          textInputAction: TextInputAction.newline,
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
}
