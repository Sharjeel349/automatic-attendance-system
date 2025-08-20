import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import '../models/teacher_model.dart';

class TeacherController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String collectionName = 'Teachers';

  final teachers = <Teacher>[].obs;
  final isLoading = false.obs;
  var assignedCourseDetails = <Map<String, dynamic>>[].obs; // reactive list of assigned courses


  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? _subscription;

  @override
  void onInit() {
    super.onInit();
    bindTeachersStream();
  }

  /// Listen to the Teachers collection and update the reactive list.
  void bindTeachersStream() {
    _subscription = _firestore
        .collection(collectionName)
    // .orderBy('name') // optional: enable if you have an index on the field
        .snapshots()
        .listen((snapshot) {
      final list = snapshot.docs
          .map((d) => Teacher.fromMap(d.id, d.data()))
          .toList();
      teachers.assignAll(list);
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

  /// Get a single Teacher by document id (TID)
  Future<Teacher?> getTeacherById(String docId) async {
    try {
      final doc = await _firestore.collection(collectionName).doc(docId).get();
      if (!doc.exists) return null;
      return Teacher.fromMap(doc.id, doc.data() as Map<String, dynamic>);
    } catch (e) {
      Get.snackbar('Error', e.toString());
      return null;
    }
  }

  /// Add a Teacher.
  /// If you want rollNo as the document id, pass it via Teacher.id.
  /// If Teacher.id is empty, Firestore will auto-generate a doc id.
  Future<void> addTeacher(Teacher teacher) async {
    try {
      isLoading.value = true;
      String teacherDocId;

      if (teacher.id.isNotEmpty) {
        // Check if the doc already exists to avoid overwriting unintentionally
        final docRef = _firestore.collection(collectionName).doc(teacher.id);
        final snapshot = await docRef.get();
        if (snapshot.exists) {
          Get.snackbar('Error', 'Teacher with id ${teacher.id} already exists');
          return;
        }
        await docRef.set(teacher.toMap());
        teacherDocId=teacher.id;
      } else {
        final newDoc = await _firestore.collection(collectionName).add(teacher.toMap());
        teacherDocId = newDoc.id;
      }

      final userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
        email: teacher.email,
        password: teacher.id, // Using student ID as password
      );

      final uid = userCredential.user!.uid;
      await _firestore.collection('users').doc(uid).set({
        'name': teacher.name,
        'email': teacher.email,
        'role': 'Teacher',
        'teacherId': teacherDocId ,
        'createdAt': FieldValue.serverTimestamp(),
      });

      Get.snackbar('Success', 'Teacher added & login created');
    } catch (e) {
      Get.snackbar('Error', e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  /// Update Teacher by doc id
  Future<void> updateTeacher(String docId, Map<String, dynamic> data) async {
    try {
      isLoading.value = true;
      await _firestore.collection(collectionName).doc(docId).update(data);
      Get.snackbar('Success', 'Teacher updated');
    } catch (e) {
      Get.snackbar('Error', e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  /// Delete Teacher
  Future<void> deleteTeacher(String docId) async {
    try {
      await _firestore.collection(collectionName).doc(docId).delete();
      Get.snackbar('Success', 'Teacher deleted');
    } catch (e) {
      Get.snackbar('Error', e.toString());
    }
  }








  Future<void> assignCourseToTeacher(String teacherId, String courseId) async {
    final teacherDoc = FirebaseFirestore.instance.collection('Teachers').doc(teacherId);
    final courseDoc = FirebaseFirestore.instance.collection('Course').doc(courseId);
    try {
      await teacherDoc.update({
        'assignedCourses': FieldValue.arrayUnion([courseId]),
      });

      await courseDoc.update({
        'teacherId': teacherId,
      });

      // Update locally
      final index = teachers.indexWhere((t) => t.id == teacherId);
      if (index != -1) {
        final updated = teachers[index];
        teachers[index] = Teacher(
          id: updated.id,
          name: updated.name,
          email: updated.email,
          assignedCourses: [...updated.assignedCourses, courseId],
        );
        teachers.refresh(); // trigger UI update
      }

      Get.snackbar("Success", "Course assigned successfully.");
    } catch (e) {
      Get.snackbar("Error", "Failed to assign course: $e");
    }
  }


  Future<void> removeAllAssignments(String teacherId) async {
    try {
      final teacherRef = _firestore.collection('Teachers').doc(teacherId);

      await teacherRef.update({
        'assignedCourses': FieldValue.delete(), // Removes the field
      });

      Get.snackbar('Success', 'All course assignments removed');
    } catch (e) {
      Get.snackbar('Error', 'Failed to remove assignments: $e');
    }
  }



  Future<void> fetchAssignedCourses(String teacherId) async {
    try {
      isLoading.value = true;

      // Fetch teacher doc to get assignedCourses array
      final teacherDoc = await _firestore.collection(collectionName).doc(teacherId).get();
      if (!teacherDoc.exists) {
        assignedCourseDetails.clear();
        return;
      }

      List assignedCourseIds = teacherDoc.data()?['assignedCourses'] ?? [];

      if (assignedCourseIds.isEmpty) {
        assignedCourseDetails.clear();
        return;
      }

      // Query Course collection to get details for assigned course IDs
      final coursesSnap = await _firestore
          .collection('Course')
          .where(FieldPath.documentId, whereIn: assignedCourseIds)
          .get();

      assignedCourseDetails.value = coursesSnap.docs.map((doc) {
        final data = doc.data();
        return {
          'id': doc.id,
          'name': data['name'] ?? 'No Name',
          'code': doc.id,
        };
      }).toList();

    } catch (e) {
      Get.snackbar('Error', 'Failed to fetch assigned courses: $e');
    } finally {
      isLoading.value = false;
    }
  }

  var assignedCoursesLength = 0.obs;

  Future<void> fetchAssignedCoursesLength(String teacherId) async {
    try {
      final doc = await _firestore.collection('Teachers').doc(teacherId).get();
      if (doc.exists) {
        final data = doc.data()!;
        final courses = data['assignedCourses'] as List<dynamic>? ?? [];
        assignedCoursesLength.value = courses.length;
      }
    } catch (e) {
      Get.snackbar('Error', 'Could not fetch courses length: $e');
    }
  }
}

