import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../Attandancesystem/attandance_recognize.dart';
import '../../Attandancesystem/camera_view.dart';
import '../../Controllers/attandance_controller.dart';
import '../../Controllers/teacher_controller.dart';
import '../../UiHelpers/app_bar.dart';
import '../../UiHelpers/containers.dart';
import '../login_screen.dart';

class TeacherDashboard extends StatelessWidget {
  const TeacherDashboard({
    super.key,
    required this.name,
    required this.teacherId,
  });

  final String name;
  final String teacherId;

  @override
  Widget build(BuildContext context) {
    final TeacherController ctrl = Get.put(TeacherController());
    final AttendanceController attendanceCtrl = Get.put(AttendanceController());

    // Fetch assigned courses after widget build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ctrl.fetchAssignedCourses(teacherId);
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      ctrl.fetchAssignedCoursesLength(teacherId);
    });

    return Scaffold(
      appBar: customAppBar(context, name, () {
        Get.off(LoginScreen());
      }),
      body: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 18),
            child: Obx(() {
              return Customcontainer(
                ic: Icon(Icons.school_outlined),
                maintext: ctrl.assignedCoursesLength.value.toString(),
                subtext: 'ASSIGNED COURSES',
              );
            }),
          ),
          Expanded(
            child: Obx(() {
              if (ctrl.isLoading.value) {
                return Center(child: CircularProgressIndicator());
              }
              if (ctrl.assignedCourseDetails.isEmpty) {
                return Center(child: Text("No assigned courses."));
              }

              return ListView.builder(
                itemCount: ctrl.assignedCourseDetails.length,
                itemBuilder: (context, index) {
                  final course = ctrl.assignedCourseDetails[index];
                  return Card(
                    margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Colors.blueAccent,
                          child: Text(
                            course['name'][0].toUpperCase(),
                            style: TextStyle(color: Colors.white,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                        title: Row(
                          children: [
                            Text(
                              course['code'],
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            Expanded(
                              child: Center(
                                child: Text(
                                  course['name'],
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ),
                            ),
                          ],
                        ),
                        trailing: IconButton(
                          onPressed: () async {
                            final file = await Get.to<File?>(
                                  () =>
                                  CameraViewGetX(
                                    onPictureTaken: (file) {
                                      Get.back(result: file);
                                    },
                                  ),
                            );

                            if (file != null) {
                              final faceRecognition = FaceRecognitionAttendance(
                                flaskUrl: 'http://10.0.11.44:5000/recognize',
                              );

                              final recognizedFaces = await faceRecognition
                                  .recognizeFromFile(file);

                              if (recognizedFaces.isNotEmpty) {
                                final recognizedStudentIds = recognizedFaces
                                    .map((face) => face['name'] as String)
                                    .toList();
                                Get.snackbar("Detected",
                                    recognizedStudentIds.toString());
                                // Mark attendance for the current course
                                await attendanceCtrl.markAttendance(
                                    course['code'], recognizedStudentIds);
                              } else {
                                Get.snackbar(
                                    'Recognition', 'No faces detected');
                              }
                              await faceRecognition.disposeCamera();
                            } else {
                              Get.snackbar('Error', 'No picture taken');
                            }
                          },
                          icon: Icon(Icons.how_to_reg),
                        )
                    ),
                  );
                },
              );
            }),
          ),
        ],
      ),
    );
  }
}

