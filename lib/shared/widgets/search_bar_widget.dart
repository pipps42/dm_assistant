// lib/shared/widgets/search_bar_widget.dart
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dm_assistant/core/constants/app_colors.dart';
import 'package:dm_assistant/core/constants/dimens.dart';
import 'package:dm_assistant/core/responsive/responsive_builder.dart';

/// Callback per when search query changes
typedef SearchCallback = void Function(String query);

/// Callback per quando viene selezionato un risultato di ricerca
typedef SearchResultCallback<T> = void Function(T result);

/// Widget search bar riutilizzabile e personalizzabile
class AppSearchBar extends StatefulWidget {
  /// Hint text da mostrare nel campo di ricerca
  final String hintText;

  /// Valore iniziale del campo di ricerca
  final String initialValue;

  /// Callback chiamato quando il testo cambia
  final SearchCallback? onChanged;

  /// Callback chiamato quando viene premuto il tasto invio
  final SearchCallback? onSubmitted;

  /// Callback chiamato quando viene premuto il pulsante di ricerca
  final VoidCallback? onSearchPressed;

  /// Callback chiamato quando viene premuto il pulsante clear
  final VoidCallback? onClearPressed;

  /// Se mostrare il pulsante di ricerca
  final bool showSearchButton;

  /// Se mostrare il pulsante per pulire il campo
  final bool showClearButton;

  /// Se il campo è enabled
  final bool enabled;

  /// Se mostrare l'icona di ricerca come prefisso
  final bool showPrefixIcon;

  /// Icona personalizzata per la ricerca
  final IconData? searchIcon;

  /// Icona personalizzata per pulire
  final IconData? clearIcon;

  /// Debounce time in millisecondi per onChanged
  final int debounceTime;

  /// Se focus automaticamente il campo quando viene creato
  final bool autofocus;

  /// Controller personalizzato
  final TextEditingController? controller;

  /// FocusNode personalizzato
  final FocusNode? focusNode;

  /// Input decoration personalizzata
  final InputDecoration? decoration;

  /// Style del testo
  final TextStyle? textStyle;

  /// Altezza del search bar
  final double? height;

  /// Border radius personalizzato
  final double? borderRadius;

  /// Background color
  final Color? backgroundColor;

  /// Se mostrare suggerimenti di ricerca
  final bool showSuggestions;

  /// Lista di suggerimenti
  final List<String>? suggestions;

  /// Callback per quando viene selezionato un suggerimento
  final SearchCallback? onSuggestionSelected;

  const AppSearchBar({
    super.key,
    this.hintText = 'Search...',
    this.initialValue = '',
    this.onChanged,
    this.onSubmitted,
    this.onSearchPressed,
    this.onClearPressed,
    this.showSearchButton = false,
    this.showClearButton = true,
    this.enabled = true,
    this.showPrefixIcon = true,
    this.searchIcon = Icons.search,
    this.clearIcon = Icons.clear,
    this.debounceTime = 300,
    this.autofocus = false,
    this.controller,
    this.focusNode,
    this.decoration,
    this.textStyle,
    this.height,
    this.borderRadius,
    this.backgroundColor,
    this.showSuggestions = false,
    this.suggestions,
    this.onSuggestionSelected,
  });

  @override
  State<AppSearchBar> createState() => _AppSearchBarState();
}

class _AppSearchBarState extends State<AppSearchBar> {
  late TextEditingController _controller;
  late FocusNode _focusNode;
  String _currentQuery = '';
  Timer? _debounceTimer;
  bool _showSuggestions = false;
  final LayerLink _layerLink = LayerLink();
  OverlayEntry? _overlayEntry;

  @override
  void initState() {
    super.initState();
    _controller =
        widget.controller ?? TextEditingController(text: widget.initialValue);
    _focusNode = widget.focusNode ?? FocusNode();
    _currentQuery = widget.initialValue;

    _focusNode.addListener(_onFocusChange);

    if (widget.autofocus) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _focusNode.requestFocus();
      });
    }
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _removeOverlay();
    if (widget.controller == null) _controller.dispose();
    if (widget.focusNode == null) _focusNode.dispose();
    super.dispose();
  }

  void _onFocusChange() {
    if (_focusNode.hasFocus &&
        widget.showSuggestions &&
        _getSuggestions().isNotEmpty) {
      _showSuggestionsOverlay();
    } else {
      _removeOverlay();
    }
  }

  void _onTextChanged(String value) {
    setState(() {
      _currentQuery = value;
    });

    // Cancel previous timer
    _debounceTimer?.cancel();

    // Start new timer
    _debounceTimer = Timer(Duration(milliseconds: widget.debounceTime), () {
      widget.onChanged?.call(value);
    });

    // Update suggestions
    if (widget.showSuggestions) {
      if (value.isNotEmpty && _getSuggestions().isNotEmpty) {
        _showSuggestionsOverlay();
      } else {
        _removeOverlay();
      }
    }
  }

  void _onSubmitted(String value) {
    _removeOverlay();
    widget.onSubmitted?.call(value);
  }

  void _onClearPressed() {
    _controller.clear();
    setState(() {
      _currentQuery = '';
    });
    _removeOverlay();
    widget.onClearPressed?.call();
    widget.onChanged?.call('');
  }

  List<String> _getSuggestions() {
    if (widget.suggestions == null || _currentQuery.isEmpty) return [];

    return widget.suggestions!
        .where(
          (suggestion) =>
              suggestion.toLowerCase().contains(_currentQuery.toLowerCase()),
        )
        .take(5)
        .toList();
  }

  void _showSuggestionsOverlay() {
    if (_overlayEntry != null) return;

    _overlayEntry = OverlayEntry(
      builder: (context) => _SuggestionsOverlay(
        layerLink: _layerLink,
        suggestions: _getSuggestions(),
        onSuggestionTap: (suggestion) {
          _controller.text = suggestion;
          setState(() {
            _currentQuery = suggestion;
          });
          _removeOverlay();
          widget.onSuggestionSelected?.call(suggestion);
          widget.onChanged?.call(suggestion);
        },
        onDismiss: _removeOverlay,
      ),
    );

    Overlay.of(context).insert(_overlayEntry!);
  }

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  @override
  Widget build(BuildContext context) {
    return CompositedTransformTarget(
      link: _layerLink,
      child: ResponsiveBuilder(
        mobile: _buildMobileSearchBar(context),
        desktop: _buildDesktopSearchBar(context),
      ),
    );
  }

  Widget _buildMobileSearchBar(BuildContext context) {
    return _buildSearchField(context, compact: true);
  }

  Widget _buildDesktopSearchBar(BuildContext context) {
    return _buildSearchField(context, compact: false);
  }

  Widget _buildSearchField(BuildContext context, {required bool compact}) {
    final effectiveDecoration =
        widget.decoration ??
        InputDecoration(
          hintText: widget.hintText,
          hintStyle: TextStyle(
            color: AppColors.neutral400,
            fontSize: compact ? 14 : 16,
          ),
          prefixIcon: widget.showPrefixIcon
              ? Icon(
                  widget.searchIcon,
                  color: AppColors.neutral400,
                  size: compact ? 20 : 24,
                )
              : null,
          suffixIcon: _buildSuffixIcon(),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(
              widget.borderRadius ??
                  (compact ? AppDimens.radiusM : AppDimens.radiusL),
            ),
            borderSide: BorderSide(color: AppColors.neutral300, width: 1),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(
              widget.borderRadius ??
                  (compact ? AppDimens.radiusM : AppDimens.radiusL),
            ),
            borderSide: BorderSide(color: AppColors.neutral300, width: 1),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(
              widget.borderRadius ??
                  (compact ? AppDimens.radiusM : AppDimens.radiusL),
            ),
            borderSide: BorderSide(color: AppColors.primary, width: 2),
          ),
          filled: true,
          fillColor:
              widget.backgroundColor ??
              (Theme.of(context).brightness == Brightness.dark
                  ? AppColors.darkSurfaceVariant
                  : AppColors.neutral50),
          contentPadding: EdgeInsets.symmetric(
            horizontal: compact ? AppDimens.spacingM : AppDimens.spacingL,
            vertical: compact ? AppDimens.spacingS : AppDimens.spacingM,
          ),
        );

    return Container(
      height: widget.height,
      child: TextFormField(
        controller: _controller,
        focusNode: _focusNode,
        enabled: widget.enabled,
        style: widget.textStyle ?? Theme.of(context).textTheme.bodyMedium,
        decoration: effectiveDecoration,
        onChanged: _onTextChanged,
        onFieldSubmitted: _onSubmitted,
        textInputAction: TextInputAction.search,
      ),
    );
  }

  Widget? _buildSuffixIcon() {
    final List<Widget> actions = [];

    // Clear button
    if (widget.showClearButton && _currentQuery.isNotEmpty) {
      actions.add(
        IconButton(
          onPressed: widget.enabled ? _onClearPressed : null,
          icon: Icon(widget.clearIcon, color: AppColors.neutral400, size: 20),
          padding: const EdgeInsets.all(4),
          constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
        ),
      );
    }

    // Search button
    if (widget.showSearchButton) {
      actions.add(
        IconButton(
          onPressed: widget.enabled
              ? () {
                  widget.onSearchPressed?.call();
                  widget.onSubmitted?.call(_currentQuery);
                }
              : null,
          icon: Icon(widget.searchIcon, color: AppColors.primary, size: 20),
          padding: const EdgeInsets.all(4),
          constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
        ),
      );
    }

    if (actions.isEmpty) return null;
    if (actions.length == 1) return actions.first;

    return Row(mainAxisSize: MainAxisSize.min, children: actions);
  }
}

/// Overlay per mostrare i suggerimenti di ricerca
class _SuggestionsOverlay extends StatelessWidget {
  final LayerLink layerLink;
  final List<String> suggestions;
  final ValueChanged<String> onSuggestionTap;
  final VoidCallback onDismiss;

  const _SuggestionsOverlay({
    required this.layerLink,
    required this.suggestions,
    required this.onSuggestionTap,
    required this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onDismiss,
      behavior: HitTestBehavior.translucent,
      child: SizedBox.expand(
        child: Stack(
          children: [
            CompositedTransformFollower(
              link: layerLink,
              showWhenUnlinked: false,
              offset: const Offset(0, 4),
              child: Material(
                elevation: 8,
                borderRadius: BorderRadius.circular(AppDimens.radiusM),
                color: Theme.of(context).colorScheme.surface,
                child: Container(
                  constraints: const BoxConstraints(
                    maxHeight: 200,
                    minWidth: 200,
                  ),
                  child: ListView.builder(
                    shrinkWrap: true,
                    padding: const EdgeInsets.symmetric(
                      vertical: AppDimens.spacingS,
                    ),
                    itemCount: suggestions.length,
                    itemBuilder: (context, index) {
                      final suggestion = suggestions[index];
                      return ListTile(
                        dense: true,
                        leading: Icon(
                          Icons.search,
                          size: 16,
                          color: AppColors.neutral400,
                        ),
                        title: Text(
                          suggestion,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        onTap: () => onSuggestionTap(suggestion),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: AppDimens.spacingM,
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Versione semplificata per uso rapido
class SimpleSearchBar extends StatelessWidget {
  final String hintText;
  final SearchCallback? onChanged;
  final String initialValue;

  const SimpleSearchBar({
    super.key,
    this.hintText = 'Search...',
    this.onChanged,
    this.initialValue = '',
  });

  @override
  Widget build(BuildContext context) {
    return AppSearchBar(
      hintText: hintText,
      onChanged: onChanged,
      initialValue: initialValue,
      showClearButton: true,
      showPrefixIcon: true,
    );
  }
}

/// Widget search bar con filtri integrati
class SearchBarWithFilters<T> extends StatefulWidget {
  final String hintText;
  final SearchCallback? onSearchChanged;
  final ValueChanged<T?>? onFilterChanged;
  final List<FilterOption<T>> filterOptions;
  final T? selectedFilter;
  final String initialSearchValue;

  const SearchBarWithFilters({
    super.key,
    this.hintText = 'Search...',
    this.onSearchChanged,
    this.onFilterChanged,
    this.filterOptions = const [],
    this.selectedFilter,
    this.initialSearchValue = '',
  });

  @override
  State<SearchBarWithFilters<T>> createState() =>
      _SearchBarWithFiltersState<T>();
}

class _SearchBarWithFiltersState<T> extends State<SearchBarWithFilters<T>> {
  @override
  Widget build(BuildContext context) {
    return ResponsiveBuilder(
      mobile: _buildMobileLayout(context),
      desktop: _buildDesktopLayout(context),
    );
  }

  Widget _buildMobileLayout(BuildContext context) {
    return Column(
      children: [
        AppSearchBar(
          hintText: widget.hintText,
          onChanged: widget.onSearchChanged,
          initialValue: widget.initialSearchValue,
        ),
        if (widget.filterOptions.isNotEmpty) ...[
          const SizedBox(height: AppDimens.spacingM),
          _buildFilterChips(context),
        ],
      ],
    );
  }

  Widget _buildDesktopLayout(BuildContext context) {
    return Row(
      children: [
        Expanded(
          flex: 2,
          child: AppSearchBar(
            hintText: widget.hintText,
            onChanged: widget.onSearchChanged,
            initialValue: widget.initialSearchValue,
          ),
        ),
        if (widget.filterOptions.isNotEmpty) ...[
          const SizedBox(width: AppDimens.spacingL),
          Expanded(flex: 1, child: _buildFilterChips(context)),
        ],
      ],
    );
  }

  Widget _buildFilterChips(BuildContext context) {
    return Wrap(
      spacing: AppDimens.spacingS,
      children: widget.filterOptions.map((option) {
        final isSelected = widget.selectedFilter == option.value;

        return FilterChip(
          label: Text(option.label),
          selected: isSelected,
          onSelected: (selected) {
            widget.onFilterChanged?.call(selected ? option.value : null);
          },
          backgroundColor: Theme.of(context).colorScheme.background,
          selectedColor: AppColors.primary.withOpacity(0.1),
          checkmarkColor: AppColors.primary,
        );
      }).toList(),
    );
  }
}

/// Modello per opzioni di filtro
class FilterOption<T> {
  final String label;
  final T value;
  final IconData? icon;

  const FilterOption({required this.label, required this.value, this.icon});
}

/// Provider per gestire lo stato di ricerca globale
final globalSearchProvider = StateProvider<String>((ref) => '');

/// Widget search bar che si sincronizza con il provider globale
class GlobalSearchBar extends ConsumerWidget {
  final String hintText;

  const GlobalSearchBar({super.key, this.hintText = 'Search...'});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final searchQuery = ref.watch(globalSearchProvider);

    return AppSearchBar(
      hintText: hintText,
      initialValue: searchQuery,
      onChanged: (value) {
        ref.read(globalSearchProvider.notifier).state = value;
      },
    );
  }
}
