// lib/features/campaign/providers/campaign_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';
import 'package:dm_assistant/features/campaign/models/campaign.dart';
import 'package:dm_assistant/features/campaign/repositories/campaign_repository.dart';
import 'package:dm_assistant/shared/providers/entity_provider.dart';
import 'package:dm_assistant/shared/providers/selected_campaign_provider.dart';

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
  Future<void> createCampaign(String name, String? description, [String? coverImagePath]) async {
    final campaign = Campaign.create(name: name, description: description, coverImagePath: coverImagePath);
    await create(campaign);
  }
}

// Campaign entity notifier for CRUD operations
class CampaignEntityNotifier extends EntityNotifier<Campaign> {
  CampaignEntityNotifier(super.repository, super.ref, super.listProvider);

  // Campaign-specific create method
  Future<void> createCampaign(String name, String? description, [String? coverImagePath]) async {
    final campaign = Campaign.create(name: name, description: description, coverImagePath: coverImagePath);
    await create(campaign);
  }

  // Campaign-specific update method
  Future<void> updateCampaign(Id id, String name, String? description, [String? coverImagePath]) async {
    final existing = await repository.getById(id);
    if (existing != null) {
      final updated = existing.copyWith(name: name, description: description, coverImagePath: coverImagePath);
      await update(updated);
    }
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

// Main providers - data loading via FutureProvider
final campaignListProvider = FutureProvider<List<Campaign>>((ref) async {
  final repository = ref.watch(campaignRepositoryProvider);
  return repository.getAll();
});

// CRUD operations via StateNotifierProvider (without auto-loading)
final campaignCrudProvider = StateNotifierProvider<CampaignEntityNotifier, AsyncValue<void>>((ref) {
  final repository = ref.watch(campaignRepositoryProvider);
  return CampaignEntityNotifier(repository, ref, campaignListProvider);
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

// Selected campaign state (imported from shared providers)
// This provider has been moved to lib/shared/providers/selected_campaign_provider.dart
// to provide persistence and better separation of concerns

// View mode state for campaigns (list or grid)
enum CampaignViewMode { list, grid }
final campaignViewModeProvider = StateProvider<CampaignViewMode>((ref) => CampaignViewMode.list);

final selectedCampaignProvider = Provider<AsyncValue<Campaign?>>((ref) {
  final selectedId = ref.watch(selectedCampaignIdProvider);
  if (selectedId == null) {
    return const AsyncValue.data(null);
  }
  return ref.watch(campaignProvider(selectedId));
});
