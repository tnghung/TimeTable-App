import 'package:flutter/cupertino.dart';
import 'package:timetable/views/task/create_task_screen.dart';
import 'package:timetable/views/task/task_screen.dart';
import 'package:timetable/views/timetable/timetable_create_screen.dart';
import 'package:timetable/views/timetable/timetable_edit_screen.dart';
import '../views/splash_screen.dart';
import 'package:timetable/views/authentication/sign_in_screen.dart';
import 'package:timetable/views/authentication/sign_up_screen.dart';
import 'package:timetable/views/course/course_list_screen.dart';
import 'package:timetable/views/course/course_screen.dart';
import 'package:timetable/views/course/create_course_screen.dart';
import 'package:timetable/views/setting/setting_screen.dart';
import 'package:timetable/views/task/task_list_screen.dart';
import 'package:timetable/views/timetable/timetable_screen.dart';

Map<String,Widget Function(BuildContext)> routeApp = {
  SettingScreen.routeName: (context) => SettingScreen(),
  TaskListScreen.routeName: (context) => TaskListScreen(),
  CreateTaskScreen.routeName: (context) => CreateTaskScreen(),
  TaskScreen.routeName: (context) => TaskScreen(),
  CourseListScreen.routeName: (context) => CourseListScreen(),
  SignUpScreen.routeName: (context) => SignUpScreen(),
  TimetableScreen.routeName: (context) => TimetableScreen(),
  SignInScreen.routeName: (context) => SignInScreen(),
  SplashScreen.routeName: (context) => SplashScreen(),
  CourseScreen.routeName: (context) => CourseScreen(),
  CreateCourseScreen.routeName: (context) => CreateCourseScreen(),
  TimeTableCreateScreen.routeName: (context) => TimeTableCreateScreen(),
  TimeTableEditScreen.routeName: (context) => TimeTableEditScreen(),
};