import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:godvlan/db/SqliteHelper.dart';
import 'package:godvlan/model/Transaksi.dart';
import 'package:godvlan/service/AuthService.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:intl/intl.dart';
import 'package:sqflite/sqflite.dart';

final GlobalKey<_TransactionListPage> transactionListPageKey = GlobalKey<_TransactionListPage>();
class TransactionListPage extends StatefulWidget{
  const TransactionListPage({
    Key? key, // Pastikan ada Key parameter
  }) : super(key: key); // Meneruskan key ke super constructor

  @override
  _TransactionListPage createState() => _TransactionListPage();
}

class _TransactionListPage extends State<TransactionListPage>{
  List<Transaksi> _transactions = [];
  bool _isLoading = true;
  final storage = FlutterSecureStorage();
  String? _errorMessage = null;

  Future<void> refreshTransactions() async {
    print('TransactionListPage: Menerima permintaan refresh dari HomePage');
    await _mockLoadTransaction(); // Memanggil metode load data yang sudah ada
  }
  @override
  void initState() {
    super.initState();
    _mockLoadTransaction();
  }

  Future<void> _mockLoadTransaction() async{
      setState(() {
        _isLoading = true; // Set loading state to true
        _errorMessage = null; // Clear previous error
      });

      try {
        await _fetchTransactionFromLocal();
      } catch (e) {
        // Tangani error jika _fetchTransactionFromLocal gagal
        setState(() {
          _errorMessage = 'Gagal memuat transaksi lokal: $e';
        });
      } finally {
        setState(() {
          _isLoading = false; // <--- SET LOADING KE FALSE DI SINI
        });
      }
  }
  Future<void> _loadTransaction() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // await _fetchTransactionFromApi();
    } catch (e) {
      print('gagal fetch dari API : $e. Mencoba fetch dari sqlite..');
      setState(() {
        _errorMessage = 'Gagal memuat data dari server. Menampilkan data offline.';
      });
      await _fetchTransactionFromLocal();
    } finally {
      setState(() {
        _isLoading = false;
      });
  }
  }

  Future<void> _fetchTransactionFromLocal() async {
    try {
      final localTransactions = await SqliteHelper.instance.getAllTransaction();
      setState(() {
        _transactions = localTransactions;
        _errorMessage = null;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Gagal memuat transaksi dari penyimpanan lokal: $e';
      });
    }
  }

  Future<void> _syncTransactionToSQLite(List<Transaksi> newTransactions) async {
    final sqliteHelper = SqliteHelper.instance;

    for (var transaction in newTransactions){
      await sqliteHelper.insertTransaction(transaction);
    }
  }

  Future<void> _fetchTransactionFromApi() async{
    final url = Uri.parse('localhost:8000:/api/transaction');
    final token = await AuthService.getToken();
    if(token == null) {
      throw Exception("User UnAuthorized");
    }
    final header = {
      'Content-type' : 'application/json',
      'Authorization' : 'Bearer : $token'
    };

    try {
      final response = await http.get(url, headers: header);
      if (response.statusCode == 200){
        List<dynamic> data = json.decode(response.body);
        List<Transaksi> fetchedTransaction = data.map((json) => Transaksi.fromJson(json)).toList();

        await _syncTransactionToSQLite(fetchedTransaction);

        setState(() {
          _transactions = fetchedTransaction;
          _isLoading = false;
        });
      } else {
        final error = json.decode(response.body);
        setState(() {
          _errorMessage = error['message'] ?? 'Gagal Memuat Transaksi';
        });
      }
    } on http.ClientException catch (e){
      throw Exception('Tidak dapat terhubung ke server');
    } catch (e){
      _errorMessage = 'Terjadi Kesalahan saat memuat transaksi. Coba Lagi : $e';
    }

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Daftar Transaksi'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _mockLoadTransaction,
            tooltip: 'Refresh Transaksi',
          )
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
          ? Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                _errorMessage!,
                style: const TextStyle(color: Colors.red, fontSize: 16),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _mockLoadTransaction,
                child: const Text('Coba Lagi'),
              ),
            ],
          ),
        ),
      )
          : _transactions.isEmpty
          ? const Center(
        child: Text('Belum ada transaksi.'),
      )
          : SingleChildScrollView(
        scrollDirection: Axis.horizontal, // Agar tabel bisa discroll horizontal
        child: DataTable(
          columnSpacing: 24.0, // Jarak antar kolom
          dataRowMinHeight: 48.0,
          dataRowMaxHeight: 60.0,
          showCheckboxColumn: false,
          columns: const <DataColumn>[
            DataColumn(
              label: Text(
                'Tanggal',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            DataColumn(
              label: Text(
                'Deskripsi',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            DataColumn(
              label: Text(
                'Nominal',
                style: TextStyle(fontWeight: FontWeight.bold),
                textAlign: TextAlign.right,
              ),
              numeric: true,
            ),
            DataColumn(
              label: Text(
                'Jenis',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
          rows: _transactions.map((transaction) {
            return DataRow(
              onSelectChanged: (isSelected) {
                if (isSelected ?? false) {
                  // _navigateToTransactionDetail(transaction);
                  print("Yuhu");
                }
              },
              cells: <DataCell>[
                DataCell(Text(DateFormat('dd MMM yyyy').format(transaction.createdAt))),
                DataCell(
                  SizedBox( // Gunakan SizedBox untuk membatasi lebar deskripsi
                    width: 150, // Sesuaikan lebar yang diinginkan
                    child: Text(
                      transaction.deskripsi,
                      overflow: TextOverflow.ellipsis, // Tambahkan ellipsis jika teks terlalu panjang
                    ),
                  ),
                ),
                DataCell(
                  Text(
                    NumberFormat.currency(locale: 'id', symbol: 'Rp ').format(transaction.nominal),
                    textAlign: TextAlign.right,
                    style: TextStyle(
                      color: transaction.jenisTransaksi == JenisTransaksi.income ? Colors.green : Colors.red,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                DataCell(Text(transaction.jenisTransaksi == JenisTransaksi.income ? 'Masuk' : 'Keluar')),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }
}