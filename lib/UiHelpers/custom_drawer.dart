import 'package:attandance_system/Views/Admin_Views/course_assignments.dart';
import 'package:attandance_system/Views/Admin_Views/student_managment.dart';
import 'package:attandance_system/Views/Admin_Views/teacher_managment.dart';
import 'package:attandance_system/models/course_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../Views/Admin_Views/course_managment.dart';

class CustomDrawer extends StatelessWidget {
  final VoidCallback onLogout;

  const CustomDrawer({super.key, required this.onLogout});

  @override
  Widget build(BuildContext context) {
    double drawerWidth = MediaQuery.of(context).size.width * 0.6;

    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.only(top:50),
        child: SafeArea(child:Container(
          decoration: BoxDecoration(
            color: Color(0x8BA59C9C),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.shade300,
                blurRadius: 5,
                offset: Offset(1, 2),
              ),
            ],
          ),
          width: drawerWidth,
          height: double.infinity,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              drawerTile(Icons.dashboard, "Dashboard",onTap: (){}),
              drawerTile(Icons.people, "Student Management",onTap: (){Get.to(StudentManagment());}),
              drawerTile(Icons.person, "Teacher Management",onTap: (){Get.to(TeacherManagment());}),
              drawerTile(Icons.school, "Course Management",onTap: (){Get.to(CourseManagment());}),
              drawerTile(Icons.assignment, "Course Assignment",onTap: (){Get.to(CourseAssignment());}),
              const Spacer(),
              drawerTile(Icons.logout, "Logout", onTap: onLogout),
            ],
          ),
        ),
            ),
      ));
  }

  Widget drawerTile(IconData icon, String title, {VoidCallback? onTap}) {
    return ListTile(
      leading: Icon(icon, color: Colors.black),
      title: Text(title, style: const TextStyle(color: Colors.black)),
      onTap: onTap,
    );
  }
}
