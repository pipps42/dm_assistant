// lib/features/npcs/providers/npc_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';
import 'package:dm_assistant/features/npcs/models/npc.dart';
import 'package:dm_assistant/features/npcs/repositories/npc_repository.dart';
import 'package:dm_assistant/features/campaign/providers/campaign_provider.dart';
import 'package:dm_assistant/shared/providers/entity_provider.dart';
import 'package:dm_assistant/shared/models/dnd_enums.dart';

// NPC repository provider
final npcRepositoryProvider = Provider<NpcRepository>((ref) {
  final isar = ref.watch(isarProvider);
  return NpcRepository(isar);
});

// NPC-specific entity provider
class NpcEntityProvider extends DnDEntityProvider<Npc> {
  NpcEntityProvider(super.repository);

  // NPC-specific methods
  Future<List<Npc>> getByCampaignId(int campaignId) async {
    if (repository is NpcRepository) {
      return await (repository as NpcRepository).getByCampaignId(campaignId);
    }
    return [];
  }

  Future<List<Npc>> getByRace(DndRace race) async {
    if (repository is NpcRepository) {
      return await (repository as NpcRepository).getByRace(race);
    }
    return [];
  }

  Future<List<Npc>> getByCreatureType(DndCreatureType creatureType) async {
    if (repository is NpcRepository) {
      return await (repository as NpcRepository).getByCreatureType(creatureType);
    }
    return [];
  }

  Future<List<Npc>> getByRole(NpcRole role) async {
    if (repository is NpcRepository) {
      return await (repository as NpcRepository).getByRole(role);
    }
    return [];
  }

  Future<List<Npc>> getByAttitude(NpcAttitude attitude) async {
    if (repository is NpcRepository) {
      return await (repository as NpcRepository).getByAttitude(attitude);
    }
    return [];
  }

  Future<List<Npc>> getByClass(DndClass characterClass) async {
    if (repository is NpcRepository) {
      return await (repository as NpcRepository).getByClass(characterClass);
    }
    return [];
  }

  Future<List<Npc>> getByCampaignAndRace(
    int campaignId,
    DndRace race,
  ) async {
    if (repository is NpcRepository) {
      return await (repository as NpcRepository).getByCampaignAndRace(
        campaignId,
        race,
      );
    }
    return [];
  }

  Future<List<Npc>> getByCampaignAndRole(
    int campaignId,
    NpcRole role,
  ) async {
    if (repository is NpcRepository) {
      return await (repository as NpcRepository).getByCampaignAndRole(
        campaignId,
        role,
      );
    }
    return [];
  }

  Future<List<Npc>> getByCampaignAndAttitude(
    int campaignId,
    NpcAttitude attitude,
  ) async {
    if (repository is NpcRepository) {
      return await (repository as NpcRepository).getByCampaignAndAttitude(
        campaignId,
        attitude,
      );
    }
    return [];
  }

  Future<List<Npc>> searchInCampaign(int campaignId, String query) async {
    if (repository is NpcRepository) {
      return await (repository as NpcRepository).searchInCampaign(
        campaignId,
        query,
      );
    }
    return [];
  }

  Future<List<Npc>> getRecentInCampaign(
    int campaignId, {
    int limit = 10,
  }) async {
    if (repository is NpcRepository) {
      return await (repository as NpcRepository).getRecentInCampaign(
        campaignId,
        limit: limit,
      );
    }
    return [];
  }

  Future<List<Npc>> getFriendlyInCampaign(int campaignId) async {
    if (repository is NpcRepository) {
      return await (repository as NpcRepository).getFriendlyInCampaign(campaignId);
    }
    return [];
  }

  Future<List<Npc>> getHostileInCampaign(int campaignId) async {
    if (repository is NpcRepository) {
      return await (repository as NpcRepository).getHostileInCampaign(campaignId);
    }
    return [];
  }
}

// NPC entity notifier for CRUD operations
class NpcEntityNotifier extends EntityNotifier<Npc> {
  NpcEntityNotifier(super.repository, super.ref, super.listProvider);

  // NPC-specific create method
  Future<void> createNpc({
    required String name,
    String? avatarPath,
    required int campaignId,
    required DndRace race,
    DndClass? characterClass,
    DndCreatureType creatureType = DndCreatureType.humanoid,
    NpcRole role = NpcRole.citizen,
    NpcAttitude attitude = NpcAttitude.neutral,
    DndAlignment? alignment,
    String? description,
  }) async {
    final npc = Npc.create(
      name: name,
      avatarPath: avatarPath,
      campaignId: campaignId,
      race: race,
      characterClass: characterClass,
      creatureType: creatureType,
      role: role,
      attitude: attitude,
      alignment: alignment,
      description: description,
    );
    await create(npc);
    // Also invalidate campaign-specific provider
    ref.invalidate(campaignNpcsProvider(campaignId));
  }

  // NPC-specific update method
  Future<void> updateNpc({
    required Id id,
    String? name,
    String? avatarPath,
    int? campaignId,
    DndRace? race,
    DndClass? characterClass,
    DndCreatureType? creatureType,
    NpcRole? role,
    NpcAttitude? attitude,
    DndAlignment? alignment,
    String? description,
  }) async {
    final existing = await repository.getById(id);
    if (existing != null) {
      final updated = existing.copyWith(
        name: name,
        avatarPath: avatarPath,
        campaignId: campaignId,
        race: race,
        characterClass: characterClass,
        creatureType: creatureType,
        role: role,
        attitude: attitude,
        alignment: alignment,
        description: description,
      );
      await update(updated);
      // Also invalidate campaign-specific provider
      if (campaignId != null) {
        ref.invalidate(campaignNpcsProvider(campaignId));
      } else {
        // If campaignId is not provided, use existing campaignId
        ref.invalidate(campaignNpcsProvider(existing.campaignId));
      }
    }
  }

  // Override deleteById to also invalidate campaign-specific providers
  @override
  Future<void> deleteById(Id id) async {
    // Get the NPC before deletion to know which campaign to invalidate
    final npc = await repository.getById(id);
    
    // Call the parent deleteById method
    await super.deleteById(id);
    
    // Invalidate campaign-specific provider if NPC was found
    if (npc != null) {
      ref.invalidate(campaignNpcsProvider(npc.campaignId));
    }
  }
}

// Main providers - data loading via FutureProvider
final npcListProvider = FutureProvider<List<Npc>>((ref) async {
  final repository = ref.watch(npcRepositoryProvider);
  return repository.getAll();
});

// CRUD operations via StateNotifierProvider (without auto-loading)
final npcCrudProvider =
    StateNotifierProvider<NpcEntityNotifier, AsyncValue<void>>((ref) {
      final repository = ref.watch(npcRepositoryProvider);
      return NpcEntityNotifier(repository, ref, npcListProvider);
    });

// Single NPC providers
final npcProvider = FutureProvider.family<Npc?, Id>((ref, id) {
  final repository = ref.watch(npcRepositoryProvider);
  return repository.getById(id);
});

final singleNpcProvider =
    StateNotifierProvider.family<
      SingleEntityProvider<Npc>,
      AsyncValue<Npc?>,
      Id
    >((ref, id) {
      final repository = ref.watch(npcRepositoryProvider);
      return SingleEntityProvider<Npc>(repository, id);
    });

// Stream providers for real-time updates
final npcStreamProvider = StreamProvider<List<Npc>>((ref) {
  final repository = ref.watch(npcRepositoryProvider);
  return repository.watchAll();
});

final singleNpcStreamProvider = StreamProvider.family<Npc?, Id>((
  ref,
  id,
) {
  final repository = ref.watch(npcRepositoryProvider);
  return repository.watchById(id);
});

// Campaign-specific NPC providers
final campaignNpcsProvider = FutureProvider.family<List<Npc>, int>((
  ref,
  campaignId,
) {
  final repository = ref.watch(npcRepositoryProvider);
  return repository.getByCampaignId(campaignId);
});

final recentCampaignNpcsProvider =
    FutureProvider.family<List<Npc>, int>((ref, campaignId) {
      final repository = ref.watch(npcRepositoryProvider);
      return repository.getRecentInCampaign(campaignId);
    });

final friendlyCampaignNpcsProvider =
    FutureProvider.family<List<Npc>, int>((ref, campaignId) {
      final repository = ref.watch(npcRepositoryProvider);
      return repository.getFriendlyInCampaign(campaignId);
    });

final hostileCampaignNpcsProvider =
    FutureProvider.family<List<Npc>, int>((ref, campaignId) {
      final repository = ref.watch(npcRepositoryProvider);
      return repository.getHostileInCampaign(campaignId);
    });

// Filter providers
final npcsByRaceProvider =
    FutureProvider.family<List<Npc>, DndRace>((ref, race) {
      final repository = ref.watch(npcRepositoryProvider);
      return repository.getByRace(race);
    });

final npcsByCreatureTypeProvider =
    FutureProvider.family<List<Npc>, DndCreatureType>((ref, creatureType) {
      final repository = ref.watch(npcRepositoryProvider);
      return repository.getByCreatureType(creatureType);
    });

final npcsByRoleProvider =
    FutureProvider.family<List<Npc>, NpcRole>((ref, role) {
      final repository = ref.watch(npcRepositoryProvider);
      return repository.getByRole(role);
    });

final npcsByAttitudeProvider =
    FutureProvider.family<List<Npc>, NpcAttitude>((ref, attitude) {
      final repository = ref.watch(npcRepositoryProvider);
      return repository.getByAttitude(attitude);
    });

final npcsByClassProvider =
    FutureProvider.family<List<Npc>, DndClass>((ref, characterClass) {
      final repository = ref.watch(npcRepositoryProvider);
      return repository.getByClass(characterClass);
    });

// Search providers
final npcSearchProvider = FutureProvider.family<List<Npc>, String>((
  ref,
  query,
) {
  final repository = ref.watch(npcRepositoryProvider);
  return repository.search(query);
});

final campaignNpcSearchProvider =
    FutureProvider.family<List<Npc>, Map<String, dynamic>>((ref, params) {
      final repository = ref.watch(npcRepositoryProvider);
      return repository.searchInCampaign(
        params['campaignId'] as int,
        params['query'] as String,
      );
    });

final npcFilterProvider =
    FutureProvider.family<List<Npc>, Map<String, dynamic>>((
      ref,
      filters,
    ) {
      final repository = ref.watch(npcRepositoryProvider);
      return repository.filter(filters);
    });

// Selected NPC state
final selectedNpcIdProvider = StateProvider<Id?>((ref) => null);

final selectedNpcProvider = Provider<AsyncValue<Npc?>>((ref) {
  final selectedId = ref.watch(selectedNpcIdProvider);
  if (selectedId == null) {
    return const AsyncValue.data(null);
  }
  return ref.watch(npcProvider(selectedId));
});

// View mode state for NPCs (list or grid)
enum NpcViewMode { list, grid }

final npcViewModeProvider = StateProvider<NpcViewMode>(
  (ref) => NpcViewMode.list,
);