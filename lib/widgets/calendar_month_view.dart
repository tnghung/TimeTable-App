import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:provider/provider.dart';

import 'package:timetable/constants/colors.dart';
import 'package:timetable/constants/texts.dart';
import 'package:timetable/views/course/course_screen.dart';
import 'package:timetable/providers/courses.dart';
import 'package:timetable/providers/timetables.dart';

class Event {
  final String title;
  final String location;
  final DateTime date;
  final TimeOfDay time;
  final int duration;
  const Event(this.title, this.location, this.date, this.time, this.duration);

  @override
  String toString() => title;
}

int getHashCode(DateTime key) {
  return key.day * 1000000 + key.month * 10000 + key.year;
}

/// Returns a list of [DateTime] objects from [first] to [last], inclusive.
List<DateTime> daysInRange(DateTime first, DateTime last) {
  final dayCount = last.difference(first).inDays + 1;
  return List.generate(
    dayCount,
    (index) => DateTime.utc(first.year, first.month, first.day + index),
  );
}

final kToday = DateTime.now();
final kFirstDay = DateTime(kToday.year, kToday.month - 3, kToday.day);
final kLastDay = DateTime(kToday.year, kToday.month + 3, kToday.day);

class CalendarMonthView extends StatefulWidget {
  final String timetableId;

  CalendarMonthView(this.timetableId);

  @override
  State<CalendarMonthView> createState() => _CalendarMonthViewState();
}

class _CalendarMonthViewState extends State<CalendarMonthView> {
  ValueNotifier<List<Event>> _selectedEvents;
  RangeSelectionMode _rangeSelectionMode = RangeSelectionMode
      .toggledOff; // Can be toggled on/off by long pressing a date
  DateTime _focusedDay;
  DateTime _selectedDay;
  DateTime _rangeStart;
  DateTime _rangeEnd;
  bool _isFirstBuilt;

  LinkedHashMap<DateTime, List<Event>> kEvents;
  Map<DateTime, List<Event>> _kEventSource;

  @override
  void initState() {
    print('CalendarMonthView::initState');
    super.initState();
    _focusedDay = DateTime.now();
    _selectedDay = _focusedDay;
    _isFirstBuilt = true;
    // _selectedEvents = ValueNotifier([]);
  }

  @override
  void dispose() {
    print('CalendarMonthView::dispose');
    _selectedEvents.dispose();
    super.dispose();
  }

  List<Event> _getEventsForDay(DateTime day) {
    // Implementation example
    return kEvents[day] ?? [];
  }

  List<Event> _getEventsForRange(DateTime start, DateTime end) {
    // Implementation example
    final days = daysInRange(start, end);

    return [
      for (final d in days) ..._getEventsForDay(d),
    ];
  }

  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    if (!isSameDay(_selectedDay, selectedDay)) {
      setState(() {
        _selectedDay = selectedDay;
        _focusedDay = focusedDay;
        _rangeStart = null; // Important to clean those
        _rangeEnd = null;
        _rangeSelectionMode = RangeSelectionMode.toggledOff;
      });

      _selectedEvents.value = _getEventsForDay(selectedDay);
    }
  }

  void _onRangeSelected(DateTime start, DateTime end, DateTime focusedDay) {
    setState(() {
      _selectedDay = null;
      _focusedDay = focusedDay;
      _rangeStart = start;
      _rangeEnd = end;
      _rangeSelectionMode = RangeSelectionMode.toggledOn;
    });

    // `start` or `end` could be null
    if (start != null && end != null) {
      _selectedEvents.value = _getEventsForRange(start, end);
    } else if (start != null) {
      _selectedEvents.value = _getEventsForDay(start);
    } else if (end != null) {
      _selectedEvents.value = _getEventsForDay(end);
    }
  }

  @override
  Widget build(BuildContext context) {
    var courseIds =
        Provider.of<Timetables>(context).findById(widget.timetableId).courseIds;
    var courses = List.generate(courseIds.length,
        (index) => Provider.of<Courses>(context).findById(courseIds[index]));

    var weekDayMap = Map.fromIterable(List.generate(7, (index) => index + 1),
        key: (element) => element.toString(), value: (element) => []);

    for (final c in courses) {
      weekDayMap[c.date.weekday.toString()].add(c);
    }

    _kEventSource = Map.fromIterable(daysInRange(kFirstDay, kLastDay),
        key: (element) => element,
        value: (element) => weekDayMap[element.weekday.toString()]
            .map((e) => Event(
                e.name,
                e.room,
                e.date,
                TimeOfDay(hour: e.startTime ~/ 60, minute: e.startTime % 60),
                e.duration))
            .toList());

    print('_kEventSource: $_kEventSource');
    // _kEventSource = Map.fromIterable(List.generate(40, (index) => index),
    //     key: (item) => DateTime.utc(kFirstDay.year, kFirstDay.month, item * 5),
    //     value: (item) => List.generate(
    //         item % 4 + 1,
    //         (index) => Event(
    //             'Event $item | ${index + 1}',
    //             'Online',
    //             DateTime.utc(kFirstDay.year, kFirstDay.month, item * 5),
    //             TimeOfDay.now(),
    //             50)))
    //   ..addAll({
    //     kToday: [
    //       Event('Today\'s Event 1', 'Online', DateTime.now(), TimeOfDay.now(),
    //           50),
    //       Event('Today\'s Event 2', 'Online', DateTime.now(), TimeOfDay.now(),
    //           50),
    //     ],
    //   });

    kEvents = LinkedHashMap<DateTime, List<Event>>(
      equals: isSameDay,
      hashCode: getHashCode,
    )..addAll(_kEventSource);
    print('kEvents: $kEvents');

    if (_isFirstBuilt) {
      _selectedEvents = ValueNotifier(_getEventsForDay(_selectedDay));
      _isFirstBuilt = false;
    }
    return Column(
      children: [
        TableCalendar<Event>(
          firstDay: kFirstDay,
          lastDay: kLastDay,
          focusedDay: _focusedDay,
          selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
          rangeStartDay: _rangeStart,
          rangeEndDay: _rangeEnd,
          calendarFormat: CalendarFormat.month,
          rangeSelectionMode: _rangeSelectionMode,
          eventLoader: _getEventsForDay,
          startingDayOfWeek: StartingDayOfWeek.monday,
          calendarStyle: CalendarStyle(
            // Use `CalendarStyle` to customize the UI
            outsideDaysVisible: false,
            markerDecoration: BoxDecoration(
                color: Colors.redAccent, borderRadius: BorderRadius.zero),
            markerMargin: const EdgeInsets.only(right: 3),
            canMarkersOverflow: false,
            selectedDecoration:
                BoxDecoration(color: mainColor, shape: BoxShape.rectangle),
            todayDecoration: BoxDecoration(color: Colors.green),
            withinRangeDecoration: BoxDecoration(
                color: Colors.black,
                border: Border.all(
                    color: Colors.black, width: 1.0, style: BorderStyle.solid)),
            cellPadding: EdgeInsets.zero,
            // cellMargin: EdgeInsets.zero,
            markersMaxCount: 3,
            markersAlignment: Alignment.topLeft,
            markerSize: 10,
            tableBorder: TableBorder.all(
                color: Colors.black, width: 1.0, style: BorderStyle.solid),
          ),
          onDaySelected: _onDaySelected,
          onRangeSelected: _onRangeSelected,
          // onFormatChanged: (format) {
          //   if (_calendarFormat != format) {
          //     setState(() {
          //       _calendarFormat = format;
          //     });
          //   }
          // },
          onPageChanged: (focusedDay) {
            _focusedDay = focusedDay;
          },
          headerStyle: HeaderStyle(
            formatButtonVisible: false,
            titleCentered: true,
          ),
        ),
        const SizedBox(height: 8.0),
        Container(
          alignment: Alignment.centerLeft,
          padding: EdgeInsets.all(8.0),
          child: Text(DateFormat('EEEE, d/MM/yyyy').format(_selectedDay)),
        ),
        const SizedBox(height: 8.0),
        Expanded(
          child: ValueListenableBuilder<List<Event>>(
            valueListenable: _selectedEvents,
            builder: (context, value, _) {
              return ListView.builder(
                itemCount: value.length,
                itemBuilder: (context, index) {
                  return GestureDetector(
                      onTap: () {
                        Navigator.of(context).pushNamed(CourseScreen.routeName, arguments: courseIds[index]);
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          boxShadow: [
                            BoxShadow(
                                color: Colors.grey[300],
                                offset: Offset(5, 5),
                                blurRadius: 1.0,
                                spreadRadius: 1.0)
                          ],
                          color: Colors.white,
                        ),
                        margin: EdgeInsets.only(bottom: 10.0),
                        height: 70,
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 8,
                              color: Colors.deepOrange,
                            ),
                            Expanded(
                              child: Container(
                                  padding: EdgeInsets.only(left: 15, right: 15),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Text('${value[index].title}'),
                                          RichText(
                                            text: TextSpan(
                                              children: [
                                                WidgetSpan(
                                                  child: Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            right: 2.0,
                                                            left: 0),
                                                    child: Icon(
                                                      Icons
                                                          .location_on_outlined,
                                                      color: Colors.grey[400],
                                                    ),
                                                  ),
                                                ),
                                                TextSpan(
                                                    text:
                                                        '${value[index].location}',
                                                    style: tileSecondaryText),
                                              ],
                                            ),
                                          )
                                        ],
                                      ),
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.end,
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Row(
                                            children: [
                                              Text(
                                                DateFormat("EEE").format(
                                                        value[index].date) +
                                                    ", ",
                                                style: tileSecondaryText,
                                              ),
                                              Text(
                                                  value[index]
                                                      .time
                                                      .format(context)
                                                      .toString(),
                                                  style: tileSecondaryText),
                                            ],
                                          ),
                                          Text('${value[index].duration}h',
                                              style: tileSecondaryText),
                                        ],
                                      )
                                    ],
                                  )),
                            ),
                          ],
                        ),
                      ));
                },
              );
            },
          ),
        ),
      ],
    );
  }
}
