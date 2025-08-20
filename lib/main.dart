import 'package:attandance_system/firebase_options.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:get/get.dart';

import 'Controllers/theme_controller.dart';
import 'Views/Admin_Views/admin_dashboard.dart';
import 'Views/Student_Views/student_dashboard.dart';
import 'Views/Teacher_Views/teacher_dashboard.dart';
import 'Views/login_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  Get.put(ThemeController());
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return Obx(() {
      return GetMaterialApp(
          title: 'Attandance System',
          debugShowCheckedModeBanner: false,
          theme: ThemeData.light(),
          darkTheme: ThemeData.dark(),
          themeMode: Get
              .find<ThemeController>()
              .theme,
          home: StreamBuilder<User?>(
            stream: FirebaseAuth.instance.authStateChanges(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              }

              if (snapshot.hasData) {
                final user = snapshot.data!;
                return FutureBuilder<DocumentSnapshot>(
                  future: FirebaseFirestore.instance.collection('users').doc(
                      user.uid).get(),
                  builder: (context, snap) {
                    if (!snap.hasData) {
                      return Center(child: CircularProgressIndicator());
                    }
                    if (!snap.data!.exists) {
                      return LoginScreen();
                    }

                    final role = snap.data!.get('role');
                    final name = snap.data!.get('name');

                    if (role == "admin") {
                      return AdminDashboard(name: name);
                    } else if (role == "teacher") {
                      return TeacherDashboard(name: name, teacherId: user.uid);
                    } else {
                      return StudentDashboard(name: name, studentId: user.uid);
                    }
                  },
                );
              }

              // Not logged in
              return LoginScreen();
            },
          )
      );
    });
  }
}