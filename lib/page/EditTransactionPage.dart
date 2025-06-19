import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:godvlan/model/Transaksi.dart';
import 'package:godvlan/page/TransactionListPage.dart';
import 'package:godvlan/service/AuthService.dart';
import 'package:godvlan/widget/DescriptionInputField.dart';
import 'package:godvlan/widget/JenisTransaksiDropdown.dart';
import 'package:godvlan/widget/NominalInputField.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:sqflite/sqflite.dart';
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
  final _dateController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _nominalController = TextEditingController();

  Transaksi? transaksi;
  String? _jenisTransaksi;
  bool _isLoading = false;
  String? _errorMessage;
  final String _api_url = dotenv.get('API_URL');

  @override
  void initState() {
    getTransaction();
    super.initState();
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    _nominalController.dispose();
    super.dispose();
  }

  // Future<dynamic> _mockEditTransaction() async {
  //   setState(() {
  //     _errorMessage = "Gaga Mengedit Transaksi Test";
  //     _isLoading = true;
  //   });
  //   await Future.delayed(Duration(seconds: 5));
  //   setState(() {
  //     _isLoading = false;
  //   });
  //   Navigator.pop(context);
  // }

  Future<dynamic> getTransaction() async{
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    final String? transactionId = widget.transactionId;
    final url = Uri.parse('$_api_url/api/transaction/history/$transactionId');
    final token = await AuthService.getToken();
    if (token == null){
      throw Exception('User Unauthorized');
    }
    final header = {
      'Content-type' : 'application/json',
      'Authorization' : token
    };
    try{
      final response = await http.get(url, headers: header);
      if (response.statusCode == 200){
        final data = jsonDecode(response.body)['data'];
        setState(() {
          transaksi = Transaksi.fromJson(data);
          _jenisTransaksi = transaksi!.jenisTransaksi.name;
          _descriptionController.text = data['deskripsi'] ?? '';
          _nominalController.text = data['nominal']?.toString() ?? '';
          transaksi!.createdAt = DateTime.parse(data['tanggalTransaksi']);
          _isLoading = false;
          _errorMessage = null;
        });
      } else {
        final error = jsonDecode(response.body);
        setState(() {
          _isLoading = false;
          _errorMessage = error['errors']['message'] ?? 'Gagal Mengambil Transaksi';
        });
      }
    } on http.ClientException catch (e){
      setState(() {
        _errorMessage= ('Tidak dapat terhubung ke server. $e');
        _isLoading = false;
      });
    } catch (e){
      setState(() {
        _errorMessage = 'Terjadi Kesalahan saat memuat transaksi. Coba Lagi : $e';
        _isLoading = false;
      });
    }
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
    final url = Uri.parse('$_api_url/api/transaction/edit/$transactionId');
    final token = await AuthService.getToken();
    if (token == null){
      throw Exception('User Unauthorized');
    }
    final header = {
      'Content-type' : 'application/json',
      'Authorization' :  token
    };
    final body = json.encode({
      'tanggalTransaksi': transaksi?.createdAt.toIso8601String(),
      'jenisTransaksi' : _jenisTransaksi.toString(),
      'nominal' : int.tryParse(_nominalController.text) ?? 0,
      'deskripsi' : _descriptionController.text,

    });
    try{
      final response = await http.patch(url, headers: header, body:body);
      if (response.statusCode == 200){
        final data = json.decode(response.body)['data'];
        setState(() {
          transaksi = Transaksi.fromJson(data);
          _isLoading = false;
          _errorMessage = null;
        });
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>HomePage()));
      } else {
        final error = json.decode(response.body);
        setState(() {
          _isLoading = false;
          _errorMessage = error['errors']['message'] ?? 'Gagal Menambah Transaksi';
        });
      }
    } catch (e){
      _isLoading = false;
      _errorMessage = 'Terjadi Kesalahan saat menambah transaksi. Coba Lagi : $e';
    }
  }

  Future<void> _selectDate() async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2050),
    );

    setState(() {
      transaksi?.createdAt = pickedDate!;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios_new_rounded, size: 18, color: Color(0xff7971ea)), // contoh pakai chevron
            onPressed: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>HomePage())),
          ),
          elevation: 4,
          backgroundColor: (Color(0xffdfe2fe)),
          title: Text("Edit Transaksi",
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
                        initialValue: _jenisTransaksi,
                        onItemSelected: (String? value){
                          setState(() {
                            _jenisTransaksi = value;
                          });
                        }
                    ),

                    SizedBox(height: 10),

                    Padding(
                        padding: EdgeInsets.symmetric(horizontal : MediaQuery.of(context).size.width * 0.1),
                        child:
                        Row( children: [
                          Expanded(child:
                          Text(
                            transaksi?.createdAt != null ?
                            '${transaksi!.createdAt.day}-${transaksi!.createdAt.month}-${transaksi!.createdAt.year}' : 'No date to display',
                            style: TextStyle(color: Color(0xff8480e5))
                          )),
                          IconButton(
                              onPressed: _selectDate,
                              icon: Icon(Icons.date_range_rounded, color: Color(0xff8480e5))
                          )
                        ])
                    ),

                    SizedBox(height: MediaQuery.of(context).size.height * 0.05),

                    Padding(
                        padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width * 0.10),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            ElevatedButton(
                                onPressed:  () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>HomePage())),
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
                                onPressed: editTransaction,
                                child: Text(
                                    "Edit Transaksi",
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