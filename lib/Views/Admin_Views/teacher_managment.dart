import 'package:get/get.dart';
import 'package:flutter/material.dart';
import '../../Controllers/teacher_controller.dart';
import '../../models/teacher_model.dart';
import '../../UiHelpers/containers.dart';

class TeacherManagment extends StatelessWidget {
  const TeacherManagment({super.key});

  @override
  Widget build(BuildContext context) {
    // Put controller (or Get.find if already put elsewhere)
    final TeacherController ctrl = Get.put(TeacherController());
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Teacher Management",
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
                      maintext: ctrl.teachers.length.toString(),
                      // reactive but snapshot at build
                      subtext: "Total Teachers",
                    );
                  }),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Customcontainer(
                    ic: const Icon(Icons.school, size: 30),
                    maintext: '3',
                    subtext: 'Total Courses',
                  ),
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
                            "All Teachers", style: TextStyle(fontSize: 16)),
                        ElevatedButton.icon(
                          onPressed: () =>
                              showAddEditTeacherDialog(context, ctrl),
                          icon: const Icon(Icons.add),
                          label: const Text("Add Teacher"),
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

                if (ctrl.teachers.isEmpty) {
                  return const Center(child: Text('No Teacher found.'));
                }

                return ListView.separated(
                  itemCount: ctrl.teachers.length,
                  separatorBuilder: (_, __) => const Divider(),
                  itemBuilder: (context, index) {
                    final Teacher t = ctrl.teachers[index];
                    return _teacherTile(context, t, ctrl);
                  },
                );
              }),
            ),
          ),
        ],
      ),
    );
  }

  Widget _teacherTile(BuildContext context, Teacher s, TeacherController ctrl) {
    return Card(
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        leading: CircleAvatar(
            child: Text(s.name.isNotEmpty ? s.name[0].toUpperCase() : '?')),
        title: Text(s.name, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Email: ${s.email}', style: const TextStyle(fontSize: 12)),
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
                  showAddEditTeacherDialog(context, ctrl, teacher: s),
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

  void _confirmDelete(BuildContext context, TeacherController ctrl, Teacher s) {
    Get.defaultDialog(
      title: 'Delete Student',
      middleText: 'Are you sure you want to delete ${s.name} (${s.id})?',
      textConfirm: 'Delete',
      textCancel: 'Cancel',
      confirmTextColor: Colors.white,
      onConfirm: () async {
        Get.back(); // close dialog
        await ctrl.deleteTeacher(s.id);
      },
    );
  }
}

Future<void> showAddEditTeacherDialog(BuildContext context,
    TeacherController ctrl, {Teacher? teacher}) async {
  final idCtrl = TextEditingController(text: teacher?.id ?? '');
  final nameCtrl = TextEditingController(text: teacher?.name ?? '');
  final emailCtrl = TextEditingController(text: teacher?.email ?? '');

  final isEdit = teacher != null;

  await showDialog(
    context: context,
    builder: (ctx) {
      return AlertDialog(
        title: Text(isEdit ? 'Edit Teacher' : 'Add Teacher'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // If editing, id disabled (id = doc id). If adding, allow id input.
              TextField(
                controller: idCtrl,
                decoration: const InputDecoration(
                    labelText: 'Teacher ID (e.g.,TID-0000 '),
                enabled: !isEdit,
              ),
              TextField(controller: nameCtrl,
                  decoration: const InputDecoration(labelText: 'Name')),
              TextField(controller: emailCtrl,
                  decoration: const InputDecoration(labelText: 'Email')),
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

              if (id.isEmpty || name.isEmpty || email.isEmpty ) {
                Get.snackbar('Validation', 'All fields are required');
                return;
              }

              final newTeacher = Teacher(
                id: id,
                name: name,
                email: email,
              );

              Navigator.pop(ctx); // close dialog

              if (isEdit) {
                await ctrl.updateTeacher(teacher.id, newTeacher.toMap());
              } else {
                await ctrl.addTeacher(newTeacher);
              }
            },
            child: Text(isEdit ? 'Save' : 'Add'),
          ),
        ],
      );
    },
  );
}