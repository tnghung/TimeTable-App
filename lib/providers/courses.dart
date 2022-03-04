import 'package:flutter/material.dart';
import '../models/course.dart';
import 'dart:developer';
import 'dart:convert';
import 'package:http/http.dart' as http;
class Courses with ChangeNotifier {
  List<Course> _items = [];

  String projectUrl = 'https://timetable-app-60033-default-rtdb.firebaseio.com';
  String authToken;
  String userId;
  DateTime previousGetRequestTime;

  Courses(this.authToken, this.userId, this._items);

  List<Course> get items {
    return [..._items];
  }
  /// Return a URL that references this path. This method assumes that you are in
  /// /user/$userId
  String _makeRef(String path) {
    return '$projectUrl/user/$userId/$path?auth=$authToken';
  }
  /// Return true if authToken and userId is not empty.
  bool _okToGo() {
    return authToken != null &&
        authToken != '' &&
        userId != null &&
        userId != '';
  }
  /// Update user authentication. If [newAuthToken] and [newUserId] are not
  /// changed, then do nothing. Otherwise, the previously-fetched timetable data
  /// will be removed to prepare for new user.
  void updateAuth(String newAuthToken, String newUserId) {
    log('Timetables: Updating new authentication ($newAuthToken, $newUserId)');
    if (newAuthToken == authToken && newUserId == userId) {
      return;
    }
    previousGetRequestTime = null;
    _items = [];
    authToken = newAuthToken;
    userId = newUserId;
  }

  Future<void> fetchAndSetDataCourses() async {
    // This tell Firebase that we want to filter by creator ID and only where it's equal to the userId
    if (!_okToGo()) {
      return;
    }
    final url = Uri.parse(_makeRef('courses.json'));

    try {
      var response;
      if (previousGetRequestTime == null) {
        response = await http.get(url);
      } else {
        response = await http.get(url, headers: {
          'If-Modified-Since': previousGetRequestTime.toIso8601String()
        });
      }
      previousGetRequestTime = DateTime.now();
      if (response.statusCode == 304) {
        log('Courses: No change since $previousGetRequestTime');
        return;
      }
      // Convert json to flutter data by json.decode()
      final extractedData = json.decode(response.body) as Map<String, dynamic>;
      final List<Course> loadedCourses = [];
      if (extractedData == null) {
        return;
      }
      extractedData.forEach((courseId, courseData) {
        loadedCourses.add(Course(
          courseId,
          courseData['name'],
          date: DateTime.parse(courseData['date']),
          startTime: courseData['startTime'],
          duration: courseData['duration'],
          lecturerName: courseData['lecturerName'],
          room: courseData['room'],
          color: Color(courseData['color']).withOpacity(1),
          note: courseData['note'],
          taskIds: courseData['taskIds'].split(", ")
        ));
      });
      _items = loadedCourses;
      notifyListeners();
    } catch (error) {
      throw error;
    }
  }

  // Make this function is Future to show the indicator when the user add new course and wait the response
  Future<void> addCourse(Course course) async {
    final url = Uri.parse(_makeRef('courses.json'));
    try {
      // Define url and kind of data to post in http.post(url, kind data)
      // Convert data to json by json.encode({})
      final response = await http.post(
        url,
        body: json.encode(
          {
            'name': course.name,
            'duration': course.duration,
            'color': course.color.value,
            'date': course.date.toIso8601String(),
            'note': course.note,
            'lecturerName': course.lecturerName,
            'room': course.room,
            'startTime': course.startTime,
            // Xoa t dap cm, nay de xac dinh ID roi load len UI
            'creatorId': userId,
            'taskIds': course.taskIds.join(", "),
          },
        ),
      );
      // Use async function to wait for post data and get the response => Can get ID from the response
      // ID = json.decode(response.body)['name']
      final newCourse = Course(
        json.decode(response.body)['name'],
        course.name,
        date: course.date,
        startTime: course.startTime,
        duration: course.duration,
        color: course.color,
        room: course.room,
        lecturerName: course.lecturerName,
        note: course.note,
        taskIds: course.taskIds
      );
      debugPrint(newCourse.id);
      _items.insert(0, newCourse);
      notifyListeners();
    } catch (error) {
      print(error);
      throw error;
    }
  }

  Future<void> updateCourse(String id, Course newCourse) async {
    final courseIndex = _items.indexWhere((value) => value.id == id);
    if (courseIndex >= 0) {
      final url = Uri.parse(_makeRef('courses/$id.json'));
      await http.patch(url,
          body: json.encode({
            'name': newCourse.name,
            'duration': newCourse.duration,
            'color': newCourse.color.value,
            'date': newCourse.date.toIso8601String(),
            'note': newCourse.note,
            'lecturer': newCourse.lecturerName,
            'room': newCourse.room,
            'startTime': newCourse.startTime,
            "taskIds": newCourse.taskIds.join(", ")
          }));
      _items[courseIndex] = newCourse;
      notifyListeners();
    } else {
      return;
    }
  }

  void deleteCourse(String id) async {
    var idx = items.indexWhere((element) => element.id == id);
    if (idx < 0) {
      return;
    }

    try {
    final url = Uri.parse(_makeRef('courses/$id.json'));
    await http.delete(url).then((value) {
      _items.removeWhere((course) => course.id == id);
      notifyListeners();
    });
    items.removeAt(idx);
    notifyListeners();
    } catch (e) {
      throw e;
    }
  }

  Course findById(String id) {
    return _items.firstWhere((value) => value.id == id);
  }
}