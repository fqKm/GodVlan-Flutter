import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:godvlan/model/Transaksi.dart';
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

  @override
  void dispose(){
    _descriptionController.dispose();
    _nominalController.dispose();
    super.dispose();
  }
  Future<dynamic> _mockAddTransaction() async {
    setState(() {
      _errorMessage = "Gagal Menambah Transaksi Test";
      _isLoading = true;
    });

    final uuid = Uuid();
    final mockId = uuid.v4();

    final nominalValue = int.tryParse(_nominalController.text);
    if (nominalValue == null) {
      setState(() {
        _errorMessage = 'Nominal harus berupa angka yang valid.';
        _isLoading = false;
      });
      return;
    }
    final newTransaction = Transaksi(
      id: mockId, // Gunakan UUID yang baru dibuat sebagai ID
      nominal: nominalValue,
      deskripsi: _descriptionController.text,
      jenisTransaksi: JenisTransaksi.values.firstWhere((e) => e.name == _jenisTransaksi!),
      createdAt: DateTime.now(),
    );


    try {
      await SqliteHelper.instance.insertTransaction(newTransaction);
      print('Transaksi berhasil ditambahkan ke SQLite (mock) dengan ID: $mockId'); // Tambahkan log ID
      await Future.delayed(const Duration(seconds: 2));

      setState(() {
        _isLoading = false;
      });
      Navigator.pop(context, true);
    } catch (e) {
      setState(() {
        _errorMessage = 'Gagal menyimpan transaksi (mock): $e';
        _isLoading = false;
      });
    }
  }

  Future<dynamic> addTransaction() async{
    if(!_formKey.currentState!.validate()){
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final url = Uri.parse('localhost:8080:/api/transaction');
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
      'transaction_type' : _jenisTransaksi.toString(),
      'createdAt': DateTime.now().toIso8601String(),
    });

    try{
      final response = await http.post(url, headers: header, body: body);
      if (response.statusCode == 200){
        final data = json.decode(response.body);
        final newTransaction = Transaksi.fromJson(data);

        await SqliteHelper.instance.insertTransaction(newTransaction);
        print('Transaksi berhasil ditambahkan ke SQLite!');

        Navigator.pop(context, true);
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
                            onPressed: _mockAddTransaction,
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