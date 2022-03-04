import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:timetable/constants/texts.dart';
import 'package:timetable/models/task.dart';
import 'package:timetable/views/task/task_screen.dart';
import 'package:timetable/views/task/create_task_screen.dart';

class TaskTile extends StatelessWidget {
  final String id;
  final String name;
  final DateTime endDate;
  final bool state;
  final Color color;
  final String courseName;
  final String type;

  TaskTile({
    this.id,
    this.name,
    this.endDate,
    this.state,
    this.color,
    this.courseName,
    this.type,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).pushNamed(
            TaskScreen.routeName,
            arguments: {'taskId': id, 'type': type});
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
          color: state ? Colors.grey : Colors.white,
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
                                    Icons.web_asset_outlined,
                                    color: Colors.grey[400],
                                  ),
                                ),
                              ),
                              TextSpan(text: courseName, style: tileSecondaryText),
                            ],
                          ),
                        )
                      ],
                    ),
                    Align(
                      alignment: Alignment.centerRight,
                      child:
                        Text('${DateFormat.E().format(endDate)}', style: tileSecondaryText)
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
