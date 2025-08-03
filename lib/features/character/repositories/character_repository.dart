// lib/features/character/repositories/character_repository.dart
import 'package:isar/isar.dart';
import 'package:dm_assistant/features/character/models/character.dart';
import 'package:dm_assistant/shared/repositories/base_repository.dart';
import 'package:dm_assistant/shared/models/dnd_enums.dart';

class CharacterRepository extends DnDEntityRepository<Character> {
  CharacterRepository(super.isar);

  @override
  IsarCollection<Character> get collection => isar.characters;

  @override
  Id? getId(Character entity) => entity.id;

  @override
  Future<List<Character>> getAll() async {
    return await collection.where().sortByCreatedAtDesc().findAll();
  }

  @override
  Future<List<Character>> search(String query) async {
    if (query.trim().isEmpty) return await getAll();

    return await collection
        .filter()
        .nameContains(query, caseSensitive: false)
        .or()
        .group(
          (q) => q.descriptionIsNotNull().and().descriptionContains(
            query,
            caseSensitive: false,
          ),
        )
        .sortByCreatedAtDesc()
        .findAll();
  }

  @override
  Future<List<Character>> filter(Map<String, dynamic> filters) async {
    var query = collection.filter().idGreaterThan(0); // Always true condition

    if (filters.containsKey('campaignId')) {
      query = query.and().campaignIdEqualTo(filters['campaignId'] as int);
    }

    if (filters.containsKey('race')) {
      query = query.and().raceEqualTo(filters['race'] as DndRace);
    }

    if (filters.containsKey('characterClass')) {
      query = query.and().characterClassEqualTo(filters['characterClass'] as DndClass);
    }

    if (filters.containsKey('level')) {
      final level = filters['level'];
      if (level is int) {
        query = query.and().levelEqualTo(level);
      } else if (level is Map && level.containsKey('min') && level.containsKey('max')) {
        query = query.and().levelBetween(level['min'] as int, level['max'] as int);
      }
    }

    if (filters.containsKey('background')) {
      query = query.and().backgroundEqualTo(filters['background'] as DndBackground);
    }

    if (filters.containsKey('alignment')) {
      query = query.and().alignmentEqualTo(filters['alignment'] as DndAlignment);
    }

    return await query.sortByCreatedAtDesc().findAll();
  }

  // Character-specific methods

  /// Get all characters for a specific campaign
  Future<List<Character>> getByCampaignId(int campaignId) async {
    return await collection
        .filter()
        .campaignIdEqualTo(campaignId)
        .sortByCreatedAtDesc()
        .findAll();
  }

  /// Get characters by race
  Future<List<Character>> getByRace(DndRace race) async {
    return await collection
        .filter()
        .raceEqualTo(race)
        .sortByCreatedAtDesc()
        .findAll();
  }

  /// Get characters by class
  Future<List<Character>> getByClass(DndClass characterClass) async {
    return await collection
        .filter()
        .characterClassEqualTo(characterClass)
        .sortByCreatedAtDesc()
        .findAll();
  }

  /// Get characters by level range
  Future<List<Character>> getByLevelRange(int minLevel, int maxLevel) async {
    return await collection
        .filter()
        .levelBetween(minLevel, maxLevel)
        .sortByCreatedAtDesc()
        .findAll();
  }

  /// Get characters for a specific campaign by race
  Future<List<Character>> getByCampaignAndRace(int campaignId, DndRace race) async {
    return await collection
        .filter()
        .campaignIdEqualTo(campaignId)
        .and()
        .raceEqualTo(race)
        .sortByCreatedAtDesc()
        .findAll();
  }

  /// Get characters for a specific campaign by class
  Future<List<Character>> getByCampaignAndClass(int campaignId, DndClass characterClass) async {
    return await collection
        .filter()
        .campaignIdEqualTo(campaignId)
        .and()
        .characterClassEqualTo(characterClass)
        .sortByCreatedAtDesc()
        .findAll();
  }

  /// Search characters within a specific campaign
  Future<List<Character>> searchInCampaign(int campaignId, String query) async {
    if (query.trim().isEmpty) return await getByCampaignId(campaignId);

    return await collection
        .filter()
        .campaignIdEqualTo(campaignId)
        .and()
        .group(
          (q) => q
              .nameContains(query, caseSensitive: false)
              .or()
              .group(
                (q2) => q2.descriptionIsNotNull().and().descriptionContains(
                  query,
                  caseSensitive: false,
                ),
              ),
        )
        .sortByCreatedAtDesc()
        .findAll();
  }

  /// Get recent characters (useful for dashboard)
  Future<List<Character>> getRecent({int limit = 10}) async {
    return await collection
        .where()
        .sortByUpdatedAtDesc()
        .limit(limit)
        .findAll();
  }

  /// Get recent characters for a specific campaign
  Future<List<Character>> getRecentInCampaign(int campaignId, {int limit = 10}) async {
    return await collection
        .filter()
        .campaignIdEqualTo(campaignId)
        .sortByUpdatedAtDesc()
        .limit(limit)
        .findAll();
  }
}