import 'package:intl/intl.dart';

String getTimeFromTimestamp(int? timestamp) {
  var date = DateTime.fromMillisecondsSinceEpoch(timestamp! * 1000);
  var formatter = DateFormat('HH:mm');
  return formatter.format(date);
}

String getDateFromTimestamp(int timestamp) {
  var date = DateTime.fromMillisecondsSinceEpoch(timestamp * 1000);
  var formatter = DateFormat('E');
  return formatter.format(date);
}

String getDayFromTimestamp(int? timestamp) {
  var date = DateTime.fromMillisecondsSinceEpoch(timestamp! * 1000);
  var formatter = DateFormat('EEEE');
  return formatter.format(date);
}
