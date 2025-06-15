import 'package:flutter/material.dart';
class SnackbarUtil{
  static void showError(BuildContext context, String? message){
    _showSnackBar(context, message, Colors.red[600]);
  }
  static void showSuccedd(BuildContext context, String? message){
    _showSnackBar(context, message, Colors.green[600]);
  }

  static void _showSnackBar(BuildContext context, String? message, Color? color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message!),
        behavior: SnackBarBehavior.floating,
        backgroundColor: color,
        duration: Duration(seconds: 3),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        margin: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      ),
    );
  }
}