import 'package:flutter/material.dart';
import '../models/exam.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
class Exams with ChangeNotifier {
  List<Exam> _items = [];

  final String authToken;
  final String userId;

  Exams(this.authToken, this.userId, this._items);

  List<Exam> get items {
    return [..._items];
  }


  Future<void> fetchAndSetDataExams() async {
    final url = Uri.parse(
        'https://timetable-app-60033-default-rtdb.firebaseio.com/user/$userId/exams.json?auth=$authToken');
    try {
      final response = await http.get(url);
      // Convert json to flutter data by json.decode()
      final extractedData = json.decode(response.body) as Map<String, dynamic>;
      final List<Exam> loadedExams = [];
      if (extractedData == null) {
        return;
      }
      extractedData.forEach((examId, data) {
        loadedExams.add(Exam(
          examId,
          data['name'],
          DateTime.parse(data['startDate']),
          DateTime.parse(data['endDate']),
          notificationTime: DateTime.parse(data['notificationTime']),
          topic: data['topic'],
          importantLevel: data['importantLevel'],
          state: data['state'],
          note: data['note'],
          color: Color(data['color']),//.withOpacity(1),
          room: data['room'],
          parentId: data['parentId']
        ));
      });
      _items = loadedExams;
      notifyListeners();
    } catch (error) {
      throw error;
    }
  }

  // Make this function is Future to show the indicator when the user add new exam and wait the response
  Future<void> addExam(Exam exam) async {
    final url = Uri.parse(
        'https://timetable-app-60033-default-rtdb.firebaseio.com/user/$userId/exams.json?auth=$authToken');
    try {
      // Define url and kind of data to post in http.post(url, kind data)
      // Convert data to json by json.encode({})
      final response = await http.post(
        url,
        body: json.encode(
          {
            'name': exam.name,
            'startDate': exam.startDate.toIso8601String(),
            'endDate': exam.endDate.toIso8601String(),
            'notificationTime': exam.notificationTime.toIso8601String(),
            'topic': exam.topic,
            'importantLevel': exam.importantLevel,
            'state': exam.state,
            'note': exam.note,
            'room': exam.room,
            'parentId': exam.parentId,
            'color': exam.color.value,
          },
        ),
      );
      // Use async function to wait for post data and get the response => Can get ID from the response
      // ID = json.decode(response.body)['name']
      final newExam = Exam(
          json.decode(response.body)['name'],
          exam.name,
          exam.startDate,
          exam.endDate,
          notificationTime: exam.notificationTime,
          topic: exam.topic,
          importantLevel: exam.importantLevel,
          state: exam.state,
          note: exam.note,
          room: exam.room,
          parentId: exam.parentId,
          color: exam.color,
      );
      debugPrint(newExam.id);
      _items.insert(0, newExam);
      notifyListeners();
    } catch (error) {
      print(error);
      throw error;
    }
  }

  Future<void> updateExam(String id, Exam newExam) async {
    final examIndex = _items.indexWhere((value) => value.id == id);
    if (examIndex >= 0) {
      final url = Uri.parse(
          'https://timetable-app-60033-default-rtdb.firebaseio.com/user/$userId/exams/$id.json?auth=$authToken');
      await http.patch(url,
          body: json.encode({
            'name': newExam.name,
            'startDate': newExam.startDate.toIso8601String(),
            'endDate': newExam.endDate.toIso8601String(),
            'notificationTime': newExam.notificationTime.toIso8601String(),
            'topic': newExam.topic,
            'importantLevel': newExam.importantLevel,
            'state': newExam.state,
            'note': newExam.note,
            'room': newExam.room,
            'parentId': newExam.parentId,
            'color': newExam.color.value,
          }));
      _items[examIndex] = newExam;
      notifyListeners();
    } else {
      return;
    }
  }

  void deleteExam(String id) {
    final url = Uri.parse(
        'https://timetable-app-60033-default-rtdb.firebaseio.com/user/$userId/exams/$id.json?auth=$authToken');
    http.delete(url).then((value) {
      _items.removeWhere((exam) => exam.id == id);
      notifyListeners();
    });
  }

  Exam findById(String id) {
    return _items.firstWhere((exam) => exam.id == id);
  }
}