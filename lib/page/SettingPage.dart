import 'package:flutter/material.dart';
import 'package:godvlan/widget/AppBar.dart';

class SettingPage extends StatefulWidget{
  const SettingPage({
  super.key
});

  @override
  _SettingPage createState() => _SettingPage();
}

class _SettingPage extends State<StatefulWidget>{
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar:  AppBar(
            elevation: 4,
            backgroundColor: (Color(0xffdfe2fe)),
            leading: IconButton(
              icon: Icon(Icons.arrow_back_ios_new_rounded, size: 18, color: Color(0xff7971ea)), // contoh pakai chevron
              onPressed: () => Navigator.pop(context),
            ),
            title: Text(
              "Settings",
              style: TextStyle(
                  color: Color(0xff7971ea),
                  fontWeight: FontWeight.w700,
                  fontSize: 18
              ),
            ),
        ),
        body: Text("SettingPage")
      );
  }
}