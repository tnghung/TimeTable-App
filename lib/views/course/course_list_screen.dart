import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:timetable/constants/colors.dart';
import 'package:timetable/providers/courses.dart';
import 'package:timetable/views/timetable/util.dart';
import 'package:timetable/widgets/course_tile.dart';
import 'package:timetable/widgets/app_drawer.dart';
import 'create_course_screen.dart';

class CourseListScreen extends StatefulWidget {
  static String routeName = "course_list_screen";
  @override
  State<CourseListScreen> createState() => _CourseListScreenState();
}

class _CourseListScreenState extends State<CourseListScreen> {
  final GlobalKey<ScaffoldState> scaffoldKey = new GlobalKey<ScaffoldState>();

  var _isInit = true;
  var _isLoading = false;

  @override
  void didChangeDependencies() {
    if (_isInit) {
      setState(() {
        _isLoading = true;
      });
      Provider.of<Courses>(context)
          .fetchAndSetDataCourses()
          .catchError((e) => Util.getInstance()
          .showAlertDialogOk(context, 'Error', 'An error occur!'))
          .whenComplete(() => {
                setState(() {
                  _isLoading = false;
                })
              });
    }
    _isInit = false;
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    final courseData = Provider.of<Courses>(context);
    return Scaffold(
      drawer: AppDrawer(),
      appBar: AppBar(
        title: Text("Courses"), //title of appbar
        backgroundColor: mainColor,
        //background color of appbar
      ),
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(),
            )
          : Padding(
              padding: EdgeInsets.all(8),
              child: courseData.items.isEmpty
                  ? Center(
                      child: Text(
                        'You not add course yet!',
                        style: TextStyle(fontSize: 20),
                      ),
                    )
                  : ListView.builder(
                      itemBuilder: (ctx, i) => Column(
                        children: [
                          CourseTile(
                            id: courseData.items[i].id,
                            name: courseData.items[i].name,
                            duration: courseData.items[i].duration,
                            color: courseData.items[i].color,
                            date: courseData.items[i].date,
                            room: courseData.items[i].room,
                            startTime: courseData.items[i].startTime,
                          ),
                          Divider(),
                        ],
                      ),
                      itemCount: courseData.items.length,
                    ),
            ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add), //child widget inside this button
        onPressed: () {
          //task to execute when this button is pressed
          Navigator.of(context).pushNamed(CreateCourseScreen.routeName);
        },
      ),
    );
  }
}
