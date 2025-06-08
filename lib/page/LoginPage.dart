import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:godvlan/page/HomePage.dart';
import 'package:godvlan/page/RegisterPage.dart';
import 'package:godvlan/service/AuthService.dart';
import 'package:godvlan/widget/EmailInputField.dart';
import 'package:godvlan/widget/PasswordInputField.dart';
import 'package:http/http.dart' as http;

class LoginPage extends StatefulWidget{
  const LoginPage({super.key});

  @override
  _LoginPage createState() => _LoginPage();
}

class _LoginPage extends State<LoginPage>{
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isLoading = false;
  String? _errorMessage;
  bool _obscurePassword = true;

  Future<dynamic> _mockLogin() async {
    setState(() {
      _errorMessage = "Error Login Test";
      _isLoading = true;
    });
    await Future.delayed(Duration(seconds: 10));
    setState(() {
      _isLoading = false;
    });
    AuthService.saveToken("token");
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=> HomePage()));
  }

  Future<void> login() async {
    if(!_formKey.currentState!.validate()){
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final url = Uri.parse('localhost:8000:/api/user/login');
    final header = {
      'Content-type' : 'application/json'
    };
    try{
      final response = await http.post(
        url,
        headers : header,
        body: json.encode({
          'email' : _emailController.text,
          'password' : _passwordController.text
        })
      );
      if(response.statusCode == 200){
        final data = json.decode(response.body);
        final token = data['token'];

        AuthService.saveToken(token);
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => HomePage()));
      }

      else{
        final error = json.decode(response.body);
        setState(() {
          _errorMessage = error['message'] ?? 'Gagal Login Ulangi Kembali';
        });
      }
    } catch (e){
      setState(() {
        _errorMessage = "Gagal Login Ulangi Kembali";
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
          body: Center(
            child: Form(
              key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    //Godvlan Icon
                    Text(
                        "Silakan Login",
                        style: TextStyle(
                            color: Color(0xff7971ea),
                            fontWeight: FontWeight.w900,
                            fontSize: 20
                        )
                    ),

                    SizedBox(
                      height: 10,
                    ),

                    if(_errorMessage != null)
                      Text(
                          _errorMessage!,
                          style: TextStyle(
                              color: Colors.redAccent,
                              fontWeight: FontWeight.w500,
                              fontSize: 12
                          )
                      ),

                    EmailInputField(
                        controller: _emailController
                    ),

                    SizedBox(
                      height: 10,
                    ),

                    PasswordInputField(
                        controller: _passwordController,
                        obscureText: _obscurePassword,
                        toggleObscure: ()
                        {
                          setState(()
                          {
                            _obscurePassword = !_obscurePassword;
                          });
                        }
                        ),

                    SizedBox(
                      height: 10,
                    ),



                    TextButton(
                        onPressed: () => {
                          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => RegisterPage()))
                        },
                        child: Text(
                                  "Saya belum memiliki akun",
                                  style: TextStyle(
                                      fontSize: 12,
                                      color: Color(0xff7971ea),
                                      fontWeight: FontWeight.w300
                                  )
                              )
                    ),

                    _isLoading? Center(child:CircularProgressIndicator(color: Color(0xff7971ea))) : ElevatedButton(
                        onPressed: _mockLogin,
                        child: Text(
                            "Login",
                            style: TextStyle(
                                fontSize: 12,
                                color: Color(0xff7971ea),
                                fontWeight: FontWeight.w900
                            )
                        )
                    )
                  ],
                )
            ),
          )
    );
  }
}