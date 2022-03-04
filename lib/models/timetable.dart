import 'package:timetable/models/abstract_thing.dart';

class Timetable extends AbstractThing {
  /// The starting date of the timetable (the time part is not used).
  DateTime startDate = DateTime.now();

  /// The date on which the timetable ends (should be >= `startDate`).
  DateTime endDate = DateTime.now();

  /// IDs of courses associated to this timetable.
  List<String> courseIds = [];

  /// Create a new `Timetable` object
  ///
  /// `startDate` and `endDate` are default to `DateTime.now()` if not supplied
  Timetable(String id, String name, {DateTime startDate, DateTime endDate})
      : super(id, name) {
    if (startDate != null) {
      this.startDate = startDate;
    }
    if (endDate != null) {
      this.endDate = endDate;
    }
  }

  Timetable.fromMap(String id, Map<String, dynamic> body) : super(id, "dummy") {
    super.name = body['name'];
    startDate = DateTime.parse(body['startDate']);
    endDate = DateTime.parse(body['endDate']);
    courseIds =
        body['courseIds'] == null ? [] : List<String>.from(body['courseIds']);
  }

  @override
  String toString() =>
      'Timetable(id: $id, name: $name, range: ${formatDate(startDate)} -> ${formatDate(endDate)})';

  @override
  Map<String, dynamic> toMap() {
    return {
      '$id': {
        'name': name,
        'startDate': startDate.toIso8601String(),
        'endDate': endDate.toIso8601String(),
        'courseIds': courseIds
      }
    };
  }

  Map<String, dynamic> bodyToMap() {
    return {
      'name': name,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'courseIds': courseIds
    };
  }
}
