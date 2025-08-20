import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../Controllers/login_controller.dart';
import '../Controllers/theme_controller.dart';
import '../UiHelpers/custom_fields.dart';


class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final LoginController controller = Get.put(LoginController());
    return Scaffold(
      body: Center(
        child: Container(
          width: 350,
          padding: EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.grey.shade200,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.shade300,
                blurRadius: 10,
                offset: Offset(2, 4),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.group, size: 48),
              SizedBox(height: 16),
              Text("Login",
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
              Text("Only registered users  can login",
                  style: TextStyle(fontSize: 12)),
              SizedBox(height: 24),
              DropDown(),
              SizedBox(height: 16),

              // Username
              FormInput(labeltext: 'Username *',
                textController: controller.emailController,
                inputType: TextInputType.emailAddress,),
              SizedBox(height: 16),


              // Password
              Obx(() {
                return FormInput(
                  labeltext: 'Password *',
                  textController: controller.passwordController,
                  inputType: TextInputType.visiblePassword,
                  isobsecure: controller.isObscured.value,
                  obsecuredPress: () {
                    controller.toggleObscure();
                  },);
              }),
              SizedBox(height: 16),
              Obx(() {
                if (controller.isLoading.value) {
                  return CircularProgressIndicator();
                }
                else {
                  return ElevatedButton(
                    onPressed: controller.login,
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(
                          horizontal: 50, vertical: 14),
                    ),
                    child: Text("Get Started"),
                  );
                }
              }),
            ],
          ),
        ),
      ),

      // Floating Action Button for theme toggle
      floatingActionButton: FloatingActionButton(
        onPressed: () => Get.find<ThemeController>().toggleTheme(),
        child: Icon(Icons.brightness_6),
      ),
    );
  }
}


class DropDown extends StatelessWidget {
  const DropDown({super.key});

  @override
  Widget build(BuildContext context) {
    final LoginController controller = Get.put(LoginController());
    return Obx(() {
      return DropdownButtonFormField<String>(
        value: controller.selectedRole.value,
        decoration: InputDecoration(labelText: "Select Role *",
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10)),),
        items: controller.roles
            .map((role) =>
            DropdownMenuItem(
              value: role,
              child: Row(
                children: [
                  Icon(role == "Admin"
                      ? Icons.security
                      : role == "Teacher"
                      ? Icons.school
                      : Icons.person),
                  SizedBox(width: 8),
                  Text(role),
                ],
              ),
            )).toList(),
        onChanged: (value) =>
        controller.selectedRole.value = value!,
      );
    });
  }
}

