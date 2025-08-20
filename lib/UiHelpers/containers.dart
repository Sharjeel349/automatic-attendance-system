

import 'package:flutter/material.dart';

class Customcontainer extends StatelessWidget {
  const Customcontainer({super.key, required this.ic, required this.maintext, required this.subtext});
  final Icon ic;
  final String maintext;
  final String subtext;


  @override
  Widget build(BuildContext context) {
      return Container(
        height: 100,
        decoration: BoxDecoration(color: Colors.grey.shade200,
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
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Row(
            mainAxisAlignment:MainAxisAlignment.center,
            children: [
              ic,
              Text(maintext,style: TextStyle(fontSize: 30,fontWeight: FontWeight.bold),),
            ],
          ),
          Text(subtext)
        ],
      ),
    );
  }
}
