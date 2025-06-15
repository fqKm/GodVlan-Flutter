import 'package:flutter/material.dart';

class ChatBubble extends StatelessWidget{
  final String text;
  final bool isUser;

  const ChatBubble({
    Key? key,
    required this.text,
    required this.isUser,
}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Align( alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
    child: Container(
      margin: EdgeInsets.symmetric(vertical: 12, horizontal: 12),
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isUser? Color(0xff7971ea) :
        Color(0xffdfe2fe),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(isUser? 16 : 0),
          topRight: Radius.circular(isUser? 0 : 0),
          bottomLeft: Radius.circular(16),
          bottomRight: Radius.circular(16)
        )
      ),
      child: Text(
        text,
        style: TextStyle(
          color: Colors.black87
        ),
      ),
    ),
    );
  }
}