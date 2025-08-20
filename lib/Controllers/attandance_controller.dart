import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';

class AttendanceController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Fetches enrolled student IDs for a given course
  Future<Set<String>> fetchEnrolledStudents(String courseId) async {
    final snapshot = await _firestore
        .collection('enrollments')
        .where('courseId', isEqualTo: courseId)
        .get();

    return snapshot.docs.map((doc) => doc['studentId'] as String).toSet();
  }

  /// Marks attendance for valid student IDs on the current date
  Future<void> markAttendance(
      String courseId, List<String> recognizedStudentIds) async {
    final enrolledStudents = await fetchEnrolledStudents(courseId);

    // Filter recognized students by enrolled students only
    final validStudents = recognizedStudentIds
        .where((studentId) => enrolledStudents.contains(studentId))
        .toList();

    if (validStudents.isEmpty) {
      Get.snackbar('Attendance', 'No enrolled students detected');
      return;
    }
    try {
      final todayDateStr = DateTime.now().toIso8601String().substring(0, 10);
      // Attendance structure:
      // attendance/courseId/dates/todayDateStr -> { studentId1: true, studentId2: true, ... }

      final attendanceDocRef = _firestore
          .collection('attendance')
          .doc(courseId)
          .collection('dates')
          .doc(todayDateStr);

      // Prepare attendance map: studentId -> true
      final attendanceMap = {for (var id in validStudents) id: true};

      await attendanceDocRef.set(attendanceMap, SetOptions(merge: true));

      Get.snackbar('Attendance',
          'Marked attendance for ${validStudents.length} students');
    }catch(e){
      Get.snackbar('Error', e.toString());
    }
  }




  Future<List<Map<String, dynamic>>> getAttendance(String courseId, String studentId) async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('attendance')
          .doc(courseId)
          .collection('dates')
          .get();

      // Filter only dates where student is marked present/absent
      List<Map<String, dynamic>> records = [];
      for (var doc in snapshot.docs) {
        final data = doc.data();
        final present = data[studentId] ?? false; // directly check studentId key
        records.add({
          'date': doc.id,
          'present': present,
        });
      }
      return records;
    } catch (e) {
      Get.snackbar("Error",e.toString());
      return [];
    }
  }


}
