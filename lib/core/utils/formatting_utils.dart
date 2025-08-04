// lib/core/utils/formatting_utils.dart
import 'package:intl/intl.dart';

/// Utility class for common formatting operations
class FormattingUtils {
  FormattingUtils._(); // Private constructor to prevent instantiation

  /// Formats enum names by capitalizing first letter and replacing underscores with spaces
  /// 
  /// Example: 'dark_elf' -> 'Dark elf'
  static String formatEnumName(String enumName) {
    if (enumName.isEmpty) return enumName;
    
    return enumName
        .split('_')
        .map((word) => word.isEmpty 
            ? word 
            : word[0].toUpperCase() + word.substring(1).toLowerCase())
        .join(' ');
  }

  /// Formats a date using the provided format
  /// 
  /// If no format is provided, uses a default format
  static String formatDate(DateTime date, {DateFormat? format}) {
    final formatter = format ?? DateFormat.yMMMd();
    return formatter.format(date);
  }

  /// Formats a date as a relative time string (e.g., "2 days ago", "Yesterday")
  static String formatRelativeDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      if (difference.inHours == 0) {
        if (difference.inMinutes == 0) {
          return 'Just now';
        }
        return '${difference.inMinutes} minute${difference.inMinutes == 1 ? '' : 's'} ago';
      }
      return '${difference.inHours} hour${difference.inHours == 1 ? '' : 's'} ago';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} day${difference.inDays == 1 ? '' : 's'} ago';
    } else if (difference.inDays < 30) {
      final weeks = (difference.inDays / 7).floor();
      return '${weeks} week${weeks == 1 ? '' : 's'} ago';
    } else if (difference.inDays < 365) {
      final months = (difference.inDays / 30).floor();
      return '${months} month${months == 1 ? '' : 's'} ago';
    } else {
      final years = (difference.inDays / 365).floor();
      return '${years} year${years == 1 ? '' : 's'} ago';
    }
  }

  /// Formats a DateTime as a short date string (e.g., "Mar 15")
  static String formatShortDate(DateTime date) {
    return DateFormat.MMMd().format(date);
  }

  /// Formats a DateTime as a long date string (e.g., "March 15, 2024")
  static String formatLongDate(DateTime date) {
    return DateFormat.yMMMMd().format(date);
  }

  /// Formats a DateTime as a time string (e.g., "2:30 PM")
  static String formatTime(DateTime date) {
    return DateFormat.jm().format(date);
  }

  /// Formats a DateTime as date and time (e.g., "Mar 15, 2:30 PM")
  static String formatDateTime(DateTime date) {
    return DateFormat.MMMd().add_jm().format(date);
  }

  /// Capitalizes the first letter of a string
  static String capitalize(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1).toLowerCase();
  }

  /// Converts a string to title case (capitalizes first letter of each word)
  static String toTitleCase(String text) {
    if (text.isEmpty) return text;
    return text.split(' ')
        .map((word) => word.isEmpty ? word : capitalize(word))
        .join(' ');
  }
}