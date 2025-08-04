import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';
import 'package:dm_assistant/features/character/models/character.dart';
import 'package:dm_assistant/features/character/providers/character_provider.dart';
import 'package:dm_assistant/features/character/repositories/character_repository.dart';
import 'package:dm_assistant/features/campaign/models/campaign.dart';
import 'package:dm_assistant/features/campaign/providers/campaign_provider.dart';
import 'package:dm_assistant/shared/models/dnd_enums.dart';

void main() {
  // Initialize Isar core once for all tests
  setUpAll(() async {
    await Isar.initializeIsarCore(download: true);
  });

  group('CharacterProvider', () {
    late Isar isar;
    late ProviderContainer container;

    setUp(() async {
      // Create in-memory Isar instance for testing
      isar = await Isar.open(
        [CharacterSchema, CampaignSchema],
        directory: '',
        name:
            'test_character_providers_${DateTime.now().millisecondsSinceEpoch}',
      );

      // Create container with overridden isar provider
      container = ProviderContainer(
        overrides: [isarProvider.overrideWithValue(isar)],
      );
    });

    tearDown(() async {
      container.dispose();
      await isar.close(deleteFromDisk: true);
    });

    group('Repository Provider', () {
      test('characterRepositoryProvider provides CharacterRepository', () {
        final repository = container.read(characterRepositoryProvider);
        expect(repository, isA<CharacterRepository>());
      });
    });

    group('Entity Provider', () {
      test('characterListProvider initially returns empty list', () async {
        final characters = await container.read(characterListProvider.future);
        expect(characters, isEmpty);
      });

      test('createCharacter adds character to state', () async {
        final crudProvider = container.read(characterCrudProvider.notifier);

        final character = Character.create(
          name: 'Test Hero',
          campaignId: 1,
          race: DndRace.elf,
          characterClass: DndClass.wizard,
          level: 3,
          background: DndBackground.sage,
          alignment: DndAlignment.neutralGood,
        );

        await crudProvider.create(character);

        final characters = await container.read(characterListProvider.future);
        expect(characters.length, 1);
        expect(characters.first.name, 'Test Hero');
        expect(characters.first.race, DndRace.elf);
        expect(characters.first.level, 3);
      });

      test('updateCharacter modifies existing character', () async {
        final crudProvider = container.read(characterCrudProvider.notifier);

        // Create a character
        final character = Character.create(
          name: 'Original Name',
          campaignId: 1,
          race: DndRace.human,
          characterClass: DndClass.fighter,
        );

        await crudProvider.create(character);

        final characters = await container.read(characterListProvider.future);
        final originalCharacter = characters.first;

        // Update the character
        final updatedCharacter = originalCharacter.copyWith(
          name: 'Updated Name',
          level: 5,
          background: DndBackground.soldier,
        );

        await crudProvider.update(updatedCharacter);

        final updatedCharacters = await container.read(characterListProvider.future);
        final finalCharacter = updatedCharacters.first;

        expect(finalCharacter.name, 'Updated Name');
        expect(finalCharacter.level, 5);
        expect(finalCharacter.background, DndBackground.soldier);
        expect(finalCharacter.race, DndRace.human); // Should remain unchanged
      });

      test('deleteById removes character from state', () async {
        final crudProvider = container.read(characterCrudProvider.notifier);

        // Create a character
        final character = Character.create(
          name: 'To Delete',
          campaignId: 1,
          race: DndRace.dwarf,
          characterClass: DndClass.cleric,
        );

        await crudProvider.create(character);

        final characters = await container.read(characterListProvider.future);
        expect(characters.length, 1);

        final characterId = characters.first.id;

        // Delete the character
        await crudProvider.deleteById(characterId);

        final remainingCharacters = await container.read(characterListProvider.future);
        expect(remainingCharacters.length, 0);
      });
    });

    group('Single Character Providers', () {
      test('characterProvider returns character by id', () async {
        final repository = container.read(characterRepositoryProvider);

        // Create a character directly in repository
        final character = Character.create(
          name: 'Single Test',
          campaignId: 1,
          race: DndRace.halfling,
          characterClass: DndClass.rogue,
        );
        final saved = await repository.save(character);
        final createdId = saved.id;

        // Test the provider
        final retrievedCharacter = await container.read(
          characterProvider(createdId).future,
        );
        expect(retrievedCharacter, isNotNull);
        expect(retrievedCharacter!.name, 'Single Test');
      });

      test('characterProvider returns null for non-existent id', () async {
        final nonExistentCharacter = await container.read(
          characterProvider(999).future,
        );
        expect(nonExistentCharacter, isNull);
      });
    });

    group('Campaign-specific Providers', () {
      setUp(() async {
        final repository = container.read(characterRepositoryProvider);

        // Create test characters in different campaigns
        final characters = [
          Character.create(
            name: 'Campaign 1 Hero 1',
            campaignId: 1,
            race: DndRace.elf,
            characterClass: DndClass.wizard,
          ),
          Character.create(
            name: 'Campaign 1 Hero 2',
            campaignId: 1,
            race: DndRace.human,
            characterClass: DndClass.fighter,
          ),
          Character.create(
            name: 'Campaign 2 Hero',
            campaignId: 2,
            race: DndRace.dwarf,
            characterClass: DndClass.cleric,
          ),
        ];

        for (final character in characters) {
          await repository.save(character);
        }
      });

      test('campaignCharactersProvider filters by campaign', () async {
        final campaign1Characters = await container.read(
          campaignCharactersProvider(1).future,
        );
        final campaign2Characters = await container.read(
          campaignCharactersProvider(2).future,
        );

        expect(campaign1Characters.length, 2);
        expect(campaign2Characters.length, 1);
        expect(campaign2Characters.first.name, 'Campaign 2 Hero');
      });

      test('recentCampaignCharactersProvider filters by campaign', () async {
        final recentInCampaign1 = await container.read(
          recentCampaignCharactersProvider(1).future,
        );
        final recentInCampaign2 = await container.read(
          recentCampaignCharactersProvider(2).future,
        );

        expect(recentInCampaign1.length, 2);
        expect(recentInCampaign2.length, 1);
      });
    });

    group('Filter Providers', () {
      setUp(() async {
        final repository = container.read(characterRepositoryProvider);

        // Create test characters with different properties
        final characters = [
          Character.create(
            name: 'Elf Wizard',
            campaignId: 1,
            race: DndRace.elf,
            characterClass: DndClass.wizard,
            level: 5,
          ),
          Character.create(
            name: 'Human Fighter',
            campaignId: 1,
            race: DndRace.human,
            characterClass: DndClass.fighter,
            level: 3,
          ),
          Character.create(
            name: 'Elf Ranger',
            campaignId: 1,
            race: DndRace.elf,
            characterClass: DndClass.ranger,
            level: 7,
          ),
        ];

        for (final character in characters) {
          await repository.save(character);
        }
      });

      test('charactersByRaceProvider filters by race', () async {
        final elves = await container.read(
          charactersByRaceProvider(DndRace.elf).future,
        );
        final humans = await container.read(
          charactersByRaceProvider(DndRace.human).future,
        );

        expect(elves.length, 2);
        expect(humans.length, 1);
        expect(humans.first.name, 'Human Fighter');
      });

      test('charactersByClassProvider filters by class', () async {
        final wizards = await container.read(
          charactersByClassProvider(DndClass.wizard).future,
        );
        final fighters = await container.read(
          charactersByClassProvider(DndClass.fighter).future,
        );

        expect(wizards.length, 1);
        expect(fighters.length, 1);
        expect(wizards.first.name, 'Elf Wizard');
      });

      test('charactersByLevelRangeProvider filters by level range', () async {
        final lowLevel = await container.read(
          charactersByLevelRangeProvider({'min': 1, 'max': 4}).future,
        );
        final midLevel = await container.read(
          charactersByLevelRangeProvider({'min': 5, 'max': 10}).future,
        );

        expect(lowLevel.length, 1); // level 3
        expect(midLevel.length, 2); // levels 5 and 7
        expect(lowLevel.first.name, 'Human Fighter');
      });

      test('characterFilterProvider with multiple filters', () async {
        final filters = {'campaignId': 1, 'race': DndRace.elf};
        final results = await container.read(
          characterFilterProvider(filters).future,
        );

        expect(results.length, 2);
        expect(results.every((c) => c.race == DndRace.elf), true);
      });
    });

    group('Search Providers', () {
      setUp(() async {
        final repository = container.read(characterRepositoryProvider);

        // Create characters with searchable names and descriptions
        final characters = [
          Character.create(
            name: 'Magical Wizard',
            description: 'A powerful spellcaster',
            campaignId: 1,
            race: DndRace.elf,
            characterClass: DndClass.wizard,
          ),
          Character.create(
            name: 'Brave Fighter',
            description: 'A courageous warrior',
            campaignId: 1,
            race: DndRace.human,
            characterClass: DndClass.fighter,
          ),
          Character.create(
            name: 'Sneaky Rogue',
            campaignId: 2,
            race: DndRace.halfling,
            characterClass: DndClass.rogue,
          ),
        ];

        for (final character in characters) {
          await repository.save(character);
        }
      });

      test('characterSearchProvider finds by name', () async {
        final wizardResults = await container.read(
          characterSearchProvider('Wizard').future,
        );
        final fighterResults = await container.read(
          characterSearchProvider('Fighter').future,
        );

        expect(wizardResults.length, 1);
        expect(fighterResults.length, 1);
        expect(wizardResults.first.name, 'Magical Wizard');
      });

      test('characterSearchProvider finds by description', () async {
        final spellcasterResults = await container.read(
          characterSearchProvider('spellcaster').future,
        );
        expect(spellcasterResults.length, 1);
        expect(spellcasterResults.first.name, 'Magical Wizard');
      });

      test('campaignCharacterSearchProvider limits to campaign', () async {
        final params = {'campaignId': 1, 'query': 'Wizard'};
        final campaign1Results = await container.read(
          campaignCharacterSearchProvider(params).future,
        );

        final params2 = {'campaignId': 2, 'query': 'Wizard'};
        final campaign2Results = await container.read(
          campaignCharacterSearchProvider(params2).future,
        );

        expect(campaign1Results.length, 1);
        expect(campaign2Results.length, 0);
      });
    });

    group('State Providers', () {
      test('selectedCharacterIdProvider manages selection state', () {
        // Initially null
        expect(container.read(selectedCharacterIdProvider), isNull);

        // Set selection
        container.read(selectedCharacterIdProvider.notifier).state = 123;
        expect(container.read(selectedCharacterIdProvider), 123);

        // Clear selection
        container.read(selectedCharacterIdProvider.notifier).state = null;
        expect(container.read(selectedCharacterIdProvider), isNull);
      });

      test('characterViewModeProvider manages view mode', () {
        // Initially list mode
        expect(
          container.read(characterViewModeProvider),
          CharacterViewMode.list,
        );

        // Switch to grid
        container.read(characterViewModeProvider.notifier).state =
            CharacterViewMode.grid;
        expect(
          container.read(characterViewModeProvider),
          CharacterViewMode.grid,
        );

        // Switch back to list
        container.read(characterViewModeProvider.notifier).state =
            CharacterViewMode.list;
        expect(
          container.read(characterViewModeProvider),
          CharacterViewMode.list,
        );
      });

      test(
        'selectedCharacterProvider returns character when id is set',
        () async {
          final repository = container.read(characterRepositoryProvider);

          // 1. Create and save a character
          final character = Character.create(
            name: 'Selected Hero',
            campaignId: 1,
            race: DndRace.dragonborn,
            characterClass: DndClass.paladin,
          );
          final saved = await repository.save(character);
          final createdId = saved.id;

          // 2. Set selection
          container.read(selectedCharacterIdProvider.notifier).state = createdId;

          // 3. selectedCharacterProvider now loads the character via FutureProvider
          // We need to wait for it to finish loading
          final selectedCharacterAsync = container.read(selectedCharacterProvider);
          
          // Wait for loading to complete and get the character
          final selectedCharacter = await selectedCharacterAsync.when(
            data: (char) async => char,
            loading: () => container.read(characterProvider(createdId).future),
            error: (_, __) async => null,
          );

          expect(selectedCharacter, isNotNull);
          expect(selectedCharacter!.name, 'Selected Hero');
        },
      );
    });
  });
}
