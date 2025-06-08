import 'package:flutter/material.dart';
class DescriptionInputfield extends StatelessWidget{
  final TextEditingController controller;

  const DescriptionInputfield({
    super.key,
    required this.controller
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: EdgeInsets.symmetric(horizontal : MediaQuery.of(context).size.width * 0.1),
        child: TextFormField(
          keyboardType: TextInputType.multiline,
          minLines: 1,
          maxLines: 5,
          controller: controller,
          textAlignVertical: TextAlignVertical.top,
          decoration: InputDecoration(
              icon: Icon(Icons.description_rounded, color: Color(0xff8480e5)),
              disabledBorder: InputBorder.none,
              labelText: "Description",
              labelStyle: TextStyle(color: Color(0xff8480e5)),
              hintText: "Perpanjang Sewa Tenda dan Alat Masak",
              hintStyle: TextStyle(color: Color(0xff8480e5)),

          ),
        )
    );
  }
}