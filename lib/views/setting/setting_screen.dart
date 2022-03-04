import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:timetable/constants/colors.dart';
import 'package:timetable/widgets/app_drawer.dart';

class SettingScreen extends StatefulWidget {

  static String routeName = "setting_screen";
  @override
  _SettingScreenState createState() => _SettingScreenState();
}

class _SettingScreenState extends State<SettingScreen> {
  final GlobalKey<ScaffoldState> scaffoldKey = new GlobalKey<ScaffoldState>();
  static const double dropdownHeight = 50;
  static const double dropdownWidth = 200;
  static const labelStyle = TextStyle(color: Colors.black, fontSize: 18);
  String selectedTheme = "Light";
  String selectedDateFormat = "DD/MM/YYYY";
  String selectedTimeFormat = "12h";
  String selectedNotificationFormat = "On";
  
  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    return Scaffold(
      drawer: AppDrawer(),
      appBar: AppBar(
        title: Text("Setting"), //title aof appbar
        backgroundColor: mainColor,
        //background color of appbar
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.only(top: 20.0),
          child: Center(
        child: Column(
        children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text("Appearance", style: labelStyle,),
            Container(
              height: dropdownHeight,
              child: DropdownButtonHideUnderline(
                child: DropdownButton2(
                  buttonHeight: dropdownHeight,
                  itemHeight: dropdownHeight,
                  buttonWidth: dropdownWidth,
                  itemWidth: dropdownWidth,
                  buttonPadding: const EdgeInsets.only(left: 12, right: 12),
                  buttonDecoration: BoxDecoration(
                      border: Border.all(width: 1.0)
                  ),
                  hint: Text(
                    selectedTheme,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.black,
                    ),
                  ),
                  items: [
                    "Light",
                    "Dark"
                  ].map((item) =>
                      DropdownMenuItem<String>(
                        value: item,
                        child: Text(
                          item,
                          style: const TextStyle(
                              fontSize: 14,
                              color: Colors.black
                          ),
                        ),
                      ))
                      .toList(),
                  value: selectedTheme,
                  onChanged: (value) {
                    setState(() {
                      selectedTheme = value as String;
                    });
                  },
                ),
              ),
            ),
          ],
        ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Date format", style: labelStyle,),
              Container(
                height: dropdownHeight,
                child: DropdownButtonHideUnderline(
                  child: DropdownButton2(
                    buttonHeight: dropdownHeight,
                    itemHeight: dropdownHeight,
                    buttonWidth: dropdownWidth,
                    itemWidth: dropdownWidth,
                    buttonPadding: const EdgeInsets.only(left: 12, right: 12),
                    buttonDecoration: BoxDecoration(
                        border: Border.all(width: 1.0)
                    ),
                    hint: Text(
                      selectedDateFormat,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.black,
                      ),
                    ),
                    items: [
                      "DD/MM/YYYY",
                      "MM/DD/YYYY"
                    ].map((item) =>
                        DropdownMenuItem<String>(
                          value: item,
                          child: Text(
                            item,
                            style: const TextStyle(
                                fontSize: 14,
                                color: Colors.black
                            ),
                          ),
                        ))
                        .toList(),
                    value: selectedDateFormat,
                    onChanged: (value) {
                      setState(() {
                        selectedDateFormat = value as String;
                      });
                    },
                  ),
                ),
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Time format", style: labelStyle,),
              Container(
                height: dropdownHeight,
                child: DropdownButtonHideUnderline(
                  child: DropdownButton2(
                    buttonHeight: dropdownHeight,
                    itemHeight: dropdownHeight,
                    buttonWidth: dropdownWidth,
                    itemWidth: dropdownWidth,
                    buttonPadding: const EdgeInsets.only(left: 12, right: 12),
                    buttonDecoration: BoxDecoration(
                        border: Border.all(width: 1.0)
                    ),
                    hint: Text(
                      selectedTimeFormat,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.black,
                      ),
                    ),
                    items: [
                      "12h",
                      "24h"
                    ].map((item) =>
                        DropdownMenuItem<String>(
                          value: item,
                          child: Text(
                            item,
                            style: const TextStyle(
                                fontSize: 14,
                                color: Colors.black
                            ),
                          ),
                        ))
                        .toList(),
                    value: selectedTimeFormat,
                    onChanged: (value) {
                      setState(() {
                        selectedTimeFormat = value as String;
                      });
                    },
                  ),
                ),
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Notification", style: labelStyle,),
              Container(
                height: dropdownHeight,
                child: DropdownButtonHideUnderline(
                  child: DropdownButton2(
                    buttonHeight: dropdownHeight,
                    itemHeight: dropdownHeight,
                    buttonWidth: dropdownWidth,
                    itemWidth: dropdownWidth,
                    buttonPadding: const EdgeInsets.only(left: 12, right: 12),
                    buttonDecoration: BoxDecoration(
                        border: Border.all(width: 1.0)
                    ),
                    hint: Text(
                      selectedNotificationFormat,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.black,
                      ),
                    ),
                    items: [
                      "On",
                      "Off"
                    ].map((item) =>
                        DropdownMenuItem<String>(
                          value: item,
                          child: Text(
                            item,
                            style: const TextStyle(
                                fontSize: 14,
                                color: Colors.black
                            ),
                          ),
                        ))
                        .toList(),
                    value: selectedNotificationFormat,
                    onChanged: (value) {
                      setState(() {
                        selectedNotificationFormat = value as String;
                      });
                    },
                  ),
                ),
              ),
            ],
          ),
          ].map((e) => Container(
        width: width-60,
        height: 90,
        child: e
    )).toList()
    )
    )
        )
      ),
    );
  }
}
