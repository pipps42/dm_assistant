// lib/core/utils/date_utils.dart
import 'package:intl/intl.dart';

/// Utility class per operazioni e formattazioni di date
/// Estende le funzionalità base con utility specifiche per DM Assistant
class AppDateUtils {
  /// Formatters predefiniti
  static final DateFormat _shortDate = DateFormat('dd/MM/yy');
  static final DateFormat _mediumDate = DateFormat('MMM d, y');
  static final DateFormat _longDate = DateFormat('EEEE, MMMM d, y');
  static final DateFormat _shortDateTime = DateFormat('dd/MM/yy HH:mm');
  static final DateFormat _mediumDateTime = DateFormat('MMM d, y HH:mm');
  static final DateFormat _timeOnly = DateFormat('HH:mm');
  static final DateFormat _dayMonth = DateFormat('MMM d');
  static final DateFormat _monthYear = DateFormat('MMM y');
  static final DateFormat _isoDate = DateFormat('yyyy-MM-dd');
  static final DateFormat _isoDateTime = DateFormat(
    "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'",
  );

  /// FORMATTAZIONE DATE

  /// Formatta data in formato corto (15/11/24)
  static String formatShort(DateTime? date) {
    if (date == null) return '--';
    return _shortDate.format(date);
  }

  /// Formatta data in formato medio (Nov 15, 2024)
  static String formatMedium(DateTime? date) {
    if (date == null) return '--';
    return _mediumDate.format(date);
  }

  /// Formatta data in formato lungo (Friday, November 15, 2024)
  static String formatLong(DateTime? date) {
    if (date == null) return '--';
    return _longDate.format(date);
  }

  /// Formatta data e ora in formato corto (15/11/24 14:30)
  static String formatShortDateTime(DateTime? date) {
    if (date == null) return '--';
    return _shortDateTime.format(date);
  }

  /// Formatta data e ora in formato medio (Nov 15, 2024 14:30)
  static String formatMediumDateTime(DateTime? date) {
    if (date == null) return '--';
    return _mediumDateTime.format(date);
  }

  /// Formatta solo l'orario (14:30)
  static String formatTime(DateTime? date) {
    if (date == null) return '--';
    return _timeOnly.format(date);
  }

  /// Formatta giorno e mese (Nov 15)
  static String formatDayMonth(DateTime? date) {
    if (date == null) return '--';
    return _dayMonth.format(date);
  }

  /// Formatta mese e anno (Nov 2024)
  static String formatMonthYear(DateTime? date) {
    if (date == null) return '--';
    return _monthYear.format(date);
  }

  /// Formatta in formato ISO per database (2024-11-15)
  static String formatISO(DateTime? date) {
    if (date == null) return '';
    return _isoDate.format(date);
  }

  /// Formatta in formato ISO completo per API (2024-11-15T14:30:00.000Z)
  static String formatISODateTime(DateTime? date) {
    if (date == null) return '';
    return _isoDateTime.format(date.toUtc());
  }

  /// PARSING DATE

  /// Parsa una stringa di data in formato ISO
  static DateTime? parseISO(String? dateString) {
    if (dateString == null || dateString.isEmpty) return null;
    try {
      return DateTime.parse(dateString);
    } catch (e) {
      return null;
    }
  }

  /// Parsa una stringa di data in formato personalizzato
  static DateTime? parseCustom(String? dateString, String pattern) {
    if (dateString == null || dateString.isEmpty) return null;
    try {
      final formatter = DateFormat(pattern);
      return formatter.parse(dateString);
    } catch (e) {
      return null;
    }
  }

  /// TEMPO RELATIVO

  /// Formatta il tempo relativo (es. "2 giorni fa", "tra 3 ore")
  static String formatRelative(DateTime? date) {
    if (date == null) return '--';

    final now = DateTime.now();
    final difference = now.difference(date);

    // Passato
    if (difference.isNegative) {
      return _formatFuture(date, now);
    } else {
      return _formatPast(difference);
    }
  }

  static String _formatPast(Duration difference) {
    if (difference.inDays > 365) {
      final years = (difference.inDays / 365).floor();
      return '${years} year${years > 1 ? 's' : ''} ago';
    } else if (difference.inDays > 30) {
      final months = (difference.inDays / 30).floor();
      return '${months} month${months > 1 ? 's' : ''} ago';
    } else if (difference.inDays > 7) {
      final weeks = (difference.inDays / 7).floor();
      return '${weeks} week${weeks > 1 ? 's' : ''} ago';
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

  static String _formatFuture(DateTime futureDate, DateTime now) {
    final difference = futureDate.difference(now);

    if (difference.inDays > 365) {
      final years = (difference.inDays / 365).floor();
      return 'in ${years} year${years > 1 ? 's' : ''}';
    } else if (difference.inDays > 30) {
      final months = (difference.inDays / 30).floor();
      return 'in ${months} month${months > 1 ? 's' : ''}';
    } else if (difference.inDays > 7) {
      final weeks = (difference.inDays / 7).floor();
      return 'in ${weeks} week${weeks > 1 ? 's' : ''}';
    } else if (difference.inDays > 0) {
      return 'in ${difference.inDays} day${difference.inDays > 1 ? 's' : ''}';
    } else if (difference.inHours > 0) {
      return 'in ${difference.inHours} hour${difference.inHours > 1 ? 's' : ''}';
    } else if (difference.inMinutes > 0) {
      return 'in ${difference.inMinutes} minute${difference.inMinutes > 1 ? 's' : ''}';
    } else {
      return 'now';
    }
  }

  /// Formatta tempo relativo smart (oggi, ieri, domani, oppure data)
  static String formatSmart(DateTime? date) {
    if (date == null) return '--';

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final dateOnly = DateTime(date.year, date.month, date.day);

    final difference = dateOnly.difference(today).inDays;

    if (difference == 0) {
      return 'Today ${formatTime(date)}';
    } else if (difference == -1) {
      return 'Yesterday ${formatTime(date)}';
    } else if (difference == 1) {
      return 'Tomorrow ${formatTime(date)}';
    } else if (difference > 1 && difference <= 7) {
      return 'in ${difference} days';
    } else if (difference < -1 && difference >= -7) {
      return '${-difference} days ago';
    } else {
      return formatMedium(date);
    }
  }

  /// OPERAZIONI SU DATE

  /// Verifica se una data è oggi
  static bool isToday(DateTime? date) {
    if (date == null) return false;
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }

  /// Verifica se una data è ieri
  static bool isYesterday(DateTime? date) {
    if (date == null) return false;
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    return date.year == yesterday.year &&
        date.month == yesterday.month &&
        date.day == yesterday.day;
  }

  /// Verifica se una data è domani
  static bool isTomorrow(DateTime? date) {
    if (date == null) return false;
    final tomorrow = DateTime.now().add(const Duration(days: 1));
    return date.year == tomorrow.year &&
        date.month == tomorrow.month &&
        date.day == tomorrow.day;
  }

  /// Verifica se una data è in questa settimana
  static bool isThisWeek(DateTime? date) {
    if (date == null) return false;
    final now = DateTime.now();
    final weekStart = now.subtract(Duration(days: now.weekday - 1));
    final weekEnd = weekStart.add(const Duration(days: 6));
    return date.isAfter(weekStart.subtract(const Duration(days: 1))) &&
        date.isBefore(weekEnd.add(const Duration(days: 1)));
  }

  /// Verifica se una data è in questo mese
  static bool isThisMonth(DateTime? date) {
    if (date == null) return false;
    final now = DateTime.now();
    return date.year == now.year && date.month == now.month;
  }

  /// Verifica se una data è in questo anno
  static bool isThisYear(DateTime? date) {
    if (date == null) return false;
    final now = DateTime.now();
    return date.year == now.year;
  }

  /// Ottiene l'inizio del giorno
  static DateTime startOfDay(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  /// Ottiene la fine del giorno
  static DateTime endOfDay(DateTime date) {
    return DateTime(date.year, date.month, date.day, 23, 59, 59, 999);
  }

  /// Ottiene l'inizio della settimana (lunedì)
  static DateTime startOfWeek(DateTime date) {
    final weekday = date.weekday;
    return startOfDay(date.subtract(Duration(days: weekday - 1)));
  }

  /// Ottiene la fine della settimana (domenica)
  static DateTime endOfWeek(DateTime date) {
    final weekday = date.weekday;
    return endOfDay(date.add(Duration(days: 7 - weekday)));
  }

  /// Ottiene l'inizio del mese
  static DateTime startOfMonth(DateTime date) {
    return DateTime(date.year, date.month, 1);
  }

  /// Ottiene la fine del mese
  static DateTime endOfMonth(DateTime date) {
    return DateTime(date.year, date.month + 1, 0, 23, 59, 59, 999);
  }

  /// Ottiene l'inizio dell'anno
  static DateTime startOfYear(DateTime date) {
    return DateTime(date.year, 1, 1);
  }

  /// Ottiene la fine dell'anno
  static DateTime endOfYear(DateTime date) {
    return DateTime(date.year, 12, 31, 23, 59, 59, 999);
  }

  /// Aggiunge giorni lavorativi (esclude weekend)
  static DateTime addBusinessDays(DateTime date, int days) {
    DateTime result = date;
    int addedDays = 0;

    while (addedDays < days) {
      result = result.add(const Duration(days: 1));
      if (result.weekday != DateTime.saturday &&
          result.weekday != DateTime.sunday) {
        addedDays++;
      }
    }

    return result;
  }

  /// Conta i giorni lavorativi tra due date
  static int businessDaysBetween(DateTime start, DateTime end) {
    if (start.isAfter(end)) return 0;

    int businessDays = 0;
    DateTime current = start;

    while (current.isBefore(end) || current.isAtSameMomentAs(end)) {
      if (current.weekday != DateTime.saturday &&
          current.weekday != DateTime.sunday) {
        businessDays++;
      }
      current = current.add(const Duration(days: 1));
    }

    return businessDays;
  }

  /// UTILITY GAMING SPECIFIC

  /// Calcola l'età di un personaggio da una data di nascita
  static int calculateAge(DateTime birthDate, [DateTime? currentDate]) {
    currentDate ??= DateTime.now();
    int age = currentDate.year - birthDate.year;

    if (currentDate.month < birthDate.month ||
        (currentDate.month == birthDate.month &&
            currentDate.day < birthDate.day)) {
      age--;
    }

    return age;
  }

  /// Formatta una durata di sessione di gioco
  static String formatSessionDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);

    if (hours > 0) {
      if (minutes > 0) {
        return '${hours}h ${minutes}m';
      } else {
        return '${hours}h';
      }
    } else {
      return '${minutes}m';
    }
  }

  /// Calcola il prossimo giorno di gioco (es. ogni mercoledì)
  static DateTime nextGameDay(int weekday) {
    final now = DateTime.now();
    int daysUntilNext = weekday - now.weekday;

    if (daysUntilNext <= 0) {
      daysUntilNext += 7; // Prossima settimana
    }

    return now.add(Duration(days: daysUntilNext));
  }

  /// Genera una lista di date per le prossime sessioni
  static List<DateTime> generateSessionDates(
    DateTime startDate,
    int weekday,
    int count,
  ) {
    final List<DateTime> dates = [];
    DateTime current = startDate;

    // Trova il primo giorno della settimana specificato
    while (current.weekday != weekday) {
      current = current.add(const Duration(days: 1));
    }

    // Genera le date
    for (int i = 0; i < count; i++) {
      dates.add(current);
      current = current.add(const Duration(days: 7)); // Settimana successiva
    }

    return dates;
  }

  /// RANGE DI DATE

  /// Verifica se una data è in un range
  static bool isInRange(DateTime date, DateTime start, DateTime end) {
    return date.isAfter(start.subtract(const Duration(milliseconds: 1))) &&
        date.isBefore(end.add(const Duration(milliseconds: 1)));
  }

  /// Ottiene tutti i giorni in un range
  static List<DateTime> getDaysInRange(DateTime start, DateTime end) {
    final List<DateTime> days = [];
    DateTime current = startOfDay(start);
    final endDay = startOfDay(end);

    while (current.isBefore(endDay) || current.isAtSameMomentAs(endDay)) {
      days.add(current);
      current = current.add(const Duration(days: 1));
    }

    return days;
  }

  /// Ottiene tutte le settimane in un range
  static List<DateTime> getWeeksInRange(DateTime start, DateTime end) {
    final List<DateTime> weeks = [];
    DateTime current = startOfWeek(start);
    final endWeek = startOfWeek(end);

    while (current.isBefore(endWeek) || current.isAtSameMomentAs(endWeek)) {
      weeks.add(current);
      current = current.add(const Duration(days: 7));
    }

    return weeks;
  }

  /// Ottiene tutti i mesi in un range
  static List<DateTime> getMonthsInRange(DateTime start, DateTime end) {
    final List<DateTime> months = [];
    DateTime current = startOfMonth(start);
    final endMonth = startOfMonth(end);

    while (current.isBefore(endMonth) || current.isAtSameMomentAs(endMonth)) {
      months.add(current);
      // Prossimo mese
      if (current.month == 12) {
        current = DateTime(current.year + 1, 1, 1);
      } else {
        current = DateTime(current.year, current.month + 1, 1);
      }
    }

    return months;
  }

  /// VALIDAZIONE

  /// Verifica se una stringa rappresenta una data valida
  static bool isValidDate(String dateString, [String? pattern]) {
    try {
      if (pattern != null) {
        DateFormat(pattern).parseStrict(dateString);
      } else {
        DateTime.parse(dateString);
      }
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Verifica se una data è nel futuro
  static bool isFuture(DateTime date, [DateTime? reference]) {
    reference ??= DateTime.now();
    return date.isAfter(reference);
  }

  /// Verifica se una data è nel passato
  static bool isPast(DateTime date, [DateTime? reference]) {
    reference ??= DateTime.now();
    return date.isBefore(reference);
  }

  /// COSTANTI UTILI

  /// Giorni della settimana
  static const Map<int, String> weekdayNames = {
    1: 'Monday',
    2: 'Tuesday',
    3: 'Wednesday',
    4: 'Thursday',
    5: 'Friday',
    6: 'Saturday',
    7: 'Sunday',
  };

  /// Giorni della settimana abbreviati
  static const Map<int, String> weekdayShortNames = {
    1: 'Mon',
    2: 'Tue',
    3: 'Wed',
    4: 'Thu',
    5: 'Fri',
    6: 'Sat',
    7: 'Sun',
  };

  /// Mesi dell'anno
  static const Map<int, String> monthNames = {
    1: 'January',
    2: 'February',
    3: 'March',
    4: 'April',
    5: 'May',
    6: 'June',
    7: 'July',
    8: 'August',
    9: 'September',
    10: 'October',
    11: 'November',
    12: 'December',
  };

  /// Mesi dell'anno abbreviati
  static const Map<int, String> monthShortNames = {
    1: 'Jan',
    2: 'Feb',
    3: 'Mar',
    4: 'Apr',
    5: 'May',
    6: 'Jun',
    7: 'Jul',
    8: 'Aug',
    9: 'Sep',
    10: 'Oct',
    11: 'Nov',
    12: 'Dec',
  };
}

/// Extensions per DateTime per semplificare l'uso
extension AppDateTimeExtensions on DateTime {
  /// Formatta in formato corto
  String get shortFormat => AppDateUtils.formatShort(this);

  /// Formatta in formato medio
  String get mediumFormat => AppDateUtils.formatMedium(this);

  /// Formatta in formato lungo
  String get longFormat => AppDateUtils.formatLong(this);

  /// Formatta il tempo relativo
  String get relativeFormat => AppDateUtils.formatRelative(this);

  /// Formatta smart
  String get smartFormat => AppDateUtils.formatSmart(this);

  /// Verifica se è oggi
  bool get isToday => AppDateUtils.isToday(this);

  /// Verifica se è ieri
  bool get isYesterday => AppDateUtils.isYesterday(this);

  /// Verifica se è domani
  bool get isTomorrow => AppDateUtils.isTomorrow(this);

  /// Verifica se è in questa settimana
  bool get isThisWeek => AppDateUtils.isThisWeek(this);

  /// Verifica se è in questo mese
  bool get isThisMonth => AppDateUtils.isThisMonth(this);

  /// Verifica se è in questo anno
  bool get isThisYear => AppDateUtils.isThisYear(this);

  /// Ottiene l'inizio del giorno
  DateTime get startOfDay => AppDateUtils.startOfDay(this);

  /// Ottiene la fine del giorno
  DateTime get endOfDay => AppDateUtils.endOfDay(this);

  /// Ottiene l'inizio della settimana
  DateTime get startOfWeek => AppDateUtils.startOfWeek(this);

  /// Ottiene la fine della settimana
  DateTime get endOfWeek => AppDateUtils.endOfWeek(this);

  /// Ottiene l'inizio del mese
  DateTime get startOfMonth => AppDateUtils.startOfMonth(this);

  /// Ottiene la fine del mese
  DateTime get endOfMonth => AppDateUtils.endOfMonth(this);
}
