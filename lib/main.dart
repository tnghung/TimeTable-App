import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:timetable/providers/assignments.dart';
import 'package:timetable/providers/auth.dart';
import 'package:timetable/providers/exams.dart';
import 'package:timetable/routes_app/route_management.dart';
import 'package:timetable/views/authentication/sign_in_screen.dart';
import 'package:timetable/providers/courses.dart';
import 'package:timetable/providers/timetables.dart';
import 'package:timetable/views/splash_screen.dart';
import 'package:timetable/views/timetable/timetable_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
        providers: [
          ChangeNotifierProvider(
            create: (ctx) => Auth(),
          ),

          ChangeNotifierProxyProvider<Auth, Assignments>(
            create: (ctx) => Assignments('', '', []),
            update: (ctx, auth, previousAssignments) => Assignments(
              auth.token,
              auth.userId,
              previousAssignments == null ? [] : previousAssignments.items,
            )
          ),
          ChangeNotifierProxyProvider<Auth, Exams>(
              create: (ctx) => Exams('', '', []),
              update: (ctx, auth, previousAssignments) => Exams(
                auth.token,
                auth.userId,
                previousAssignments == null ? [] : previousAssignments.items,
              )
          ),
          ChangeNotifierProxyProvider<Auth, Timetables>(
              create: (context) => Timetables('', '', []),
              update: (context, auth, timetable) =>
                  timetable..updateAuth(auth.token, auth.userId)),
          ChangeNotifierProxyProvider<Auth, Courses>(
            create: (ctx) => Courses('', '', []),
            update: (ctx, auth, course) => course..updateAuth(auth.token, auth.userId)
          ),
        ],
        child: Consumer<Auth>(
          builder: (ctx, auth, _) => MaterialApp(
            title: 'Timetable App',
            theme: ThemeData(
              primarySwatch: Colors.blue,
              visualDensity: VisualDensity.adaptivePlatformDensity,
            ),
            debugShowCheckedModeBanner: false,
            home: auth.isAuth
                ? TimetableScreen()
                : FutureBuilder(
                    future: auth.tryAutoLogin(),
                    builder: (ctx, authResultSnapshot) =>
                        authResultSnapshot.connectionState ==
                                ConnectionState.waiting
                            ? SplashScreen()
                            : SignInScreen(),
                  ),
            routes: routeApp,
          ),
        ));
  }
}
