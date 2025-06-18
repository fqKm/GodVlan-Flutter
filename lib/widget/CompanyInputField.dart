import 'package:flutter/material.dart';

class CompanyInputField extends StatelessWidget {
  final TextEditingController controller;
  final bool isRequired; // Add a new property to control required status

  const CompanyInputField({
    super.key,
    required this.controller,
    this.isRequired = false, // Default to not required
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width * 0.10),
      child: TextFormField(
        keyboardType: TextInputType.text,
        controller: controller,
        decoration: InputDecoration(
          icon: Icon(Icons.business_outlined, color: Color(0xff7971ea)),
          disabledBorder: InputBorder.none,
          labelText: "Company",
          labelStyle: TextStyle(color: Color(0xff8480e5)),
        ),
        validator: (val) {
          // If isRequired is true, apply the validation rule
          if (isRequired && (val == null || val.isEmpty)) {
            return 'company wajib diisi';
          }
          // If not required, or if required and has a value, return null (no error)
          return null;
        },
      ),
    );
  }
}