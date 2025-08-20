import 'package:attandance_system/Controllers/course_controller.dart';
import 'package:flutter/material.dart';
import '../../Controllers/student_controller.dart';
import 'package:attandance_system/models/student_model.dart';
import '../../UiHelpers/containers.dart';
import 'package:get/get.dart';


class StudentManagment extends StatelessWidget {
  const StudentManagment({super.key});

  @override
  Widget build(BuildContext context) {
    // Put controller (or Get.find if already put elsewhere)
    final StudentController ctrl = Get.put(StudentController());
    final CourseController cctrl = Get.put(CourseController());

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Student Managment",
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
                      maintext: ctrl.students.length.toString(),
                      // reactive but snapshot at build
                      subtext: "Total Students",
                    );
                  }),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Obx(() {
                    return Customcontainer(
                      ic: const Icon(Icons.school, size: 30),
                      maintext: cctrl.courses.length.toString(),
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
                            "All Students", style: TextStyle(fontSize: 16)),
                        ElevatedButton.icon(
                          onPressed: () =>
                              showAddEditStudentDialog(context, ctrl),
                          icon: const Icon(Icons.add),
                          label: const Text("Add Student"),
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

                if (ctrl.students.isEmpty) {
                  return const Center(child: Text('No students found.'));
                }

                return ListView.separated(
                  itemCount: ctrl.students.length,
                  separatorBuilder: (_, __) => const Divider(),
                  itemBuilder: (context, index) {
                    final Student s = ctrl.students[index];
                    return _studentTile(context, s, ctrl);
                  },
                );
              }),
            ),
          ),
        ],
      ),
    );
  }

  Widget _studentTile(BuildContext context, Student s, StudentController ctrl) {
    return Card(
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        leading: CircleAvatar(
            child: Text(s.name.isNotEmpty ? s.name[0].toUpperCase() : '?')),
        title: Text(s.name, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Discipline: ${s.discipline}'),
            // Text('Email: ${s.email}', style: const TextStyle(fontSize: 12)),
            Text('ID: ${s.id}',
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
                  showAddEditStudentDialog(context, ctrl, student: s),
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

  void _confirmDelete(BuildContext context, StudentController ctrl, Student s) {
    Get.defaultDialog(
      title: 'Delete Student',
      middleText: 'Are you sure you want to delete ${s.name} (${s.id})?',
      textConfirm: 'Delete',
      textCancel: 'Cancel',
      confirmTextColor: Colors.white,
      onConfirm: () async {
        Get.back(); // close dialog
        await ctrl.deleteStudent(s.id);
      },
    );
  }
}

Future<void> showAddEditStudentDialog(BuildContext context,
    StudentController ctrl, {Student? student}) async {
  final idCtrl = TextEditingController(text: student?.id ?? '');
  final nameCtrl = TextEditingController(text: student?.name ?? '');
  final emailCtrl = TextEditingController(text: student?.email ?? '');
  final disciplineCtrl = TextEditingController(text: student?.discipline ?? '');

  final isEdit = student != null;

  await showDialog(
    context: context,
    builder: (ctx) {
      return AlertDialog(
        title: Text(isEdit ? 'Edit Student' : 'Add Student'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // If editing, id disabled (id = doc id). If adding, allow id input.
              TextField(
                controller: idCtrl,
                decoration: const InputDecoration(
                    labelText: 'Student ID (e.g., 23-Arid-0274)'),
                enabled: !isEdit,
              ),
              TextField(controller: nameCtrl,
                  decoration: const InputDecoration(labelText: 'Name')),
              TextField(controller: emailCtrl,
                  decoration: const InputDecoration(labelText: 'Email')),
              TextField(controller: disciplineCtrl,
                  decoration: const InputDecoration(labelText: 'Discipline')),
            ],
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
              final discipline = disciplineCtrl.text.trim();

              if (id.isEmpty || name.isEmpty || email.isEmpty ||
                  discipline.isEmpty) {
                Get.snackbar('Validation', 'All fields are required');
                return;
              }

              final newStudent = Student(
                id: id,
                name: name,
                email: email,
                discipline: discipline,
              );

              Navigator.pop(ctx); // close dialog

              if (isEdit) {
                await ctrl.updateStudent(student.id, newStudent.toMap());
              } else {
                await ctrl.addStudent(newStudent);
              }
            },
            child: Text(isEdit ? 'Save' : 'Add'),
          ),
        ],
      );
    },
  );
}
