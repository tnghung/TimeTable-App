import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:timetable/constants/colors.dart';
import 'package:timetable/providers/assignments.dart';
import 'package:timetable/providers/courses.dart';
import 'package:timetable/providers/exams.dart';

import 'create_task_screen.dart';

class TaskScreen extends StatefulWidget {
  static String routeName = "task_screen";

  @override
  _TaskScreenState createState() => _TaskScreenState();
}

class _TaskScreenState extends State<TaskScreen> {
  double marginH = 15;
  double marginV = 5;

  bool _isInit = true;
  bool _isLoading = false;
  String type;
  var task;

  @override
  void didChangeDependencies() {
    if (_isInit) {
      var args = ModalRoute.of(context).settings.arguments as Map<String, dynamic>;
      String id = args['taskId'];
      type = args['type'];
      assert (type == 'assignment' || type == 'exam');

      if (type == 'assignment')
        task = Provider.of<Assignments>(context, listen: false).findById(id);
      else
        task = Provider.of<Exams>(context, listen: false).findById(id);
    }
    _isInit = false;
    super.didChangeDependencies();
  }

  void _deleteTask() async {
    final ok = await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Are you sure?'),
        content: Text(
            "The deletion cannot be restored"),
        actions: [
          FlatButton(
            onPressed: () {
              Navigator.of(context).pop(false);
            },
            child: Text(
              "Cancel",
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).primaryColor
              ),
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
    if (ok) {
      if (type == 'assignment') {
        Provider.of<Assignments>(context, listen: false)
            .deleteAssignment(task.id);
      }
      else {
        Provider.of<Exams>(context, listen: false)
            .deleteExam(task.id);
      }
      Navigator.of(context).pop();
    }
  }

  void _goToEditTask() async {
    final resultTask = await Navigator.of(context).pushNamed(
        CreateTaskScreen.routeName,
        arguments: {'taskId': task.id, 'type': type}
    );
    if (resultTask != null)
      setState(() {
        task = resultTask;
      });
  }

  @override
  Widget build(BuildContext context) {
    String courseName = task.parentId == ''
        ? 'No course selected'
        : 'Course: ' + Provider.of<Courses>(context, listen: false)
            .findById(task.parentId)
            .name;

    TimeOfDay startTime = TimeOfDay(
        hour: task.startDate.hour,
        minute: task.startDate.minute
    );

    TimeOfDay endTime = TimeOfDay(
        hour: task.endDate.hour,
        minute: task.endDate.minute
    );

    return Scaffold(
        backgroundColor: Color(0xfffffcf0),
        appBar: AppBar(
          title: Text(type == 'assignment' ? 'Assignment' : 'Exam'),
          backgroundColor: task.color,
          actions: <Widget>[
            IconButton(
              icon: Icon(Icons.create_rounded, color: Colors.white),
              onPressed: () { _goToEditTask(); },
            ),
            IconButton(
              icon: Icon(Icons.delete, color: Colors.white),
              onPressed: () { _deleteTask(); },
            ),
          ],
        ),
        body: _isLoading
            ? Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                child: Column(
                  children: [
                    // Heading
                    Container(
                      width: double.infinity,
                      height: 180,
                      decoration: BoxDecoration(
                        color: task.color,
                        borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(0),
                            topRight: Radius.circular(0),
                            bottomLeft: Radius.circular(30),
                            bottomRight: Radius.circular(30)
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.5),
                            spreadRadius: 2,
                            blurRadius: 2,
                            offset: Offset(0, 3), // changes position of shadow
                          ),
                        ],
                      ),
                      child: Container(
                        margin: EdgeInsets.symmetric(horizontal: 30, vertical: 30),
                        child: Column(
                          children: [
                            Expanded(
                                child: Text(task.name,
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 36,
                                        fontWeight: FontWeight.bold
                                    )
                                ),
                                flex: 2,
                            ),
                            Expanded(
                                child: Text(courseName,
                                   style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 18,
                                   )
                                ),
                                flex: 1,
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Detail
                    Center(
                      child: Column(
                        children: [
                          // Start date
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
                                      DateFormat("yyyy-MM-dd").format(task.startDate),
                                      style: TextStyle(color: Colors.black),
                                    ),
                                    onPressed: (){}
                                  ),
                                  flex: 12,
                                ),
                                Expanded(
                                  child: ElevatedButton.icon(
                                    style: ButtonStyle(
                                        backgroundColor:
                                          MaterialStateProperty.all(Colors.white)
                                    ),
                                    icon: Icon(Icons.access_time, color: Colors.black,),
                                    label: Text(startTime.format(context),
                                      style: TextStyle(color: Colors.black)
                                    ),
                                    onPressed: (){},
                                  ),
                                  flex: 8,
                                ),
                              ],
                            ),
                          ),

                          // End date
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
                                        DateFormat("yyyy-MM-dd").format(task.endDate),
                                        style: TextStyle(color: Colors.black),
                                      ),
                                      onPressed: (){}
                                  ),
                                  flex: 12,
                                ),
                                Expanded(
                                  child: ElevatedButton.icon(
                                    style: ButtonStyle(
                                        backgroundColor:
                                        MaterialStateProperty.all(Colors.white)
                                    ),
                                    icon: Icon(Icons.access_time, color: Colors.black,),
                                    label: Text(endTime.format(context),
                                        style: TextStyle(color: Colors.black)
                                    ),
                                    onPressed: (){},
                                  ),
                                  flex: 8,
                                ),
                              ],
                            ),
                          ),

                          type == 'assignment' ?
                            // Progress
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
                                      activeColor: task.color,
                                      inactiveColor: task.color,
                                      value: task.progress.toDouble(),
                                      max: 100,
                                      divisions: 20,
                                      onChanged: (double value) {},
                                    ),
                                    flex: 12,
                                  ),
                                  Expanded(
                                    child: Text(
                                      task.progress.toInt().toString() + ' %',
                                      style: TextStyle(fontSize: 18, color: Colors.black),
                                    ),
                                    flex: 8,
                                  ),
                                ],
                              ),
                            ) :
                            // Room
                            Container(
                              margin: EdgeInsets.symmetric(horizontal: marginH, vertical: marginV + 5),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      'Location',
                                      style: TextStyle(fontSize: 18, color: Colors.black),
                                    ),
                                    flex: 8,
                                  ),
                                  Expanded(
                                    child: Text(
                                      task.room,
                                      style: TextStyle(
                                        fontSize: 18,
                                        color: Colors.black,
                                        fontWeight: FontWeight.bold
                                      ),
                                    ),
                                    flex: 20,
                                  ),
                                ],
                              ),
                            ),

                          // Important level
                          Container(
                              margin: EdgeInsets.symmetric(horizontal: marginH, vertical: marginV + 5),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      "Important level",
                                      style: TextStyle(fontSize: 18, color: Colors.black),
                                    ),
                                    flex: 4,
                                  ),
                                  Expanded(
                                    child: Container(
                                      margin: EdgeInsets.symmetric(horizontal: 20),
                                      alignment: Alignment.centerLeft,
                                      child: Container(
                                          alignment: Alignment.center,
                                          width: 40,
                                          height: 40,
                                          child: Text(task.importantLevel.toString(),
                                              style: TextStyle(
                                                  fontSize: 18
                                              )
                                          ),
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            color: importantLevelColor[task.importantLevel],
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.grey.withOpacity(0.5),
                                                spreadRadius: 1,
                                                blurRadius: 1,
                                                offset: Offset(0, 3), // changes position of shadow
                                              ),
                                            ],
                                          )
                                      ),
                                    ),
                                    flex: 6,
                                  )
                                  ,
                                ],
                              )
                          ),

                          // Note
                          Container(
                            width: double.infinity,
                            height: 300,
                            margin: EdgeInsets.symmetric(horizontal: marginH, vertical: marginV + 5),
                            padding: EdgeInsets.symmetric(horizontal: 15, vertical: 15),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(30),
                                  topRight: Radius.circular(30),
                                  bottomLeft: Radius.circular(30),
                                  bottomRight: Radius.circular(30)
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.withOpacity(0.5),
                                  spreadRadius: 2,
                                  blurRadius: 2,
                                  offset: Offset(0, 3), // changes position of shadow
                                ),
                              ],
                            ),
                            child: Text(
                              task.note == '' ? 'No notes added yet' : task.note,
                              style: TextStyle(
                                fontSize: 18,
                                color: task.note == '' ? Colors.grey : Colors.black
                              ),
                            ),
                          ),
                        ],
                      ),
                    )
                  ],
                ),
            )
    );
  }
}