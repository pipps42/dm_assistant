// lib/shared/components/navigation/tab_navigation.dart
import 'package:flutter/material.dart';
import 'package:dm_assistant/core/constants/dimens.dart';

enum TabStyle { standard, pills, underline, floating }

class BaseTabBar extends StatelessWidget {
  final List<TabItem> tabs;
  final int selectedIndex;
  final ValueChanged<int> onTabChanged;
  final TabStyle style;
  final EdgeInsets padding;
  final bool isScrollable;
  final Color? backgroundColor;
  final Color? selectedColor;
  final Color? unselectedColor;

  const BaseTabBar({
    super.key,
    required this.tabs,
    required this.selectedIndex,
    required this.onTabChanged,
    this.style = TabStyle.standard,
    this.padding = const EdgeInsets.symmetric(horizontal: AppDimens.spacingM),
    this.isScrollable = false,
    this.backgroundColor,
    this.selectedColor,
    this.unselectedColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    switch (style) {
      case TabStyle.pills:
        return _buildPillTabs(context, theme);
      case TabStyle.underline:
        return _buildUnderlineTabs(context, theme);
      case TabStyle.floating:
        return _buildFloatingTabs(context, theme);
      case TabStyle.standard:
        return _buildStandardTabs(context, theme);
    }
  }

  Widget _buildStandardTabs(BuildContext context, ThemeData theme) {
    return Container(
      decoration: BoxDecoration(
        color: backgroundColor ?? theme.colorScheme.surface,
        border: Border(
          bottom: BorderSide(color: theme.dividerColor.withOpacity(0.2)),
        ),
      ),
      child: TabBar(
        tabs: tabs
            .map(
              (tab) => Tab(
                icon: tab.icon != null ? Icon(tab.icon) : null,
                text: tab.label,
              ),
            )
            .toList(),
        isScrollable: isScrollable,
        labelColor: selectedColor ?? theme.colorScheme.primary,
        unselectedLabelColor:
            unselectedColor ?? theme.colorScheme.onSurface.withOpacity(0.6),
        indicatorColor: selectedColor ?? theme.colorScheme.primary,
        padding: padding,
      ),
    );
  }

  Widget _buildPillTabs(BuildContext context, ThemeData theme) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: backgroundColor ?? theme.colorScheme.surface,
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: tabs.asMap().entries.map((entry) {
            final index = entry.key;
            final tab = entry.value;
            final isSelected = index == selectedIndex;

            return Padding(
              padding: EdgeInsets.only(
                right: index < tabs.length - 1 ? AppDimens.spacingS : 0,
              ),
              child: _PillTab(
                tab: tab,
                isSelected: isSelected,
                onTap: () => onTabChanged(index),
                selectedColor: selectedColor ?? theme.colorScheme.primary,
                unselectedColor:
                    unselectedColor ??
                    theme.colorScheme.onSurface.withOpacity(0.6),
                theme: theme,
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildUnderlineTabs(BuildContext context, ThemeData theme) {
    return Container(
      decoration: BoxDecoration(
        color: backgroundColor ?? theme.colorScheme.surface,
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: tabs.asMap().entries.map((entry) {
            final index = entry.key;
            final tab = entry.value;
            final isSelected = index == selectedIndex;

            return _UnderlineTab(
              tab: tab,
              isSelected: isSelected,
              onTap: () => onTabChanged(index),
              selectedColor: selectedColor ?? theme.colorScheme.primary,
              unselectedColor:
                  unselectedColor ??
                  theme.colorScheme.onSurface.withOpacity(0.6),
              theme: theme,
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildFloatingTabs(BuildContext context, ThemeData theme) {
    return Container(
      padding: padding,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: tabs.asMap().entries.map((entry) {
            final index = entry.key;
            final tab = entry.value;
            final isSelected = index == selectedIndex;

            return Padding(
              padding: EdgeInsets.only(
                right: index < tabs.length - 1 ? AppDimens.spacingS : 0,
              ),
              child: _FloatingTab(
                tab: tab,
                isSelected: isSelected,
                onTap: () => onTabChanged(index),
                selectedColor: selectedColor ?? theme.colorScheme.primary,
                unselectedColor:
                    unselectedColor ??
                    theme.colorScheme.onSurface.withOpacity(0.6),
                theme: theme,
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}

class BaseTabView extends StatefulWidget {
  final List<TabItem> tabs;
  final List<Widget> children;
  final int initialIndex;
  final ValueChanged<int>? onTabChanged;
  final TabStyle style;
  final EdgeInsets tabPadding;
  final bool isScrollable;
  final Color? backgroundColor;
  final Color? selectedColor;
  final Color? unselectedColor;

  const BaseTabView({
    super.key,
    required this.tabs,
    required this.children,
    this.initialIndex = 0,
    this.onTabChanged,
    this.style = TabStyle.standard,
    this.tabPadding = const EdgeInsets.symmetric(
      horizontal: AppDimens.spacingM,
    ),
    this.isScrollable = false,
    this.backgroundColor,
    this.selectedColor,
    this.unselectedColor,
  }) : assert(
         tabs.length == children.length,
         'Tabs and children must have the same length',
       );

  @override
  State<BaseTabView> createState() => _BaseTabViewState();
}

class _BaseTabViewState extends State<BaseTabView> {
  late int _selectedIndex;

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialIndex;
  }

  void _onTabChanged(int index) {
    setState(() {
      _selectedIndex = index;
    });
    widget.onTabChanged?.call(index);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        BaseTabBar(
          tabs: widget.tabs,
          selectedIndex: _selectedIndex,
          onTabChanged: _onTabChanged,
          style: widget.style,
          padding: widget.tabPadding,
          isScrollable: widget.isScrollable,
          backgroundColor: widget.backgroundColor,
          selectedColor: widget.selectedColor,
          unselectedColor: widget.unselectedColor,
        ),
        Expanded(
          child: IndexedStack(index: _selectedIndex, children: widget.children),
        ),
      ],
    );
  }
}

// Tab item data class
class TabItem {
  final String label;
  final IconData? icon;
  final Widget? badge;
  final bool enabled;

  const TabItem({
    required this.label,
    this.icon,
    this.badge,
    this.enabled = true,
  });
}

// Custom tab widgets for different styles
class _PillTab extends StatelessWidget {
  final TabItem tab;
  final bool isSelected;
  final VoidCallback onTap;
  final Color selectedColor;
  final Color unselectedColor;
  final ThemeData theme;

  const _PillTab({
    required this.tab,
    required this.isSelected,
    required this.onTap,
    required this.selectedColor,
    required this.unselectedColor,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: tab.enabled ? onTap : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimens.spacingM,
          vertical: AppDimens.spacingS,
        ),
        decoration: BoxDecoration(
          color: isSelected
              ? selectedColor.withOpacity(0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(AppDimens.radiusXL),
          border: Border.all(
            color: isSelected
                ? selectedColor
                : theme.dividerColor.withOpacity(0.3),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (tab.icon != null) ...[
              Icon(
                tab.icon,
                size: 16,
                color: isSelected ? selectedColor : unselectedColor,
              ),
              const SizedBox(width: AppDimens.spacingXS),
            ],
            Text(
              tab.label,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: isSelected ? selectedColor : unselectedColor,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
            if (tab.badge != null) ...[
              const SizedBox(width: AppDimens.spacingXS),
              tab.badge!,
            ],
          ],
        ),
      ),
    );
  }
}

class _UnderlineTab extends StatelessWidget {
  final TabItem tab;
  final bool isSelected;
  final VoidCallback onTap;
  final Color selectedColor;
  final Color unselectedColor;
  final ThemeData theme;

  const _UnderlineTab({
    required this.tab,
    required this.isSelected,
    required this.onTap,
    required this.selectedColor,
    required this.unselectedColor,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: tab.enabled ? onTap : null,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimens.spacingL,
          vertical: AppDimens.spacingM,
        ),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: isSelected ? selectedColor : Colors.transparent,
              width: 2,
            ),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (tab.icon != null) ...[
              Icon(
                tab.icon,
                size: 20,
                color: isSelected ? selectedColor : unselectedColor,
              ),
              const SizedBox(width: AppDimens.spacingS),
            ],
            Text(
              tab.label,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: isSelected ? selectedColor : unselectedColor,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
            if (tab.badge != null) ...[
              const SizedBox(width: AppDimens.spacingS),
              tab.badge!,
            ],
          ],
        ),
      ),
    );
  }
}

class _FloatingTab extends StatelessWidget {
  final TabItem tab;
  final bool isSelected;
  final VoidCallback onTap;
  final Color selectedColor;
  final Color unselectedColor;
  final ThemeData theme;

  const _FloatingTab({
    required this.tab,
    required this.isSelected,
    required this.onTap,
    required this.selectedColor,
    required this.unselectedColor,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: tab.enabled ? onTap : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimens.spacingM,
          vertical: AppDimens.spacingS,
        ),
        decoration: BoxDecoration(
          color: isSelected ? selectedColor : theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(AppDimens.radiusM),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: selectedColor.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (tab.icon != null) ...[
              Icon(
                tab.icon,
                size: 16,
                color: isSelected
                    ? theme.colorScheme.onPrimary
                    : unselectedColor,
              ),
              const SizedBox(width: AppDimens.spacingXS),
            ],
            Text(
              tab.label,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: isSelected
                    ? theme.colorScheme.onPrimary
                    : unselectedColor,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
            if (tab.badge != null) ...[
              const SizedBox(width: AppDimens.spacingXS),
              tab.badge!,
            ],
          ],
        ),
      ),
    );
  }
}

// Specialized D&D tab views
class CampaignTabView extends BaseTabView {
  CampaignTabView({
    super.key,
    required List<Widget> children,
    super.onTabChanged,
    super.initialIndex = 0,
    super.style = TabStyle.underline,
  }) : super(
         tabs: const [
           TabItem(label: 'Overview', icon: Icons.dashboard),
           TabItem(label: 'Sessions', icon: Icons.event),
           TabItem(label: 'Characters', icon: Icons.people),
           TabItem(label: 'Quests', icon: Icons.auto_stories),
           TabItem(label: 'Maps', icon: Icons.map),
           TabItem(label: 'Notes', icon: Icons.note),
         ],
         children: children,
       );
}

class CharacterTabView extends BaseTabView {
  CharacterTabView({
    super.key,
    required List<Widget> children,
    super.onTabChanged,
    super.initialIndex = 0,
    super.style = TabStyle.pills,
  }) : super(
         tabs: const [
           TabItem(label: 'Stats', icon: Icons.bar_chart),
           TabItem(label: 'Equipment', icon: Icons.inventory),
           TabItem(label: 'Spells', icon: Icons.auto_fix_high),
           TabItem(label: 'Features', icon: Icons.star),
           TabItem(label: 'Background', icon: Icons.history_edu),
         ],
         children: children,
       );
}
