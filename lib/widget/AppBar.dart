import 'package:flutter/material.dart';

import '../page/SettingPage.dart';
class MyAppBar extends StatelessWidget {
  final String title;
  const MyAppBar({
    super.key,
    required this.title
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
        elevation: 4,
        backgroundColor: (Color(0xffdfe2fe)),
        title: Text(title,
          style: TextStyle(
              color: Color(0xff7971ea),
              fontWeight: FontWeight.w700,
              fontSize: 18
          ),
        ),
        actions: [
          IconButton(onPressed: (){
            Navigator.push(context, MaterialPageRoute(builder: (context)=>SettingPage()));
          }, icon: Icon(Icons.settings, color: Color(0xFF7971EA),))
        ]
    );
  }
}