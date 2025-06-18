import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:godvlan/model/Transaksi.dart';
import 'package:godvlan/page/TransactionListPage.dart';
import 'package:godvlan/service/AuthService.dart';
import 'package:godvlan/widget/DescriptionInputField.dart';
import 'package:godvlan/widget/JenisTransaksiDropdown.dart';
import 'package:godvlan/widget/NominalInputField.dart';
import 'package:http/http.dart' as http;
import 'package:uuid/uuid.dart';

import '../db/SqliteHelper.dart';
import 'HomePage.dart';

class AddTransactionPage extends StatefulWidget{
  const AddTransactionPage({
    super.key
  });

  @override
  State<AddTransactionPage> createState() {
    return _AddTransactionPage();
  }
}

class _AddTransactionPage extends State<AddTransactionPage>{
  final _formKey = GlobalKey<FormState>();
  final _descriptionController = TextEditingController();
  final _nominalController = TextEditingController();

  String? _jenisTransaksi;
  bool _isLoading = false;
  String? _errorMessage;
  final String _api_url = 'https://ac-interracial-ent-audio.trycloudflare.com';

  @override
  void dispose(){
    _descriptionController.dispose();
    _nominalController.dispose();
    super.dispose();
  }

  Future<dynamic> addTransaction() async{
    if(!_formKey.currentState!.validate()){
      return;
    }
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final url = Uri.parse('$_api_url/api/transaction/add');
    final token = await AuthService.getToken();
    if (token == null){
      setState(() {
        _errorMessage = ('User Unauthorized');
        _isLoading = false;
      });
      return;
    }
    final header = {
      'Content-type' : 'application/json',
      'Authorization' : token
    };
    final body = json.encode({
      'tanggalTransaksi' : DateTime.now().toIso8601String(),
      'jenisTransaksi' : _jenisTransaksi.toString(),
      'nominal' : _nominalController.text,
      'deskripsi' : _descriptionController.text,
    });

    try{
      final response = await http.post(url, headers: header, body: body);
      if (response.statusCode == 201){
        final data = json.decode(response.body);
        Navigator.pop(context, true);
      } else {
        final error = json.decode(response.body);
        setState(() {
          _errorMessage = error['errors']['message'] ?? 'Gagal Menambah Transaksi';
          _isLoading = false;
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
            fontWeight: FontWeight.w700,
              color: Color(0xff7971ea),
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
                            onPressed: addTransaction,
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