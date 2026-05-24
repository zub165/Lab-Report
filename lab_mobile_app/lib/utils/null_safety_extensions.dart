/// Null safety extensions and utilities for the lab management app
/// These helpers provide safe ways to work with nullable fields

extension NullableStringX on String? {
  /// Returns lowercase string or empty string if null
  String lcOrEmpty() => this?.toLowerCase() ?? '';
  
  /// Returns the string or empty string if null
  String orEmpty() => this ?? '';
  
  /// Returns true if string contains the query (case insensitive), false if null
  bool containsIgnoreCase(String query) => 
      this?.toLowerCase().contains(query.toLowerCase()) ?? false;
}

extension NullableDateX on DateTime? {
  /// Returns true if date is after the given date, false if null
  bool isOnOrAfter(DateTime other) => this != null && !this!.isBefore(other);
  
  /// Returns true if date is before the given date, false if null
  bool isOnOrBefore(DateTime other) => this != null && !this!.isAfter(other);
  
  /// Returns true if date is after the given date, false if null
  bool isAfterOrFalse(DateTime other) => this != null && this!.isAfter(other);
  
  /// Returns true if date is before the given date, false if null
  bool isBeforeOrFalse(DateTime other) => this != null && this!.isBefore(other);
}

/// Compare two nullable dates, with nulls sorted last
int compareDatesNullsLast(DateTime? a, DateTime? b) {
  if (a == null && b == null) return 0;
  if (a == null) return 1;   // nulls after real dates
  if (b == null) return -1;
  return a.compareTo(b);
}

/// Compare two nullable strings, with nulls sorted last
int compareStringsNullsLast(String? a, String? b) {
  if (a == null && b == null) return 0;
  if (a == null) return 1;   // nulls after real strings
  if (b == null) return -1;
  return a.compareTo(b);
}

/// Generic null-safe comparator
int nullsLast<T extends Comparable>(T? a, T? b) {
  if (a == null && b == null) return 0;
  if (a == null) return 1;
  if (b == null) return -1;
  return a.compareTo(b);
}

/// Safe way to access Map entries
extension NullableMapX on Map<String, dynamic>? {
  /// Returns map entries or empty iterable if null
  Iterable<MapEntry<String, dynamic>> get safeEntries => 
      this?.entries ?? const <MapEntry<String, dynamic>>[];
  
  /// Returns the map or empty map if null
  Map<String, dynamic> get orEmpty => this ?? const <String, dynamic>{};
}
