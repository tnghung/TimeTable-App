import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:timetable/constants/texts.dart';
import 'package:intl/intl.dart';
import 'package:timetable/providers/courses.dart';
import 'package:timetable/views/course/create_course_screen.dart';

class CourseScreen extends StatefulWidget {
  static String routeName = "course_screen";

  @override
  State<CourseScreen> createState() => _CourseScreenState();
}

class _CourseScreenState extends State<CourseScreen> {
  var _isInit = true;
  var courseId;
  var loadedCourse;

  @override
  void didChangeDependencies() {
    if (_isInit) {
      if (courseId == null) {
        courseId = ModalRoute.of(context).settings.arguments as String;
        loadedCourse = Provider.of<Courses>(context).findById(courseId);
      } else {
        return;
      }
    }
    _isInit = false;
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: loadedCourse.color,
        actions: <Widget>[
          IconButton(
            icon: Icon(
              Icons.create_rounded,
              color: Colors.white,
            ),
            onPressed: () {
              Navigator.of(context)
                  .pushNamed(CreateCourseScreen.routeName, arguments: courseId);
            },
          )
        ],
        //background color of appbar
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Column(children: [
            Container(
                padding: EdgeInsets.all(20.0),
                width: double.infinity,
                height: 260,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(10.0),
                    bottomRight: Radius.circular(10.0),
                  ),
                  boxShadow: [
                    BoxShadow(
                        color: Colors.grey[400],
                        offset: Offset(5, 5),
                        blurRadius: 5.0,
                        spreadRadius: 1.0)
                  ],
                  color: loadedCourse.color,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Padding(
                      padding: EdgeInsets.only(bottom: 10),
                      child: Text(loadedCourse.name, style: primaryText),
                    ),
                    Text(loadedCourse.lecturerName, style: normalText)
                  ],
                )),
            Column(
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.access_time,
                      size: 32,
                    ),
                    SizedBox(
                      width: 20,
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          DateFormat('EEEE').format(loadedCourse.date),
                          style: TextStyle(color: Colors.black, fontSize: 18),
                        ),
                        SizedBox(height: 5),
                        RichText(
                          text: TextSpan(
                            children: [
                              TextSpan(
                                  text:
                                      '${loadedCourse.startTime ~/ 60}:${loadedCourse.startTime % 60}',
                                  style: TextStyle(
                                      color: Colors.black, fontSize: 18)),
                              TextSpan(
                                  text:
                                      '  (${(loadedCourse.duration / 60.0).toStringAsFixed(1)} hours)',
                                  style: TextStyle(
                                      color: Colors.black, fontSize: 18)),
                            ],
                          ),
                        )
                      ],
                    )
                  ],
                ),
                Row(
                  children: [
                    Icon(
                      Icons.location_on_outlined,
                      size: 32,
                    ),
                    SizedBox(
                      width: 20,
                    ),
                    Text(loadedCourse.room,
                        style: TextStyle(color: Colors.black, fontSize: 18))
                  ],
                ),
                Row(
                  children: [
                    Icon(
                      Icons.note_outlined,
                      size: 32,
                    ),
                    SizedBox(
                      width: 20,
                    ),
                    Text(loadedCourse.note,
                        style: TextStyle(color: Colors.black, fontSize: 18))
                  ],
                ),
              ]
                  .map(
                    (c) => Container(
                        padding: EdgeInsets.all(20.0),
                        height: 90,
                        width: double.infinity,
                        child: c),
                  )
                  .toList(),
            ),
          ]),
        ),
      ),
    );
  }
}
