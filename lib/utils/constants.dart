import 'package:intl/intl.dart';

class Constants {
  static String getTimeFromTimestamp(int? timestamp) {
    var date = DateTime.fromMillisecondsSinceEpoch(timestamp! * 1000);
    var formatter = DateFormat('HH:mm');
    return formatter.format(date);
  }

  static String getDateFromTimestamp(int? timestamp) {
    var date = DateTime.fromMillisecondsSinceEpoch(timestamp! * 1000);
    var formatter = DateFormat('dd/MM');
    return formatter.format(date);
  }

  static String getDayFromTimestamp(int? timestamp) {
    var date = DateTime.fromMillisecondsSinceEpoch(timestamp! * 1000);
    var formatter = DateFormat('E');
    return formatter.format(date);
  }
}
