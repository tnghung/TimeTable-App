import 'package:flutter/material.dart';

class Util {
  static Util _util = Util._internal();

  Util._internal();

  static Util getInstance() {
    return _util;
  }

  /// Display an AlertDialog with one OK button
  showAlertDialogOk(BuildContext context, String title, String content) {
    return showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(
          title,
          style: TextStyle(
              fontSize: 25, fontWeight: FontWeight.bold, color: Colors.black),
        ),
        content: Text(content),
        actions: [
          TextButton(
              onPressed: () {
                Navigator.of(context).pop();
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
