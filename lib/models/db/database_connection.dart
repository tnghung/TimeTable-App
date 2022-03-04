/// (not implemented) This class defines the interaction with the database
class DatabaseConnection {
  static final DatabaseConnection _db = DatabaseConnection._internal();
  static DatabaseConnection getInstance() {
    return _db;
  }

  DatabaseConnection._internal();

  String _clientId;
  String _userId;

  void setClientId(String clientID) => _clientId = clientID;

  void setUserId(String uid) => _userId = uid;

  /// Generic query to the database
  Map<String, dynamic> query(String q) {}

  String getUserName() {}

  List<Map<String, dynamic>> getTimetables({int limit = 5}) {}

  Map<String, dynamic> getTimetableById(int id) {}

  bool updateTimetable(int id, Map<String, dynamic> change) {}

  void deleteTimetable(int id) {}

  List<Map<String, dynamic>> getCourses({int limit = 5}) {}

  Map<String, dynamic> getCourseById(int id) {}

  List<Map<String, dynamic>> getCoursesFromTimetable(int timetableId) {}

  bool updateCourse(int id, Map<String, dynamic> change) {}

  void deleteCourse(int id) {}

  List<Map<String, dynamic>> getTasks({String type}) {}

  Map<String, dynamic> getTaskById(int id) {}

  List<Map<String, dynamic>> getTasksFromCourse(int courseId) {}

  bool updateTask(int id) {}

  void deleteTask(int id) {}
}

void main() {
  var db = DatabaseConnection.getInstance();
  db.setClientId('123');
}
