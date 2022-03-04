import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_material_pickers/helpers/show_date_picker.dart';
import 'package:flutter_material_pickers/helpers/show_swatch_picker.dart';
import 'package:flutter_material_pickers/helpers/show_time_picker.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:timetable/constants/colors.dart';
import 'package:timetable/models/assignment.dart';
import 'package:timetable/models/exam.dart';
import 'package:timetable/models/course.dart';
import 'package:timetable/providers/assignments.dart';
import 'package:timetable/providers/courses.dart';
import 'package:timetable/providers/exams.dart';

class CreateTaskScreen extends StatefulWidget {
  static String routeName = "create_task_screen";

  @override
  _CreateTaskScreenState createState() => _CreateTaskScreenState();
}

class _CreateTaskScreenState extends State<CreateTaskScreen> {
  double marginH = 15;
  double marginV = 8;

  var _isInit = true;
  var _isLoading = false;
  final _formKey = new GlobalKey<FormState>();
  String taskId;
  DateTime _startDate;
  DateTime _endDate;
  TimeOfDay _startTime;
  TimeOfDay _endTime;
  List<Course> _allCourses;
  Course currentCourse;
  Color taskColor;
  Map<String, dynamic> _attributes = {
    'id': '',
    'name': '',
    'startDate': '', //DateFormat('yyyy-MM-dd HH:mm').format(DateTime.now()),
    'endDate': '', //DateFormat('yyyy-MM-dd HH:mm').format(DateTime.now()),
    'notificationTime': '', // deprecated
    'topic': '', // deprecated
    'importantLevel': 1,
    'state': false, // deprecated
    'note': '',
    'parentId': '',
    'color': 0,
    'progress': 0.0,
    'isGroupProject': false, // deprecated
    'room': '',
    'type': '',
  };

  void updateDateAttributes() {
    _startDate = DateTime(
      _startDate.year,
      _startDate.month,
      _startDate.day,
      _startTime.hour,
      _startTime.minute,
    );
    _endDate = DateTime(
      _endDate.year,
      _endDate.month,
      _endDate.day,
      _endTime.hour,
      _endTime.minute,
    );
    _attributes['startDate'] = DateFormat('yyyy-MM-dd HH:mm').format(_startDate);
    _attributes['endDate'] = DateFormat('yyyy-MM-dd HH:mm').format(_endDate);
  }

  @override
  void didChangeDependencies() {
    if (_isInit) {
      var args = ModalRoute.of(context).settings.arguments as Map<String, dynamic>;
      taskId = args['taskId'];
      assert (args['type'] == 'assignment' || args['type'] == 'exam');
      _attributes['type'] = args['type'];
      _allCourses = Provider.of<Courses>(context, listen: false).items;
      _allCourses.insert(0, Course('', 'No course selected'));

      if (taskId != null) {
        if (_attributes['type'] == 'assignment') {
          var assignment = Provider.of<Assignments>(context, listen: false).findById(taskId);
          _attributes.addAll(assignment.toMap());
        }
        else {
          var exam = Provider.of<Exams>(context, listen: false).findById(taskId);
          _attributes.addAll(exam.toMap());
        }
        taskColor = Color(_attributes['color']);
        currentCourse = _allCourses.firstWhere((item) => item.id == _attributes['parentId']);
        _startDate = DateTime.parse(_attributes['startDate']);
        _endDate = DateTime.parse(_attributes['endDate']);
      }
      else {
        taskColor = mainColor;
        _attributes['color'] = mainColor.value;
        currentCourse = _allCourses[0];
        _startDate = DateTime.now();
        _endDate = DateTime.now();
      }
      _startTime = TimeOfDay(hour: _startDate.hour, minute: _startDate.minute);
      _endTime = TimeOfDay(hour: _endDate.hour, minute: _endDate.minute);
      if (taskId == null) updateDateAttributes();
    }
    _isInit = false;
    super.didChangeDependencies();
  }

  Future<void> _saveTask() async {
    final isValid = _formKey.currentState.validate();
    if (!isValid) return;
    _formKey.currentState.save();

    updateDateAttributes();
    if (_startDate.isAfter(_endDate)) {
      final snackBar = SnackBar(
          content: const Text('The start date must come before the end date'),
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
      return;
    }

    setState(() { _isLoading = true; });

    _attributes['parentId'] = currentCourse.id;
    var task = _attributes['type'] == 'assignment' ?
      Assignment.fromMap(_attributes) : Exam.fromMap(_attributes);

    if (taskId != null) {
      if (_attributes['type'] == 'assignment') {
        await Provider.of<Assignments>(context, listen: false)
          .updateAssignment(taskId, task);
      }
      else {
        await Provider.of<Exams>(context, listen: false)
            .updateExam(taskId, task);
      }
    }
    else {
      try {
        if (_attributes['type'] == 'assignment') {
          await Provider.of<Assignments>(context, listen: false)
            .addAssignment(task);
        }
        else {
          await Provider.of<Exams>(context, listen: false)
            .addExam(task);
        }
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
    if (taskId == null) // create
      Navigator.of(context).pop();
    else
      Navigator.of(context).pop(task);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xfffffcf0),
      appBar: AppBar(
        title: Text((taskId == null ? 'Create ' : 'Edit ') + 'task'),
        backgroundColor: taskColor,
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.check, color: Colors.white),
            onPressed: () { _saveTask(); },
          )
        ],
      ),
      body: _isLoading
        ? Center(child: CircularProgressIndicator())
        : SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.only(left: 8.0, right: 8.0, top: 50.0),
              child: Center(
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      // Enter name
                      Container(
                        margin: EdgeInsets.symmetric(horizontal: marginH, vertical: marginV),
                        color: Colors.white,
                        child: TextFormField(
                          initialValue: _attributes['name'],
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
                            _attributes['name'] = value;
                          },
                        ),
                      ),

                      // Select course
                      Container(
                        margin: EdgeInsets.symmetric(horizontal: marginH, vertical: marginV),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                "Course",
                                style: TextStyle(fontSize: 18, color: Colors.black),
                              ),
                              flex: 8,
                            ),
                            Expanded(
                              child: Container(
                                padding: EdgeInsets.symmetric(horizontal: 15),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.only(
                                      topLeft: Radius.circular(5),
                                      topRight: Radius.circular(5),
                                      bottomLeft: Radius.circular(5),
                                      bottomRight: Radius.circular(5)
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.grey.withOpacity(0.5),
                                      spreadRadius: 1,
                                      blurRadius: 1,
                                      offset: Offset(0, 3), // changes position of shadow
                                    ),
                                  ],
                                ),
                                child: DropdownButton<Course>(
                                  isExpanded: true,
                                  value: currentCourse,
                                  icon: const Icon(Icons.arrow_drop_down),
                                  elevation: 16,
                                  style: const TextStyle(fontSize: 16, color: Colors.black),
                                  underline: Container(
                                    height: 2,
                                    color: Colors.white,
                                  ),
                                  onChanged: (Course newValue) {
                                    setState(() {
                                      currentCourse = newValue;
                                    });
                                  },
                                  items: _allCourses
                                      .map<DropdownMenuItem<Course>>((Course value) {
                                    return DropdownMenuItem<Course>(
                                      value: value,
                                      child: Text(value.name),
                                    );
                                  }).toList(),
                                ),
                              ),

                              flex: 20,
                            ),
                          ],
                        )
                      ),

                      // Select type
                      Container(
                          margin: EdgeInsets.symmetric(horizontal: marginH, vertical: marginV),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  "Type",
                                  style: TextStyle(fontSize: 18, color: Colors.black),
                                ),
                                flex: 8,
                              ),
                              Expanded(
                                child: Container(
                                  padding: EdgeInsets.symmetric(horizontal: 15),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.only(
                                        topLeft: Radius.circular(5),
                                        topRight: Radius.circular(5),
                                        bottomLeft: Radius.circular(5),
                                        bottomRight: Radius.circular(5)
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.grey.withOpacity(0.5),
                                        spreadRadius: 1,
                                        blurRadius: 1,
                                        offset: Offset(0, 3), // changes position of shadow
                                      ),
                                    ],
                                  ),
                                  child: DropdownButton<String>(
                                    isExpanded: true,
                                    value: _attributes['type'],
                                    icon: const Icon(Icons.arrow_drop_down),
                                    elevation: 16,
                                    style: const TextStyle(fontSize: 16, color: Colors.black),
                                    underline: Container(
                                      height: 2,
                                      color: Colors.white,
                                    ),
                                    onChanged: taskId != null ? null : (String newValue) {
                                      setState(() {
                                        _attributes['type'] = newValue;
                                      });
                                    },
                                    items: (taskId != null ? <String>[_attributes['type']] : <String>['assignment', 'exam'])
                                        .map<DropdownMenuItem<String>>((String value) {
                                      return DropdownMenuItem<String>(
                                        value: value,
                                        child: Text(value),
                                      );
                                    }).toList(),
                                  ),
                                ),
                                flex: 20,
                              ),
                            ],
                          )
                      ),

                      // Pick start date
                      Container(
                        margin: EdgeInsets.symmetric(horizontal: marginH, vertical: marginV),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                "Start date",
                                style: TextStyle(fontSize: 18, color: Colors.black),
                              ),
                              flex: 8,
                            ),
                            Expanded(
                              child: ElevatedButton.icon(
                                style: ButtonStyle(
                                  backgroundColor:
                                  MaterialStateProperty.all(Colors.white)),
                                icon: Icon(Icons.calendar_today_outlined,
                                  color: Colors.black),
                                label: Text(
                                  DateFormat("yyyy-MM-dd").format(_startDate),
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
                                    selectedDate: _startDate,
                                    onChanged: (value) => setState(() {
                                      _startDate = value;
                                      updateDateAttributes();
                                    }),
                                  );
                                },
                              ),
                              flex: 12,
                            ),
                            Expanded(
                              child: ElevatedButton.icon(
                                style: ButtonStyle(
                                  backgroundColor:
                                    MaterialStateProperty.all(
                                        Colors.white)),
                                icon: Icon(Icons.access_time, color: Colors.black),
                                label: Text(_startTime.format(context),
                                  style: TextStyle(color: Colors.black),
                                ),
                                onPressed: () {
                                  showMaterialTimePicker(
                                    context: context,
                                    selectedTime: _startTime,
                                    onChanged: (value) => setState(() {
                                      _startTime = value;
                                      updateDateAttributes();
                                    }),
                                  );
                                },
                              ),
                              flex: 8,
                            ),
                          ],
                        ),
                      ),

                      // Pick end date
                      Container(
                        margin: EdgeInsets.symmetric(horizontal: marginH, vertical: marginV),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                "End date",
                                style: TextStyle(fontSize: 18, color: Colors.black),
                              ),
                              flex: 8,
                            ),
                            Expanded(
                              child: ElevatedButton.icon(
                                style: ButtonStyle(
                                    backgroundColor:
                                    MaterialStateProperty.all(Colors.white)),
                                icon: Icon(Icons.calendar_today_outlined,
                                    color: Colors.black),
                                label: Text(
                                  DateFormat("yyyy-MM-dd").format(_endDate),
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
                                    selectedDate: _endDate,
                                    onChanged: (value) => setState(() {
                                      _endDate = value;
                                      updateDateAttributes();
                                    }),
                                  );
                                },
                              ),
                              flex: 12,
                            ),
                            Expanded(
                              child: ElevatedButton.icon(
                                style: ButtonStyle(
                                    backgroundColor:
                                    MaterialStateProperty.all(
                                        Colors.white)),
                                icon: Icon(Icons.access_time, color: Colors.black,),
                                label: Text(_endTime.format(context),
                                  style: TextStyle(color: Colors.black),
                                ),
                                onPressed: () {
                                  showMaterialTimePicker(
                                    context: context,
                                    selectedTime: _endTime,
                                    onChanged: (value) => setState(() {
                                      _endTime = value;
                                      updateDateAttributes();
                                    }),
                                  );
                                },
                              ),
                              flex: 8,
                            ),
                          ],
                        ),
                      ),

                      // Select important level, color
                      Container(
                        margin: EdgeInsets.symmetric(horizontal: marginH, vertical: marginV + 5),
                        child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  "Important level",
                                  style: TextStyle(fontSize: 18, color: Colors.black),
                                ),
                                flex: 8,
                              ),
                              Expanded(
                                child: Container(
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.grey.withOpacity(0.5),
                                        spreadRadius: 1,
                                        blurRadius: 1,
                                        offset: Offset(0, 3), // changes position of shadow
                                      ),
                                    ],
                                  ),
                                  child: DropdownButton<int>(
                                    icon: SizedBox(),
                                    value: _attributes['importantLevel'],
                                    elevation: 16,
                                    style: const TextStyle(fontSize: 16, color: Colors.black),
                                    underline: SizedBox(),
                                    onChanged: (int newValue) {
                                      setState(() {
                                        _attributes['importantLevel'] = newValue;
                                      });
                                    },
                                    items: <int>[1, 2, 3, 4, 5]
                                        .map<DropdownMenuItem<int>>((int value) {
                                            return DropdownMenuItem<int>(
                                        value: value,
                                        child: Container(
                                          alignment: Alignment.center,
                                          width: 32,
                                          height: 32,
                                          child: Text(value.toString()),
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            color: importantLevelColor[value],
                                          )
                                        ),
                                      );
                                    }).toList(),
                                  ),
                                ),
                                flex: 3,
                              ),
                              Expanded(
                                child: Container(
                                  margin: EdgeInsets.symmetric(horizontal: 20),
                                  child: Row(
                                    children: [
                                      Text(
                                        "Color",
                                        style: TextStyle(fontSize: 18, color: Colors.black),
                                      ),
                                      SizedBox(
                                        height: 36,
                                        child: ElevatedButton(
                                          style: ElevatedButton.styleFrom(
                                            primary: taskColor,
                                            shape: CircleBorder(), // background
                                          ),
                                          onPressed: () {
                                            showMaterialSwatchPicker(
                                              context: context,
                                              selectedColor: Colors.blue,
                                              onChanged: (value) => setState(() {
                                                taskColor = value;
                                                _attributes['color'] = taskColor.value;
                                              }),
                                            );
                                          },
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                flex: 9,
                              )
                            ],
                        )
                      ),

                      _attributes['type'] == 'assignment' ?
                        // Adjust assignment progress
                      Container(
                        margin: EdgeInsets.symmetric(horizontal: marginH, vertical: marginV + 5),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                "Progress",
                                style: TextStyle(fontSize: 18, color: Colors.black),
                              ),
                              flex: 8,
                            ),
                            Expanded(
                              child: Slider(
                                activeColor: taskColor,
                                inactiveColor: taskColor,
                                value: _attributes['progress'].toDouble(),
                                max: 100,
                                divisions: 20,
                                onChanged: (double value) {
                                  setState(() {
                                    _attributes['progress'] = value.toInt();
                                  });
                                },
                              ),
                              flex: 12,
                            ),
                            Expanded(
                              child: Text(
                                _attributes['progress'].toString() + ' %',
                                style: TextStyle(fontSize: 18, color: Colors.black),
                              ),
                              flex: 8,
                            ),
                          ],
                        ),
                      ) :
                        // Select exam location
                        Container(
                          margin: EdgeInsets.symmetric(horizontal: marginH, vertical: marginV + 5),
                          padding: EdgeInsets.symmetric(vertical: 5),
                          color: Colors.white,
                          child: TextFormField(
                            initialValue: _attributes['room'],
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
                              if (_attributes['type'] == 'exam' && value.isEmpty) {
                                return "Please enter the location!";
                              }
                              return null;
                            },
                            onSaved: (value) {
                              _attributes['room'] = value;
                            },
                          ),
                        ),

                      // Add note
                      Container(
                        margin: EdgeInsets.symmetric(horizontal: marginH, vertical: marginV + 5),
                        child: TextFormField(
                          initialValue: _attributes['note'],
                          keyboardType: TextInputType.multiline,
                          textInputAction: TextInputAction.newline,
                          maxLines: 8,
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
                            _attributes['note'] = value;
                          },
                        ),
                      ),
                    ],
                  )
                ),
              )
            )
        )
    );
  }
}
