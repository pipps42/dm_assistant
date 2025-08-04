// lib/shared/components/cards/entity_detail_row.dart
import 'package:flutter/material.dart';
import 'package:dm_assistant/core/constants/dimens.dart';

/// A reusable component for displaying detail rows in entity cards
/// Commonly used in grid cards to show metadata like dates, counts, etc.
class EntityDetailRow extends StatelessWidget {
  /// Icon to display on the left
  final IconData icon;
  
  /// Label text to display
  final String label;
  
  /// Value text to display
  final String value;
  
  /// Color for the icon (defaults to theme's secondary color)
  final Color? iconColor;
  
  /// Text style for the label (defaults to bodySmall)
  final TextStyle? labelStyle;
  
  /// Text style for the value (defaults to bodySmall with medium weight)
  final TextStyle? valueStyle;
  
  /// Size of the icon
  final double iconSize;
  
  /// Spacing between icon and text
  final double spacing;

  const EntityDetailRow({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
    this.iconColor,
    this.labelStyle,
    this.valueStyle,
    this.iconSize = AppDimens.iconS,
    this.spacing = AppDimens.spacingXS,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final effectiveIconColor = iconColor ?? theme.colorScheme.secondary;
    final effectiveLabelStyle = labelStyle ?? theme.textTheme.bodySmall;
    final effectiveValueStyle = valueStyle ?? theme.textTheme.bodySmall?.copyWith(
      fontWeight: FontWeight.w500,
    );

    return Row(
      children: [
        Icon(
          icon,
          size: iconSize,
          color: effectiveIconColor,
        ),
        SizedBox(width: spacing),
        Expanded(
          child: Text.rich(
            TextSpan(
              text: '$label: ',
              style: effectiveLabelStyle,
              children: [
                TextSpan(
                  text: value,
                  style: effectiveValueStyle,
                ),
              ],
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

/// Builder function for creating EntityDetailRow widgets
/// Useful for creating lists of detail rows programmatically
class EntityDetailRowBuilder {
  /// Creates a detail row for dates
  static EntityDetailRow date({
    required String label,
    required DateTime date,
    IconData icon = Icons.calendar_today,
    String Function(DateTime)? formatter,
  }) {
    final defaultFormatter = (DateTime d) => '${d.day}/${d.month}/${d.year}';
    final formatDate = formatter ?? defaultFormatter;
    
    return EntityDetailRow(
      icon: icon,
      label: label,
      value: formatDate(date),
    );
  }

  /// Creates a detail row for counts/numbers
  static EntityDetailRow count({
    required String label,
    required int count,
    IconData icon = Icons.numbers,
    String? suffix,
  }) {
    return EntityDetailRow(
      icon: icon,
      label: label,
      value: '$count${suffix ?? ''}',
    );
  }

  /// Creates a detail row for status/enum values
  static EntityDetailRow status({
    required String label,
    required String status,
    IconData icon = Icons.info_outline,
    String Function(String)? formatter,
  }) {
    final formatStatus = formatter ?? (String s) => s;
    
    return EntityDetailRow(
      icon: icon,
      label: label,
      value: formatStatus(status),
    );
  }

  /// Creates a detail row for text values
  static EntityDetailRow text({
    required String label,
    required String value,
    IconData icon = Icons.text_fields,
  }) {
    return EntityDetailRow(
      icon: icon,
      label: label,
      value: value,
    );
  }
}