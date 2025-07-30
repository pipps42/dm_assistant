// lib/features/campaign/providers/campaign_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';
import 'package:dm_assistant/features/campaign/models/campaign.dart';
import 'package:dm_assistant/features/campaign/repositories/campaign_repository.dart';
import 'package:dm_assistant/shared/providers/entity_provider.dart';

// Core providers
final isarProvider = Provider<Isar>((ref) {
  throw UnimplementedError('Isar must be initialized');
});

final campaignRepositoryProvider = Provider<CampaignRepository>((ref) {
  final isar = ref.watch(isarProvider);
  return CampaignRepository(isar);
});

// Campaign-specific entity provider
class CampaignEntityProvider extends DnDEntityProvider<Campaign> {
  CampaignEntityProvider(super.repository);

  // Campaign-specific methods
  Future<void> updateLastPlayed(Id id) async {
    if (repository is CampaignRepository) {
      await (repository as CampaignRepository).updateLastPlayed(id);
      await refresh();
    }
  }

  Future<List<Campaign>> getRecentlyPlayed({int limit = 5}) async {
    if (repository is CampaignRepository) {
      return await (repository as CampaignRepository).getRecentlyPlayed(
        limit: limit,
      );
    }
    return [];
  }

  Future<List<Campaign>> getNeverPlayed() async {
    if (repository is CampaignRepository) {
      return await (repository as CampaignRepository).getNeverPlayed();
    }
    return [];
  }

  Future<List<Campaign>> getPlayedInRange(DateTime start, DateTime end) async {
    if (repository is CampaignRepository) {
      return await (repository as CampaignRepository).getPlayedInRange(
        start,
        end,
      );
    }
    return [];
  }

  // Create campaign with factory method
  Future<void> createCampaign(String name, String? description) async {
    final campaign = Campaign.create(name: name, description: description);
    await create(campaign);
  }
}

// Campaign entity notifier for CRUD operations
class CampaignEntityNotifier extends EntityNotifier<Campaign> {
  CampaignEntityNotifier(super.repository, super.ref, super.listProvider);

  // Campaign-specific create method
  Future<void> createCampaign(String name, String? description) async {
    final campaign = Campaign.create(name: name, description: description);
    await create(campaign);
  }

  // Update last played when starting a session
  Future<void> startSession(Id campaignId) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await (repository as CampaignRepository).updateLastPlayed(campaignId);
      ref.invalidate(listProvider);
    });
  }
}

// Main providers using the generic entity system
final campaignEntityProvider =
    StateNotifierProvider<CampaignEntityProvider, AsyncValue<List<Campaign>>>((
      ref,
    ) {
      final repository = ref.watch(campaignRepositoryProvider);
      return CampaignEntityProvider(repository);
    });

final campaignEntityNotifierProvider =
    StateNotifierProvider<CampaignEntityNotifier, AsyncValue<void>>((ref) {
      final repository = ref.watch(campaignRepositoryProvider);
      return CampaignEntityNotifier(repository, ref, campaignEntityProvider);
    });

// Single campaign providers
final campaignProvider = FutureProvider.family<Campaign?, Id>((ref, id) {
  final repository = ref.watch(campaignRepositoryProvider);
  return repository.getById(id);
});

final singleCampaignProvider =
    StateNotifierProvider.family<
      SingleEntityProvider<Campaign>,
      AsyncValue<Campaign?>,
      Id
    >((ref, id) {
      final repository = ref.watch(campaignRepositoryProvider);
      return SingleEntityProvider<Campaign>(repository, id);
    });

// Stream providers for real-time updates
final campaignStreamProvider = StreamProvider<List<Campaign>>((ref) {
  final repository = ref.watch(campaignRepositoryProvider);
  return repository.watchAll();
});

final singleCampaignStreamProvider = StreamProvider.family<Campaign?, Id>((
  ref,
  id,
) {
  final repository = ref.watch(campaignRepositoryProvider);
  return repository.watchById(id);
});

// Convenience providers for common queries
final recentCampaignsProvider = FutureProvider<List<Campaign>>((ref) {
  final repository = ref.watch(campaignRepositoryProvider);
  return repository.getRecent();
});

final recentlyPlayedCampaignsProvider = FutureProvider<List<Campaign>>((ref) {
  final repository = ref.watch(campaignRepositoryProvider);
  return repository.getRecentlyPlayed();
});

final neverPlayedCampaignsProvider = FutureProvider<List<Campaign>>((ref) {
  final repository = ref.watch(campaignRepositoryProvider);
  return repository.getNeverPlayed();
});

// Search and filter providers
final campaignSearchProvider = FutureProvider.family<List<Campaign>, String>((
  ref,
  query,
) {
  final repository = ref.watch(campaignRepositoryProvider);
  return repository.search(query);
});

final campaignFilterProvider =
    FutureProvider.family<List<Campaign>, Map<String, dynamic>>((ref, filters) {
      final repository = ref.watch(campaignRepositoryProvider);
      return repository.filter(filters);
    });

// Selected campaign state
final selectedCampaignIdProvider = StateProvider<Id?>((ref) => null);

final selectedCampaignProvider = Provider<AsyncValue<Campaign?>>((ref) {
  final selectedId = ref.watch(selectedCampaignIdProvider);
  if (selectedId == null) {
    return const AsyncValue.data(null);
  }
  return ref.watch(campaignProvider(selectedId));
});
