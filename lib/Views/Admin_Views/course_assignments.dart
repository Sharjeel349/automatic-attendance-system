import 'package:attandance_system/Controllers/teacher_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../Controllers/course_controller.dart';
import '../../models/teacher_model.dart';
import '../../UiHelpers/containers.dart';

class CourseAssignment extends StatelessWidget {
  const CourseAssignment({super.key});

  @override
  Widget build(BuildContext context) {
    final TeacherController teacherCtrl = Get.put(TeacherController());
    final CourseController courseCtrl = Get.put(CourseController());
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Assign Courses",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      body: Column(
          children: <Widget>[
      Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: <Widget>[
          Expanded(
            child: Obx(() {
              return Customcontainer(
                ic: const Icon(Icons.group, size: 30),
                maintext: teacherCtrl.teachers.length.toString(),
                // reactive but snapshot at build
                subtext: "Total Teaches",
              );
            }),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Obx(() {
              return Customcontainer(
                ic: const Icon(Icons.school, size: 30),
                maintext: courseCtrl.courses.length.toString(),
                subtext: 'Total Courses',
              );
            }),
          ),
        ],
      ),
    ),
    const SizedBox(height: 10),
            Expanded(
              child: Obx(() {
                if (teacherCtrl.teachers.isEmpty) {
                  return const Center(child: Text("No teachers found."));
                }

                return ListView.builder(
                  itemCount: teacherCtrl.teachers.length,
                  itemBuilder: (context, index) {
                    final teacher = teacherCtrl.teachers[index];
                    return Card(
                      child: ListTile(
                        leading: const Icon(Icons.person),
                        title: Text(teacher.name),
                        subtitle: Text("Assigned: ${teacher.assignedCourses.length} course(s)"),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.add, color: Colors.green),
                              onPressed: () => _showAssignDialog(context, teacher, teacherCtrl, courseCtrl),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () {
                                // Remove all course assignments for that teacher
                                teacherCtrl.removeAllAssignments(teacher.id);
                              },
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              }),
            ),
    ]),

    );
  }
}






void _showAssignDialog(BuildContext context, Teacher teacher, TeacherController teacherCtrl, CourseController courseCtrl) {
  final unassignedCourses = courseCtrl.courses
      .where((c) => !c.assignedTeachers.contains(teacher.id))
      .toList();

  if (unassignedCourses.isEmpty) {
    Get.snackbar("No Courses", "All courses already assigned to this teacher.");
    return;
  }

  showDialog(
    context: context,
    builder: (context) {
      return SimpleDialog(
        title: Text("Assign Course to ${teacher.name}"),
        children: unassignedCourses.map((course) {
          return SimpleDialogOption(
            onPressed: () {
              teacherCtrl.assignCourseToTeacher(teacher.id, course.id);
              Get.back();
            },
            child: Text(course.name),
          );
        }).toList(),
      );
    },
  );
}

