import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:timetable/models/abstract_thing.dart';

class Course extends AbstractThing {
  /// Minutes since 00:00.
  int startTime;

  /// Unit: minutes.
  int duration;

  /// The weekday that this course occurs. Must be `"Monday"`, `"Tuesday"`, ...,
  /// `"Sunday"`.
  ///
  /// Note: capitalized weekdays.
  DateTime date = DateTime.now();

  /// Name of the lecturer.
  String lecturerName;

  /// Location where this course occurs. Can be arbitrary name or a URL.
  String room;

  /// User's note on this course.
  String note;

  /// HTML color code. Example: `#FF0000`.
  Color color;

  List<String> taskIds = [];
  static const  initialDate =  DateTime;
  /// Create a new `Course` object.
  Course(String id, String name,
      {this.date,
        this.startTime = 0,
        this.duration = 0,
        this.lecturerName,
        this.room,
        this.color=Colors.blue,
        this.note,
        this.taskIds })
      : super(id, name);

  /// Load the `Course` object from the JSON object in the database (the JSON
  /// must be converted to `Map` beforehand).
  Course.fromMap(Map<String, dynamic> map) : super(map['id'], map['name']) {
    date = map['date'];
    startTime = map['startTime'];
    duration = map['duration'];
    taskIds = map['taskIds'];
  }

  @override
  String toString() =>
      'Course(id: $id, name: $name, date: $date, range: ${formatTime(
          startTime)} -> ${formatTime(startTime + duration)})';

  @override
  Map<String, dynamic> toMap() =>
      {
        'id': id,
        'name': name,
        'date': date.toIso8601String(),
        'startTime': startTime,
        'duration': duration,
        'lecturerName': lecturerName,
        'room': room,
        'color': color.value,
        'note': note,
        'taskIds': taskIds.join(", ")
      };

}