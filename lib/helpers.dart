import 'dart:io';

RegExp dateRegex =
    RegExp(r'(\d{4})[\-](0?[1-9]|1[012])[\-](0?[1-9]|[12][0-9]|3[01])$');

bool isPriorityString(String prioString) {
  return prioString.length == 3 &&
      prioString[0] == '(' &&
      prioString[2] == ')' &&
      prioString.codeUnitAt(1) >= 65 &&
      prioString.codeUnitAt(1) <= 90;
}

bool isDateString(String date) {
  return dateRegex.hasMatch(date);
}

String dateToDateString(DateTime date) {
  return '${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
}

String paramsToString(Map params) {
  var strParams = '';
  params.forEach((key, value) => strParams += ' $key:$value');
  return strParams.trim();
}

String pathToPlatformPath(String path) {
  return path.replaceAll(RegExp(r'\\|\/'), Platform.pathSeparator);
}
