// lib/core/utils/formatters.dart
import 'package:intl/intl.dart';

/// Utility class per la formattazione di dati comuni nell'app
class AppFormatters {
  // Formatters per date
  static final DateFormat _dayMonthYear = DateFormat('MMM d, y');
  static final DateFormat _dayMonthYearTime = DateFormat('MMM d, y - HH:mm');
  static final DateFormat _shortDate = DateFormat('dd/MM/yy');
  static final DateFormat _longDate = DateFormat('EEEE, MMMM d, y');
  static final DateFormat _timeOnly = DateFormat('HH:mm');
  static final DateFormat _dateTimeISO = DateFormat('yyyy-MM-ddTHH:mm:ss');

  // Formatters per numeri
  static final NumberFormat _decimal = NumberFormat('#,##0.00');
  static final NumberFormat _currency = NumberFormat.currency(symbol: '\$');
  static final NumberFormat _percent = NumberFormat.percentPattern();
  static final NumberFormat _compact = NumberFormat.compact();

  /// FORMATTAZIONE DATE

  /// Formatta una data in formato "Nov 15, 2024"
  static String formatDate(DateTime? date) {
    if (date == null) return '--';
    return _dayMonthYear.format(date);
  }

  /// Formatta una data con orario "Nov 15, 2024 - 14:30"
  static String formatDateTime(DateTime? date) {
    if (date == null) return '--';
    return _dayMonthYearTime.format(date);
  }

  /// Formatta una data in formato breve "15/11/24"
  static String formatShortDate(DateTime? date) {
    if (date == null) return '--';
    return _shortDate.format(date);
  }

  /// Formatta una data in formato lungo "Friday, November 15, 2024"
  static String formatLongDate(DateTime? date) {
    if (date == null) return '--';
    return _longDate.format(date);
  }

  /// Formatta solo l'orario "14:30"
  static String formatTime(DateTime? date) {
    if (date == null) return '--';
    return _timeOnly.format(date);
  }

  /// Formatta per database (ISO format)
  static String formatDateTimeISO(DateTime? date) {
    if (date == null) return '';
    return _dateTimeISO.format(date);
  }

  /// Formatta una durata in formato leggibile
  static String formatDuration(Duration? duration) {
    if (duration == null) return '--';

    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);

    if (hours > 0) {
      return '${hours}h ${minutes}m';
    } else {
      return '${minutes}m';
    }
  }

  /// Formatta il tempo relativo (es. "2 giorni fa")
  static String formatRelativeTime(DateTime? date) {
    if (date == null) return '--';

    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 365) {
      final years = (difference.inDays / 365).floor();
      return '${years} year${years > 1 ? 's' : ''} ago';
    } else if (difference.inDays > 30) {
      final months = (difference.inDays / 30).floor();
      return '${months} month${months > 1 ? 's' : ''} ago';
    } else if (difference.inDays > 0) {
      return '${difference.inDays} day${difference.inDays > 1 ? 's' : ''} ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hour${difference.inHours > 1 ? 's' : ''} ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minute${difference.inMinutes > 1 ? 's' : ''} ago';
    } else {
      return 'Just now';
    }
  }

  /// FORMATTAZIONE NUMERI

  /// Formatta un numero decimale con separatori delle migliaia
  static String formatDecimal(double? number) {
    if (number == null) return '--';
    return _decimal.format(number);
  }

  /// Formatta una valuta
  static String formatCurrency(double? amount, {String symbol = '\$'}) {
    if (amount == null) return '--';
    final formatter = NumberFormat.currency(symbol: symbol);
    return formatter.format(amount);
  }

  /// Formatta una percentuale
  static String formatPercent(double? value) {
    if (value == null) return '--';
    return _percent.format(value);
  }

  /// Formatta un numero in formato compatto (es. 1.2K, 1.5M)
  static String formatCompactNumber(num? number) {
    if (number == null) return '--';
    return _compact.format(number);
  }

  /// Formatta un numero intero con separatori delle migliaia
  static String formatInteger(int? number) {
    if (number == null) return '--';
    return NumberFormat('#,###').format(number);
  }

  /// FORMATTAZIONE TESTO

  /// Capitalizza la prima lettera di una stringa
  static String capitalize(String? text) {
    if (text == null || text.isEmpty) return '';
    return text[0].toUpperCase() + text.substring(1).toLowerCase();
  }

  /// Converte in Title Case
  static String toTitleCase(String? text) {
    if (text == null || text.isEmpty) return '';
    return text
        .split(' ')
        .map((word) => word.isEmpty ? '' : capitalize(word))
        .join(' ');
  }

  /// Tronca il testo con ellipsis
  static String truncateText(
    String? text,
    int maxLength, {
    String ellipsis = '...',
  }) {
    if (text == null || text.isEmpty) return '';
    if (text.length <= maxLength) return text;
    return '${text.substring(0, maxLength)}$ellipsis';
  }

  /// Rimuove spazi multipli e trim
  static String cleanWhitespace(String? text) {
    if (text == null) return '';
    return text.trim().replaceAll(RegExp(r'\s+'), ' ');
  }

  /// FORMATTAZIONE GAMING SPECIFICA

  /// Formatta livello del personaggio
  static String formatLevel(int? level) {
    if (level == null) return '--';
    return 'Level $level';
  }

  /// Formatta punti esperienza
  static String formatExperience(int? xp) {
    if (xp == null) return '--';
    return '${formatInteger(xp)} XP';
  }

  /// Formatta punti vita
  static String formatHealthPoints(int? current, int? max) {
    if (current == null || max == null) return '--';
    return '$current / $max HP';
  }

  /// Formatta punti mana/incantesimi
  static String formatManaPoints(int? current, int? max) {
    if (current == null || max == null) return '--';
    return '$current / $max MP';
  }

  /// Formatta modificatori di abilità (es. +3, -1)
  static String formatAbilityModifier(int? modifier) {
    if (modifier == null) return '--';
    if (modifier >= 0) {
      return '+$modifier';
    } else {
      return '$modifier';
    }
  }

  /// Formatta classi armatura
  static String formatArmorClass(int? ac) {
    if (ac == null) return '--';
    return 'AC $ac';
  }

  /// Formatta dadi (es. 1d6, 2d8+3)
  static String formatDice(int? count, int? sides, {int? modifier}) {
    if (count == null || sides == null) return '--';

    String result = '${count}d$sides';
    if (modifier != null && modifier != 0) {
      result += formatAbilityModifier(modifier);
    }
    return result;
  }

  /// FORMATTAZIONE SIZE/FILE

  /// Formatta dimensioni file in byte/KB/MB
  static String formatFileSize(int? bytes) {
    if (bytes == null) return '--';

    if (bytes < 1024) {
      return '$bytes B';
    } else if (bytes < 1024 * 1024) {
      return '${(bytes / 1024).toStringAsFixed(1)} KB';
    } else if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    } else {
      return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
    }
  }

  /// FORMATTAZIONE SPECIALE

  /// Formatta un nome utente/personaggio per display
  static String formatDisplayName(String? firstName, String? lastName) {
    final first = firstName?.trim() ?? '';
    final last = lastName?.trim() ?? '';

    if (first.isEmpty && last.isEmpty) return 'Unknown';
    if (first.isEmpty) return last;
    if (last.isEmpty) return first;

    return '$first $last';
  }

  /// Formatta iniziali (es. "John Doe" -> "JD")
  static String formatInitials(String? firstName, String? lastName) {
    final first = firstName?.trim().isNotEmpty == true
        ? firstName![0].toUpperCase()
        : '';
    final last = lastName?.trim().isNotEmpty == true
        ? lastName![0].toUpperCase()
        : '';

    return '$first$last';
  }

  /// Formatta ID con prefisso (es. "CAMP-001")
  static String formatId(String prefix, int? id, {int padLength = 3}) {
    if (id == null) return '--';
    return '$prefix-${id.toString().padLeft(padLength, '0')}';
  }

  /// Formatta un elenco di stringhe (es. ["a", "b", "c"] -> "a, b, and c")
  static String formatList(List<String>? items, {String conjunction = 'and'}) {
    if (items == null || items.isEmpty) return '';

    if (items.length == 1) return items.first;
    if (items.length == 2) return '${items.first} $conjunction ${items.last}';

    final allButLast = items.sublist(0, items.length - 1).join(', ');
    return '$allButLast, $conjunction ${items.last}';
  }
}

/// Extension methods per semplificare l'uso dei formatter
extension DateTimeFormatters on DateTime {
  String get formatted => AppFormatters.formatDate(this);
  String get formattedWithTime => AppFormatters.formatDateTime(this);
  String get shortFormatted => AppFormatters.formatShortDate(this);
  String get longFormatted => AppFormatters.formatLongDate(this);
  String get timeFormatted => AppFormatters.formatTime(this);
  String get relativeFormatted => AppFormatters.formatRelativeTime(this);
}

extension NumberFormatters on num {
  String get formattedDecimal => AppFormatters.formatDecimal(toDouble());
  String get formattedCurrency => AppFormatters.formatCurrency(toDouble());
  String get formattedPercent => AppFormatters.formatPercent(toDouble());
  String get formattedCompact => AppFormatters.formatCompactNumber(this);
}

extension StringFormatters on String {
  String get capitalized => AppFormatters.capitalize(this);
  String get titleCase => AppFormatters.toTitleCase(this);
  String get cleanWhitespace => AppFormatters.cleanWhitespace(this);
  String truncate(int maxLength, {String ellipsis = '...'}) =>
      AppFormatters.truncateText(this, maxLength, ellipsis: ellipsis);
}
