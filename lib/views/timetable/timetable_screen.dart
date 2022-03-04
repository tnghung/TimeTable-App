import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:developer';

import 'package:timetable/constants/colors.dart';
import 'package:timetable/views/timetable/timetable_create_screen.dart';
import 'package:timetable/views/timetable/timetable_edit_screen.dart';
import 'package:timetable/widgets/app_drawer.dart';
import 'package:timetable/widgets/calendar_month_view.dart';
import 'package:timetable/widgets/calendar_week_view.dart';
import 'package:timetable/providers/courses.dart';
import 'package:timetable/providers/timetables.dart';
import 'package:timetable/views/timetable/util.dart';

class TimetableScreen extends StatefulWidget {
  static String routeName = "timetable_screen";

  @override
  State<TimetableScreen> createState() => _TimetableScreenState();
}

class _TimetableScreenState extends State<TimetableScreen> {
  static double inputHeight = 30;
  String _selectedValue = '';
  List<String> _items = [];

  bool _isMonthView;
  bool _isInit;
  bool _isFirstBuilt;
  bool _isLoading;
  Timetables _timetables;

  @override
  void initState() {
    log('TimetableScreen: initState');
    _selectedValue = '';
    _items = [];
    _isMonthView = false;
    _isInit = true;
    _isFirstBuilt = true;
    _isLoading = true;
    super.initState();
  }

  @override
  void didChangeDependencies() {
    log('TimetableScreen: didChangeDependencies');
    super.didChangeDependencies();

    if (_isInit) {
      setState(() {
        _isLoading = true;
      });

      Provider.of<Courses>(context).fetchAndSetDataCourses().then((value) {
        Provider.of<Timetables>(context, listen: false).fetch().then((value) {
          setState(() {
            _isLoading = false;
          });
        }).catchError((e) => Util.getInstance()
            .showAlertDialogOk(context, 'Error', 'An error occured'));
      }).catchError((e) => Util.getInstance()
          .showAlertDialogOk(context, 'Error', 'An error occured'));
      _isInit = false;
    }
  }

  @override
  void deactivate() {
    log('TimetableScreen: deactivate');
    super.deactivate();
  }

  @override
  void dispose() {
    log('TimetableScreen: dispose');
    super.dispose();
  }

  /// Get timetable ID from [name]
  String nameToID(String name) {
    return _timetables.items.firstWhere((element) => element.name == name).id;
  }

  @override
  Widget build(BuildContext context) {
    _timetables = Provider.of<Timetables>(context);
    _items = _timetables.items.map((e) => e.name).toList();

    // First time the build method is called
    if (_isFirstBuilt) {
      // Assign _selectedValue with the first value of _items, '' if _items is
      // empty.
      _selectedValue = _items.isEmpty ? '' : _items.first;
      _isFirstBuilt = false;

      // For other time, if somehow _items is updated so that the _selectedValue
      // timetable is deleted, assign _selectedValue with the default first value
      // of _items
    } else if (!_items.isEmpty && !_items.contains(_selectedValue)) {
      _selectedValue = _items.first;
    }
    // Otherwise, leave _selectedValue untouched.
    return Scaffold(
      drawer: AppDrawer(),
      appBar: AppBar(
        title: Text("Timetable"), //title aof appbar
        backgroundColor: mainColor,
        actions: <Widget>[
          IconButton(
            icon: Icon(
              Icons.add,
              color: Colors.white,
            ),
            onPressed: () {
              Navigator.of(context).pushNamed(TimeTableCreateScreen.routeName);
            },
          )
        ],
      ),
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(),
            )
          : Padding(
              padding: const EdgeInsets.only(left: 8, right: 8, top: 10),
              child: _items.isEmpty
                  ? Center(
                      child: Text(
                        'You haven\'t add any timetable yet!',
                        style: TextStyle(fontSize: 20),
                      ),
                    )
                  : Column(
                      children: [
                        Expanded(
                          child: Column(
                            children: [
                              Container(
                                width: MediaQuery.of(context).size.width,
                                height: inputHeight,
                                color: Color(0xFFF1F1F1),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      children: [
                                        Column(
                                          children: [
                                            Container(
                                              width: 80,
                                              child: DropdownButtonHideUnderline(
                                                child: DropdownButton2(
                                                  buttonHeight: inputHeight,
                                                  itemHeight: inputHeight,
                                                  buttonWidth: 60,
                                                  itemWidth: 100,
                                                  buttonPadding:
                                                      const EdgeInsets.only(
                                                          left: 15, right: 5),
                                                  buttonDecoration: BoxDecoration(
                                                    color: Color(0xFFC4C4C4),
                                                  ),
                                                  hint: Text(
                                                    _selectedValue,
                                                    style: TextStyle(
                                                      fontSize: 14,
                                                      color: Colors.black,
                                                    ),
                                                  ),
                                                  items: _items
                                                      .map((item) =>
                                                          DropdownMenuItem<
                                                              String>(
                                                            value: item,
                                                            child: Text(
                                                              item,
                                                              style:
                                                                  const TextStyle(
                                                                      fontSize:
                                                                          14,
                                                                      color: Colors
                                                                          .black),
                                                            ),
                                                          ))
                                                      .toList(),
                                                  value: _selectedValue,
                                                  onChanged: (value) {
                                                    setState(() {
                                                      _selectedValue =
                                                          value as String;
                                                    });
                                                  },
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        IconButton(
                                            onPressed: () {
                                              Navigator.of(context).pushNamed(
                                                  TimeTableEditScreen.routeName,
                                                  arguments:
                                                      nameToID(_selectedValue));
                                            },
                                            icon: Icon(Icons.edit)),
                                      ],
                                    ),
                                    Row(
                                      children: [
                                        GestureDetector(
                                          onTap: () {
                                            setState(() =>
                                                // week calendar widget
                                                {_isMonthView = false});
                                          },
                                          child: Container(
                                              height: inputHeight,
                                              width: 80,
                                              decoration: BoxDecoration(
                                                  color: _isMonthView == false
                                                      ? Colors.blue
                                                      : Colors.grey[300],
                                                  boxShadow: [
                                                    BoxShadow(
                                                        color: Colors.grey[350],
                                                        offset: Offset(2, 5),
                                                        blurRadius: 5.0,
                                                        spreadRadius: 1.0)
                                                  ]),
                                              child: Center(
                                                child: Text(
                                                  "Week",
                                                  style: TextStyle(
                                                      color: Colors.white),
                                                ),
                                              )),
                                        ),
                                        // Month view calendar
                                        GestureDetector(
                                          onTap: () => setState(
                                              () => {_isMonthView = true}),
                                          child: Container(
                                            height: inputHeight,
                                            width: 80,
                                            decoration: BoxDecoration(
                                                color: _isMonthView == true
                                                    ? Colors.blue
                                                    : Colors.grey[300],
                                                boxShadow: [
                                                  BoxShadow(
                                                      color: Colors.grey[350],
                                                      offset: Offset(2, 5),
                                                      blurRadius: 5.0,
                                                      spreadRadius: 1.0)
                                                ]),
                                            child: Center(
                                                child: Text(
                                              "Month",
                                              style: TextStyle(
                                                  color: Colors.white),
                                            )),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ]
                                      .map((e) => (Padding(
                                            padding: EdgeInsets.only(
                                                left: 5, right: 5),
                                            child: e,
                                          )))
                                      .toList(),
                                ),
                              ),
                              Expanded(
                                  child: _isMonthView
                                      ? CalendarMonthView(
                                          nameToID(_selectedValue))
                                      : CalendarWeekView(
                                          nameToID(_selectedValue))),
                            ],
                          ),
                        ),
                      ],
                    ),
            ),
    );
  }
}
