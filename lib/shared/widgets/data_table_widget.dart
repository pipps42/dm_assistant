// lib/shared/widgets/data_table_widget.dart
import 'package:flutter/material.dart';
import 'package:dm_assistant/core/constants/app_colors.dart';
import 'package:dm_assistant/core/constants/dimens.dart';
import 'package:dm_assistant/core/responsive/responsive_builder.dart';
import 'package:dm_assistant/core/widgets/empty_state_widget.dart';

/// Callback per azioni su righe
typedef RowActionCallback<T> = void Function(T item);

/// Callback per ordinamento colonne
typedef SortCallback<T> = void Function(String columnKey, bool ascending);

/// Modello per una colonna della tabella
class DataTableColumn<T> {
  /// Chiave univoca della colonna
  final String key;

  /// Label da mostrare nell'header
  final String label;

  /// Funzione per ottenere il valore da mostrare nella cella
  final String Function(T item) getValue;

  /// Widget personalizzato per la cella (opzionale)
  final Widget Function(T item)? buildCell;

  /// Se la colonna è ordinabile
  final bool sortable;

  /// Larghezza fissa della colonna
  final double? width;

  /// Larghezza minima della colonna
  final double? minWidth;

  /// Larghezza massima della colonna
  final double? maxWidth;

  /// Flex della colonna (per colonne elastiche)
  final int? flex;

  /// Allineamento del contenuto
  final Alignment alignment;

  /// Se nascondere la colonna su mobile
  final bool hideOnMobile;

  /// Tooltip per l'header della colonna
  final String? tooltip;

  /// Icona da mostrare nell'header
  final IconData? icon;

  const DataTableColumn({
    required this.key,
    required this.label,
    required this.getValue,
    this.buildCell,
    this.sortable = false,
    this.width,
    this.minWidth,
    this.maxWidth,
    this.flex,
    this.alignment = Alignment.centerLeft,
    this.hideOnMobile = false,
    this.tooltip,
    this.icon,
  });
}

/// Modello per azioni su righe
class RowAction<T> {
  /// Label dell'azione
  final String label;

  /// Icona dell'azione
  final IconData icon;

  /// Callback dell'azione
  final RowActionCallback<T> onPressed;

  /// Colore dell'azione
  final Color? color;

  /// Se l'azione è distruttiva
  final bool isDestructive;

  /// Tooltip dell'azione
  final String? tooltip;

  const RowAction({
    required this.label,
    required this.icon,
    required this.onPressed,
    this.color,
    this.isDestructive = false,
    this.tooltip,
  });
}

/// Widget data table responsive e personalizzabile
class AppDataTable<T> extends StatefulWidget {
  /// Dati da mostrare nella tabella
  final List<T> data;

  /// Definizione delle colonne
  final List<DataTableColumn<T>> columns;

  /// Azioni disponibili per ogni riga
  final List<RowAction<T>>? rowActions;

  /// Callback per tap su riga
  final RowActionCallback<T>? onRowTap;

  /// Callback per selezione multipla
  final void Function(List<T> selectedItems)? onSelectionChanged;

  /// Se abilitare la selezione multipla
  final bool enableSelection;

  /// Se mostrare il checkbox per selezionare tutto
  final bool showSelectAll;

  /// Callback per ordinamento
  final SortCallback<T>? onSort;

  /// Colonna correntemente ordinata
  final String? sortColumn;

  /// Direzione dell'ordinamento
  final bool sortAscending;

  /// Se mostrare i bordi tra le righe
  final bool showRowDividers;

  /// Se abilitare hover effects
  final bool enableHover;

  /// Altezza delle righe
  final double? rowHeight;

  /// Padding delle celle
  final EdgeInsets? cellPadding;

  /// Widget da mostrare quando non ci sono dati
  final Widget? emptyWidget;

  /// Se la tabella è loading
  final bool isLoading;

  /// Widget di loading personalizzato
  final Widget? loadingWidget;

  /// Se la tabella è scrollabile orizzontalmente
  final bool horizontalScrollable;

  /// Se compattare la tabella su mobile
  final bool compactOnMobile;

  const AppDataTable({
    super.key,
    required this.data,
    required this.columns,
    this.rowActions,
    this.onRowTap,
    this.onSelectionChanged,
    this.enableSelection = false,
    this.showSelectAll = true,
    this.onSort,
    this.sortColumn,
    this.sortAscending = true,
    this.showRowDividers = true,
    this.enableHover = true,
    this.rowHeight,
    this.cellPadding,
    this.emptyWidget,
    this.isLoading = false,
    this.loadingWidget,
    this.horizontalScrollable = true,
    this.compactOnMobile = true,
  });

  @override
  State<AppDataTable<T>> createState() => _AppDataTableState<T>();
}

class _AppDataTableState<T> extends State<AppDataTable<T>> {
  final Set<T> _selectedItems = {};

  @override
  Widget build(BuildContext context) {
    if (widget.isLoading) {
      return widget.loadingWidget ??
          const Center(child: CircularProgressIndicator());
    }

    if (widget.data.isEmpty) {
      return widget.emptyWidget ??
          EmptyStateWidget(
            icon: Icons.table_chart_outlined,
            title: 'No data available',
            subtitle: 'There are no items to display in this table',
          );
    }

    return ResponsiveBuilder(
      mobile: widget.compactOnMobile
          ? _buildMobileCardList(context)
          : _buildScrollableTable(context),
      desktop: _buildDesktopTable(context),
    );
  }

  Widget _buildDesktopTable(BuildContext context) {
    return _buildScrollableTable(context);
  }

  Widget _buildScrollableTable(BuildContext context) {
    Widget table = _buildDataTable(context, compact: false);

    if (widget.horizontalScrollable) {
      table = SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: table,
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(AppDimens.radiusM),
        border: Border.all(color: Theme.of(context).dividerColor, width: 1),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppDimens.radiusM),
        child: table,
      ),
    );
  }

  Widget _buildMobileCardList(BuildContext context) {
    return ListView.separated(
      itemCount: widget.data.length,
      separatorBuilder: (context, index) =>
          const SizedBox(height: AppDimens.spacingS),
      itemBuilder: (context, index) {
        final item = widget.data[index];
        return _buildMobileCard(context, item, index);
      },
    );
  }

  Widget _buildMobileCard(BuildContext context, T item, int index) {
    final isSelected = _selectedItems.contains(item);

    return Card(
      margin: EdgeInsets.zero,
      child: InkWell(
        onTap: widget.onRowTap != null ? () => widget.onRowTap!(item) : null,
        borderRadius: BorderRadius.circular(AppDimens.radiusM),
        child: Padding(
          padding: const EdgeInsets.all(AppDimens.spacingM),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header row con selezione e azioni
              Row(
                children: [
                  if (widget.enableSelection) ...[
                    Checkbox(
                      value: isSelected,
                      onChanged: (value) => _toggleSelection(item),
                    ),
                    const SizedBox(width: AppDimens.spacingS),
                  ],

                  Expanded(
                    child: Text(
                      widget.columns.first.getValue(item),
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),

                  if (widget.rowActions != null)
                    _buildRowActionsMenu(context, item),
                ],
              ),

              // Data rows
              const SizedBox(height: AppDimens.spacingS),
              ...widget.columns
                  .skip(1)
                  .where((col) => !col.hideOnMobile)
                  .map(
                    (column) => Padding(
                      padding: const EdgeInsets.only(
                        bottom: AppDimens.spacingXS,
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                            width: 100,
                            child: Text(
                              column.label,
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(
                                    color: AppColors.neutral500,
                                    fontWeight: FontWeight.w500,
                                  ),
                            ),
                          ),
                          Expanded(
                            child:
                                column.buildCell?.call(item) ??
                                Text(
                                  column.getValue(item),
                                  style: Theme.of(context).textTheme.bodyMedium,
                                ),
                          ),
                        ],
                      ),
                    ),
                  ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDataTable(BuildContext context, {required bool compact}) {
    return DataTable(
      columns: _buildColumns(context, compact: compact),
      rows: _buildRows(context, compact: compact),
      showCheckboxColumn: widget.enableSelection,
      sortColumnIndex: widget.sortColumn != null
          ? widget.columns.indexWhere((col) => col.key == widget.sortColumn)
          : null,
      sortAscending: widget.sortAscending,
      columnSpacing: compact ? AppDimens.spacingS : AppDimens.spacingM,
      horizontalMargin: compact ? AppDimens.spacingS : AppDimens.spacingM,
      dataRowHeight: widget.rowHeight ?? (compact ? 48 : 56),
      headingRowHeight: compact ? 44 : 56,
      dividerThickness: widget.showRowDividers ? 1 : 0,
      showBottomBorder: true,
    );
  }

  List<DataColumn> _buildColumns(
    BuildContext context, {
    required bool compact,
  }) {
    final visibleColumns = widget.columns
        .where((col) => !compact || !col.hideOnMobile)
        .toList();

    return visibleColumns.map((column) {
      Widget label = Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (column.icon != null) ...[
            Icon(
              column.icon,
              size: compact ? 16 : 18,
              color: AppColors.neutral600,
            ),
            const SizedBox(width: AppDimens.spacingXS),
          ],
          Text(
            column.label,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: compact ? 12 : 14,
              color: AppColors.neutral700,
            ),
          ),
        ],
      );

      if (column.tooltip != null) {
        label = Tooltip(message: column.tooltip!, child: label);
      }

      return DataColumn(
        label: label,
        onSort: column.sortable && widget.onSort != null
            ? (columnIndex, ascending) => widget.onSort!(column.key, ascending)
            : null,
      );
    }).toList();
  }

  List<DataRow> _buildRows(BuildContext context, {required bool compact}) {
    return widget.data.asMap().entries.map((entry) {
      final index = entry.key;
      final item = entry.value;
      final isSelected = _selectedItems.contains(item);

      final visibleColumns = widget.columns
          .where((col) => !compact || !col.hideOnMobile)
          .toList();

      return DataRow(
        selected: isSelected,
        onSelectChanged: widget.enableSelection
            ? (selected) => _toggleSelection(item)
            : null,
        cells: visibleColumns.map((column) {
          Widget cellContent =
              column.buildCell?.call(item) ??
              Text(
                column.getValue(item),
                style: TextStyle(fontSize: compact ? 12 : 14),
                overflow: TextOverflow.ellipsis,
              );

          // Add row actions to last column if present
          if (column == visibleColumns.last && widget.rowActions != null) {
            cellContent = Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(child: cellContent),
                _buildRowActionsMenu(context, item),
              ],
            );
          }

          return DataCell(
            Container(
              alignment: column.alignment,
              padding:
                  widget.cellPadding ??
                  EdgeInsets.symmetric(
                    vertical: compact
                        ? AppDimens.spacingXS
                        : AppDimens.spacingS,
                  ),
              child: cellContent,
            ),
            onTap: widget.onRowTap != null
                ? () => widget.onRowTap!(item)
                : null,
          );
        }).toList(),
      );
    }).toList();
  }

  Widget _buildRowActionsMenu(BuildContext context, T item) {
    if (widget.rowActions == null || widget.rowActions!.isEmpty) {
      return const SizedBox.shrink();
    }

    if (widget.rowActions!.length == 1) {
      final action = widget.rowActions!.first;
      return IconButton(
        icon: Icon(action.icon),
        onPressed: () => action.onPressed(item),
        tooltip: action.tooltip ?? action.label,
        color: action.color,
        iconSize: 20,
      );
    }

    return PopupMenuButton<RowAction<T>>(
      icon: const Icon(Icons.more_vert, size: 20),
      onSelected: (action) => action.onPressed(item),
      itemBuilder: (context) => widget.rowActions!.map((action) {
        return PopupMenuItem<RowAction<T>>(
          value: action,
          child: ListTile(
            leading: Icon(
              action.icon,
              size: 20,
              color: action.isDestructive ? AppColors.error : action.color,
            ),
            title: Text(
              action.label,
              style: TextStyle(
                color: action.isDestructive ? AppColors.error : null,
              ),
            ),
            dense: true,
            contentPadding: EdgeInsets.zero,
          ),
        );
      }).toList(),
    );
  }

  void _toggleSelection(T item) {
    setState(() {
      if (_selectedItems.contains(item)) {
        _selectedItems.remove(item);
      } else {
        _selectedItems.add(item);
      }
    });
    widget.onSelectionChanged?.call(_selectedItems.toList());
  }
}

/// Widget per tabelle semplici senza troppe funzionalità
class SimpleDataTable<T> extends StatelessWidget {
  final List<T> data;
  final List<DataTableColumn<T>> columns;
  final RowActionCallback<T>? onRowTap;

  const SimpleDataTable({
    super.key,
    required this.data,
    required this.columns,
    this.onRowTap,
  });

  @override
  Widget build(BuildContext context) {
    return AppDataTable<T>(
      data: data,
      columns: columns,
      onRowTap: onRowTap,
      enableSelection: false,
      enableHover: true,
      compactOnMobile: true,
    );
  }
}

/// Tabella paginata
class PaginatedDataTable<T> extends StatefulWidget {
  final List<T> data;
  final List<DataTableColumn<T>> columns;
  final int rowsPerPage;
  final List<RowAction<T>>? rowActions;
  final RowActionCallback<T>? onRowTap;

  const PaginatedDataTable({
    super.key,
    required this.data,
    required this.columns,
    this.rowsPerPage = 10,
    this.rowActions,
    this.onRowTap,
  });

  @override
  State<PaginatedDataTable<T>> createState() => _PaginatedDataTableState<T>();
}

class _PaginatedDataTableState<T> extends State<PaginatedDataTable<T>> {
  int _currentPage = 0;

  int get _totalPages => (widget.data.length / widget.rowsPerPage).ceil();

  List<T> get _currentPageData {
    final startIndex = _currentPage * widget.rowsPerPage;
    final endIndex = (startIndex + widget.rowsPerPage).clamp(
      0,
      widget.data.length,
    );
    return widget.data.sublist(startIndex, endIndex);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: AppDataTable<T>(
            data: _currentPageData,
            columns: widget.columns,
            rowActions: widget.rowActions,
            onRowTap: widget.onRowTap,
          ),
        ),
        if (_totalPages > 1) _buildPagination(context),
      ],
    );
  }

  Widget _buildPagination(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppDimens.spacingM),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(color: Theme.of(context).dividerColor, width: 1),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Showing ${_currentPage * widget.rowsPerPage + 1}-${(_currentPage + 1) * widget.rowsPerPage} of ${widget.data.length}',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          Row(
            children: [
              IconButton(
                onPressed: _currentPage > 0
                    ? () {
                        setState(() {
                          _currentPage--;
                        });
                      }
                    : null,
                icon: const Icon(Icons.chevron_left),
              ),
              Text('${_currentPage + 1} / $_totalPages'),
              IconButton(
                onPressed: _currentPage < _totalPages - 1
                    ? () {
                        setState(() {
                          _currentPage++;
                        });
                      }
                    : null,
                icon: const Icon(Icons.chevron_right),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
