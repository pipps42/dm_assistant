// lib/shared/providers/selected_campaign_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:isar/isar.dart';

class SelectedCampaignNotifier extends StateNotifier<Id?> {
  static const String _selectedCampaignKey = 'selected_campaign_id';
  
  SelectedCampaignNotifier() : super(null) {
    _loadSelectedCampaign();
  }

  Future<void> _loadSelectedCampaign() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedId = prefs.getInt(_selectedCampaignKey);
      if (savedId != null) {
        state = savedId;
      }
    } catch (e) {
      // If loading fails, keep state as null
    }
  }

  Future<void> selectCampaign(Id? campaignId) async {
    state = campaignId;
    
    try {
      final prefs = await SharedPreferences.getInstance();
      if (campaignId != null) {
        await prefs.setInt(_selectedCampaignKey, campaignId);
      } else {
        await prefs.remove(_selectedCampaignKey);
      }
    } catch (e) {
      // If saving fails, the selection still works in memory
    }
  }

  void clearSelection() {
    selectCampaign(null);
  }
}

// Provider for selected campaign ID with persistence
final selectedCampaignIdProvider = StateNotifierProvider<SelectedCampaignNotifier, Id?>((ref) {
  return SelectedCampaignNotifier();
});