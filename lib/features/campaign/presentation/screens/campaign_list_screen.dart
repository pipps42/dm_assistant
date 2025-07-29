// lib/features/campaign/presentation/screens/campaign_list_screen.dart (aggiornato)
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:dm_assistant/core/constants/strings.dart';
import 'package:dm_assistant/core/constants/app_colors.dart';
import 'package:dm_assistant/core/constants/dimens.dart';
import 'package:dm_assistant/core/responsive/responsive_builder.dart';
import 'package:dm_assistant/core/widgets/loading_widget.dart';
import 'package:dm_assistant/core/widgets/error_widget.dart';
import 'package:dm_assistant/features/campaign/models/campaign.dart';
import 'package:dm_assistant/features/campaign/providers/campaign_provider.dart';
import 'package:dm_assistant/features/campaign/presentation/widgets/campaign_card.dart';
import 'package:dm_assistant/features/campaign/presentation/screens/create_campaign_dialog.dart';
import 'package:dm_assistant/shared/widgets/breadcrumb_bar.dart';

/// Provider per lo stato di ricerca delle campagne
final campaignSearchProvider = StateProvider<String>((ref) => '');

/// Provider per il filtro delle campagne
final campaignFilterProvider = StateProvider<CampaignFilter>(
  (ref) => CampaignFilter.all,
);

/// Provider per le campagne filtrate
final filteredCampaignsProvider = Provider<AsyncValue<List<Campaign>>>((ref) {
  final campaignsAsync = ref.watch(campaignsProvider);
  final searchQuery = ref.watch(campaignSearchProvider);
  final filter = ref.watch(campaignFilterProvider);

  return campaignsAsync.when(
    data: (campaigns) {
      var filtered = campaigns;

      // Applica filtro per tipo
      switch (filter) {
        case CampaignFilter.recent:
          filtered = campaigns.where((c) => c.lastPlayed != null).toList()
            ..sort(
              (a, b) => (b.lastPlayed ?? DateTime(0)).compareTo(
                a.lastPlayed ?? DateTime(0),
              ),
            );
          break;
        case CampaignFilter.active:
          // Considera attive le campagne giocate negli ultimi 30 giorni
          final cutoff = DateTime.now().subtract(const Duration(days: 30));
          filtered = campaigns
              .where(
                (c) => c.lastPlayed != null && c.lastPlayed!.isAfter(cutoff),
              )
              .toList();
          break;
        case CampaignFilter.all:
        default:
          break;
      }

      // Applica filtro per ricerca
      if (searchQuery.isNotEmpty) {
        filtered = filtered
            .where(
              (campaign) =>
                  campaign.name.toLowerCase().contains(
                    searchQuery.toLowerCase(),
                  ) ||
                  (campaign.description?.toLowerCase().contains(
                        searchQuery.toLowerCase(),
                      ) ??
                      false),
            )
            .toList();
      }

      return AsyncValue.data(filtered);
    },
    loading: () => const AsyncValue.loading(),
    error: (error, stack) => AsyncValue.error(error, stack),
  );
});

/// Enum per i filtri delle campagne
enum CampaignFilter { all, recent, active }

/// Schermata principale per la lista delle campagne
class CampaignListScreen extends ConsumerWidget {
  const CampaignListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filteredCampaignsAsync = ref.watch(filteredCampaignsProvider);

    return ResponsiveBuilder(
      mobile: _buildMobileLayout(context, ref, filteredCampaignsAsync),
      desktop: _buildDesktopLayout(context, ref, filteredCampaignsAsync),
    );
  }

  Widget _buildMobileLayout(
    BuildContext context,
    WidgetRef ref,
    AsyncValue<List<Campaign>> campaignsAsync,
  ) {
    return Column(
      children: [
        // Search and filter bar
        _buildSearchAndFilterBar(context, ref),

        // Content
        Expanded(
          child: campaignsAsync.when(
            loading: () =>
                const AppLoadingWidget(message: 'Loading campaigns...'),
            error: (error, stack) => AppErrorWidget(
              message: 'Failed to load campaigns: $error',
              onRetry: () => ref.refresh(campaignsProvider),
            ),
            data: (campaigns) =>
                _buildCampaignGrid(context, ref, campaigns, crossAxisCount: 1),
          ),
        ),
      ],
    );
  }

  Widget _buildDesktopLayout(
    BuildContext context,
    WidgetRef ref,
    AsyncValue<List<Campaign>> campaignsAsync,
  ) {
    return Column(
      children: [
        // Header with actions
        _buildDesktopHeader(context, ref),

        // Search and filter bar
        _buildSearchAndFilterBar(context, ref),

        // Content
        Expanded(
          child: campaignsAsync.when(
            loading: () =>
                const AppLoadingWidget(message: 'Loading campaigns...'),
            error: (error, stack) => AppErrorWidget(
              message: 'Failed to load campaigns: $error',
              onRetry: () => ref.refresh(campaignsProvider),
            ),
            data: (campaigns) => _buildCampaignGrid(
              context,
              ref,
              campaigns,
              crossAxisCount: context.responsive<int>(
                mobile: 1,
                tablet: 2,
                desktop: 3,
                largeDesktop: 4,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDesktopHeader(BuildContext context, WidgetRef ref) {
    return Container(
      padding: const EdgeInsets.all(AppDimens.spacingL),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(
          bottom: BorderSide(color: Theme.of(context).dividerColor, width: 1),
        ),
      ),
      child: Row(
        children: [
          // Title and description
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppStrings.campaigns,
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: AppDimens.spacingXS),
                Text(
                  'Manage your D&D campaigns and adventures',
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(color: AppColors.neutral600),
                ),
              ],
            ),
          ),

          const SizedBox(width: AppDimens.spacingL),

          // Actions
          Row(
            children: [
              // Import button
              OutlinedButton.icon(
                onPressed: () {
                  // TODO: Implement import functionality
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Import feature coming soon!'),
                    ),
                  );
                },
                icon: const Icon(Icons.upload),
                label: const Text('Import'),
              ),

              const SizedBox(width: AppDimens.spacingM),

              // Create campaign button
              ElevatedButton.icon(
                onPressed: () => _showCreateDialog(context, ref),
                icon: const Icon(Icons.add),
                label: const Text(AppStrings.newCampaign),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSearchAndFilterBar(BuildContext context, WidgetRef ref) {
    final searchQuery = ref.watch(campaignSearchProvider);
    final currentFilter = ref.watch(campaignFilterProvider);

    return Container(
      padding: const EdgeInsets.all(AppDimens.spacingM),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(
          bottom: BorderSide(color: Theme.of(context).dividerColor, width: 1),
        ),
      ),
      child: ResponsiveBuilder(
        mobile: Column(
          children: [
            _buildSearchField(context, ref, searchQuery),
            const SizedBox(height: AppDimens.spacingM),
            _buildFilterChips(context, ref, currentFilter),
          ],
        ),
        desktop: Row(
          children: [
            // Search field
            Expanded(
              flex: 2,
              child: _buildSearchField(context, ref, searchQuery),
            ),

            const SizedBox(width: AppDimens.spacingL),

            // Filter chips
            Expanded(
              flex: 3,
              child: _buildFilterChips(context, ref, currentFilter),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchField(
    BuildContext context,
    WidgetRef ref,
    String searchQuery,
  ) {
    return TextFormField(
      initialValue: searchQuery,
      decoration: InputDecoration(
        hintText: 'Search campaigns...',
        prefixIcon: const Icon(Icons.search),
        suffixIcon: searchQuery.isNotEmpty
            ? IconButton(
                icon: const Icon(Icons.clear),
                onPressed: () {
                  ref.read(campaignSearchProvider.notifier).state = '';
                },
              )
            : null,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimens.radiusM),
        ),
        filled: true,
        fillColor: Theme.of(context).colorScheme.background,
      ),
      onChanged: (value) {
        ref.read(campaignSearchProvider.notifier).state = value;
      },
    );
  }

  Widget _buildFilterChips(
    BuildContext context,
    WidgetRef ref,
    CampaignFilter currentFilter,
  ) {
    return Wrap(
      spacing: AppDimens.spacingS,
      children: CampaignFilter.values.map((filter) {
        final isSelected = currentFilter == filter;

        return FilterChip(
          label: Text(_getFilterLabel(filter)),
          selected: isSelected,
          onSelected: (selected) {
            if (selected) {
              ref.read(campaignFilterProvider.notifier).state = filter;
            }
          },
          backgroundColor: Theme.of(context).colorScheme.background,
          selectedColor: AppColors.primary.withOpacity(0.1),
          checkmarkColor: AppColors.primary,
        );
      }).toList(),
    );
  }

  Widget _buildCampaignGrid(
    BuildContext context,
    WidgetRef ref,
    List<Campaign> campaigns, {
    required int crossAxisCount,
  }) {
    if (campaigns.isEmpty) {
      return _buildEmptyState(context, ref);
    }

    return GridView.builder(
      padding: const EdgeInsets.all(AppDimens.spacingM),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: AppDimens.spacingM,
        mainAxisSpacing: AppDimens.spacingM,
        childAspectRatio: context.responsive<double>(mobile: 1.5, desktop: 1.2),
      ),
      itemCount: campaigns.length,
      itemBuilder: (context, index) {
        final campaign = campaigns[index];
        return CampaignCard(campaign: campaign);
      },
    );
  }

  Widget _buildEmptyState(BuildContext context, WidgetRef ref) {
    final searchQuery = ref.watch(campaignSearchProvider);
    final hasSearch = searchQuery.isNotEmpty;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppDimens.spacingXL),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              hasSearch ? Icons.search_off : Icons.campaign_outlined,
              size: 80,
              color: AppColors.neutral400,
            ),
            const SizedBox(height: AppDimens.spacingL),

            Text(
              hasSearch ? 'No campaigns found' : 'No campaigns yet',
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(color: AppColors.neutral600),
            ),
            const SizedBox(height: AppDimens.spacingS),

            Text(
              hasSearch
                  ? 'Try adjusting your search or filters'
                  : 'Create your first campaign to get started',
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: AppColors.neutral500),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppDimens.spacingXL),

            if (hasSearch) ...[
              OutlinedButton.icon(
                onPressed: () {
                  ref.read(campaignSearchProvider.notifier).state = '';
                  ref.read(campaignFilterProvider.notifier).state =
                      CampaignFilter.all;
                },
                icon: const Icon(Icons.clear),
                label: const Text('Clear filters'),
              ),
            ] else ...[
              ElevatedButton.icon(
                onPressed: () => _showCreateDialog(context, ref),
                icon: const Icon(Icons.add),
                label: const Text(AppStrings.newCampaign),
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _getFilterLabel(CampaignFilter filter) {
    switch (filter) {
      case CampaignFilter.all:
        return 'All';
      case CampaignFilter.recent:
        return 'Recent';
      case CampaignFilter.active:
        return 'Active';
    }
  }

  void _showCreateDialog(BuildContext context, WidgetRef ref) {
    if (context.isMobile) {
      // Su mobile, naviga a una schermata full-screen
      context.go('/campaigns/create');
    } else {
      // Su desktop, mostra un dialog
      showDialog(
        context: context,
        builder: (context) => const CreateCampaignDialog(),
      );
    }
  }
}

/// Widget FAB per mobile
class CampaignListFAB extends ConsumerWidget {
  const CampaignListFAB({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return FloatingActionButton.extended(
      onPressed: () => _showCreateDialog(context, ref),
      icon: const Icon(Icons.add),
      label: const Text(AppStrings.newCampaign),
    );
  }

  void _showCreateDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => const CreateCampaignDialog(),
    );
  }
}
