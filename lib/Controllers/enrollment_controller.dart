import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';

class EnrollmentController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String enrollmentCollection = 'enrollments';

  var isLoading = false.obs;
  var availableCourses = <Map<String, dynamic>>[].obs;
  var enrolledCourses = <Map<String, dynamic>>[].obs;

  /// Fetch available courses that the student is NOT already enrolled in
  Future<void> fetchAvailableCourses(String studentId) async {
    try {
      isLoading.value = true;

      // Get already enrolled course IDs for this student
      final enrolledSnapshot = await _firestore
          .collection(enrollmentCollection)
          .where('studentId', isEqualTo: studentId)
          .get();

      final enrolledCourseIds = enrolledSnapshot.docs
          .map((doc) => doc.data()['courseId'] ?? '')
          .where((id) => id.isNotEmpty)
          .toSet();

      // Get all courses
      final coursesSnapshot = await _firestore.collection('Course').get();

      // Filter only courses not enrolled in
      availableCourses.value = coursesSnapshot.docs
          .where((doc) => !enrolledCourseIds.contains(doc.id))
          .map((doc) {
        final data = doc.data();
        return {
          'id': doc.id,
          'name': data['name'] ?? 'Untitled Course',
          'teacherId': data['teacherId'] ?? '',
          'credithour':data['credithour']?? '',
        };
      })
          .toList();
    } catch (e) {
      Get.snackbar('Error', e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  /// Enroll student in a course
  Future<void> enrollStudent({
    required String studentId,
    required String courseId,
    required String teacherId,
  }) async {
    try {
      await _firestore.collection(enrollmentCollection).add({
        'studentId': studentId,
        'courseId': courseId,
        'teacherId': teacherId,
        'timestamp': FieldValue.serverTimestamp(),
      });

      Get.snackbar('Success', 'You have enrolled in the course');

      // Refresh lists
      await fetchAvailableCourses(studentId);   // Already there
      await getEnrolledCourses(studentId);      // Add this line to refresh enrolled courses
    } catch (e) {
      Get.snackbar('Error', 'Could not enroll: $e');
    }
  }

  Future<void> getEnrolledCourses(String studentId) async {
    try {
      isLoading.value = true;
      enrolledCourses.clear();

      // Get all enrollments for this student
      final enrollmentSnap = await _firestore
          .collection(enrollmentCollection)
          .where('studentId', isEqualTo: studentId)
          .get();

      if (enrollmentSnap.docs.isEmpty) {
        enrolledCourses.value = [];
        return;
      }

      // Extract course IDs
      final courseIds = enrollmentSnap.docs
          .map((doc) => doc.data()['courseId'] ?? '')
          .where((id) => id.isNotEmpty)
          .toList();

      // Get course details
      final coursesSnap = await _firestore
          .collection('Course')
          .where(FieldPath.documentId, whereIn: courseIds)
          .get();

      // Get teacher IDs from the courses
      final teacherIds = coursesSnap.docs
          .map((doc) => doc.data()['teacherId'] ?? '')
          .where((id) => id.isNotEmpty)
          .toSet()
          .toList();

      // Get teacher names
      final teachersSnap = await _firestore
          .collection('Teachers')
          .where(FieldPath.documentId, whereIn: teacherIds)
          .get();

      final teacherMap = {
        for (var doc in teachersSnap.docs) doc.id: doc.data()['name'] ?? 'Unknown'
      };

      // Build enrolled courses list
      enrolledCourses.value = coursesSnap.docs.map((doc) {
        final data = doc.data();
        return {
          'id': doc.id,
          'name': data['name'] ?? 'Untitled Course',
          'credithour': data['credithour'] ?? '',
          'teacherName': teacherMap[data['teacherId']] ?? 'Unknown',
        };
      }).toList();
    } catch (e) {
      Get.snackbar('Error', 'Could not fetch enrolled courses: $e');
    } finally {
      isLoading.value = false;
    }
  }
}
