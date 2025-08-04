import 'package:flutter_test/flutter_test.dart';
import 'package:dm_assistant/features/character/models/character.dart';
import 'package:dm_assistant/shared/models/dnd_enums.dart';

void main() {
  group('Character model', () {
    test('factory create sets required fields and DateTime.now()', () {
      final now = DateTime.now();
      final character = Character.create(
        name: 'Test Hero',
        campaignId: 1,
        race: DndRace.elf,
        characterClass: DndClass.wizard,
      );

      expect(character.name, 'Test Hero');
      expect(character.campaignId, 1);
      expect(character.race, DndRace.elf);
      expect(character.characterClass, DndClass.wizard);
      expect(character.level, 1); // Default level
      expect(character.createdAt.difference(now).inSeconds, lessThan(1));
      expect(character.updatedAt.difference(now).inSeconds, lessThan(1));
    });

    test('factory create with all optional fields', () {
      final character = Character.create(
        name: 'Full Hero',
        description: 'A brave adventurer',
        avatarPath: '/path/to/avatar.jpg',
        campaignId: 2,
        race: DndRace.dwarf,
        characterClass: DndClass.fighter,
        level: 5,
        background: DndBackground.soldier,
        alignment: DndAlignment.lawfulGood,
      );

      expect(character.name, 'Full Hero');
      expect(character.avatarPath, '/path/to/avatar.jpg');
      expect(character.campaignId, 2);
      expect(character.race, DndRace.dwarf);
      expect(character.characterClass, DndClass.fighter);
      expect(character.level, 5);
      expect(character.background, DndBackground.soldier);
      expect(character.alignment, DndAlignment.lawfulGood);
    });

    test('copyWith creates a new instance with updated fields', () {
      final original = Character.create(
        name: 'Original Hero',
        description: 'Old description',
        campaignId: 1,
        race: DndRace.human,
        characterClass: DndClass.rogue,
        level: 3,
      );

      final updated = original.copyWith(
        name: 'Updated Hero',
        description: 'New description',
        level: 4,
        background: DndBackground.criminal,
      );

      expect(updated.name, 'Updated Hero');
      expect(updated.level, 4);
      expect(updated.background, DndBackground.criminal);

      // Unchanged fields
      expect(updated.campaignId, original.campaignId);
      expect(updated.race, original.race);
      expect(updated.characterClass, original.characterClass);
      expect(updated.id, original.id);
      expect(updated.createdAt, original.createdAt);

      // updatedAt should be newer
      expect(updated.updatedAt.isAfter(original.updatedAt), true);
    });

    test('copyWith preserves original values when no changes provided', () {
      final original = Character.create(
        name: 'Unchanged Hero',
        campaignId: 1,
        race: DndRace.halfling,
        characterClass: DndClass.bard,
        level: 2,
      );

      final unchanged = original.copyWith();

      expect(unchanged.name, original.name);
      expect(unchanged.campaignId, original.campaignId);
      expect(unchanged.race, original.race);
      expect(unchanged.characterClass, original.characterClass);
      expect(unchanged.level, original.level);
      expect(unchanged.id, original.id);
      expect(unchanged.createdAt, original.createdAt);
    });

    test('display name getters return correct values', () {
      final character = Character.create(
        name: 'Test Hero',
        campaignId: 1,
        race: DndRace.dragonborn,
        characterClass: DndClass.paladin,
        background: DndBackground.noble,
        alignment: DndAlignment.chaoticNeutral,
      );

      expect(character.raceDisplayName, 'Dragonborn');
      expect(character.classDisplayName, 'Paladin');
      expect(character.backgroundDisplayName, 'Noble');
      expect(character.alignmentDisplayName, 'Chaotic Neutral');
    });

    test('display name getters handle null optional fields', () {
      final character = Character.create(
        name: 'Minimal Hero',
        campaignId: 1,
        race: DndRace.gnome,
        characterClass: DndClass.monk,
        // background and alignment are null
      );

      expect(character.raceDisplayName, 'Gnome');
      expect(character.classDisplayName, 'Monk');
      expect(character.backgroundDisplayName, null);
      expect(character.alignmentDisplayName, null);
    });

    test('level validation through constructor', () {
      // Test minimum level
      final lowLevel = Character.create(
        name: 'Newbie',
        campaignId: 1,
        race: DndRace.human,
        characterClass: DndClass.wizard,
        level: 1,
      );
      expect(lowLevel.level, 1);

      // Test high level
      final highLevel = Character.create(
        name: 'Master',
        campaignId: 1,
        race: DndRace.elf,
        characterClass: DndClass.wizard,
        level: 20,
      );
      expect(highLevel.level, 20);
    });

    test('enum values are preserved correctly', () {
      final character = Character.create(
        name: 'Enum Test',
        campaignId: 1,
        race: DndRace.tiefling,
        characterClass: DndClass.warlock,
        background: DndBackground.charlatan,
        alignment: DndAlignment.chaoticEvil,
      );

      expect(character.race, DndRace.tiefling);
      expect(character.characterClass, DndClass.warlock);
      expect(character.background, DndBackground.charlatan);
      expect(character.alignment, DndAlignment.chaoticEvil);
    });
  });
}
