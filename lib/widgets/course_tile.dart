import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:timetable/constants/texts.dart';
import 'package:timetable/views/course/course_screen.dart';

class CourseTile extends StatelessWidget {
  final String id;
  final String name;
  final String room;
  final DateTime date;
  final int startTime;
  final int duration;
  final Color color;

  CourseTile({
    this.id,
    this.name,
    this.room,
    this.date,
    this.startTime,
    this.duration,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).pushNamed(CourseScreen.routeName, arguments: id);
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
        height: 70,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 8,
              color: color,
            ),
            Expanded(
              child: Container(
                padding: EdgeInsets.only(left: 15, right: 15),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(name),
                        RichText(
                          text: TextSpan(
                            children: [
                              WidgetSpan(
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 2.0),
                                  child: Icon(
                                    Icons.location_on_outlined,
                                    color: Colors.grey[400],
                                  ),
                                ),
                              ),
                              TextSpan(text: room, style: tileSecondaryText),
                            ],
                          ),
                        )
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                            '${DateFormat.E().format(date)}, ${startTime ~/ 60}:${startTime % 60}',
                            style: tileSecondaryText),
                        Text('${(duration / 60.0).toStringAsFixed(1)}h',
                            style: tileSecondaryText),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
