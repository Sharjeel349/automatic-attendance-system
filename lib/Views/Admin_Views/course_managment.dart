import 'package:attandance_system/Controllers/course_controller.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import '../../models/course_model.dart';
import '../../UiHelpers/containers.dart';

class CourseManagment extends StatelessWidget {
  const CourseManagment({super.key});

  @override
  Widget build(BuildContext context) {
    // Put controller (or Get.find if already put elsewhere)
    final CourseController ctrl = Get.put(CourseController());
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Course Management",
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
                // Expanded(
                //   child: Obx(() {
                //     return Customcontainer(
                //       ic: const Icon(Icons.group, size: 30),
                //       maintext: ctrl.courses.length.toString(),
                //       // reactive but snapshot at build
                //       subtext: "Total Courses",
                //     );
                //   }),
                // ),
                // const SizedBox(width: 10),
                Expanded(
                  child: Obx(() {
                    return Customcontainer(
                      ic: const Icon(Icons.school, size: 30),
                      maintext: ctrl.courses.length.toString(),
                      subtext: 'Total Courses',
                    );
                  }),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          // Header card with Add button
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.shade300,
                    blurRadius: 10,
                    offset: const Offset(2, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                            "All Courses", style: TextStyle(fontSize: 16)),
                        ElevatedButton.icon(
                          onPressed: () =>
                              showAddEditCourseDialog(context, ctrl),
                          icon: const Icon(Icons.add),
                          label: const Text("Add Course"),
                          style: ElevatedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10)),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Student list (expanded)
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: 16.0, vertical: 8),
              child: Obx(() {
                if (ctrl.isLoading.value) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (ctrl.courses.isEmpty) {
                  return const Center(child: Text('No Course found.'));
                }

                return ListView.separated(
                  itemCount: ctrl.courses.length,
                  separatorBuilder: (_, __) => const Divider(),
                  itemBuilder: (context, index) {
                    final Course t = ctrl.courses[index];
                    return _courseTile(context, t, ctrl);
                  },
                );
              }),
            ),
          ),
        ],
      ),
    );
  }

  Widget _courseTile(BuildContext context, Course s, CourseController ctrl) {
    return Card(
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        leading: CircleAvatar(
            child: Text(s.name.isNotEmpty ? s.name[0].toUpperCase() : '?')),
        title: Text(s.name, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Code: ${s.id}', style: const TextStyle(fontSize: 12)),
            Text('Cr Hr: ${s.credithour}',
                style: const TextStyle(fontSize: 12, color: Colors.grey)),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Edit
            IconButton(
              icon: const Icon(Icons.edit, color: Colors.blue),
              onPressed: () =>
                  showAddEditCourseDialog(context, ctrl, course: s),
            ),
      
            // Delete
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () => _confirmDelete(context, ctrl, s),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context, CourseController ctrl, Course s) {
    Get.defaultDialog(
      title: 'Delete Course',
      middleText: 'Are you sure you want to delete ${s.name} (${s.id})?',
      textConfirm: 'Delete',
      textCancel: 'Cancel',
      confirmTextColor: Colors.white,
      onConfirm: () async {
        Get.back(); // close dialog
        await ctrl.deleteCourse(s.id);
      },
    );
  }
}

Future<void> showAddEditCourseDialog(BuildContext context,
    CourseController ctrl, {Course? course}) async {
  final idCtrl = TextEditingController(text: course?.id ?? '');
  final nameCtrl = TextEditingController(text: course?.name ?? '');
  final emailCtrl = TextEditingController(text: course?.credithour.toString() ?? '');

  final isEdit = course != null;

  await showDialog(
    context: context,
    builder: (ctx) {
      return AlertDialog(
        title: Text(isEdit ? 'Edit Course' : 'Add Course'),
        content: SingleChildScrollView(
          child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // If editing, id disabled (id = doc id). If adding, allow id input.
                TextField(
                  controller: idCtrl,
                  decoration: const InputDecoration(
                      labelText: 'Course Code (e.g.,CSC-200'),
                  enabled: !isEdit,
                ),
                TextField(controller: nameCtrl,
                    decoration: const InputDecoration(labelText: 'title')),
                TextField(controller: emailCtrl,
                    decoration: const InputDecoration(labelText: 'Credit hour')),
              ]
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              final id = idCtrl.text.trim();
              final name = nameCtrl.text.trim();
              final email = emailCtrl.text.trim();

              if (id.isEmpty || name.isEmpty || email.isEmpty) {
                Get.snackbar('Validation', 'All fields are required');
                return;
              }

              final newCourse = Course(
                id: id,
                name: name,
                credithour: int.tryParse(emailCtrl.text) ?? 0,
              );

              Navigator.pop(ctx); // close dialog

              if (isEdit) {
                await ctrl.updateCourse(newCourse.id, newCourse.toMap());
              } else {
                await ctrl.addCourse(newCourse);
              }
            },
            child: Text(isEdit ? 'Save' : 'Add'),
          ),
        ],
      );
    },
  );
}