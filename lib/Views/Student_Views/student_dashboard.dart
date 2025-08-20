import 'package:attandance_system/Controllers/attandance_controller.dart';
import 'package:flutter/material.dart';
  import 'package:get/get.dart';
import '../../UiHelpers/app_bar.dart';
import '../../UiHelpers/containers.dart';
import '../login_screen.dart';
import '../../controllers/enrollment_controller.dart';

class StudentDashboard extends StatelessWidget {
  const StudentDashboard({
    super.key,
    required this.name,
    required this.studentId,
  });

  final String name;
  final String studentId;

  @override
  Widget build(BuildContext context) {
    final EnrollmentController ctrl = Get.put(EnrollmentController());
    final AttendanceController attendanceController = Get.put(AttendanceController());

    WidgetsBinding.instance.addPostFrameCallback((_) {
      ctrl.getEnrolledCourses(studentId);
    });

    return Scaffold(
      appBar: customAppBar(context, name, () {
        Get.off(LoginScreen());
      }),
      body: Column(
        children: <Widget>[
          InkWell(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 12,horizontal: 18),
              child: Customcontainer(
                ic: Icon(Icons.school_outlined),
                maintext: 'ENROLL',
                subtext: 'COURSES',
              ),
            ),
            onTap: () async {
              await ctrl.fetchAvailableCourses(studentId);
              _showEnrollDialog(context, ctrl);
            },
          ),
          buildEnrolledCoursesList(ctrl,attendanceController,studentId),
        ],
      ),
    );
  }


  void _showEnrollDialog(BuildContext context, EnrollmentController ctrl) {
    showDialog(
      context: context,
      builder: (context) {
        return Obx(() {
          if (ctrl.isLoading.value) {
            return AlertDialog(
              content: Center(child: CircularProgressIndicator()),
            );
          }

          return AlertDialog(
            title: Text('Available Courses'),
            content: SizedBox(
              width: double.maxFinite,
              child: ctrl.availableCourses.isEmpty
                  ? Text("No courses available.")
                  : ListView.builder(
                shrinkWrap: true,
                itemCount: ctrl.availableCourses.length,
                itemBuilder: (context, index) {
                  final course = ctrl.availableCourses[index];
                  return Card(
                    child: ListTile(
                      title: Text(
                        course['name'],
                        textAlign: TextAlign.left,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      subtitle: Text(
                        'Credit Hours: ${course['credithour']}',
                        style: const TextStyle(color: Colors.grey, fontSize: 14),
                      ),
                      trailing: const Icon(Icons.add_box_outlined, size: 16, color: Colors.grey),
                      onTap: () async{
                        ctrl.enrollStudent(
                          studentId: studentId,
                          courseId: course['id'],
                          teacherId: course['teacherId'],
                        );
                        Navigator.pop(context);
                      },
                    ),
                  );
                },
              ),
            ),
            actions: [
              TextButton(
                child: Text('Close'),
                onPressed: () => Navigator.pop(context),
              )
            ],
          );
        });
      },
    );
  }
}


Widget buildEnrolledCoursesList(EnrollmentController ctrl,AttendanceController actrl,String studentId) {
  return Expanded(
    child: Obx(() {
      if (ctrl.enrolledCourses.isEmpty) {
        return const Center(
          child: Text("No enrolled courses yet."),
        );
      }
      return ListView.builder(
        itemCount: ctrl.enrolledCourses.length,
        itemBuilder: (context, index) {
          final course = ctrl.enrolledCourses[index];
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            child: ListTile(
              title: Text(
                course['name'],
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text("Teacher: ${course['teacherName']}"),
              trailing: IconButton(
                icon: const Icon(Icons.visibility, color: Colors.blue),
                onPressed: () async {
                  final attendanceRecords = await actrl.getAttendance(course['id'], studentId);

                  showDialog(
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        title: Text("Attendance - ${course['name']}"),
                        content: SizedBox(
                          width: double.maxFinite,
                          child: attendanceRecords.isEmpty
                              ? const Text("No attendance records yet.")
                              : ListView.builder(
                            shrinkWrap: true,
                            itemCount: attendanceRecords.length,
                            itemBuilder: (context, index) {
                              final record = attendanceRecords[index];
                              return ListTile(
                                title: Text(record['date']),
                                trailing: Icon(
                                  record['present'] ? Icons.check_circle : Icons.cancel,
                                  color: record['present'] ? Colors.green : Colors.red,
                                ),
                              );
                            },
                          ),
                        ),
                        actions: [
                          TextButton(
                            child: const Text("Close"),
                            onPressed: () => Navigator.pop(context),
                          ),
                        ],
                      );
                    },
                  );
                },
            ),
            ),
          );
        },
      );
    }),
  );
}


