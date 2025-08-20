import 'dart:async';
import 'package:attandance_system/models/course_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';

class CourseController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String collectionName = 'Course';

  final courses = <Course>[].obs;
  final isLoading = false.obs;

  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? _subscription;

  @override
  void onInit() {
    super.onInit();
    bindCoursesStream();
  }

  /// Listen to the Courses collection and update the reactive list.
  void bindCoursesStream() {
    _subscription = _firestore
        .collection(collectionName)
    // .orderBy('name') // optional: enable if you have an index on the field
        .snapshots()
        .listen((snapshot) {
      final list = snapshot.docs
          .map((d) => Course.fromMap(d.id, d.data()))
          .toList();
      courses.assignAll(list);
    }, onError: (err) {
      Get.snackbar('Error', err.toString());
    });
  }

  /// Stop listening when controller is disposed.
  @override
  void onClose() {
    _subscription?.cancel();
    super.onClose();
  }

  /// Get a single Course by document id (TID)
  Future<Course?> getCourseById(String docId) async {
    try {
      final doc = await _firestore.collection(collectionName).doc(docId).get();
      if (!doc.exists) return null;
      return Course.fromMap(doc.id, doc.data() as Map<String, dynamic>);
    } catch (e) {
      Get.snackbar('Error', e.toString());
      return null;
    }
  }

  /// Add a Course.
  /// If you want rollNo as the document id, pass it via Course.id.
  /// If Course.id is empty, Firestore will auto-generate a doc id.
  Future<void> addCourse(Course course) async {
    try {
      isLoading.value = true;

      if (course.id.isNotEmpty) {
        // Check if the doc already exists to avoid overwriting unintentionally
        final docRef = _firestore.collection(collectionName).doc(course.id);
        final snapshot = await docRef.get();
        if (snapshot.exists) {
          Get.snackbar('Error', 'Course with id ${course.id} already exists');
          return;
        }
        await docRef.set(course.toMap());
      } else {
        await _firestore.collection(collectionName).add(course.toMap());
      }

      Get.snackbar('Success', 'Course added');
    } catch (e) {
      Get.snackbar('Error', e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  /// Update Course by doc id
  Future<void> updateCourse(String docId, Map<String, dynamic> data) async {
    try {
      isLoading.value = true;
      await _firestore.collection(collectionName).doc(docId).update(data);
      Get.snackbar('Success', 'Course updated');
    } catch (e) {
      Get.snackbar('Error', e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  /// Delete Course
  Future<void> deleteCourse(String docId) async {
    try {
      await _firestore.collection(collectionName).doc(docId).delete();
      Get.snackbar('Success', 'Course deleted');
    } catch (e) {
      Get.snackbar('Error', e.toString());
    }
  }

  Future<void> assignCourseToTeacher({
    required String teacherId,
    required String courseId,
  }) async {
    try {
      final teacherRef = _firestore.collection('Teacher').doc(teacherId);
      await teacherRef.update({
        'assignedCourses': FieldValue.arrayUnion([courseId]),
      });
      Get.snackbar('Success', 'Course assigned to teacher');
    } catch (e) {
      Get.snackbar('Error', e.toString());
    }
  }


  Future<void> unassignCourseFromTeacher({
    required String teacherId,
    required String courseId,
  }) async {
    try {
      final teacherRef = _firestore.collection('Teacher').doc(teacherId);
      await teacherRef.update({
        'assignedCourses': FieldValue.arrayRemove([courseId]),
      });
      Get.snackbar('Success', 'Course unassigned from teacher');
    } catch (e) {
      Get.snackbar('Error', e.toString());
    }
  }

}






