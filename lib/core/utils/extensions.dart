import 'package:intl/intl.dart';

/// DateTime extensions
extension DateTimeExtensions on DateTime {
  /// Format as date string (yyyy-MM-dd)
  String toDateString() => DateFormat('yyyy-MM-dd').format(this);

  /// Format as ISO string for database
  String toIsoString() => toIso8601String();

  /// Format as readable date (e.g., "Nov 29, 2025")
  String toReadableDate() => DateFormat('MMM d, y').format(this);

  /// Format as readable date and time
  String toReadableDateTime() => DateFormat('MMM d, y • h:mm a').format(this);

  /// Format as time only (e.g., "9:15 AM")
  String toTimeString() => DateFormat('h:mm a').format(this);

  /// Check if same day as another date
  bool isSameDay(DateTime other) =>
      year == other.year && month == other.month && day == other.day;

  /// Check if yesterday
  bool get isYesterday {
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    return isSameDay(yesterday);
  }

  /// Check if today
  bool get isToday => isSameDay(DateTime.now());

  /// Get start of day
  DateTime get startOfDay => DateTime(year, month, day);

  /// Get end of day
  DateTime get endOfDay => DateTime(year, month, day, 23, 59, 59, 999);

  /// Get days since date
  int daysSince(DateTime other) => difference(other).inDays;
}

/// String extensions
extension StringExtensions on String {
  /// Capitalize first letter
  String capitalize() {
    if (isEmpty) return this;
    return '${this[0].toUpperCase()}${substring(1)}';
  }

  /// Convert snake_case to Title Case
  String snakeToTitle() {
    return split('_').map((word) => word.capitalize()).join(' ');
  }

  /// Truncate with ellipsis
  String truncate(int maxLength) {
    if (length <= maxLength) return this;
    return '${substring(0, maxLength - 3)}...';
  }

  /// Parse to DateTime or return null
  DateTime? tryParseDateTime() {
    try {
      return DateTime.parse(this);
    } catch (_) {
      return null;
    }
  }
}

/// Duration extensions
extension DurationExtensions on Duration {
  /// Format as mm:ss
  String toMinutesSeconds() {
    final minutes = inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  /// Format as readable string (e.g., "1h 30m")
  String toReadable() {
    if (inHours > 0) {
      final minutes = inMinutes.remainder(60);
      return '${inHours}h ${minutes}m';
    }
    return '${inMinutes}m';
  }
}

/// Int extensions
extension IntExtensions on int {
  /// Format as ordinal (1st, 2nd, 3rd, etc.)
  String toOrdinal() {
    if (this >= 11 && this <= 13) return '${this}th';
    switch (this % 10) {
      case 1:
        return '${this}st';
      case 2:
        return '${this}nd';
      case 3:
        return '${this}rd';
      default:
        return '${this}th';
    }
  }

  /// Format duration minutes as readable string
  String minutesToReadable() {
    if (this >= 60) {
      final hours = this ~/ 60;
      final minutes = this % 60;
      if (minutes == 0) return '${hours}h';
      return '${hours}h ${minutes}m';
    }
    return '${this}m';
  }
}

/// List extensions
extension ListExtensions<T> on List<T> {
  /// Get element at index or null
  T? getOrNull(int index) {
    if (index < 0 || index >= length) return null;
    return this[index];
  }

  /// Safe sublist
  List<T> safeSublist(int start, [int? end]) {
    if (start >= length) return [];
    return sublist(start, end != null && end <= length ? end : length);
  }
}

/// Map extensions
extension MapExtensions<K, V> on Map<K, V> {
  /// Get value or default
  V getOr(K key, V defaultValue) => this[key] ?? defaultValue;
}
