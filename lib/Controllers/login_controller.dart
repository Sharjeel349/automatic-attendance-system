import 'package:attandance_system/Views/Admin_Views/admin_dashboard.dart';
import 'package:attandance_system/Views/Student_Views/student_dashboard.dart';
import 'package:attandance_system/Views/Teacher_Views/teacher_dashboard.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';

class LoginController extends GetxController{
  final emailController=TextEditingController();
  final passwordController=TextEditingController();
  final selectedRole='Admin'.obs;
  var isObscured = true.obs;
  var isLoading = false.obs;
  void toggleObscure() => isObscured.value = !isObscured.value;

  final roles = ['Admin', 'Teacher', 'Student'];

  void login() async {
    try {
      isLoading.value=true;
      UserCredential userCredential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );
      final uid = userCredential.user!.uid;

      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .get();

      if (!doc.exists) {
        //isLoading.value=false;
        Get.snackbar("Error", "No user data found in Firestore");
        return;
      }

      final role = doc['role'];

      if (role == "Admin") {
        Get.off(AdminDashboard(name:doc.data()?['name']));
      } else if (role == "Teacher") {
        Get.offAll(TeacherDashboard(name: doc.data()?['name'],
            teacherId: passwordController.text));
      } else {
        Get.offAll(StudentDashboard(
          name: doc.data()?['name'],
          studentId: passwordController.text,
        ));
      }

    } catch (e) {
      Get.snackbar("Login Failed", e.toString());
    }
    finally {
      isLoading.value = false;
    }
  }

}