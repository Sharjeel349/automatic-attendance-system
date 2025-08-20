
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../UiHelpers/app_bar.dart';
import '../../UiHelpers/custom_drawer.dart';
import '../login_screen.dart';

class AdminDashboard extends StatelessWidget {
  const AdminDashboard({super.key, required this.name});
  final String name;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: CustomDrawer(onLogout: (){Get.off(LoginScreen());}),
      appBar: customAppBar(context, name, (){Get.off(LoginScreen());}),
      body: Column(
        children: <Widget>[
        ],
      ),
    );
  }
}
