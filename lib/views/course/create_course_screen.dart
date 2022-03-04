import 'package:flutter_material_pickers/flutter_material_pickers.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:timetable/constants/colors.dart';
import 'package:intl/intl.dart';
import 'package:timetable/models/course.dart';
import 'package:timetable/providers/courses.dart';
import 'package:timetable/providers/timetables.dart';
import 'package:timetable/views/course/course_list_screen.dart';

class CreateCourseScreen extends StatefulWidget {
  static String routeName = "create_course_screen";

  @override
  _CreateCourseScreenState createState() => _CreateCourseScreenState();
}

class _CreateCourseScreenState extends State<CreateCourseScreen> {
  String selectedValue;
  List<String> timeTableItems = [
    'time table 1',
    'time table 2',
    'time table 3',
    'time table 4',
  ];

  String formatTimeOfDay(TimeOfDay tod) {
    final now = new DateTime.now();
    final dt = DateTime(now.year, now.month, now.day, tod.hour, tod.minute);
    final format = DateFormat.jm(); //"6:00 AM"
    return format.format(dt);
  }

  static const double inputHeight = 60;
  static const double gap = 15;
  Color colorChoose;
  var time;
  var date;
  var _isLoading = false;

  final _formKey = new GlobalKey<FormState>();
  String courseId;

  var _createCourse = Course(null, '',
      room: '',
      date: null,
      color: null,
      duration: 0,
      startTime: null,
      lecturerName: '',
      taskIds: []);

  var _isInit = true;

  var _initValues = {
    'name': '',
    'lecturerName': '',
    'room': '',
    'duration': '',
    'note': ''
  };

  @override
  void didChangeDependencies() {
    if (_isInit) {
      courseId = ModalRoute.of(context).settings.arguments as String;
      if (courseId != null) {
        _createCourse =
            Provider.of<Courses>(context, listen: false).findById(courseId);
        _initValues = {
          'name': _createCourse.name,
          'lecturerName': _createCourse.lecturerName,
          'room': _createCourse.room,
          'duration': _createCourse.duration.toString(),
          'note': _createCourse.note,
        };
      } else {
        _createCourse.startTime =
            TimeOfDay.now().hour * 60 + TimeOfDay.now().minute;
        _createCourse.date = DateTime.now();
        _createCourse.color = Colors.blue;
      }
      colorChoose = _createCourse.color;
      date = _createCourse.date;
      time = TimeOfDay(
          hour: _createCourse.startTime ~/ 60,
          minute: _createCourse.startTime % 60);
    }
    _isInit = false;
    super.didChangeDependencies();
  }

  Future<void> _saveCourse() async {
    final isValid = _formKey.currentState.validate();
    if (!isValid) {
      return;
    }
    _formKey.currentState.save();
    setState(() {
      _isLoading = true;
    });
    if (_createCourse.id != null) {
      await Provider.of<Courses>(context, listen: false)
          .updateCourse(_createCourse.id, _createCourse);
    } else {
      try {
        await Provider.of<Courses>(context, listen: false)
            .addCourse(_createCourse);
      } catch (error) {
        await showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: Text(
              'Error',
              style: TextStyle(
                  fontSize: 25,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).errorColor),
            ),
            content:
                Text('Something went wrong!\nPlease try it later! ${error}'),
            actions: [
              FlatButton(
                  onPressed: () {
                    Navigator.of(ctx).pop();
                  },
                  child: Text(
                    'OK',
                    style: TextStyle(color: Theme.of(context).primaryColor),
                  ))
            ],
          ),
        );
      }
    }
    setState(() {
      _isLoading = false;
    });
    Navigator.of(context).popAndPushNamed(CourseListScreen.routeName);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xfffffcf0),
      appBar: AppBar(
        title: courseId == null ? Text("Create Course") : Text("Edit Course"),
        //title of appbar
        backgroundColor: mainColor,
        actions: <Widget>[
          IconButton(
            icon: Icon(
              Icons.check,
              color: Colors.white,
            ),
            onPressed: () {
              _saveCourse();
            },
          )
        ],
        //background color of appbar
      ),
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(),
            )
          : SingleChildScrollView(
              child: Padding(
                padding:
                    const EdgeInsets.only(left: 8.0, right: 8.0, top: 50.0),
                child: Center(
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        Container(
                          margin: EdgeInsets.symmetric(horizontal: 15),
                          padding: EdgeInsets.symmetric(vertical: 5),
                          color: Colors.white,
                          child: TextFormField(
                            initialValue: _initValues['name'],
                            keyboardType: TextInputType.name,
                            textInputAction: TextInputAction.next,
                            decoration: InputDecoration(
                              prefixIcon: Icon(
                                Icons.title,
                                color: mainColor,
                              ),
                              fillColor: Colors.white,
                              focusedBorder: UnderlineInputBorder(
                                borderSide: const BorderSide(
                                    color: const Color(0xff0075FF), width: 3.0),
                              ),
                              hintText: "Title",
                              hintStyle:
                                  TextStyle(fontSize: 14, color: hintText),
                            ),
                            style: TextStyle(fontSize: 16, color: Colors.black),
                            validator: (value) {
                              if (value.isEmpty) {
                                return "Please enter the title!";
                              }
                              return null;
                            },
                            onSaved: (value) {
                              _createCourse.name = value;
                            },
                          ),
                        ),
                        Container(
                          margin: EdgeInsets.symmetric(horizontal: 15),
                          padding: EdgeInsets.symmetric(vertical: 5),
                          color: Colors.white,
                          child: TextFormField(
                            initialValue: _initValues['lecturerName'],
                            keyboardType: TextInputType.name,
                            decoration: InputDecoration(
                              prefixIcon: Icon(
                                Icons.supervisor_account,
                                color: mainColor,
                              ),
                              fillColor: Colors.white,
                              filled: true,
                              focusedBorder: UnderlineInputBorder(
                                borderSide: const BorderSide(
                                    color: const Color(0xff0075FF), width: 3.0),
                              ),
                              hintText: "Lecturer",
                              hintStyle:
                                  TextStyle(fontSize: 14, color: hintText),
                            ),
                            style: TextStyle(fontSize: 16, color: Colors.black),
                            validator: (value) {
                              if (value.isEmpty) {
                                return "Please enter the lecturer!";
                              }
                              return null;
                            },
                            onSaved: (value) {
                              _createCourse.lecturerName = value;
                            },
                          ),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Container(
                                margin: EdgeInsets.only(left: 15),
                                padding: EdgeInsets.symmetric(vertical: 5),
                                color: Colors.white,
                                child: TextFormField(
                                  initialValue: _initValues['room'],
                                  keyboardType: TextInputType.streetAddress,
                                  decoration: InputDecoration(
                                    prefixIcon: Icon(
                                      Icons.location_on_outlined,
                                      color: mainColor,
                                    ),
                                    fillColor: Colors.white,
                                    filled: true,
                                    focusedBorder: UnderlineInputBorder(
                                      borderSide: const BorderSide(
                                          color: const Color(0xff0075FF),
                                          width: 3.0),
                                    ),
                                    hintText: "Location",
                                    hintStyle: TextStyle(
                                        fontSize: 14, color: hintText),
                                  ),
                                  style: TextStyle(
                                      fontSize: 16, color: Colors.black),
                                  validator: (value) {
                                    if (value.isEmpty) {
                                      return "Please enter the location!";
                                    }
                                    return null;
                                  },
                                  onSaved: (value) {
                                    _createCourse.room = value;
                                  },
                                ),
                              ),
                            ),
                            SizedBox(
                              child: Row(
                                children: [
                                  Padding(
                                      padding:
                                          EdgeInsets.only(right: 5, left: 10),
                                      child: Icon(Icons.color_lens_outlined)),
                                  SizedBox(
                                    height: 40,
                                    child: ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        primary: colorChoose,
                                        shape: CircleBorder(), // background
                                      ),
                                      onPressed: () {
                                        showMaterialSwatchPicker(
                                          context: context,
                                          selectedColor: Colors.blue,
                                          onChanged: (value) => setState(() {
                                            colorChoose = value;
                                            _createCourse.color = colorChoose;
                                          }),
                                        );
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),

                        // Enter date
                        Container(
                          padding:
                              EdgeInsets.symmetric(horizontal: 16, vertical: 5),
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            style: ButtonStyle(
                                backgroundColor:
                                    MaterialStateProperty.all(Colors.white)),
                            icon: Icon(Icons.calendar_today_outlined,
                                color: Colors.black),
                            label: Text(
                              DateFormat("yyyy-MM-dd").format(date),
                              style: TextStyle(color: Colors.black),
                            ),
                            onPressed: () {
                              showMaterialDatePicker(
                                title: "Calendar",
                                firstDate: DateTime.now()
                                    .subtract(Duration(days: 2021 * 10)),
                                lastDate: DateTime.now()
                                    .add(Duration(days: 2021 * 10)),
                                context: context,
                                selectedDate: date,
                                onChanged: (value) => setState(() {
                                  date = value;
                                  _createCourse.date = date;
                                }),
                              );
                            },
                          ),
                        ),

                        // Enter time
                        Container(
                          padding: EdgeInsets.only(bottom: gap, left: 16),
                          width: double.infinity,
                          height: inputHeight,
                          child: Row(
                            children: [
                              SizedBox(
                                width: 180,
                                height: 50,
                                child: ElevatedButton.icon(
                                  style: ButtonStyle(
                                      backgroundColor:
                                          MaterialStateProperty.all(
                                              Colors.redAccent)),
                                  icon: Icon(Icons.access_time),
                                  label: Text(time.format(context)),
                                  onPressed: () {
                                    showMaterialTimePicker(
                                      context: context,
                                      selectedTime: time,
                                      onChanged: (value) => setState(() {
                                        time = value;
                                        _createCourse.startTime =
                                            value.hour * 60 + value.minute;
                                      }),
                                    );
                                  },
                                ),
                              ),

                              // Enter duration (text form field)
                              Container(
                                margin: EdgeInsets.symmetric(horizontal: 16),
                                padding: EdgeInsets.symmetric(vertical: 5),
                                child: Container(
                                  // infinity
                                  width: 165,
                                  height: 50,
                                  child: TextFormField(
                                    initialValue: _initValues['duration'],
                                    keyboardType: TextInputType.number,
                                    decoration: InputDecoration(
                                      fillColor: Colors.white,
                                      filled: true,
                                      focusedBorder: UnderlineInputBorder(
                                        borderSide: const BorderSide(
                                            color: const Color(0xff0075FF),
                                            width: 3.0),
                                      ),
                                      hintText: "Duration (min)",
                                      hintStyle: TextStyle(
                                          fontSize: 14, color: hintText),
                                    ),
                                    style: TextStyle(
                                        fontSize: 16, color: Colors.black),
                                    validator: (value) {
                                      if (value.isEmpty) {
                                        return "Please enter the time!";
                                      }
                                      return null;
                                    },
                                    onSaved: (value) {
                                      _createCourse.duration = int.parse(value);
                                    },
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Enter note (text form field)
                        Container(
                          padding:
                              EdgeInsets.only(bottom: gap, left: 16, right: 16),
                          // infinity
                          width: double.infinity,
                          child: TextFormField(
                            initialValue: _initValues['note'],
                            keyboardType: TextInputType.multiline,
                            textInputAction: TextInputAction.newline,
                            maxLines: 5,
                            decoration: InputDecoration(
                              fillColor: Colors.white,
                              filled: true,
                              focusedBorder: UnderlineInputBorder(
                                borderSide: const BorderSide(
                                    color: const Color(0xff0075FF), width: 3.0),
                              ),
                              hintText: "Add note",
                              hintStyle:
                                  TextStyle(fontSize: 14, color: hintText),
                            ),
                            style: TextStyle(fontSize: 16, color: Colors.black),
                            onSaved: (value) {
                              _createCourse.note = value;
                            },
                          ),
                        ),
                        courseId == null
                            ? SizedBox()
                            : FlatButton(
                                onPressed: () async {
                                  final chooseOption = await showDialog(
                                    context: context,
                                    builder: (ctx) => AlertDialog(
                                      title: Text('Are you sure?'),
                                      content: Text(
                                          "All assignments and exams of this course will be lost"),
                                      actions: [
                                        FlatButton(
                                          onPressed: () {
                                            Navigator.of(context).pop(false);
                                          },
                                          child: Text(
                                            "CANCEL",
                                            style: TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.w600,
                                                color: Theme.of(context)
                                                    .primaryColor),
                                          ),
                                        ),
                                        FlatButton(
                                          onPressed: () {
                                            Navigator.of(context).pop(true);
                                          },
                                          child: Text(
                                            "OK",
                                            style: TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.w600,
                                                color: Theme.of(context)
                                                    .primaryColor),
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                  if (chooseOption == true) {
                                    Provider.of<Courses>(context, listen: false)
                                        .deleteCourse(courseId);
                                    Provider.of<Timetables>(context,
                                            listen: false)
                                        .updateWhenCourseDeleted(courseId);
                                    Navigator.of(context).popAndPushNamed(
                                        CourseListScreen.routeName);
                                  } else {
                                    return;
                                  }
                                },
                                child: Center(
                                    child: Text(
                                  'DELETE',
                                  style: TextStyle(
                                    fontSize: 25,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFFC20000),
                                  ),
                                ))),
                      ],
                    ),
                  ),
                ),
              ),
            ),
    );
  }
}
