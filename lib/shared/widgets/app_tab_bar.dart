// lib/shared/widgets/app_tab_bar.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dm_assistant/core/constants/app_colors.dart';
import 'package:dm_assistant/core/constants/dimens.dart';
import 'package:dm_assistant/core/responsive/responsive_builder.dart';

/// Callback chiamato quando viene selezionato un tab
typedef TabSelectedCallback = void Function(int index);

/// Modello per un tab personalizzato
class AppTab {
  /// Testo del tab
  final String text;

  /// Icona del tab (opzionale)
  final IconData? icon;

  /// Badge da mostrare sul tab (opzionale)
  final String? badge;

  /// Se il tab è enabled
  final bool enabled;

  /// Tooltip del tab
  final String? tooltip;

  /// Widget personalizzato per il contenuto del tab
  final Widget? customContent;

  /// Callback chiamato quando il tab viene tappato
  final VoidCallback? onTap;

  const AppTab({
    required this.text,
    this.icon,
    this.badge,
    this.enabled = true,
    this.tooltip,
    this.customContent,
    this.onTap,
  });
}

/// Widget tab bar personalizzato e riutilizzabile
class AppTabBar extends StatefulWidget {
  /// Lista dei tab
  final List<AppTab> tabs;

  /// Indice del tab inizialmente selezionato
  final int initialIndex;

  /// Callback chiamato quando cambia il tab selezionato
  final TabSelectedCallback? onTabSelected;

  /// Se i tab possono essere scrollati orizzontalmente
  final bool isScrollable;

  /// Se mostrare i divisori tra i tab
  final bool showDividers;

  /// Se mostrare indicatori per i tab selezionati
  final bool showIndicator;

  /// Colore dell'indicatore del tab selezionato
  final Color? indicatorColor;

  /// Spessore dell'indicatore
  final double indicatorWeight;

  /// Padding dei tab
  final EdgeInsets? tabPadding;

  /// Altezza della tab bar
  final double? height;

  /// Background color della tab bar
  final Color? backgroundColor;

  /// Se i tab devono occupare tutto lo spazio disponibile
  final bool expandTabs;

  /// Stile del testo per i tab non selezionati
  final TextStyle? unselectedTextStyle;

  /// Stile del testo per il tab selezionato
  final TextStyle? selectedTextStyle;

  /// Colore dei tab non selezionati
  final Color? unselectedColor;

  /// Colore del tab selezionato
  final Color? selectedColor;

  /// Controller personalizzato per i tab
  final TabController? controller;

  const AppTabBar({
    super.key,
    required this.tabs,
    this.initialIndex = 0,
    this.onTabSelected,
    this.isScrollable = false,
    this.showDividers = false,
    this.showIndicator = true,
    this.indicatorColor,
    this.indicatorWeight = 2.0,
    this.tabPadding,
    this.height,
    this.backgroundColor,
    this.expandTabs = false,
    this.unselectedTextStyle,
    this.selectedTextStyle,
    this.unselectedColor,
    this.selectedColor,
    this.controller,
  });

  @override
  State<AppTabBar> createState() => _AppTabBarState();
}

class _AppTabBarState extends State<AppTabBar> with TickerProviderStateMixin {
  late TabController _controller;
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _controller =
        widget.controller ??
        TabController(
          length: widget.tabs.length,
          vsync: this,
          initialIndex: widget.initialIndex,
        );

    _controller.addListener(_onTabChanged);
  }

  @override
  void dispose() {
    if (widget.controller == null) {
      _controller.dispose();
    }
    super.dispose();
  }

  void _onTabChanged() {
    if (_controller.index != _currentIndex) {
      setState(() {
        _currentIndex = _controller.index;
      });
      widget.onTabSelected?.call(_controller.index);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ResponsiveBuilder(
      mobile: _buildMobileTabBar(context),
      desktop: _buildDesktopTabBar(context),
    );
  }

  Widget _buildMobileTabBar(BuildContext context) {
    return _buildTabBar(context, compact: true);
  }

  Widget _buildDesktopTabBar(BuildContext context) {
    return _buildTabBar(context, compact: false);
  }

  Widget _buildTabBar(BuildContext context, {required bool compact}) {
    return Container(
      height: widget.height ?? (compact ? 48.0 : 56.0),
      decoration: BoxDecoration(
        color: widget.backgroundColor ?? Theme.of(context).colorScheme.surface,
        border: widget.showDividers
            ? Border(
                bottom: BorderSide(
                  color: Theme.of(context).dividerColor,
                  width: 1,
                ),
              )
            : null,
      ),
      child: TabBar(
        controller: _controller,
        tabs: widget.tabs.asMap().entries.map((entry) {
          return _buildTab(context, entry.value, entry.key, compact: compact);
        }).toList(),
        isScrollable: widget.isScrollable,
        indicatorColor: widget.indicatorColor ?? AppColors.primary,
        indicatorWeight: widget.indicatorWeight,
        indicatorSize: TabBarIndicatorSize.tab,
        labelColor: widget.selectedColor ?? AppColors.primary,
        unselectedLabelColor: widget.unselectedColor ?? AppColors.neutral500,
        labelStyle:
            widget.selectedTextStyle ??
            TextStyle(fontSize: compact ? 14 : 16, fontWeight: FontWeight.w600),
        unselectedLabelStyle:
            widget.unselectedTextStyle ??
            TextStyle(fontSize: compact ? 14 : 16, fontWeight: FontWeight.w400),
        indicatorPadding: EdgeInsets.zero,
        labelPadding:
            widget.tabPadding ??
            EdgeInsets.symmetric(
              horizontal: compact ? AppDimens.spacingS : AppDimens.spacingM,
            ),
        splashFactory: InkRipple.splashFactory,
        overlayColor: MaterialStateProperty.resolveWith<Color?>((
          Set<MaterialState> states,
        ) {
          if (states.contains(MaterialState.hovered)) {
            return AppColors.primary.withOpacity(0.04);
          }
          if (states.contains(MaterialState.pressed)) {
            return AppColors.primary.withOpacity(0.08);
          }
          return null;
        }),
      ),
    );
  }

  Widget _buildTab(
    BuildContext context,
    AppTab tab,
    int index, {
    required bool compact,
  }) {
    final isSelected = index == _currentIndex;

    Widget content;

    if (tab.customContent != null) {
      content = tab.customContent!;
    } else {
      content = _buildDefaultTabContent(tab, isSelected, compact: compact);
    }

    // Wrap in tooltip if provided
    if (tab.tooltip != null) {
      content = Tooltip(message: tab.tooltip!, child: content);
    }

    return Tab(
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(
          horizontal: compact ? AppDimens.spacingS : AppDimens.spacingM,
          vertical: compact ? AppDimens.spacingXS : AppDimens.spacingS,
        ),
        child: content,
      ),
    );
  }

  Widget _buildDefaultTabContent(
    AppTab tab,
    bool isSelected, {
    required bool compact,
  }) {
    final List<Widget> children = [];

    // Icon
    if (tab.icon != null) {
      children.add(
        Icon(
          tab.icon,
          size: compact ? 16 : 20,
          color: isSelected
              ? (widget.selectedColor ?? AppColors.primary)
              : (widget.unselectedColor ?? AppColors.neutral500),
        ),
      );

      if (children.isNotEmpty) {
        children.add(SizedBox(width: compact ? 4 : 8));
      }
    }

    // Text
    children.add(
      Flexible(
        child: Text(
          tab.text,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: compact ? 14 : 16,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
            color: isSelected
                ? (widget.selectedColor ?? AppColors.primary)
                : (widget.unselectedColor ?? AppColors.neutral500),
          ),
        ),
      ),
    );

    // Badge
    if (tab.badge != null) {
      children.add(SizedBox(width: compact ? 4 : 8));
      children.add(_buildBadge(tab.badge!, compact: compact));
    }

    return Row(mainAxisSize: MainAxisSize.min, children: children);
  }

  Widget _buildBadge(String badge, {required bool compact}) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 4 : 6,
        vertical: compact ? 2 : 3,
      ),
      decoration: BoxDecoration(
        color: AppColors.error,
        borderRadius: BorderRadius.circular(compact ? 8 : 10),
      ),
      constraints: BoxConstraints(
        minWidth: compact ? 16 : 20,
        minHeight: compact ? 16 : 20,
      ),
      child: Text(
        badge,
        style: TextStyle(
          color: Colors.white,
          fontSize: compact ? 10 : 12,
          fontWeight: FontWeight.w600,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}

/// Tab bar con stile chip/segmented control
class ChipTabBar extends StatefulWidget {
  final List<AppTab> tabs;
  final int initialIndex;
  final TabSelectedCallback? onTabSelected;
  final EdgeInsets? padding;
  final Color? backgroundColor;
  final Color? selectedChipColor;
  final Color? unselectedChipColor;

  const ChipTabBar({
    super.key,
    required this.tabs,
    this.initialIndex = 0,
    this.onTabSelected,
    this.padding,
    this.backgroundColor,
    this.selectedChipColor,
    this.unselectedChipColor,
  });

  @override
  State<ChipTabBar> createState() => _ChipTabBarState();
}

class _ChipTabBarState extends State<ChipTabBar> {
  late int _selectedIndex;

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialIndex;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: widget.padding ?? const EdgeInsets.all(AppDimens.spacingM),
      decoration: BoxDecoration(
        color: widget.backgroundColor ?? Theme.of(context).colorScheme.surface,
      ),
      child: ResponsiveBuilder(
        mobile: _buildMobileChips(context),
        desktop: _buildDesktopChips(context),
      ),
    );
  }

  Widget _buildMobileChips(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(children: _buildChips(context, compact: true)),
    );
  }

  Widget _buildDesktopChips(BuildContext context) {
    return Wrap(
      spacing: AppDimens.spacingS,
      children: _buildChips(context, compact: false),
    );
  }

  List<Widget> _buildChips(BuildContext context, {required bool compact}) {
    return widget.tabs.asMap().entries.map((entry) {
      final index = entry.key;
      final tab = entry.value;
      final isSelected = index == _selectedIndex;

      return Padding(
        padding: EdgeInsets.only(right: compact ? AppDimens.spacingS : 0),
        child: FilterChip(
          label: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (tab.icon != null) ...[
                Icon(
                  tab.icon,
                  size: compact ? 16 : 18,
                  color: isSelected ? Colors.white : AppColors.neutral600,
                ),
                SizedBox(width: compact ? 4 : 6),
              ],
              Text(
                tab.text,
                style: TextStyle(
                  fontSize: compact ? 14 : 16,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                  color: isSelected ? Colors.white : AppColors.neutral600,
                ),
              ),
              if (tab.badge != null) ...[
                SizedBox(width: compact ? 4 : 6),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? Colors.white.withOpacity(0.2)
                        : AppColors.error,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    tab.badge!,
                    style: TextStyle(
                      color: isSelected ? Colors.white : Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ],
          ),
          selected: isSelected,
          onSelected: tab.enabled
              ? (selected) {
                  if (selected && index != _selectedIndex) {
                    setState(() {
                      _selectedIndex = index;
                    });
                    widget.onTabSelected?.call(index);
                    tab.onTap?.call();
                  }
                }
              : null,
          backgroundColor:
              widget.unselectedChipColor ??
              Theme.of(context).colorScheme.background,
          selectedColor: widget.selectedChipColor ?? AppColors.primary,
          checkmarkColor: Colors.transparent,
          side: BorderSide(
            color: isSelected ? AppColors.primary : AppColors.neutral300,
            width: 1,
          ),
          elevation: isSelected ? 2 : 0,
          pressElevation: 4,
        ),
      );
    }).toList();
  }
}

/// Provider per gestire lo stato dei tab
final tabStateProvider = StateProvider.family<int, String>((ref, tabId) => 0);

/// Tab bar che si sincronizza con Riverpod
class ProviderTabBar extends ConsumerWidget {
  final String tabId;
  final List<AppTab> tabs;
  final TabSelectedCallback? onTabSelected;
  final bool isScrollable;
  final bool showIndicator;

  const ProviderTabBar({
    super.key,
    required this.tabId,
    required this.tabs,
    this.onTabSelected,
    this.isScrollable = false,
    this.showIndicator = true,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentIndex = ref.watch(tabStateProvider(tabId));

    return AppTabBar(
      tabs: tabs,
      initialIndex: currentIndex,
      isScrollable: isScrollable,
      showIndicator: showIndicator,
      onTabSelected: (index) {
        ref.read(tabStateProvider(tabId).notifier).state = index;
        onTabSelected?.call(index);
      },
    );
  }
}

/// Widget completo con tab bar e content
class AppTabView extends StatefulWidget {
  final List<AppTab> tabs;
  final List<Widget> children;
  final int initialIndex;
  final TabSelectedCallback? onTabSelected;
  final bool isScrollable;
  final Duration animationDuration;
  final Curve animationCurve;

  const AppTabView({
    super.key,
    required this.tabs,
    required this.children,
    this.initialIndex = 0,
    this.onTabSelected,
    this.isScrollable = false,
    this.animationDuration = const Duration(milliseconds: 300),
    this.animationCurve = Curves.easeInOut,
  });

  @override
  State<AppTabView> createState() => _AppTabViewState();
}

class _AppTabViewState extends State<AppTabView> with TickerProviderStateMixin {
  late TabController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TabController(
      length: widget.tabs.length,
      vsync: this,
      initialIndex: widget.initialIndex,
      animationDuration: widget.animationDuration,
    );

    _controller.addListener(() {
      widget.onTabSelected?.call(_controller.index);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        AppTabBar(
          tabs: widget.tabs,
          controller: _controller,
          isScrollable: widget.isScrollable,
        ),
        Expanded(
          child: TabBarView(controller: _controller, children: widget.children),
        ),
      ],
    );
  }
}

/// Estensione per semplificare la creazione di tab
extension AppTabExtensions on List<String> {
  /// Converte una lista di stringhe in AppTab
  List<AppTab> toAppTabs({List<IconData>? icons, List<String>? badges}) {
    return asMap().entries.map((entry) {
      final index = entry.key;
      final text = entry.value;

      return AppTab(
        text: text,
        icon: icons != null && index < icons.length ? icons[index] : null,
        badge: badges != null && index < badges.length ? badges[index] : null,
      );
    }).toList();
  }
}

/// Utility per tab comuni nell'app DM Assistant
class DMTabs {
  /// Tab per campaign details
  static List<AppTab> get campaignTabs => [
    const AppTab(text: 'Overview', icon: Icons.dashboard),
    const AppTab(text: 'Characters', icon: Icons.people),
    const AppTab(text: 'Sessions', icon: Icons.event),
    const AppTab(text: 'Notes', icon: Icons.note),
    const AppTab(text: 'Maps', icon: Icons.map),
  ];

  /// Tab per character details
  static List<AppTab> get characterTabs => [
    const AppTab(text: 'Stats', icon: Icons.bar_chart),
    const AppTab(text: 'Inventory', icon: Icons.inventory),
    const AppTab(text: 'Spells', icon: Icons.auto_fix_high),
    const AppTab(text: 'Background', icon: Icons.person),
    const AppTab(text: 'Notes', icon: Icons.note),
  ];

  /// Tab per session management
  static List<AppTab> get sessionTabs => [
    const AppTab(text: 'Planning', icon: Icons.schedule),
    const AppTab(text: 'Combat', icon: Icons.security),
    const AppTab(text: 'Story', icon: Icons.menu_book),
    const AppTab(text: 'NPCs', icon: Icons.people_outline),
  ];
}
