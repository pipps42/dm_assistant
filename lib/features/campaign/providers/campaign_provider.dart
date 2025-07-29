// lib/features/campaign/providers/campaign_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';
import 'package:dm_assistant/features/campaign/models/campaign.dart';
import 'package:dm_assistant/features/campaign/repositories/campaign_repository.dart';

final isarProvider = Provider<Isar>((ref) {
  throw UnimplementedError('Isar must be initialized');
});

final campaignRepositoryProvider = Provider<CampaignRepository>((ref) {
  final isar = ref.watch(isarProvider);
  return CampaignRepository(isar);
});

final campaignsProvider = FutureProvider<List<Campaign>>((ref) {
  final repository = ref.watch(campaignRepositoryProvider);
  return repository.getAllCampaigns();
});

final campaignProvider = FutureProvider.family<Campaign?, int>((ref, id) {
  final repository = ref.watch(campaignRepositoryProvider);
  return repository.getCampaignById(id);
});

final selectedCampaignIdProvider = StateProvider<int?>((ref) => null);

class CampaignNotifier extends StateNotifier<AsyncValue<void>> {
  final CampaignRepository _repository;

  CampaignNotifier(this._repository) : super(const AsyncValue.data(null));

  Future<void> createCampaign(String name, String? description) async {
    state = const AsyncValue.loading();
    
    state = await AsyncValue.guard(() async {
      final campaign = Campaign.create(
        name: name,
        description: description,
      );
      await _repository.saveCampaign(campaign);
    });
  }

  Future<void> updateCampaign(Campaign campaign) async {
    state = const AsyncValue.loading();
    
    state = await AsyncValue.guard(() async {
      await _repository.saveCampaign(campaign);
    });
  }

  Future<void> deleteCampaign(int id) async {
    state = const AsyncValue.loading();
    
    state = await AsyncValue.guard(() async {
      await _repository.deleteCampaign(id);
    });
  }
}

final campaignNotifierProvider = StateNotifierProvider<CampaignNotifier, AsyncValue<void>>((ref) {
  final repository = ref.watch(campaignRepositoryProvider);
  return CampaignNotifier(repository);
});