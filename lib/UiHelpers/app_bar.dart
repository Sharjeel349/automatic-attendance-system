import 'package:flutter/material.dart';

PreferredSizeWidget customAppBar(BuildContext context, String userName, VoidCallback onLogout) {
  return AppBar(
    backgroundColor: Colors.white,
    elevation: 4,
    automaticallyImplyLeading: false,
    titleSpacing: 0,
    title: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Builder(
              builder: (context) => IconButton(
                onPressed: () {
          Scaffold.of(context).openDrawer();
          },
            icon: Icon(Icons.menu, color: Colors.black),
          ),),
            ],
          ),
          Row(
            children: [
              Image.asset('images/logo1.png', height: 30),
              SizedBox(width: 10),
              Text(
                'Welcome, $userName',
                style: const TextStyle(color: Colors.black, fontSize: 14),
              ),
              IconButton(
                onPressed: onLogout,
                icon: Icon(Icons.logout, color: Colors.red),
              ),
            ],
          ),
        ],
      ),
    ),
  );
}
