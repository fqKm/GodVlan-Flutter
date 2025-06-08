import 'package:flutter/material.dart';
class NominalInputField extends StatelessWidget{
  final TextEditingController controller;
  
  const NominalInputField({
    super.key,
    required this.controller
  });
  
  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: EdgeInsets.symmetric(horizontal : MediaQuery.of(context).size.width * 0.1), 
        child: TextFormField(
          keyboardType: TextInputType.number,
          controller: controller,
          decoration: InputDecoration(
              icon: Icon(Icons.attach_money_rounded, color: Color(0xff7971ea)),
              disabledBorder: InputBorder.none,
              labelText: "Nominal",
              labelStyle: TextStyle(color: Color(0xff8480e5)),
              hintText: "10.000.000",
              hintStyle: TextStyle(color: Color(0xff8480e5))
          ),
    ));
  }
}