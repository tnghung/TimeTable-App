// import 'package:timetable/models/daos/timetable_dao.dart';
// import 'package:timetable/models/daos/course_dao.dart';
// import 'package:timetable/models/daos/task_dao.dart';
//
// void main(List<String> args) {
//   var timetableDao = TimetableDao.getInstance();
//   var courseDao = CourseDao.getInstance();
//   var taskDao = TaskDao.getInstance();
//
//   // Create a timetable with default values
//   var timetable = timetableDao.create();
//   print('Created timetable: $timetable');
//
//   // Create a course name Software Engineering
//   var course = courseDao.create();
//   course.name = "Software Engineering";
//   course.date = DateTime.now();
//   course.startTime = 7 * 60 + 30;
//   course.duration = 180;
//   print('Created course: $course');
//
//   // Add course into the timetable
//   courseDao.updateParent(course.id, timetable.id);
//   print('Course parent: ${course.parentId}');
//
//   // Create an assignment
//   var assignment = taskDao.createAssignment();
//   assignment.name = 'PA6';
//   assignment.startDate = DateTime.now();
//   assignment.endDate = DateTime(2022, 01, 01);
//
//   // Add the assignment to the Software Engineer course
//   taskDao.updateParent(assignment.id, course.id);
//
//   print('Created assignment: $assignment');
//   print('Assignment parent: ${assignment.parentId}');
//
//   // Test delete timetable
//   timetableDao.delete(timetable.id);
//   print(timetableDao.getAll());
//   print(courseDao.getAll());
//   print(taskDao.getAll());
// }
