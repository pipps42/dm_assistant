// lib/features/npcs/repositories/npc_repository.dart
import 'package:isar/isar.dart';
import 'package:dm_assistant/features/npcs/models/npc.dart';
import 'package:dm_assistant/shared/repositories/base_repository.dart';
import 'package:dm_assistant/shared/models/dnd_enums.dart';

class NpcRepository extends DnDEntityRepository<Npc> {
  NpcRepository(super.isar);

  @override
  IsarCollection<Npc> get collection => isar.npcs;

  @override
  Id? getId(Npc entity) => entity.id;

  @override
  Future<List<Npc>> getAll() async {
    return await collection.where().sortByCreatedAtDesc().findAll();
  }

  @override
  Future<List<Npc>> search(String query) async {
    if (query.trim().isEmpty) return await getAll();

    return await collection
        .filter()
        .nameContains(query, caseSensitive: false)
        .sortByCreatedAtDesc()
        .findAll();
  }

  @override
  Future<List<Npc>> filter(Map<String, dynamic> filters) async {
    var query = collection.filter().idGreaterThan(0); // Always true condition

    if (filters.containsKey('campaignId')) {
      query = query.and().campaignIdEqualTo(filters['campaignId'] as int);
    }

    if (filters.containsKey('race')) {
      query = query.and().raceEqualTo(filters['race'] as DndRace);
    }

    if (filters.containsKey('characterClass')) {
      query = query.and().characterClassEqualTo(
        filters['characterClass'] as DndClass,
      );
    }

    if (filters.containsKey('creatureType')) {
      query = query.and().creatureTypeEqualTo(
        filters['creatureType'] as DndCreatureType,
      );
    }

    if (filters.containsKey('role')) {
      query = query.and().roleEqualTo(filters['role'] as NpcRole);
    }

    if (filters.containsKey('attitude')) {
      query = query.and().attitudeEqualTo(filters['attitude'] as NpcAttitude);
    }

    if (filters.containsKey('alignment')) {
      query = query.and().alignmentEqualTo(
        filters['alignment'] as DndAlignment,
      );
    }

    return await query.sortByCreatedAtDesc().findAll();
  }

  // NPC-specific methods

  /// Get all NPCs for a specific campaign
  Future<List<Npc>> getByCampaignId(int campaignId) async {
    return await collection
        .filter()
        .campaignIdEqualTo(campaignId)
        .sortByCreatedAtDesc()
        .findAll();
  }

  /// Get NPCs by race
  Future<List<Npc>> getByRace(DndRace race) async {
    return await collection
        .filter()
        .raceEqualTo(race)
        .sortByCreatedAtDesc()
        .findAll();
  }

  /// Get NPCs by creature type
  Future<List<Npc>> getByCreatureType(DndCreatureType creatureType) async {
    return await collection
        .filter()
        .creatureTypeEqualTo(creatureType)
        .sortByCreatedAtDesc()
        .findAll();
  }

  /// Get NPCs by role
  Future<List<Npc>> getByRole(NpcRole role) async {
    return await collection
        .filter()
        .roleEqualTo(role)
        .sortByCreatedAtDesc()
        .findAll();
  }

  /// Get NPCs by attitude
  Future<List<Npc>> getByAttitude(NpcAttitude attitude) async {
    return await collection
        .filter()
        .attitudeEqualTo(attitude)
        .sortByCreatedAtDesc()
        .findAll();
  }

  /// Get NPCs by class (only those with a class)
  Future<List<Npc>> getByClass(DndClass characterClass) async {
    return await collection
        .filter()
        .characterClassEqualTo(characterClass)
        .sortByCreatedAtDesc()
        .findAll();
  }

  /// Get NPCs for a specific campaign by race
  Future<List<Npc>> getByCampaignAndRace(
    int campaignId,
    DndRace race,
  ) async {
    return await collection
        .filter()
        .campaignIdEqualTo(campaignId)
        .and()
        .raceEqualTo(race)
        .sortByCreatedAtDesc()
        .findAll();
  }

  /// Get NPCs for a specific campaign by role
  Future<List<Npc>> getByCampaignAndRole(
    int campaignId,
    NpcRole role,
  ) async {
    return await collection
        .filter()
        .campaignIdEqualTo(campaignId)
        .and()
        .roleEqualTo(role)
        .sortByCreatedAtDesc()
        .findAll();
  }

  /// Get NPCs for a specific campaign by attitude
  Future<List<Npc>> getByCampaignAndAttitude(
    int campaignId,
    NpcAttitude attitude,
  ) async {
    return await collection
        .filter()
        .campaignIdEqualTo(campaignId)
        .and()
        .attitudeEqualTo(attitude)
        .sortByCreatedAtDesc()
        .findAll();
  }

  /// Search NPCs within a specific campaign
  Future<List<Npc>> searchInCampaign(int campaignId, String query) async {
    if (query.trim().isEmpty) return await getByCampaignId(campaignId);

    return await collection
        .filter()
        .campaignIdEqualTo(campaignId)
        .and()
        .group((q) => q.nameContains(query, caseSensitive: false))
        .sortByCreatedAtDesc()
        .findAll();
  }

  /// Get recent NPCs (useful for dashboard)
  Future<List<Npc>> getRecent({int limit = 10}) async {
    return await collection
        .where()
        .sortByUpdatedAtDesc()
        .limit(limit)
        .findAll();
  }

  /// Get recent NPCs for a specific campaign
  Future<List<Npc>> getRecentInCampaign(
    int campaignId, {
    int limit = 10,
  }) async {
    return await collection
        .filter()
        .campaignIdEqualTo(campaignId)
        .sortByUpdatedAtDesc()
        .limit(limit)
        .findAll();
  }

  /// Get friendly NPCs in a campaign
  Future<List<Npc>> getFriendlyInCampaign(int campaignId) async {
    return await collection
        .filter()
        .campaignIdEqualTo(campaignId)
        .and()
        .group((q) => q
            .attitudeEqualTo(NpcAttitude.friendly)
            .or()
            .attitudeEqualTo(NpcAttitude.helpful))
        .sortByCreatedAtDesc()
        .findAll();
  }

  /// Get hostile NPCs in a campaign
  Future<List<Npc>> getHostileInCampaign(int campaignId) async {
    return await collection
        .filter()
        .campaignIdEqualTo(campaignId)
        .and()
        .attitudeEqualTo(NpcAttitude.hostile)
        .sortByCreatedAtDesc()
        .findAll();
  }
}