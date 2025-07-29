// lib/features/campaign/repositories/campaign_repository.dart
import 'package:isar/isar.dart';
import 'package:dm_assistant/features/campaign/models/campaign.dart';

class CampaignRepository {
  final Isar _isar;

  CampaignRepository(this._isar);

  Future<List<Campaign>> getAllCampaigns() async {
    return await _isar.campaigns.where().sortByCreatedAtDesc().findAll();
  }

  Future<Campaign?> getCampaignById(Id id) async {
    return await _isar.campaigns.get(id);
  }

  Future<void> saveCampaign(Campaign campaign) async {
    await _isar.writeTxn(() async {
      await _isar.campaigns.put(campaign);
    });
  }

  Future<void> deleteCampaign(Id id) async {
    await _isar.writeTxn(() async {
      await _isar.campaigns.delete(id);
    });
  }

  Future<void> updateLastPlayed(Id id) async {
    await _isar.writeTxn(() async {
      final campaign = await _isar.campaigns.get(id);
      if (campaign != null) {
        campaign.lastPlayed = DateTime.now();
        await _isar.campaigns.put(campaign);
      }
    });
  }
}