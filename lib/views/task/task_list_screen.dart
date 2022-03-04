import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:timetable/constants/colors.dart';
import 'package:timetable/models/assignment.dart';
import 'package:timetable/models/course.dart';
import 'package:timetable/models/task.dart';
import 'package:timetable/providers/assignments.dart';
import 'package:timetable/providers/courses.dart';
import 'package:timetable/providers/exams.dart';
import 'package:timetable/widgets/app_drawer.dart';
import 'package:timetable/widgets/task_tile.dart';

import 'create_task_screen.dart';

class TaskListScreen extends StatefulWidget {
  static String routeName = "task_list_screen";
  @override
  State<StatefulWidget> createState() => _TaskListScreenState();
}

class _TaskListScreenState extends State<TaskListScreen> {
  final GlobalKey<ScaffoldState> scaffoldKey = new GlobalKey<ScaffoldState>();

  var _isInit = true;
  var _isLoading = false;

  @override
  void didChangeDependencies() {
    if(_isInit){
      setState(() {
        _isLoading = true;
      });
      Future.wait([
        Provider.of<Assignments>(context).fetchAndSetDataAssignments(),
        Provider.of<Exams>(context).fetchAndSetDataExams(),
        Provider.of<Courses>(context).fetchAndSetDataCourses(),
      ]).catchError((error) => {}).whenComplete(() => {
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
    final assignments = Provider.of<Assignments>(context).items;
    final exams = Provider.of<Exams>(context).items;
    final List<Task> tasks = [...assignments];
    tasks.addAll([...exams]);
    tasks.sort((a,b) {
      return a.endDate.compareTo(b.endDate);
    });
    assignments.sort((a,b) {
      return a.endDate.compareTo(b.endDate);
    });
    exams.sort((a,b) {
      return a.endDate.compareTo(b.endDate);
    });
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        drawer: AppDrawer(),
        appBar: AppBar(
          title: Text("Tasks"), //title aof appbar
          backgroundColor: mainColor,
          //background color of appbar
          bottom: TabBar(
              tabs: [
                Tab(text: 'Task',
                    icon: Icon(Icons.library_add_check_outlined)),
                Tab(text: 'Assignment',
                    icon: Icon(Icons.check_box_outlined)),
                Tab(text: 'Exam', icon: Icon(Icons.fact_check_outlined)),
              ]
          ),
        ),
        body: TabBarView(
          children: [
            _isLoading ? Center(child: CircularProgressIndicator(),) : Padding(
              padding: EdgeInsets.all(8),
              child: tasks.isEmpty ? Center(child: Text('You not add task yet!', style: TextStyle(fontSize: 20),),) : ListView.builder(
                itemBuilder: (ctx, i) => Column(
                  children: [
                    TaskTile(
                      id: tasks[i].id,
                      name: tasks[i].name,
                      endDate: tasks[i].endDate,
                      state: tasks[i].state,
                      color: tasks[i].color,
                      courseName: tasks[i].parentId == ''
                          ? 'No course selected'
                          : Provider.of<Courses>(context).findById(tasks[i].parentId).name,
                      type: tasks[i].type,
                    ),
                    Divider(),
                  ],
                ),
              itemCount: tasks.length,
              ),
            ),
            _isLoading ? Center(child: CircularProgressIndicator(),) : Padding(
              padding: EdgeInsets.all(8),
              child: assignments.isEmpty ? Center(child: Text('You not add task yet!', style: TextStyle(fontSize: 20),),) : ListView.builder(
                itemBuilder: (ctx, i) => Column(
                  children: [
                    TaskTile(
                      id: assignments[i].id,
                      name: assignments[i].name,
                      endDate: assignments[i].endDate,
                      state: assignments[i].state,
                      color: assignments[i].color,
                      courseName: assignments[i].parentId == ''
                          ? 'No course selected'
                          : Provider.of<Courses>(context).findById(assignments[i].parentId).name,
                      type: assignments[i].type,
                    ),
                    Divider(),
                  ],
                ),
                itemCount: assignments.length,
              ),
            ),
            _isLoading ? Center(child: CircularProgressIndicator(),) : Padding(
              padding: EdgeInsets.all(8),
              child: exams.isEmpty ? Center(child: Text('You not add task yet!', style: TextStyle(fontSize: 20),),) : ListView.builder(
                itemBuilder: (ctx, i) => Column(
                  children: [
                    TaskTile(
                      id: exams[i].id,
                      name: exams[i].name,
                      endDate: exams[i].endDate,
                      state: exams[i].state,
                      color: exams[i].color,
                      courseName: exams[i].parentId == ''
                          ? 'No course selected'
                          : Provider.of<Courses>(context).findById(exams[i].parentId).name,
                      type: exams[i].type,
                    ),
                    Divider(),
                  ],
                ),
                itemCount: exams.length,
              ),
            ),
        ],
        ),
        floatingActionButton: FloatingActionButton(
          child: Icon(Icons.add), //child widget inside this button
          onPressed: (){
            //task to execute when this button is pressed
            Navigator.of(context).pushNamed(
                CreateTaskScreen.routeName,
                arguments: {'taskId': null, 'type': 'assignment'}
            );
          },
        ),
      ),
    );
  }
}
