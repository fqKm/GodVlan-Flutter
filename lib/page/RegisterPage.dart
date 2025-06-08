import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:godvlan/page/LoginPage.dart';
import 'package:godvlan/widget/EmailInputField.dart';
import 'package:godvlan/widget/PasswordInputField.dart';
import 'package:http/http.dart' as http;

import '../service/AuthService.dart';
import 'HomePage.dart';

class RegisterPage extends StatefulWidget{
  const RegisterPage({super.key});

  @override
  _RegisterPage createState() => _RegisterPage();
}

class _RegisterPage extends State<RegisterPage>{
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();
  final _companyController = TextEditingController();

  bool _isLoading = false;
  String? _errorMessage;
  bool _obscurePassword = true;

  Future<dynamic> mockRegister() async{
    setState(() {
      _isLoading = true;
      _errorMessage = 'Error Register Test';
    });

    await Future.delayed(Duration(seconds: 10));
    AuthService.saveToken('token');
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=> HomePage()));
  }

  Future<void> register() async{
    if(!_formKey.currentState!.validate()){
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final url = Uri.parse('localhost:8000:/api/user');
    final header = {
      'Content-type' : 'application/json'
    };

    try{
      final response = await http.post(
          url,
          headers: header,
          body: json.encode({
            'email' : _emailController.text,
            'password' : _passwordController.text,
            'name' : _nameController.text,
            'company' : _companyController.text
          })
      );

      if(response.statusCode == 201){
        final data = json.decode(response.body);
        final token = data['token'];

        AuthService.saveToken(token);
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => HomePage()));
      } else {
        final error = json.decode(response.body);
        setState(() {
          _errorMessage = error['message'] ?? 'Gagal Login Ulangi Kembali';
        });
      }
    } catch (e){
      setState(() {
        _errorMessage = 'Gagal Register Ulangi Lagi!';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body : Center(
        child: Form(
            key : _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "Silakan Register",
                  style:
                  TextStyle(
                    color: Color(0xff7971ea),
                    fontWeight: FontWeight.w500,
                    fontSize: 12
                  )
                ),

                SizedBox(height: 10),

                if(_errorMessage != null)
                  Text(
                      _errorMessage!,
                      style: TextStyle(
                          color: Colors.redAccent,
                          fontWeight: FontWeight.w900,
                          fontSize: 20
                      )
                  ),

                SizedBox(height: 10),

                EmailInputField(controller: _emailController),

                SizedBox(height: 10),

                PasswordInputField(
                    controller: _passwordController,
                    obscureText: _obscurePassword,
                    toggleObscure: ()
                    {
                      setState(() {
                        _obscurePassword = !_obscurePassword;
                      });
                    }
                    ),

                SizedBox(height: 10),

                Padding(
                  padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width * 0.10),
                  child: TextFormField(
                    keyboardType: TextInputType.name,
                    controller: _nameController,
                    decoration: InputDecoration(
                        icon : Icon(Icons.person_outline, color: Color(0xff7971ea)),
                        disabledBorder: InputBorder.none,
                        labelText: "Nama Anda",
                        labelStyle: TextStyle(color: Color(0xff8480e5))
                    )
                  ),
                ),

                Padding(
                  padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width * 0.20),
                  child: TextFormField(
                      controller: _companyController,
                      decoration: InputDecoration(
                          disabledBorder: InputBorder.none,
                          labelText: "Nama Usaha",
                          labelStyle: TextStyle(color: Color(0xff8480e5))
                      )
                  ),
                ),

                TextButton(
                    onPressed: () => {
                      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => LoginPage()))
                    },
                    child: Text(
                        "Saya sudah memiliki akun",
                        style: TextStyle(
                            fontSize: 12,
                            color: Color(0xff7971ea),
                            fontWeight: FontWeight.w300
                        )
                    )
                ),

                SizedBox(height: 10),

                _isLoading? Center(child: CircularProgressIndicator(color: Color(0xff7971ea))) :
                ElevatedButton(
                    onPressed: mockRegister,
                    child: Text(
                      "Register",
                      style: TextStyle(
                        fontSize: 12,
                        color: Color(0xff7971ea),
                        fontWeight: FontWeight.w900
                      ),
                    )
                )
              ],
            )
        ),
      )
    );
  }
}