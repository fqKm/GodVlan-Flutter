import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:godvlan/service/AuthService.dart';
import 'package:godvlan/widget/DescriptionInputField.dart';
import 'package:godvlan/widget/JenisTransaksiDropdown.dart';
import 'package:godvlan/widget/NominalInputField.dart';
import 'package:http/http.dart' as http;

import 'HomePage.dart';

class EditTransactionPage extends StatefulWidget{
  final String? transactionId;
  const EditTransactionPage({
    super.key,
    required this.transactionId
  });

  @override
  State<EditTransactionPage> createState() {
    return _EditTransactionPage();
  }
}

class _EditTransactionPage extends State<EditTransactionPage>{
  final _formKey = GlobalKey<FormState>();
  final _descriptionController = TextEditingController();
  final _nominalController = TextEditingController();

  List<dynamic> transactions = [];
  String? _jenisTransaksi;
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    _nominalController.dispose();
    super.dispose();
  }

  Future<dynamic> _mockEditTransaction() async {
    setState(() {
      _errorMessage = "Gaga Mengedit Transaksi Test";
      _isLoading = true;
    });
    await Future.delayed(Duration(seconds: 5));
    setState(() {
      _isLoading = false;
    });
    Navigator.pop(context);
  }

  Future<dynamic> editTransaction() async{
    if(!_formKey.currentState!.validate()){
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    final String? transactionId = widget.transactionId;
    final url = Uri.parse('localhost:8080:/api/transaction/$transactionId');
    final token = await AuthService.getToken();
    if (token == null){
      throw Exception('User Unauthorized');
    }
    final header = {
      'Content-type' : 'application/json',
      'Authorization' : 'Bearer : $token'
    };

    final body = json.encode({
      'nominal' : _nominalController.text,
      'description' : _descriptionController.text,
      'transaction_type' : _jenisTransaksi.toString()
    });

    try{
      final response = await http.patch(url, headers: header, body:body);
      if (response.statusCode == 200){
        List<dynamic> data = json.decode(response.body);
        setState(() {
          transactions = data;
          _isLoading = false;
        });
      } else {
        final error = json.decode(response.body);
        setState(() {
          _errorMessage = error['message'] ?? 'Gagal Menambah Transaksi';
        });
      }
    } catch (e){
      _errorMessage = 'Terjadi Kesalahan saat menambah transaksi. Coba Lagi';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios_new_rounded, size: 18, color: Color(0xff7971ea)), // contoh pakai chevron
            onPressed: () => Navigator.pop(context),
          ),
          elevation: 4,
          backgroundColor: (Color(0xffdfe2fe)),
          title: Text("Tambah Transaksi",
            style: TextStyle(
                color: Color(0xff7971ea),
                fontWeight: FontWeight.w700,
                fontSize: 18
            ),
          ),
        ),
        body: Center(
            child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if(_errorMessage != null)
                      Text(
                          _errorMessage!,
                          style: TextStyle(
                              color: Colors.redAccent,
                              fontWeight: FontWeight.w500,
                              fontSize: 12
                          )
                      ),

                    SizedBox(height: 10),

                    NominalInputField(controller: _nominalController),

                    SizedBox(height: 10),

                    DescriptionInputfield(controller: _descriptionController),

                    SizedBox(height: 10),

                    JenisTransaksiDropdown(
                        onItemSelected: (String? value){
                          setState(() {
                            _jenisTransaksi = value;
                          });
                        }
                    ),

                    SizedBox(height: MediaQuery.of(context).size.height * 0.05),

                    Padding(
                        padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width * 0.10),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            ElevatedButton(
                                onPressed:  () => Navigator.pop(context),
                                child: Text(
                                    "Cancel",
                                    style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.redAccent,
                                        fontWeight: FontWeight.w900
                                    )
                                )
                            ),

                            SizedBox(width: 20),

                            _isLoading? Center(child:CircularProgressIndicator(color: Color(0xff7971ea))) : ElevatedButton(
                                onPressed: _mockEditTransaction,
                                child: Text(
                                    "Tambah Transaksi",
                                    style: TextStyle(
                                        fontSize: 12,
                                        color: Color(0xff7971ea),
                                        fontWeight: FontWeight.w900
                                    )
                                )
                            ),
                          ],
                        ))

                  ],
                )
            )
        )
    );
  }
}