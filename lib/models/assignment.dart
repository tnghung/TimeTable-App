import 'dart:ui';

import 'package:timetable/models/task.dart';

class Assignment extends Task {
  int progress;
  bool isGroupProject;

  Assignment(String id, String name, DateTime startDate, DateTime endDate,
      {DateTime notificationTime,
      String topic,
      int importantLevel = 1,
      bool state = false,
      String note,
      String parentId,
      Color color,
      this.progress = 0,
      this.isGroupProject = false})
      : assert(progress >= 0 && progress <= 100),
        super(id, name, startDate, endDate,
            notificationTime: notificationTime,
            topic: topic,
            note: note,
            importantLevel: importantLevel,
            state: state,
            parentId: parentId,
            color: color);

  Assignment.fromMap(Map<String, dynamic> map)
      : assert(map['type'] == 'assignment'),
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
    progress = map['progress'];
    isGroupProject = map['isGroupProject'];
  }

  @override
  String get type => 'assignment';

  @override
  String toString() =>
      'Assignment(id: $id, name: $name, range: ${formatDate(startDate)} - ${formatDate(endDate)}, progress: $progress)';

  @override
  Map<String, dynamic> toMap() {
    var map = super.toMap();
    var n = {
      'type': 'assignment',
      'progress': progress,
      'isGroupProject': isGroupProject
    };
    map.addAll(n);
    return map;
  }
}
