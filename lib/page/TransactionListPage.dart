import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:godvlan/db/SqliteHelper.dart';
import 'package:godvlan/model/Transaksi.dart';
import 'package:godvlan/service/AuthService.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:intl/intl.dart';

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
  String? _errorMessage;
  int? _selectedYear;
  List<int> _availableYears = [];
  final String _api_url = 'https://ac-interracial-ent-audio.trycloudflare.com';

  @override
  void initState() {
    super.initState();
    _initializeYears();
    fetchTransactionFromApi();
  }

  void _initializeYears() {
    final currentYear = DateTime.now().year;
    for (int i = 0; i < 4; i++) {
      _availableYears.add(currentYear - i);
    }
    _selectedYear = currentYear;
  }

  Future<void> fetchTransactionFromApi({int? year}) async{
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    final int tahun = year ?? DateTime.now().year;
    final DateTime startDate = DateTime(tahun, 1, 1);
    final DateTime endDate = DateTime((tahun + 1), 1, 1);

    String startDateStr = DateFormat('yyyy-MM-dd').format(startDate);
    String endDateStr = DateFormat('yyyy-MM-dd').format(endDate);

    final url = Uri.parse('$_api_url/api/transaction/history/date_range?start_date=$startDateStr&end_date=$endDateStr');
    final token = await AuthService.getToken();
    if(token == null) {
      setState(() {
        _errorMessage = "User Unauthorized. Harap Login Kembali";
        _isLoading = false;
      });
      return;
    }
    final header = {
      'Content-type' : 'application/json',
      'Authorization' : token
    };

    try {
      final response = await http.get(url, headers: header);
      if (response.statusCode == 200){
        List<dynamic> data = json.decode(response.body)['data'];
        List<Transaksi> fetchedTransaction = data.map((json) => Transaksi.fromJson(json)).toList();

        setState(() {
          _transactions = fetchedTransaction;
          _isLoading = false;
        });
      } else {
        final error = json.decode(response.body);
        setState(() {
          _errorMessage = error["errors"]['message'] ?? 'Gagal Memuat Transaksi';
          _isLoading = false;
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
            'Daftar Transaksi',
        style: TextStyle(
          color: Color(0xff7971ea),
          fontWeight: FontWeight.w900
        ),),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Color(0xff7971ea),),
            onPressed: () => fetchTransactionFromApi(),
            tooltip: 'Refresh Transaksi',
          )
        ],
      ),
      body:
      Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              DropdownButtonFormField<int?>(
                decoration: const InputDecoration(
                  labelText: 'Tahun',
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 0)
                ),
                value: _selectedYear,
                items: [
                  const DropdownMenuItem(value: null, child: Text('Semua Tahun')),
                  ..._availableYears.map((year) =>
                      DropdownMenuItem(value: year, child: Text(year.toString()))
                  ),
                ],
                onChanged: (int? newValue) {
                  setState(() {
                    _selectedYear = newValue;
                  });
                  fetchTransactionFromApi(year: _selectedYear);
                },
              ),

              _isLoading
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
                        onPressed: () => fetchTransactionFromApi,
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
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  columnSpacing: 24.0,
                  dataRowMinHeight: 48.0,
                  dataRowMaxHeight: 60.0,
                  showCheckboxColumn: false,
                  columns: const <DataColumn>[
                    DataColumn(
                      label: Text(
                        'Tanggal',
                        style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xff7971ea)),
                      ),
                    ),
                    DataColumn(
                      label: Text(
                        'Deskripsi',
                        style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xff7971ea)),
                      ),
                    ),
                    DataColumn(
                      label: Text(
                        'Nominal',
                        style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xff7971ea)),
                        textAlign: TextAlign.right,
                      ),
                      numeric: true,
                    )
                  ],
                  rows: _transactions.map((transaction) {
                    return DataRow(
                      onSelectChanged: (isSelected) {
                        if (isSelected ?? false) {
                          print("Yuhu");
                        }
                      },
                      cells: <DataCell>[
                        DataCell(Text(
                            DateFormat('dd MMM yyyy').format(transaction.createdAt), style: TextStyle(color: Color(0xff7971ea)))),
                        DataCell(
                          SizedBox(
                            width: 150,
                            child: Text(
                              transaction.deskripsi,
                              style: TextStyle(color: Color(0xff7971ea)),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                        DataCell(
                          Text(
                            NumberFormat.currency(locale: 'id', symbol: 'Rp ').format(transaction.nominal),
                            textAlign: TextAlign.right,
                            style: TextStyle(
                              color: transaction.jenisTransaksi == JenisTransaksi.pemasukan ? Colors.green : Color(0xffff004d),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    );
                  }).toList(),
                ),
              ),
            ],
          )
      )
    );
  }
}