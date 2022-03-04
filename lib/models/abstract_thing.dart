import 'package:intl/intl.dart';

/// Abstract base class for Timetable, Course and Task.
abstract class AbstractThing {
  /// Unique ID within the app
  final String _id;
  String name;

  String get id => _id;

  AbstractThing(this._id, this.name);

  String formatDate(DateTime date) => DateFormat('yyyy-MM-dd').format(date);

  DateTime parseDate(String date) => DateTime.parse(date);

  /// Convert `time` into a string formatted as `hh:mm`. `time` is the number of
  /// minutes since midnight (00:00).
  String formatTime(int time) {
    var h = time ~/ 60;
    var m = time % 60;
    return '${h.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')}';
  }

  /// Convert the string of the format `hh:mm` into integer. The integer is the
  /// number of minutes since midnight (00:00).
  ///
  /// Return `null` if the parse fails.
  int parseTime(String time) {
    var re = RegExp(r'^(\d{2}):(\d{2})$');
    var match = re.firstMatch(time);

    if (match == null) {
      return null;
    }

    if (match.groupCount != 2) {
      return null;
    }

    var h = int.parse(match.group(1));
    var m = int.parse(match.group(2));

    if (h >= 0 && h < 24 && m >= 0 && m < 60) {
      return h * 60 + m;
    }
    return null;
  }

  /// Convert `time` into hour and minute. Returns a list, where list[0] is the
  /// hour and list[1] is the minute.
  ///
  /// Example:
  /// ```dart
  /// var r = toHourMinute(150); // 150 minutes since 00:00
  /// print(r); // [2, 30]
  /// ```
  List<int> toHourMinute(int time) {
    var r = List<int>.filled(2, 0, growable: false);
    r[0] = time ~/ 60;
    r[1] = time % 60;
    return r;
  }

  @override
  String toString();

  /// Export this object to `Map`, ready to be written into database.
  Map<String, dynamic> toMap();
}
