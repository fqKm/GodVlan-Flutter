import 'package:flutter/material.dart';

class NameInputField extends StatelessWidget{
  final TextEditingController controller;

  const NameInputField({
    super.key,
    required this.controller
  });

  @override
  Widget build(BuildContext context) {
    return  Padding(
        padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width * 0.10),
        child: TextFormField(
          keyboardType: TextInputType.name,
          controller: controller,
          decoration: InputDecoration(
              icon : Icon(Icons.person_outline, color: Color(0xff7971ea)),
              disabledBorder: InputBorder.none,
              labelText: "Name",
              labelStyle: TextStyle(color: Color(0xff8480e5))
          ),
          validator: (val) =>
          val == null || val.isEmpty ? 'name wajib diisi' : null,
        )
    );
  }

}