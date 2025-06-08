import 'package:flutter/material.dart';

class PasswordInputField extends StatelessWidget{
  final TextEditingController controller;
  final bool obscureText;
  final VoidCallback toggleObscure;

  const PasswordInputField({
    super.key,
    required this.controller,
    required this.obscureText,
    required this.toggleObscure
  });

  @override
  Widget build(BuildContext context) {
    return  Padding(
        padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width * 0.10),
        child: TextFormField(
          keyboardType: TextInputType.visiblePassword,
          controller: controller,
          obscureText: obscureText,
          decoration: InputDecoration(
              icon : Icon(Icons.password_outlined, color: Color(0xff7971ea)),
              disabledBorder: InputBorder.none,
              labelText: "Password",
              labelStyle: TextStyle(color: Color(0xff8480e5)),
              suffixIcon: IconButton(
                  icon : Icon(Icons.remove_red_eye_outlined, color: Color(0xff8480e5)),
                  onPressed: toggleObscure
              )
          ),
          validator: (val) =>
          val == null || val.isEmpty ? 'password wajib diisi' : null,
        )
    );
  }
  
}