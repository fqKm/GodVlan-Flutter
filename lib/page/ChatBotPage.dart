import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:godvlan/model/Message.dart';
import 'package:godvlan/service/AuthService.dart';
import 'package:godvlan/widget/ChatBubble.dart';
import 'package:godvlan/widget/SnackbarUtil.dart';
import 'package:http/http.dart' as http;

class ChatBotPage extends StatefulWidget {
  const ChatBotPage({super.key});

  @override
  _ChatBotPage createState() => _ChatBotPage();
}

class _ChatBotPage extends State<ChatBotPage>{
  final String _api_url = 'https://ac-interracial-ent-audio.trycloudflare.com';
  final TextEditingController _chatController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;
  List<Message> _messages = [];

  Future<void> _sendMessage() async{
    final message = _chatController.text.trim();
    setState(() {
      _messages.add(Message(text: message, isUser: true));
      _isLoading = true;
      _errorMessage = null;
    });

    _chatController.clear();

    final url = Uri.parse('$_api_url:/api/chatbot/ask');
    final token = await AuthService.getToken();
    if(token == null){
      throw Exception('User Unauthorized');
    }
    final header = {
      'Content-type' : 'application/json',
      'Authorization' : token
    };
    final body = jsonEncode({
      'prompt' : message
    });
    try{
      final response = await http.post(url, headers: header, body: body);
      if(response.statusCode == 200){
        final chatResponse = jsonDecode(response.body)['data'];
        _messages.add(Message(text: chatResponse, isUser: false));
        setState(() {
          _isLoading = false;
          _errorMessage = null;
        });
      } else {
        final error = jsonDecode(response.body);
        setState(() {
          _errorMessage = error['errors']['message']??"Tidak bisa menggunakan AI coba lagi";
          _isLoading = false;
        });
      }
    } catch (e){
      setState(() {
        _errorMessage = "Gagal Chat dengan Chatbot harap Coba Lagi : $e";
        _isLoading = false;
      });
    }
    Future.delayed(Duration(seconds: 5));
    setState(() {
      _errorMessage = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(children: [
        Expanded(child: ListView.builder(
            itemCount: _messages.length,
            itemBuilder: (context, index){
              final message = _messages[index];
              return ChatBubble(text: message.text, isUser: message.isUser);
            }),
        ),
        if (_errorMessage != null )
          Padding(
              padding: EdgeInsets.all(14),
              child: Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                    color: Color(0xffdfe2fe),
                    borderRadius: BorderRadius.circular(25)),
                child: Text(_errorMessage!, style: TextStyle(color: Colors.red[600])
                ),
              )
          ),

        Padding(
          padding: EdgeInsets.all(14),
          child: Row(children: [
            Expanded(child: TextField(
              controller: _chatController,
              decoration: InputDecoration(
                hintText: 'AI akan menjawab berdasarkan data transaksi anda',
                hintStyle: TextStyle(color: Colors.black12),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25),
                  borderSide: BorderSide.none
                ),
                filled: true,
                fillColor: Color(0xffdfe2fe),
                contentPadding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0)
              ),
            )),
            SizedBox(width: 8.0),
            _isLoading? CircularProgressIndicator() : ElevatedButton(
              onPressed: _sendMessage,
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all<Color>(Color(0xffdfe2fe)),
              ),
              child: Icon(Icons.send_rounded, color: Color(0xff7971ea)),
            ),
          ],),)
      ],),
    );
  }
}