import 'dart:io';

/// Matches a valid `YYYY-MM-DD` date (spec Rules 2/3 for creation/completion dates).
RegExp dateRegex = RegExp(r'^(\d{4})[\-](0[1-9]|1[012])[\-](0[1-9]|[12][0-9]|3[01])$');

/// Returns true if [prioString] is a priority `(A)`–`(Z)` (spec Rule 1, uppercase only).
bool isPriorityString(String prioString) {
  return prioString.length == 3 &&
      prioString[0] == '(' &&
      prioString[2] == ')' &&
      prioString.codeUnitAt(1) >= 65 &&
      prioString.codeUnitAt(1) <= 90;
}

/// Returns true if [date] matches [dateRegex] (`YYYY-MM-DD`).
bool isDateString(String date) {
  return dateRegex.hasMatch(date);
}

/// Strictly parses a YYYY-MM-DD string, throwing a [FormatException] for
/// impossible calendar dates (e.g. 2011-02-31) which [DateTime.tryParse]
/// would overflow into the next month.
DateTime parseStrictDate(String date) {
  if (!isDateString(date)) {
    throw FormatException('Invalid date', date);
  }
  final parts = date.split('-');
  final year = int.parse(parts[0]);
  final month = int.parse(parts[1]);
  final day = int.parse(parts[2]);
  final parsed = DateTime(year, month, day);
  if (parsed.year != year || parsed.month != month || parsed.day != day) {
    throw FormatException('Invalid date', date);
  }
  return parsed;
}

/// Formats [date] as `YYYY-MM-DD` for creation/completion dates.
String dateToDateString(DateTime date) {
  return '${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
}

/// Serializes [params] as space-separated `key:value` metadata tags.
String paramsToString(Map<String, String> params) {
  var strParams = '';
  params.forEach((key, value) => strParams += ' $key:$value');
  return strParams.trim();
}

/// Normalizes [path] separators to the current platform separator.
String pathToPlatformPath(String path) {
  return path.replaceAll(RegExp(r'\\|\/'), Platform.pathSeparator);
}
