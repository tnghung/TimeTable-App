import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:timetable/constants/colors.dart';
import 'package:timetable/providers/auth.dart';
import 'package:timetable/views/authentication/sign_in_screen.dart';
import 'package:timetable/views/course/course_list_screen.dart';
import 'package:timetable/views/setting/setting_screen.dart';
import 'package:timetable/views/task/task_list_screen.dart';
import 'package:timetable/views/timetable/timetable_screen.dart';


class AppDrawer extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
      // Important: Remove any padding from the ListView.
      padding: EdgeInsets.zero,
      children: [
        Container(
          height: 250,
          child:DrawerHeader(
            decoration: BoxDecoration(
              color: lightblack,
            ),
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  CircleAvatar(
                    backgroundImage: AssetImage("assets/logo.png"),
                    radius: 50,
                    backgroundColor: lightblack,
                  ),
                  SizedBox(height: 25),
                  Text("Wellcome to Study Life", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 22)),
                ]
            ),
          ),
        ),

        ListTile(
          leading: Icon(Icons.calendar_today, color: lightblack,),
          title: const Text('Calendar'),
          onTap: () {
            Navigator.popAndPushNamed(context, TimetableScreen.routeName);
          },
        ),
        ListTile(
          leading: Icon(Icons.school_outlined, color: lightblack,),
          title: const Text('Courses'),
          onTap: () {
            
            Navigator.popAndPushNamed(context, CourseListScreen.routeName);
          },
        ),
        ListTile(
          leading: Icon(Icons.task_outlined, color: lightblack,),
          title: const Text('Tasks'),
          onTap: () {
            // Update the state of the app
            // ...
            // Then close the drawer
            Navigator.pop(context);
            Navigator.pushReplacementNamed(context, TaskListScreen.routeName);
          },
        ),
        ListTile(
          leading: Icon(Icons.settings, color: lightblack,),
          title: const Text('Setting'),
          onTap: () {
            // Update the state of the app
            // ...
            // Then close the drawer
            Navigator.popAndPushNamed(context, SettingScreen.routeName);
          },
        ),
        ListTile(
          leading: Icon(Icons.logout, color: lightblack,),
          title: const Text('Logout'),
          onTap: () {
            Navigator.of(context).pop();
            Navigator.pushReplacementNamed(context, SignInScreen.routeName);
            Provider.of<Auth>(context, listen: false).logOut();
          },
        ),
      ],
    ));
  }
}
