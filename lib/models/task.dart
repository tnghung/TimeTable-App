import 'package:intl/intl.dart';
import 'dart:ui';
import 'package:timetable/models/abstract_thing.dart';

abstract class Task extends AbstractThing {
  /// Starting date of the task.
  DateTime startDate = DateTime.now();

  /// Due date.
  DateTime endDate = DateTime.now();

  /// Reminder time.
  DateTime notificationTime;

  /// (unused for now, maybe duplicated with attribute `name`)
  String topic;

  /// Priority of this task.
  int importantLevel;

  /// Whether the task is marked as done.
  bool state;

  /// User's note on this task.
  String note;

  /// ID of the parent course.
  String parentId;

  /// HTML color code. Example: `#FF0000`.
  Color color;

  Task(String id, String name, DateTime startDate, DateTime endDate,
      {this.notificationTime,
      this.topic,
      this.importantLevel = 1,
      this.state = false,
      this.note,
      this.parentId,
      this.color})
      : assert(startDate.compareTo(endDate) <= 0),
        super(id, name) {
    if (startDate != null) {
      this.startDate = startDate;
    }
    if (endDate != null) {
      this.endDate = endDate;
    }
  }

  @override
  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'startDate': DateFormat('yyyy-MM-dd HH:mm').format(startDate),
        'endDate': DateFormat('yyyy-MM-dd HH:mm').format(endDate),
        'notificationTime': '',
        'topic': topic,
        'note': note,
        'importantLevel': importantLevel,
        'state': state,
        'parentId': parentId,
        'color': color.value,
      };

  String get type;

  void removeNotificationTime() => notificationTime = null;
}
