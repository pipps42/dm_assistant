// lib/core/widgets/empty_state_widget.dart
import 'package:flutter/material.dart';
import 'package:dm_assistant/core/constants/app_colors.dart';
import 'package:dm_assistant/core/constants/dimens.dart';
import 'package:dm_assistant/core/responsive/responsive_builder.dart';

/// Widget riutilizzabile per mostrare stati vuoti
class EmptyStateWidget extends StatelessWidget {
  /// Icona da mostrare (default: no data icon)
  final IconData? icon;

  /// Widget personalizzato al posto dell'icona
  final Widget? customIcon;

  /// Titolo principale
  final String title;

  /// Sottotitolo/descrizione
  final String? subtitle;

  /// Pulsante di azione primaria
  final Widget? primaryAction;

  /// Pulsante di azione secondaria
  final Widget? secondaryAction;

  /// Immagine personalizzata (sovrascrive l'icona)
  final Widget? illustration;

  /// Colore dell'icona
  final Color? iconColor;

  /// Dimensione dell'icona
  final double? iconSize;

  /// Padding del widget
  final EdgeInsets? padding;

  /// Background color del widget
  final Color? backgroundColor;

  /// Se mostrare animazioni
  final bool animated;

  const EmptyStateWidget({
    super.key,
    this.icon,
    this.customIcon,
    required this.title,
    this.subtitle,
    this.primaryAction,
    this.secondaryAction,
    this.illustration,
    this.iconColor,
    this.iconSize,
    this.padding,
    this.backgroundColor,
    this.animated = true,
  });

  /// Factory per stato "nessuna campagna"
  factory EmptyStateWidget.noCampaigns({VoidCallback? onCreateCampaign}) {
    return EmptyStateWidget(
      icon: Icons.campaign_outlined,
      title: 'No campaigns yet',
      subtitle:
          'Create your first campaign to get started with your D&D adventures',
      primaryAction: onCreateCampaign != null
          ? ElevatedButton.icon(
              onPressed: onCreateCampaign,
              icon: const Icon(Icons.add),
              label: const Text('Create Campaign'),
            )
          : null,
    );
  }

  /// Factory per stato "nessun personaggio"
  factory EmptyStateWidget.noCharacters({VoidCallback? onCreateCharacter}) {
    return EmptyStateWidget(
      icon: Icons.people_outline,
      title: 'No characters yet',
      subtitle: 'Add characters to your campaign to bring your story to life',
      primaryAction: onCreateCharacter != null
          ? ElevatedButton.icon(
              onPressed: onCreateCharacter,
              icon: const Icon(Icons.add),
              label: const Text('Add Character'),
            )
          : null,
    );
  }

  /// Factory per stato "nessuna sessione"
  factory EmptyStateWidget.noSessions({VoidCallback? onCreateSession}) {
    return EmptyStateWidget(
      icon: Icons.event_outlined,
      title: 'No sessions yet',
      subtitle: 'Start planning and tracking your game sessions',
      primaryAction: onCreateSession != null
          ? ElevatedButton.icon(
              onPressed: onCreateSession,
              icon: const Icon(Icons.add),
              label: const Text('Create Session'),
            )
          : null,
    );
  }

  /// Factory per risultati di ricerca vuoti
  factory EmptyStateWidget.noSearchResults({
    required String searchQuery,
    VoidCallback? onClearSearch,
  }) {
    return EmptyStateWidget(
      icon: Icons.search_off,
      title: 'No results found',
      subtitle:
          'No items match "$searchQuery". Try adjusting your search terms.',
      primaryAction: onClearSearch != null
          ? OutlinedButton.icon(
              onPressed: onClearSearch,
              icon: const Icon(Icons.clear),
              label: const Text('Clear Search'),
            )
          : null,
    );
  }

  /// Factory per stato di errore
  factory EmptyStateWidget.error({
    required String message,
    VoidCallback? onRetry,
  }) {
    return EmptyStateWidget(
      icon: Icons.error_outline,
      iconColor: AppColors.error,
      title: 'Something went wrong',
      subtitle: message,
      primaryAction: onRetry != null
          ? ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            )
          : null,
    );
  }

  /// Factory per stato offline
  factory EmptyStateWidget.offline({VoidCallback? onRetry}) {
    return EmptyStateWidget(
      icon: Icons.wifi_off,
      iconColor: AppColors.warning,
      title: 'No internet connection',
      subtitle: 'Check your connection and try again',
      primaryAction: onRetry != null
          ? ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            )
          : null,
    );
  }

  /// Factory per coming soon
  factory EmptyStateWidget.comingSoon({required String feature}) {
    return EmptyStateWidget(
      icon: Icons.construction,
      iconColor: AppColors.info,
      title: 'Coming Soon',
      subtitle:
          '$feature is currently under development and will be available in a future update.',
    );
  }

  /// Factory per accesso negato
  factory EmptyStateWidget.accessDenied({VoidCallback? onContactSupport}) {
    return EmptyStateWidget(
      icon: Icons.lock_outline,
      iconColor: AppColors.warning,
      title: 'Access Denied',
      subtitle: 'You don\'t have permission to view this content.',
      primaryAction: onContactSupport != null
          ? TextButton.icon(
              onPressed: onContactSupport,
              icon: const Icon(Icons.help),
              label: const Text('Contact Support'),
            )
          : null,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: backgroundColor,
      padding:
          padding ??
          ResponsivePadding(
            mobile: const EdgeInsets.all(AppDimens.spacingXL),
            desktop: const EdgeInsets.all(AppDimens.spacingXXL),
            child: const SizedBox.shrink(),
          ).padding,
      child: ResponsiveBuilder(
        mobile: _buildMobileLayout(context),
        desktop: _buildDesktopLayout(context),
      ),
    );
  }

  Widget _buildMobileLayout(BuildContext context) {
    return _buildContent(context, compact: true);
  }

  Widget _buildDesktopLayout(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 500),
        child: _buildContent(context, compact: false),
      ),
    );
  }

  Widget _buildContent(BuildContext context, {required bool compact}) {
    final content = Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Illustration, Custom Icon, or Default Icon
        _buildIllustration(context, compact: compact),

        SizedBox(height: compact ? AppDimens.spacingL : AppDimens.spacingXL),

        // Title
        _buildTitle(context, compact: compact),

        // Subtitle
        if (subtitle != null) ...[
          SizedBox(height: compact ? AppDimens.spacingS : AppDimens.spacingM),
          _buildSubtitle(context, compact: compact),
        ],

        // Actions
        if (primaryAction != null || secondaryAction != null) ...[
          SizedBox(height: compact ? AppDimens.spacingL : AppDimens.spacingXL),
          _buildActions(context, compact: compact),
        ],
      ],
    );

    return animated ? _AnimatedEmptyState(child: content) : content;
  }

  Widget _buildIllustration(BuildContext context, {required bool compact}) {
    final effectiveIconSize = iconSize ?? (compact ? 64.0 : 80.0);
    final effectiveIconColor = iconColor ?? AppColors.neutral400;

    if (illustration != null) {
      return illustration!;
    }

    if (customIcon != null) {
      return customIcon!;
    }

    return Icon(
      icon ?? Icons.inbox_outlined,
      size: effectiveIconSize,
      color: effectiveIconColor,
    );
  }

  Widget _buildTitle(BuildContext context, {required bool compact}) {
    return Text(
      title,
      style:
          (compact
                  ? Theme.of(context).textTheme.titleLarge
                  : Theme.of(context).textTheme.headlineSmall)
              ?.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColors.neutral700,
              ),
      textAlign: TextAlign.center,
    );
  }

  Widget _buildSubtitle(BuildContext context, {required bool compact}) {
    return Text(
      subtitle!,
      style:
          (compact
                  ? Theme.of(context).textTheme.bodyMedium
                  : Theme.of(context).textTheme.bodyLarge)
              ?.copyWith(color: AppColors.neutral500, height: 1.5),
      textAlign: TextAlign.center,
    );
  }

  Widget _buildActions(BuildContext context, {required bool compact}) {
    if (primaryAction == null && secondaryAction == null) {
      return const SizedBox.shrink();
    }

    final actions = <Widget>[];

    if (primaryAction != null) {
      actions.add(primaryAction!);
    }

    if (secondaryAction != null) {
      if (actions.isNotEmpty) {
        actions.add(
          SizedBox(width: compact ? AppDimens.spacingM : AppDimens.spacingL),
        );
      }
      actions.add(secondaryAction!);
    }

    return compact
        ? Column(
            children: actions
                .expand(
                  (action) => [
                    action,
                    const SizedBox(height: AppDimens.spacingM),
                  ],
                )
                .take(actions.length * 2 - 1)
                .toList(),
          )
        : Row(mainAxisAlignment: MainAxisAlignment.center, children: actions);
  }
}

/// Widget per animazioni dell'empty state
class _AnimatedEmptyState extends StatefulWidget {
  final Widget child;

  const _AnimatedEmptyState({required this.child});

  @override
  State<_AnimatedEmptyState> createState() => _AnimatedEmptyStateState();
}

class _AnimatedEmptyStateState extends State<_AnimatedEmptyState>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.7, curve: Curves.easeOut),
      ),
    );

    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _animationController,
            curve: const Interval(0.2, 1.0, curve: Curves.easeOutBack),
          ),
        );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return FadeTransition(
          opacity: _fadeAnimation,
          child: SlideTransition(
            position: _slideAnimation,
            child: widget.child,
          ),
        );
      },
    );
  }
}

/// Mixin per widget che usano empty states
mixin EmptyStateMixin {
  /// Costruisce un empty state per liste vuote
  Widget buildEmptyListState({
    required String title,
    required String subtitle,
    required VoidCallback onAction,
    required String actionLabel,
    IconData? icon,
  }) {
    return EmptyStateWidget(
      icon: icon ?? Icons.inbox_outlined,
      title: title,
      subtitle: subtitle,
      primaryAction: ElevatedButton.icon(
        onPressed: onAction,
        icon: const Icon(Icons.add),
        label: Text(actionLabel),
      ),
    );
  }

  /// Costruisce un empty state per ricerche
  Widget buildEmptySearchState({
    required String searchQuery,
    required VoidCallback onClear,
  }) {
    return EmptyStateWidget.noSearchResults(
      searchQuery: searchQuery,
      onClearSearch: onClear,
    );
  }

  /// Costruisce un empty state per errori
  Widget buildErrorState({
    required String message,
    required VoidCallback onRetry,
  }) {
    return EmptyStateWidget.error(message: message, onRetry: onRetry);
  }
}
