import 'package:flutter_test/flutter_test.dart';
import 'package:isar/isar.dart';
import 'package:dm_assistant/features/character/models/character.dart';
import 'package:dm_assistant/features/character/repositories/character_repository.dart';
import 'package:dm_assistant/features/campaign/models/campaign.dart';
import 'package:dm_assistant/shared/models/dnd_enums.dart';

void main() {
  group('CharacterRepository', () {
    late Isar isar;
    late CharacterRepository repository;

    setUp(() async {
      // Create in-memory Isar instance for testing
      isar = await Isar.open(
        [CharacterSchema, CampaignSchema],
        directory: '',
        name: 'test_characters',
      );
      repository = CharacterRepository(isar);
    });

    tearDown(() async {
      await isar.close(deleteFromDisk: true);
    });

    group('Basic CRUD operations', () {
      test('create and retrieve character', () async {
        final character = Character.create(
          name: 'Test Hero',
          campaignId: 1,
          race: DndRace.elf,
          characterClass: DndClass.wizard,
        );

        final saved = await repository.save(character);
        expect(saved.id, isNotNull);

        final retrieved = await repository.getById(saved.id);
        expect(retrieved, isNotNull);
        expect(retrieved!.name, 'Test Hero');
        expect(retrieved.race, DndRace.elf);
        expect(retrieved.characterClass, DndClass.wizard);
      });

      test('update character', () async {
        final character = Character.create(
          name: 'Original Name',
          campaignId: 1,
          race: DndRace.human,
          characterClass: DndClass.fighter,
          level: 1,
        );

        final saved = await repository.save(character);
        final original = await repository.getById(saved.id);

        final updated = original!.copyWith(
          name: 'Updated Name',
          level: 5,
          background: DndBackground.soldier,
        );

        await repository.save(updated);
        final retrieved = await repository.getById(saved.id);

        expect(retrieved!.name, 'Updated Name');
        expect(retrieved.level, 5);
        expect(retrieved.background, DndBackground.soldier);
        expect(retrieved.race, DndRace.human); // Unchanged
      });

      test('delete character', () async {
        final character = Character.create(
          name: 'To Delete',
          campaignId: 1,
          race: DndRace.dwarf,
          characterClass: DndClass.cleric,
        );

        final saved = await repository.save(character);
        expect(await repository.getById(saved.id), isNotNull);

        await repository.deleteById(saved.id);
        expect(await repository.getById(saved.id), isNull);
      });
    });

    group('Query operations', () {
      setUp(() async {
        // Create test data
        final characters = [
          Character.create(
            name: 'Elf Wizard',
            campaignId: 1,
            race: DndRace.elf,
            characterClass: DndClass.wizard,
            level: 5,
            background: DndBackground.sage,
          ),
          Character.create(
            name: 'Human Fighter',
            campaignId: 1,
            race: DndRace.human,
            characterClass: DndClass.fighter,
            level: 3,
            background: DndBackground.soldier,
          ),
          Character.create(
            name: 'Dwarf Cleric',
            campaignId: 2,
            race: DndRace.dwarf,
            characterClass: DndClass.cleric,
            level: 7,
            background: DndBackground.acolyte,
          ),
          Character.create(
            name: 'Halfling Rogue',
            campaignId: 1,
            race: DndRace.halfling,
            characterClass: DndClass.rogue,
            level: 4,
            background: DndBackground.criminal,
          ),
        ];

        for (final character in characters) {
          await repository.save(character);
        }
      });

      test('getAll returns all characters', () async {
        final all = await repository.getAll();
        expect(all.length, 4);
      });

      test('getByCampaignId filters by campaign', () async {
        final campaign1Characters = await repository.getByCampaignId(1);
        final campaign2Characters = await repository.getByCampaignId(2);

        expect(campaign1Characters.length, 3);
        expect(campaign2Characters.length, 1);
        expect(campaign2Characters.first.name, 'Dwarf Cleric');
      });

      test('getByRace filters by race', () async {
        final elves = await repository.getByRace(DndRace.elf);
        expect(elves.length, 1);
        expect(elves.first.name, 'Elf Wizard');
      });

      test('getByClass filters by class', () async {
        final wizards = await repository.getByClass(DndClass.wizard);
        expect(wizards.length, 1);
        expect(wizards.first.name, 'Elf Wizard');
      });

      test('getByLevelRange filters by level range', () async {
        final midLevel = await repository.getByLevelRange(3, 5);
        expect(midLevel.length, 3); // levels 3, 4, 5

        final highLevel = await repository.getByLevelRange(6, 10);
        expect(highLevel.length, 1); // level 7
        expect(highLevel.first.name, 'Dwarf Cleric');
      });

      test('getByCampaignAndRace combines filters', () async {
        final campaign1Humans = await repository.getByCampaignAndRace(
          1,
          DndRace.human,
        );
        expect(campaign1Humans.length, 1);
        expect(campaign1Humans.first.name, 'Human Fighter');

        final campaign2Elves = await repository.getByCampaignAndRace(
          2,
          DndRace.elf,
        );
        expect(campaign2Elves.length, 0);
      });

      test('getByCampaignAndClass combines filters', () async {
        final campaign1Fighters = await repository.getByCampaignAndClass(
          1,
          DndClass.fighter,
        );
        expect(campaign1Fighters.length, 1);
        expect(campaign1Fighters.first.name, 'Human Fighter');
      });

      test('search finds characters by name', () async {
        final wizardResults = await repository.search('Wizard');
        expect(wizardResults.length, 1);
        expect(wizardResults.first.name, 'Elf Wizard');

        final fighterResults = await repository.search('Fighter');
        expect(fighterResults.length, 1);
        expect(fighterResults.first.name, 'Human Fighter');
      });

      test('search finds characters by description', () async {
        // Add a character with description
        final characterWithDesc = Character.create(
          name: 'Special Hero',
          description: 'A brave adventurer who loves magic',
          campaignId: 1,
          race: DndRace.human,
          characterClass: DndClass.sorcerer,
        );
        await repository.save(characterWithDesc);

        final results = await repository.search('magic');
        expect(results.length, 1);
        expect(results.first.name, 'Special Hero');
      });

      test('searchInCampaign limits search to specific campaign', () async {
        final campaign1Results = await repository.searchInCampaign(
          1,
          'Fighter',
        );
        expect(campaign1Results.length, 1);
        expect(campaign1Results.first.name, 'Human Fighter');

        final campaign2Results = await repository.searchInCampaign(
          2,
          'Fighter',
        );
        expect(campaign2Results.length, 0);
      });

      test('getRecent returns limited results', () async {
        final recent = await repository.getRecent(limit: 2);
        expect(recent.length, 2);
      });

      test('getRecentInCampaign filters by campaign', () async {
        final recentInCampaign1 = await repository.getRecentInCampaign(
          1,
          limit: 2,
        );
        expect(recentInCampaign1.length, 2);

        final recentInCampaign2 = await repository.getRecentInCampaign(2);
        expect(recentInCampaign2.length, 1);
      });
    });

    group('Filter operations', () {
      setUp(() async {
        // Create test data with various combinations
        final characters = [
          Character.create(
            name: 'Test 1',
            campaignId: 1,
            race: DndRace.elf,
            characterClass: DndClass.wizard,
            level: 5,
            background: DndBackground.sage,
            alignment: DndAlignment.lawfulGood,
          ),
          Character.create(
            name: 'Test 2',
            campaignId: 1,
            race: DndRace.human,
            characterClass: DndClass.fighter,
            level: 3,
            background: DndBackground.soldier,
            alignment: DndAlignment.lawfulNeutral,
          ),
          Character.create(
            name: 'Test 3',
            campaignId: 2,
            race: DndRace.elf,
            characterClass: DndClass.ranger,
            level: 7,
          ),
        ];

        for (final character in characters) {
          await repository.save(character);
        }
      });

      test('filter by campaignId', () async {
        final filters = {'campaignId': 1};
        final results = await repository.filter(filters);
        expect(results.length, 2);
      });

      test('filter by race', () async {
        final filters = {'race': DndRace.elf};
        final results = await repository.filter(filters);
        expect(results.length, 2);
      });

      test('filter by characterClass', () async {
        final filters = {'characterClass': DndClass.wizard};
        final results = await repository.filter(filters);
        expect(results.length, 1);
        expect(results.first.name, 'Test 1');
      });

      test('filter by level (exact)', () async {
        final filters = {'level': 5};
        final results = await repository.filter(filters);
        expect(results.length, 1);
        expect(results.first.name, 'Test 1');
      });

      test('filter by level (range)', () async {
        final filters = {
          'level': {'min': 3, 'max': 6},
        };
        final results = await repository.filter(filters);
        expect(results.length, 2); // levels 3 and 5
      });

      test('filter by background', () async {
        final filters = {'background': DndBackground.sage};
        final results = await repository.filter(filters);
        expect(results.length, 1);
        expect(results.first.name, 'Test 1');
      });

      test('filter by alignment', () async {
        final filters = {'alignment': DndAlignment.lawfulGood};
        final results = await repository.filter(filters);
        expect(results.length, 1);
        expect(results.first.name, 'Test 1');
      });

      test('filter by multiple criteria', () async {
        final filters = {
          'campaignId': 1,
          'race': DndRace.elf,
          'characterClass': DndClass.wizard,
        };
        final results = await repository.filter(filters);
        expect(results.length, 1);
        expect(results.first.name, 'Test 1');
      });

      test('filter with no matches', () async {
        final filters = {
          'campaignId': 1,
          'race': DndRace.dwarf, // No dwarfs in campaign 1
        };
        final results = await repository.filter(filters);
        expect(results.length, 0);
      });
    });

    test('empty search returns all results', () async {
      // Add one character
      final character = Character.create(
        name: 'Solo Hero',
        campaignId: 1,
        race: DndRace.human,
        characterClass: DndClass.bard,
      );
      await repository.save(character);

      final emptyResults = await repository.search('');
      final spaceResults = await repository.search('   ');

      expect(emptyResults.length, 1);
      expect(spaceResults.length, 1);
    });
  });
}
