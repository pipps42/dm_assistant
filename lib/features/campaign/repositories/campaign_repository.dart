// lib/features/campaign/repositories/campaign_repository.dart
import 'package:isar/isar.dart';
import 'package:dm_assistant/features/campaign/models/campaign.dart';
import 'package:dm_assistant/shared/repositories/base_repository.dart';

class CampaignRepository extends DnDEntityRepository<Campaign> {
  CampaignRepository(super.isar);

  @override
  IsarCollection<Campaign> get collection => isar.campaigns;

  @override
  Id? getId(Campaign entity) => entity.id;

  @override
  Future<List<Campaign>> getAll() async {
    return await collection.where().sortByCreatedAtDesc().findAll();
  }

  @override
  Future<List<Campaign>> search(String query) async {
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
  Future<List<Campaign>> searchByName(String name) async {
    if (name.trim().isEmpty) return await getAll();

    return await collection
        .filter()
        .nameContains(name, caseSensitive: false)
        .sortByCreatedAtDesc()
        .findAll();
  }

  @override
  Future<List<Campaign>> getCreatedAfter(DateTime date) async {
    return await collection
        .filter()
        .createdAtGreaterThan(date)
        .sortByCreatedAtDesc()
        .findAll();
  }

  @override
  Future<List<Campaign>> getRecent({int limit = 10}) async {
    return await collection
        .where()
        .sortByCreatedAtDesc()
        .limit(limit)
        .findAll();
  }

  // Campaign-specific methods
  Future<void> updateLastPlayed(Id id) async {
    await isar.writeTxn(() async {
      final campaign = await collection.get(id);
      if (campaign != null) {
        campaign.lastPlayed = DateTime.now();
        await collection.put(campaign);
      }
    });
  }

  Future<List<Campaign>> getRecentlyPlayed({int limit = 5}) async {
    return await collection
        .filter()
        .not()
        .lastPlayedIsNull()
        .sortByLastPlayedDesc()
        .limit(limit)
        .findAll();
  }

  Future<List<Campaign>> getNeverPlayed() async {
    return await collection
        .filter()
        .lastPlayedIsNull()
        .sortByCreatedAtDesc()
        .findAll();
  }

  Future<List<Campaign>> getPlayedInRange(DateTime start, DateTime end) async {
    return await collection
        .filter()
        .lastPlayedBetween(start, end)
        .sortByLastPlayedDesc()
        .findAll();
  }

  @override
  Future<List<Campaign>> filter(Map<String, dynamic> filters) async {
    var query = collection.filter().idGreaterThan(0); // Always true condition

    // Filter by name
    if (filters.containsKey('name') && filters['name'] != null) {
      final name = filters['name'] as String;
      if (name.isNotEmpty) {
        query = query.and().nameContains(name, caseSensitive: false);
      }
    }

    // Filter by creation date range
    if (filters.containsKey('createdAfter') && filters['createdAfter'] != null) {
      query = query.and().createdAtGreaterThan(filters['createdAfter'] as DateTime);
    }

    if (filters.containsKey('createdBefore') && filters['createdBefore'] != null) {
      query = query.and().createdAtLessThan(filters['createdBefore'] as DateTime);
    }

    // Filter by play status
    if (filters.containsKey('hasBeenPlayed') && filters['hasBeenPlayed'] != null) {
      final hasBeenPlayed = filters['hasBeenPlayed'] as bool;
      if (hasBeenPlayed) {
        query = query.and().not().lastPlayedIsNull();
      } else {
        query = query.and().lastPlayedIsNull();
      }
    }

    return await query.sortByCreatedAtDesc().findAll();
  }
}
