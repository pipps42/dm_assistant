// lib/shared/components/inputs/search_bar.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dm_assistant/core/constants/dimens.dart';

class CustomSearchBar extends ConsumerStatefulWidget {
  final String hint;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final VoidCallback? onClear;
  final List<SearchFilter>? filters;
  final bool showFilters;
  final bool autofocus;
  final TextEditingController? controller;
  final Widget? leading;
  final List<Widget>? actions;

  const CustomSearchBar({
    super.key,
    this.hint = 'Search...',
    this.onChanged,
    this.onSubmitted,
    this.onClear,
    this.filters,
    this.showFilters = true,
    this.autofocus = false,
    this.controller,
    this.leading,
    this.actions,
  });

  @override
  ConsumerState<CustomSearchBar> createState() => _CustomSearchBarState();
}

class _CustomSearchBarState extends ConsumerState<CustomSearchBar> {
  late TextEditingController _controller;
  final FocusNode _focusNode = FocusNode();
  bool _showClear = false;
  List<SearchFilter> _activeFilters = [];

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? TextEditingController();
    _controller.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    if (widget.controller == null) {
      _controller.dispose();
    }
    _focusNode.dispose();
    super.dispose();
  }

  void _onTextChanged() {
    setState(() {
      _showClear = _controller.text.isNotEmpty;
    });
    widget.onChanged?.call(_controller.text);
  }

  void _handleClear() {
    _controller.clear();
    widget.onClear?.call();
    _focusNode.requestFocus();
  }

  void _toggleFilter(SearchFilter filter) {
    setState(() {
      if (_activeFilters.contains(filter)) {
        _activeFilters.remove(filter);
      } else {
        _activeFilters.add(filter);
      }
    });

    // Notify about filter changes
    final filterQuery = _activeFilters
        .map((f) => '${f.key}:${f.value}')
        .join(' ');
    widget.onChanged?.call('${_controller.text} $filterQuery'.trim());
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          height: 48,
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(AppDimens.radiusL),
            border: Border.all(
              color: _focusNode.hasFocus
                  ? theme.colorScheme.primary
                  : theme.colorScheme.outline.withOpacity(0.2),
              width: _focusNode.hasFocus ? 2 : 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              if (widget.leading != null) ...[
                const SizedBox(width: AppDimens.spacingM),
                widget.leading!,
              ] else ...[
                const SizedBox(width: AppDimens.spacingM),
                Icon(
                  Icons.search,
                  color: theme.colorScheme.onSurface.withOpacity(0.5),
                ),
              ],
              const SizedBox(width: AppDimens.spacingM),
              Expanded(
                child: TextField(
                  controller: _controller,
                  focusNode: _focusNode,
                  autofocus: widget.autofocus,
                  onSubmitted: widget.onSubmitted,
                  style: theme.textTheme.bodyLarge,
                  decoration: InputDecoration(
                    hintText: widget.hint,
                    hintStyle: TextStyle(
                      color: theme.colorScheme.onSurface.withOpacity(0.5),
                    ),
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
              ),
              if (_showClear) ...[
                IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: _handleClear,
                  iconSize: 20,
                  color: theme.colorScheme.onSurface.withOpacity(0.5),
                ),
              ],
              if (widget.filters != null &&
                  widget.filters!.isNotEmpty &&
                  widget.showFilters) ...[
                Container(
                  width: 1,
                  height: 24,
                  color: theme.dividerColor.withOpacity(0.2),
                ),
                IconButton(
                  icon: Icon(
                    Icons.filter_list,
                    color: _activeFilters.isNotEmpty
                        ? theme.colorScheme.primary
                        : theme.colorScheme.onSurface.withOpacity(0.5),
                  ),
                  onPressed: () => _showFilterDialog(context),
                  iconSize: 20,
                ),
              ],
              if (widget.actions != null) ...[...widget.actions!],
              const SizedBox(width: AppDimens.spacingS),
            ],
          ),
        ),
        if (_activeFilters.isNotEmpty) ...[
          const SizedBox(height: AppDimens.spacingS),
          SizedBox(
            height: 32,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: _activeFilters.length,
              separatorBuilder: (context, index) =>
                  const SizedBox(width: AppDimens.spacingS),
              itemBuilder: (context, index) {
                final filter = _activeFilters[index];
                return FilterChip(
                  label: Text(filter.label),
                  selected: true,
                  onSelected: (_) => _toggleFilter(filter),
                  deleteIcon: const Icon(Icons.close, size: 18),
                  onDeleted: () => _toggleFilter(filter),
                  labelStyle: theme.textTheme.bodySmall,
                  backgroundColor: theme.colorScheme.primary.withOpacity(0.1),
                  selectedColor: theme.colorScheme.primary.withOpacity(0.2),
                  checkmarkColor: theme.colorScheme.primary,
                  deleteIconColor: theme.colorScheme.primary,
                  side: BorderSide(
                    color: theme.colorScheme.primary.withOpacity(0.3),
                  ),
                );
              },
            ),
          ),
        ],
      ],
    );
  }

  void _showFilterDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => _FilterDialog(
        filters: widget.filters!,
        activeFilters: _activeFilters,
        onFiltersChanged: (filters) {
          setState(() {
            _activeFilters = filters;
          });

          final filterQuery = _activeFilters
              .map((f) => '${f.key}:${f.value}')
              .join(' ');
          widget.onChanged?.call('${_controller.text} $filterQuery'.trim());
        },
      ),
    );
  }
}

class _FilterDialog extends StatefulWidget {
  final List<SearchFilter> filters;
  final List<SearchFilter> activeFilters;
  final ValueChanged<List<SearchFilter>> onFiltersChanged;

  const _FilterDialog({
    required this.filters,
    required this.activeFilters,
    required this.onFiltersChanged,
  });

  @override
  State<_FilterDialog> createState() => _FilterDialogState();
}

class _FilterDialogState extends State<_FilterDialog> {
  late List<SearchFilter> _tempFilters;

  @override
  void initState() {
    super.initState();
    _tempFilters = List.from(widget.activeFilters);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimens.radiusXL),
      ),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 400),
        padding: const EdgeInsets.all(AppDimens.spacingL),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Filters', style: theme.textTheme.titleLarge),
            const SizedBox(height: AppDimens.spacingL),
            ...widget.filters.map(
              (filter) => CheckboxListTile(
                title: Text(filter.label),
                subtitle: filter.description != null
                    ? Text(filter.description!)
                    : null,
                value: _tempFilters.contains(filter),
                onChanged: (value) {
                  setState(() {
                    if (value == true) {
                      _tempFilters.add(filter);
                    } else {
                      _tempFilters.remove(filter);
                    }
                  });
                },
                contentPadding: EdgeInsets.zero,
              ),
            ),
            const SizedBox(height: AppDimens.spacingL),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () {
                    setState(() {
                      _tempFilters.clear();
                    });
                  },
                  child: const Text('Clear All'),
                ),
                const SizedBox(width: AppDimens.spacingS),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cancel'),
                ),
                const SizedBox(width: AppDimens.spacingS),
                ElevatedButton(
                  onPressed: () {
                    widget.onFiltersChanged(_tempFilters);
                    Navigator.of(context).pop();
                  },
                  child: const Text('Apply'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class SearchFilter {
  final String key;
  final String value;
  final String label;
  final String? description;
  final IconData? icon;

  const SearchFilter({
    required this.key,
    required this.value,
    required this.label,
    this.description,
    this.icon,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is SearchFilter && other.key == key && other.value == value;
  }

  @override
  int get hashCode => key.hashCode ^ value.hashCode;
}
