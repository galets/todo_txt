import 'dart:io';

/// Returns true if [prioString] is a priority `(A)`–`(Z)` (spec Rule 1, uppercase only).
bool isPriorityString(String prioString) {
  return prioString.length == 3 &&
      prioString[0] == '(' &&
      prioString[2] == ')' &&
      prioString.codeUnitAt(1) >= 65 &&
      prioString.codeUnitAt(1) <= 90;
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
