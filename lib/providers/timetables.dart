import 'package:timetable/models/timetable.dart';

import 'dart:convert';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class Timetables with ChangeNotifier {
  List<Timetable> _items = [];

  String projectUrl = 'https://timetable-app-60033-default-rtdb.firebaseio.com';
  String authToken;
  String userId;
  DateTime previousGetRequestTime;

  Timetables(this.authToken, this.userId, this._items) {
    log('Timetables: Constructor with auth token $authToken, user id $userId');
  }

  List<Timetable> get items => _items;

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

  /// Check if the data has changed. If it is, download the changes, apply the
  /// changes and notify listeners.
  Future<void> fetch() async {
    log('Timetables: Fetching timetable data...');
    if (!_okToGo()) {
      return;
    }
    final url = Uri.parse(_makeRef('timetables.json'));

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
        log('Timetables: No change since $previousGetRequestTime');
        return;
      }
      final jsonData = json.decode(response.body) as Map<String, dynamic>;
      if (jsonData == null) {
        return;
      }
      final List<Timetable> loadedTimetables = [];
      jsonData.forEach((id, body) {
        loadedTimetables.add(Timetable.fromMap(id, body));
      });
      _items = loadedTimetables;
      log('Timetables: Fetched successfully.');
      notifyListeners();
    } catch (e) {
      throw e;
    }
  }

  /// Add a new timetable.
  ///
  /// This method posts a timetable with info stored in [t] to the database,
  /// update [t] with the ID returned by the database, and then add [t] to items.
  Future<void> addTimetable(Timetable t) async {
    log('Timetables: Adding new timetable...');
    final url = Uri.parse(_makeRef('timetables.json'));

    try {
      final response = await http.post(url, body: json.encode(t.bodyToMap()));
      final newTimetable = Timetable(json.decode(response.body)['name'], t.name,
          startDate: t.startDate, endDate: t.endDate);
      newTimetable.courseIds = t.courseIds;
      _items.insert(0, newTimetable);
      log('Timetables: Added successfully. New ID: ${newTimetable.id}');
      notifyListeners();
    } catch (e) {
      throw e;
    }
  }

  /// Overwrite the info of the timetable with ID [id] by [newTimetable].
  Future<void> updateTimetable(String id, Timetable newTimetable) async {
    log('Timetables: Updating timetable $id...');
    var idx = items.indexWhere((element) => element.id == id);
    if (idx < 0) {
      return;
    }

    final url = Uri.parse(_makeRef('timetables/$id.json'));
    try {
      await http.patch(url, body: json.encode(newTimetable.bodyToMap()));
      items[idx].name = newTimetable.name;
      items[idx].startDate = newTimetable.startDate;
      items[idx].endDate = newTimetable.endDate;
      items[idx].courseIds = newTimetable.courseIds;
      log('Timetables: Updated successfully.');
      notifyListeners();
    } catch (e) {
      throw e;
    }
  }

  /// Remove a timetable.
  Future<void> deleteTimetable(String id) async {
    log('Timetables: Deleting timetable $id...');
    var idx = items.indexWhere((element) => element.id == id);
    if (idx < 0) {
      return;
    }

    try {
      final url = Uri.parse(_makeRef('timetables/$id.json'));
      await http.delete(url);
      items.removeAt(idx);
      log('Timetables: Deleted successfully.');
      notifyListeners();
    } catch (e) {
      throw e;
    }
  }

  Timetable findById(String id) {
    return _items.firstWhere((element) => element.id == id);
  }

  /// Remove traces of [courseId] from whatever timetable containing it.
  Future<void> updateWhenCourseDeleted(String courseId) async {
    log('Timetables: Removing course $courseId from timetables...');
    for (final item in items) {
      int idx = item.courseIds.indexWhere((element) => element == courseId);
      if (idx != -1) {
        item.courseIds.removeAt(idx);
        final url = Uri.parse(_makeRef('timetables/${item.id}.json'));
        try {
          await http.patch(url,
              body: json.encode({'courseIds': item.courseIds}));
          log('Timetables: Done removing for timetable ${item.name}.');
        } catch (e) {
          throw e;
        }
      }
    }
    notifyListeners();
  }
}
