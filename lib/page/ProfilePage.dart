import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:godvlan/page/LoginPage.dart';
import 'package:godvlan/service/AuthService.dart';
import 'package:godvlan/widget/AppBar.dart';
import 'package:http/http.dart' as http;
class ProfilePage extends StatefulWidget {
  const ProfilePage({
    Key? key,
  }) : super(key: key);

  @override
  _ProfilePage createState()=> _ProfilePage();
}

class _ProfilePage extends State<ProfilePage>{
  final String _api_url = dotenv.get('API_URL');
  bool _isLoading = false;
  bool _isEdited = false;
  String? _errorMessage;
  String? _name;
  String? _email;
  String? _company;

  @override
  void initState() {
    super.initState();
    getProfile();
  }
  Future<void> getProfile() async{
    setState(() {
      _errorMessage = null;
      _isLoading = true;
    });
    final token = await AuthService.getToken();
    final uri = Uri.parse('$_api_url/api/profile');
    if(token == null){
      setState(() {
        _errorMessage = 'User Unauthorized, Please Login';
        _isLoading = false;
      });
    }
    final header = {
      'Content-type' : 'application/json',
      'Authorization' : '$token'
    };

    try {
      final response = await http.get(uri, headers: header);
      if(response.statusCode == 200){
        final data = jsonDecode(response.body)['data'];
        setState(() {
          _name = data['name']??'coeg';
          _email = data['email']??'email ilang cok';
          _company = data['company']??'company ga kebaca';
          _isLoading = false;
          _errorMessage = null;
        });
      } else {
        final error = json.decode(response.body);
        setState(() {
          _errorMessage = error['errors']['messages'] ?? 'Gagal Fetch Data Profile';
          _isLoading = false;
        });
      }
    } catch(e) {
      setState(() {
        _errorMessage = 'Error : $e';
        _isLoading = false;
      });
    } finally {
      setState(() {
        _errorMessage = null;
        _isLoading = false;
      });
    }
  }

  Future<void> logout() async {
    setState(() {
      _errorMessage = null;
      _isLoading = true;
    });
    final token = await AuthService.getToken();
    final uri = Uri.parse('$_api_url/api/logout');
    if(token == null){
      setState(() {
        _errorMessage = 'User Unauthorized, Please Login';
        _isLoading = false;
      });
    }
    final header = {
      'Content-type' : 'application/json',
      'Authorization' : '$token'
    };

    try{
      final response = await http.delete(uri, headers: header);
      if(response.statusCode == 200){
        final data = jsonDecode(response.body)['data'];
        setState(() {
          _errorMessage = null;
          _isLoading = false;
        });
        AuthService.deleteToken();
        if(mounted) {
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>LoginPage()));
        }
      } else {
        final error = json.decode(response.body);
        setState(() {
          _errorMessage = error['errors']['messages'] ?? 'Gagal Logout';
          _isLoading = false;
        });
      }
    } catch(e) {
      setState(() {
        _errorMessage = 'Error Logout : $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(preferredSize: Size.fromHeight(56),
          child: MyAppBar(title: "Profile")),
      body: SafeArea(child:
      _errorMessage != null?
      Text(
        _errorMessage!,
        style: const TextStyle(color: Colors.red, fontSize: 16),
        textAlign: TextAlign.center,
      ) :
      Column(
        children: [
          SizedBox(height: MediaQuery.of(context).size.height * 0.05),

          Center(child: Icon(Icons.person_2_rounded, color: Color(0xff8480e5), size: 48,)),

          SizedBox(height: 10),

          ListTile(
            title: Text("Name"),
            subtitle: Text(_name ?? 'Load'),
            titleTextStyle: TextStyle(color: Color(0xff8480e5), fontWeight: FontWeight.w500, fontSize: 20),
            subtitleTextStyle: TextStyle(color: Color(0xff9896e3), fontSize: 16),
          ),
          SizedBox(height: 10),

          ListTile(
            title: Text("Email"),
            subtitle: Text(_email?? 'Load'),
            titleTextStyle: TextStyle(color: Color(0xff8480e5), fontWeight: FontWeight.w500, fontSize: 20),
            subtitleTextStyle: TextStyle(color: Color(0xff9896e3), fontSize: 16),
          ),

          SizedBox(height: 10),
          ListTile(
            title: Text("Company"),
            subtitle: Text(_company?? 'Load'),
            titleTextStyle: TextStyle(color: Color(0xff8480e5), fontWeight: FontWeight.w500, fontSize: 20),
            subtitleTextStyle: TextStyle(color: Color(0xff9896e3), fontSize: 16),
          ),

          SizedBox(height: MediaQuery.of(context).size.height * 0.40),

          Padding(padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width * 0.10), child:
          Row(mainAxisAlignment: MainAxisAlignment.end, children: [
            _isLoading? Center(child:CircularProgressIndicator(color: Color(0xff7971ea))) : ElevatedButton(
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all(Colors.redAccent),
                ),
                onPressed: logout,
                child: Text(
                    "LogOut",
                    style: TextStyle(
                        fontSize: 12,
                        color:  Colors.white,
                        fontWeight: FontWeight.w900
                    )
                )
            ),
          ],)
          )
        ],
      ),
    )
    );
  }

}