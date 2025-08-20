// lib/controllers/student_controller.dart
import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import '../models/student_model.dart';

class StudentController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  //final FirebaseAuth _auth = FirebaseAuth.instance;
  final String collectionName = 'students';
  final students = <Student>[].obs;
  final isLoading = false.obs;


  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? _subscription;

  @override
  void onInit() {
    super.onInit();
    bindStudentsStream();
  }

  /// Listen to the students collection and update the reactive list.
  void bindStudentsStream() {
    _subscription = _firestore
        .collection(collectionName)
    // .orderBy('name') // optional: enable if you have an index on the field
        .snapshots()
        .listen((snapshot) {
      final list = snapshot.docs
          .map((d) => Student.fromMap(d.id, d.data()))
          .toList();
      students.assignAll(list);
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

  /// Get a single student by document id (rollNo)
  Future<Student?> getStudentById(String docId) async {
    try {
      final doc = await _firestore.collection(collectionName).doc(docId).get();
      if (!doc.exists) return null;
      return Student.fromMap(doc.id, doc.data() as Map<String, dynamic>);
    } catch (e) {
      Get.snackbar('Error', e.toString());
      return null;
    }
  }



  Future<void> addStudent(Student student) async {
    try {
      isLoading.value = true;

      String studentDocId;

      // Step 1: Add to 'students' collection
      if (student.id.isNotEmpty) {
        final docRef = _firestore.collection(collectionName).doc(student.id);
        final snapshot = await docRef.get();
        if (snapshot.exists) {
          Get.snackbar('Error', 'Student with id ${student.id} already exists');
          return;
        }
        await docRef.set(student.toMap());
        studentDocId = student.id;
      } else {
        final newDoc = await _firestore.collection(collectionName).add(student.toMap());
        studentDocId = newDoc.id;
      }

      // Step 2: Create Firebase Auth account for student
      final userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
        email: student.email,
        password: student.id, // Using student ID as password
      );

      final uid = userCredential.user!.uid;

      // Step 3: Add login info to 'users' collection
      await _firestore.collection('users').doc(uid).set({
        'name': student.name,
        'email': student.email,
        'role': 'Student',
        'studentId': studentDocId,
        'createdAt': FieldValue.serverTimestamp(),
      });

      Get.snackbar('Success', 'Student added & login created');
    } catch (e) {
      Get.snackbar('Error', e.toString());
    } finally {
      isLoading.value = false;
    }
  }


  /// Update student by doc id
  Future<void> updateStudent(String docId, Map<String, dynamic> data) async {
    try {
      isLoading.value = true;
      await _firestore.collection(collectionName).doc(docId).update(data);
      Get.snackbar('Success', 'Student updated');
    } catch (e) {
      Get.snackbar('Error', e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  /// Delete student
  Future<void> deleteStudent(String docId) async {
    try {
      await _firestore.collection(collectionName).doc(docId).delete();
      Get.snackbar('Success', 'Student deleted');
    } catch (e) {
      Get.snackbar('Error', e.toString());
    }
  }
}
