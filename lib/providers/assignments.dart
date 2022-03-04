import 'package:flutter/material.dart';
import '../models/assignment.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
class Assignments with ChangeNotifier {
  List<Assignment> _items = [];

  final String authToken;
  final String userId;

  Assignments(this.authToken, this.userId, this._items);

  List<Assignment> get items {
    return [..._items];
  }


  Future<void> fetchAndSetDataAssignments() async {
    final url = Uri.parse(
        'https://timetable-app-60033-default-rtdb.firebaseio.com/user/$userId/assignments.json?auth=$authToken');
    try {
      final response = await http.get(url);
      // Convert json to flutter data by json.decode()
      final extractedData = json.decode(response.body) as Map<String, dynamic>;
      final List<Assignment> loadedAssignments = [];
      if (extractedData == null) {
        return;
      }
      extractedData.forEach((assignmentId, data) {
        loadedAssignments.add(Assignment(
          assignmentId,
          data['name'],
          DateTime.parse(data['startDate']),
          DateTime.parse(data['endDate']),
          notificationTime: DateTime.parse(data['notificationTime']),
          topic: data['topic'],
          importantLevel: data['importantLevel'],
          state: data['state'],
          note: data['note'],
          progress: data['progress'],
          isGroupProject: data['isGroupProject'],
          color: Color(data['color']),
          parentId: data['parentId'],
        ));
      });
      _items = loadedAssignments;
      notifyListeners();
    } catch (error) {
      throw error;
    }
  }

  // Make this function is Future to show the indicator when the user add new assignment and wait the response
  Future<void> addAssignment(Assignment assignment) async {
    final url = Uri.parse(
        'https://timetable-app-60033-default-rtdb.firebaseio.com/user/$userId/assignments.json?auth=$authToken');
    try {
      // Define url and kind of data to post in http.post(url, kind data)
      // Convert data to json by json.encode({})
      final response = await http.post(
        url,
        body: json.encode(
          {
            'name': assignment.name,
            'startDate': assignment.startDate.toIso8601String(),
            'endDate': assignment.endDate.toIso8601String(),
            'notificationTime': assignment.notificationTime.toIso8601String(),
            'topic': assignment.topic,
            'importantLevel': assignment.importantLevel,
            'state': assignment.state,
            'note': assignment.note,
            'progress': assignment.progress,
            'isGroupProject': assignment.isGroupProject,
            'parentId': assignment.parentId,
            'color': assignment.color.value,
          },
        ),
      );
      // Use async function to wait for post data and get the response => Can get ID from the response
      // ID = json.decode(response.body)['name']
      final newAssignment = Assignment(
          json.decode(response.body)['name'],
          assignment.name,
          assignment.startDate,
          assignment.endDate,
          notificationTime: assignment.notificationTime,
          topic: assignment.topic,
          importantLevel: assignment.importantLevel,
          state: assignment.state,
          note: assignment.note,
          progress: assignment.progress,
          isGroupProject: assignment.isGroupProject,
          parentId: assignment.parentId,
          color: assignment.color,
      );
      debugPrint(newAssignment.id);
      _items.insert(0, newAssignment);
      notifyListeners();
    } catch (error) {
      print(error);
      throw error;
    }
  }

  Future<void> updateAssignment(String id, Assignment newAssignment) async {
    final assignmentIndex = _items.indexWhere((value) => value.id == id);
    if (assignmentIndex >= 0) {
      final url = Uri.parse(
          'https://timetable-app-60033-default-rtdb.firebaseio.com/user/$userId/assignments/$id.json?auth=$authToken');
      await http.patch(url,
          body: json.encode({
            'name': newAssignment.name,
            'startDate': newAssignment.startDate.toIso8601String(),
            'endDate': newAssignment.endDate.toIso8601String(),
            'notificationTime': newAssignment.notificationTime.toIso8601String(),
            'topic': newAssignment.topic,
            'importantLevel': newAssignment.importantLevel,
            'state': newAssignment.state,
            'note': newAssignment.note,
            'progress': newAssignment.progress,
            'isGroupProject': newAssignment.isGroupProject,
            'parentId': newAssignment.parentId,
            'color': newAssignment.color.value,
          }));
      _items[assignmentIndex] = newAssignment;
      notifyListeners();
    } else {
      return;
    }
  }

  void deleteAssignment(String id) {
    final url = Uri.parse(
        'https://timetable-app-60033-default-rtdb.firebaseio.com/user/$userId/assignments/$id.json?auth=$authToken');
    http.delete(url).then((value) {
      _items.removeWhere((assignment) => assignment.id == id);
      notifyListeners();
    });
  }

  Assignment findById(String id) {
    return _items.firstWhere((assignment) => assignment.id == id);
  }
}