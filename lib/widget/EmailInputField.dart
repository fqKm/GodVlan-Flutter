import 'package:flutter/material.dart';

class EmailInputField extends StatelessWidget{
  final TextEditingController controller;

  const EmailInputField({
    super.key,
    required this.controller
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width * 0.10),
        child:
        TextFormField(
          keyboardType: TextInputType.emailAddress,
            controller: controller,
            decoration: InputDecoration(
                icon : Icon(
                    Icons.email_outlined,
                    color: Color(0xff7971ea)),
                disabledBorder: InputBorder.none,
                labelText: "Email",
                hintText: "contoh@gmail.com",
                labelStyle: TextStyle(color: Color(0xff8480e5)),
                hintStyle: TextStyle(color: Color(0xff8480e5))),
            validator: (val) =>
            val == null || val.isEmpty ? 'Email wajib diisi' : null
        )
    );
  }
}