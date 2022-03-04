import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:developer';

import 'package:timetable/models/timetable.dart';
import 'package:timetable/widgets/course_tile.dart';
import 'package:timetable/providers/courses.dart';
import 'package:timetable/providers/timetables.dart';
import 'package:timetable/views/timetable/util.dart';

class TimeTableEditScreen extends StatefulWidget {
  static const routeName = 'timetable-edit-screen';

  @override
  State<TimeTableEditScreen> createState() => _TimeTableEditScreenState();
}

class _TimeTableEditScreenState extends State<TimeTableEditScreen> {
  final _formKey = new GlobalKey<FormState>();

  bool _isInit;
  Timetable _currentTimetable;
  String _currentName;
  List<String> _selectedCourses;

  @override
  void initState() {
    log('TimeTableEditScreen: initState');
    super.initState();
    _isInit = true;
    _currentTimetable = null;
    _currentName = '';
    _selectedCourses = [];
  }

  @override
  void didChangeDependencies() {
    log('TimeTableEditScreen: didChangeDependencies');
    if (_isInit) {
      _currentTimetable = Provider.of<Timetables>(context)
          .findById(ModalRoute.of(context).settings.arguments as String);
      _currentName = _currentTimetable.name;
      _selectedCourses = _currentTimetable.courseIds;
      _isInit = false;
    }
    super.didChangeDependencies();
  }

  void _editTimeTable() {
    log('TimeTableEditScreen: _editTimeTable');
    final isValid = _formKey.currentState.validate();
    if (!isValid) {
      return;
    }
    _formKey.currentState.save();
    Timetable newTimetable = Timetable('', _currentName);
    newTimetable.courseIds = _selectedCourses;
    Provider.of<Timetables>(context, listen: false)
        .updateTimetable(_currentTimetable.id, newTimetable)
        .then((_) {
      Navigator.of(context).pop();
    }).catchError((e) => Util.getInstance()
            .showAlertDialogOk(context, 'Error', 'An error occured'));
  }

  void _deleteTimetable() {
    log('TimeTableEditScreen: _deleteTimetable');
    Provider.of<Timetables>(context, listen: false)
        .deleteTimetable(_currentTimetable.id)
        .then((_) {
      Navigator.of(context).pop();
    }).catchError((e) => Util.getInstance()
            .showAlertDialogOk(context, 'Error', 'An error occured'));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Color(0xfffffcf0),
        appBar: AppBar(
          title: Text(
            "Edit timetable",
            style: TextStyle(color: Colors.white),
          ),
          actions: <Widget>[
            IconButton(
              icon: Icon(
                Icons.check,
                color: Colors.white,
              ),
              onPressed: () {
                _editTimeTable();
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
                      initialValue: _currentName,
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
                        }
                        return null;
                      },
                      onSaved: (value) {
                        // Save the value when user type
                        setState(() {
                          _currentName = value;
                        });
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
                  Divider(),
                  SizedBox(
                    height: 40,
                  ),
                  Center(
                    child: FlatButton(
                      onPressed: () {
                        _deleteTimetable();
                      },
                      child: Text(
                        "DELETE",
                        style: TextStyle(
                          fontSize: 25,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFC20000),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ));
  }
}
