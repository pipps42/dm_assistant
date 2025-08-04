// lib/features/character/providers/character_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';
import 'package:dm_assistant/features/character/models/character.dart';
import 'package:dm_assistant/features/character/repositories/character_repository.dart';
import 'package:dm_assistant/features/campaign/providers/campaign_provider.dart';
import 'package:dm_assistant/shared/providers/entity_provider.dart';
import 'package:dm_assistant/shared/models/dnd_enums.dart';

// Character repository provider
final characterRepositoryProvider = Provider<CharacterRepository>((ref) {
  final isar = ref.watch(isarProvider);
  return CharacterRepository(isar);
});

// Character-specific entity provider
class CharacterEntityProvider extends DnDEntityProvider<Character> {
  CharacterEntityProvider(super.repository);

  // Character-specific methods
  Future<List<Character>> getByCampaignId(int campaignId) async {
    if (repository is CharacterRepository) {
      return await (repository as CharacterRepository).getByCampaignId(
        campaignId,
      );
    }
    return [];
  }

  Future<List<Character>> getByRace(DndRace race) async {
    if (repository is CharacterRepository) {
      return await (repository as CharacterRepository).getByRace(race);
    }
    return [];
  }

  Future<List<Character>> getByClass(DndClass characterClass) async {
    if (repository is CharacterRepository) {
      return await (repository as CharacterRepository).getByClass(
        characterClass,
      );
    }
    return [];
  }

  Future<List<Character>> getByLevelRange(int minLevel, int maxLevel) async {
    if (repository is CharacterRepository) {
      return await (repository as CharacterRepository).getByLevelRange(
        minLevel,
        maxLevel,
      );
    }
    return [];
  }

  Future<List<Character>> getByCampaignAndRace(
    int campaignId,
    DndRace race,
  ) async {
    if (repository is CharacterRepository) {
      return await (repository as CharacterRepository).getByCampaignAndRace(
        campaignId,
        race,
      );
    }
    return [];
  }

  Future<List<Character>> getByCampaignAndClass(
    int campaignId,
    DndClass characterClass,
  ) async {
    if (repository is CharacterRepository) {
      return await (repository as CharacterRepository).getByCampaignAndClass(
        campaignId,
        characterClass,
      );
    }
    return [];
  }

  Future<List<Character>> searchInCampaign(int campaignId, String query) async {
    if (repository is CharacterRepository) {
      return await (repository as CharacterRepository).searchInCampaign(
        campaignId,
        query,
      );
    }
    return [];
  }

  Future<List<Character>> getRecentInCampaign(
    int campaignId, {
    int limit = 10,
  }) async {
    if (repository is CharacterRepository) {
      return await (repository as CharacterRepository).getRecentInCampaign(
        campaignId,
        limit: limit,
      );
    }
    return [];
  }

  // Create character with factory method
  Future<void> createCharacter({
    required String name,
    String? avatarPath,
    required int campaignId,
    required DndRace race,
    required DndClass characterClass,
    int level = 1,
    DndBackground? background,
    DndAlignment? alignment,
  }) async {
    final character = Character.create(
      name: name,
      avatarPath: avatarPath,
      campaignId: campaignId,
      race: race,
      characterClass: characterClass,
      level: level,
      background: background,
      alignment: alignment,
    );
    await create(character);
  }
}

// Character entity notifier for CRUD operations
class CharacterEntityNotifier extends EntityNotifier<Character> {
  CharacterEntityNotifier(super.repository, super.ref, super.listProvider);

  // Character-specific create method
  Future<void> createCharacter({
    required String name,
    String? avatarPath,
    required int campaignId,
    required DndRace race,
    required DndClass characterClass,
    int level = 1,
    DndBackground? background,
    DndAlignment? alignment,
  }) async {
    final character = Character.create(
      name: name,
      avatarPath: avatarPath,
      campaignId: campaignId,
      race: race,
      characterClass: characterClass,
      level: level,
      background: background,
      alignment: alignment,
    );
    await create(character);
  }

  // Character-specific update method
  Future<void> updateCharacter({
    required Id id,
    String? name,
    String? avatarPath,
    int? campaignId,
    DndRace? race,
    DndClass? characterClass,
    int? level,
    DndBackground? background,
    DndAlignment? alignment,
  }) async {
    final existing = await repository.getById(id);
    if (existing != null) {
      final updated = existing.copyWith(
        name: name,
        avatarPath: avatarPath,
        campaignId: campaignId,
        race: race,
        characterClass: characterClass,
        level: level,
        background: background,
        alignment: alignment,
      );
      await update(updated);
    }
  }
}

// Main providers - data loading via FutureProvider
final characterListProvider = FutureProvider<List<Character>>((ref) async {
  final repository = ref.watch(characterRepositoryProvider);
  return repository.getAll();
});

// CRUD operations via StateNotifierProvider (without auto-loading)
final characterCrudProvider =
    StateNotifierProvider<CharacterEntityNotifier, AsyncValue<void>>((ref) {
      final repository = ref.watch(characterRepositoryProvider);
      return CharacterEntityNotifier(repository, ref, characterListProvider);
    });

// Single character providers
final characterProvider = FutureProvider.family<Character?, Id>((ref, id) {
  final repository = ref.watch(characterRepositoryProvider);
  return repository.getById(id);
});

final singleCharacterProvider =
    StateNotifierProvider.family<
      SingleEntityProvider<Character>,
      AsyncValue<Character?>,
      Id
    >((ref, id) {
      final repository = ref.watch(characterRepositoryProvider);
      return SingleEntityProvider<Character>(repository, id);
    });

// Stream providers for real-time updates
final characterStreamProvider = StreamProvider<List<Character>>((ref) {
  final repository = ref.watch(characterRepositoryProvider);
  return repository.watchAll();
});

final singleCharacterStreamProvider = StreamProvider.family<Character?, Id>((
  ref,
  id,
) {
  final repository = ref.watch(characterRepositoryProvider);
  return repository.watchById(id);
});

// Campaign-specific character providers
final campaignCharactersProvider = FutureProvider.family<List<Character>, int>((
  ref,
  campaignId,
) {
  final repository = ref.watch(characterRepositoryProvider);
  return repository.getByCampaignId(campaignId);
});

final recentCampaignCharactersProvider =
    FutureProvider.family<List<Character>, int>((ref, campaignId) {
      final repository = ref.watch(characterRepositoryProvider);
      return repository.getRecentInCampaign(campaignId);
    });

// Filter providers
final charactersByRaceProvider =
    FutureProvider.family<List<Character>, DndRace>((ref, race) {
      final repository = ref.watch(characterRepositoryProvider);
      return repository.getByRace(race);
    });

final charactersByClassProvider =
    FutureProvider.family<List<Character>, DndClass>((ref, characterClass) {
      final repository = ref.watch(characterRepositoryProvider);
      return repository.getByClass(characterClass);
    });

final charactersByLevelRangeProvider =
    FutureProvider.family<List<Character>, Map<String, int>>((ref, levelRange) {
      final repository = ref.watch(characterRepositoryProvider);
      return repository.getByLevelRange(levelRange['min']!, levelRange['max']!);
    });

// Search providers
final characterSearchProvider = FutureProvider.family<List<Character>, String>((
  ref,
  query,
) {
  final repository = ref.watch(characterRepositoryProvider);
  return repository.search(query);
});

final campaignCharacterSearchProvider =
    FutureProvider.family<List<Character>, Map<String, dynamic>>((ref, params) {
      final repository = ref.watch(characterRepositoryProvider);
      return repository.searchInCampaign(
        params['campaignId'] as int,
        params['query'] as String,
      );
    });

final characterFilterProvider =
    FutureProvider.family<List<Character>, Map<String, dynamic>>((
      ref,
      filters,
    ) {
      final repository = ref.watch(characterRepositoryProvider);
      return repository.filter(filters);
    });

// Selected character state
final selectedCharacterIdProvider = StateProvider<Id?>((ref) => null);

final selectedCharacterProvider = Provider<AsyncValue<Character?>>((ref) {
  final selectedId = ref.watch(selectedCharacterIdProvider);
  if (selectedId == null) {
    return const AsyncValue.data(null);
  }
  return ref.watch(characterProvider(selectedId));
});

// View mode state for characters (list or grid)
enum CharacterViewMode { list, grid }

final characterViewModeProvider = StateProvider<CharacterViewMode>(
  (ref) => CharacterViewMode.list,
);
