import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import 'package:provider/provider.dart';
import 'package:timetable/providers/courses.dart';
import 'package:timetable/providers/timetables.dart';

class CalendarWeekView extends StatelessWidget {
  final String timetableId;
  CalendarWeekView(this.timetableId);

  DateTime _makeDateTime(DateTime date, int time) {
    var a =
        DateTime(date.year, date.month, date.day - 2, time ~/ 60, time % 60, 0);
    print(a);
    return a;
  }

  String _toWeekDaySyncfusionFormat(DateTime date) {
    var map = {
      '1': 'MO',
      '2': 'TU',
      '3': 'WE',
      '4': 'TH',
      '5': 'FR',
      '6': 'SA',
      '7': 'SU'
    };
    return map[date.weekday.toString()];
  }

  List<Appointment> _getAppointments(Courses courses, List<String> courseIds) {
    List<Appointment> meetings = <Appointment>[];
    if (courseIds != null) {
      for (final id in courseIds) {
        var c = courses.findById(id);
        meetings.add(Appointment(
            startTime: _makeDateTime(c.date, c.startTime),
            endTime: _makeDateTime(c.date, c.startTime + c.duration),
            subject: c.name,
            color: c.color,
            recurrenceRule:
                'FREQ=WEEKLY;BYDAY=${_toWeekDaySyncfusionFormat(c.date)};INTERVAL=1'));
      }
    }
    return meetings;
  }

  @override
  Widget build(BuildContext context) {
    final Courses courses = Provider.of<Courses>(context);
    final courseIds = Provider.of<Timetables>(context, listen: false)
        .findById(timetableId)
        .courseIds;
    return SfCalendar(
      firstDayOfWeek: 1,
      view: CalendarView.week,
      headerStyle: CalendarHeaderStyle(textAlign: TextAlign.center),
      dataSource: MeetingDataSource(_getAppointments(courses, courseIds)),
      showCurrentTimeIndicator: false,
    );
  }
}

class MeetingDataSource extends CalendarDataSource {
  MeetingDataSource(List<Appointment> data) {
    appointments = data;
  }
}
