import 'dart:ui';

import 'package:timetable/models/task.dart';

class Exam extends Task {
  String room;

  Exam(String id, String name, DateTime startDate, DateTime endDate,
      {DateTime notificationTime,
      String topic,
      int importantLevel,
      bool state,
      String note,
      String parentId,
      Color color,
      this.room})
      : super(id, name, startDate, endDate,
            notificationTime: notificationTime,
            topic: topic,
            importantLevel: importantLevel,
            state: state,
            note: note,
            parentId: parentId,
            color: color);

  Exam.fromMap(Map<String, dynamic> map)
      : assert(map['type'] == 'exam'),
        super(
          map['id'],
          map['name'],
          DateTime.parse(map['startDate']),
          DateTime.parse(map['endDate']),
          notificationTime: DateTime.now(),
          importantLevel: map['importantLevel'],
          state: map['state'],
          note: map['note'],
          parentId: map['parentId'],
          color: Color(map['color']),
      ) {
    room = map['room'];
  }

  @override
  String get type => 'exam';

  @override
  String toString() => 'Exam(id: $id, name: $name, range: ${formatDate(startDate)} - ${formatDate(endDate)}, room: $room)';

  @override
  Map<String, dynamic> toMap() {
    var map = super.toMap();
    map.addAll({'type': 'exam', 'room': room});
    return map;
  }
}
