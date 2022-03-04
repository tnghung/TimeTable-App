import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:developer';

import 'package:timetable/widgets/course_tile.dart';
import 'package:timetable/models/timetable.dart';
import 'package:timetable/providers/timetables.dart';
import 'package:timetable/providers/courses.dart';
import 'package:timetable/views/timetable/util.dart';

class TimeTableCreateScreen extends StatefulWidget {
  static const routeName = 'timetable-create-screen';

  @override
  State<TimeTableCreateScreen> createState() => _TimeTableCreateScreenState();
}

class _TimeTableCreateScreenState extends State<TimeTableCreateScreen> {
  final GlobalKey<FormState> _formKey = new GlobalKey<FormState>();

  String _name;
  List<String> _selectedCourses = [];

  void _createTimeTable() {
    log('TimetableCreateScreen: _createTimeTable');
    final isValid = _formKey.currentState.validate();
    if (!isValid) {
      return;
    }
    _formKey.currentState.save();

    Timetable t = Timetable('', _name);
    t.courseIds = _selectedCourses;
    Provider.of<Timetables>(context, listen: false)
        .addTimetable(t)
        .then((value) {
      Navigator.of(context).pop();
    }).catchError((e) => Util.getInstance()
            .showAlertDialogOk(context, 'Error', 'An error occured'));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: Text(
            "New Timetable",
            style: TextStyle(color: Colors.white),
          ),
          actions: <Widget>[
            IconButton(
              icon: Icon(
                Icons.check,
                color: Colors.white,
              ),
              onPressed: () {
                _createTimeTable();
              },
            )
          ],
        ),
        body: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Padding(
              padding: EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    color: Colors.white,
                    margin: EdgeInsets.only(right: 50),
                    child: TextFormField(
                      keyboardType: TextInputType.text,
                      decoration: InputDecoration(
                        fillColor: Colors.white,
                        focusedBorder: UnderlineInputBorder(
                          borderSide: const BorderSide(
                              color: const Color(0xff0075FF), width: 3.0),
                        ),
                        hintText: "Title",
                        hintStyle: TextStyle(fontSize: 18, color: Colors.black),
                      ),
                      style: TextStyle(fontSize: 18, color: Colors.black),
                      validator: (value) {
                        if (value.isEmpty) {
                          return "Please enter the title!";
                        } else if (Provider.of<Timetables>(context,
                                listen: false)
                            .items
                            .map((e) => e.name)
                            .toList()
                            .contains(value)) {
                          return "\"$value\" already existed. Please choose another name.";
                        }
                        return null;
                      },
                      onSaved: (value) {
                        // Save the value when user type
                        print('TextFormField onSaved');
                        _name = value;
                      },
                    ),
                  ),
                  SizedBox(
                    height: 40,
                  ),
                  Text(
                    "Pick some courses",
                    style: TextStyle(fontSize: 15),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Divider(),
                  ...Provider.of<Courses>(context).items.map((elem) {
                    return Row(
                      children: [
                        Expanded(
                          child: CourseTile(
                            id: elem.id,
                            name: elem.name,
                            color: elem.color,
                            room: elem.room,
                            date: DateTime.now(),
                            startTime: elem.startTime,
                            duration: elem.duration,
                          ),
                        ),
                        SizedBox(width: 10),
                        Transform.scale(
                          scale: 1.5,
                          child: Checkbox(
                            side: BorderSide(color: Colors.blue),
                            value: _selectedCourses.contains(elem.id),
                            onChanged: (value) {
                              setState(() {
                                if (value == true) {
                                  _selectedCourses.add(elem.id);
                                } else {
                                  _selectedCourses.removeWhere(
                                      (element) => element == elem.id);
                                }
                              });
                            },
                          ),
                        )
                      ],
                    );
                  }).toList(),
                ],
              ),
            ),
          ),
        ));
  }
}
