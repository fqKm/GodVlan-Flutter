import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:godvlan/db/SqliteHelper.dart';
import 'package:godvlan/model/Transaksi.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../service/AuthService.dart';

class AnalysisPage extends StatefulWidget {
  const AnalysisPage({super.key});

  @override
  _AnalysisPage createState() => _AnalysisPage();
}

class _AnalysisPage extends State<AnalysisPage> {
  bool _isLoading = true;
  String? _errorMessage;
  List<Transaksi> _transactions = [];
  double _totalIncome = 0.0;
  double _totalOutcome = 0.0;
  Map<int, Map<String, double>> _monthlySummary = {};

  int? _selectedYear;
  int? _selectedMonth; // 1-12
  List<int> _availableYears = [];
  final String _api_url = dotenv.get('API_URL');

  @override
  void initState() {
    super.initState();
    _initializeYears();
    _loadAnalysisData();
  }

  void _initializeYears() {
    final currentYear = DateTime.now().year;
    for (int i = 0; i < 4; i++) {
      _availableYears.add(currentYear - i);
    }
  }

  Future<List<Transaksi>> _fetchFromAPI(DateTime startDate, DateTime endDate) async{
    String startDateStr = DateFormat('yyyy-MM-dd').format(startDate);
    String endDateStr = DateFormat('yyyy-MM-dd').format(endDate);

    final url = Uri.parse('$_api_url/api/transaction/history/date_range?start_date=$startDateStr&end_date=$endDateStr');
    final token = await AuthService.getToken();
    if(token == null) {
      setState(() {
        _errorMessage = "User Unauthorized. Harap Login Kembali";
        _isLoading = false;
      });
      return [];
    }
    final header = {
      'Content-type' : 'application/json',
      'Authorization' : token
    };

    try {
      final response = await http.get(url, headers: header);
      if (response.statusCode == 200){
        List<dynamic> data = json.decode(response.body)['data'];
        return data.map((json) => Transaksi.fromJson(json)).toList();
      } else {
        final error = json.decode(response.body);
        setState(() {
          _errorMessage = error['errors']['message'] ?? 'Gagal Memuat Transaksi';
          _isLoading = false;
        });
        return [];
      }
    } on http.ClientException catch (e){
      setState(() {
        _errorMessage= ('Tidak dapat terhubung ke server. $e');
        _isLoading = false;
      });
      return [];
    } catch (e){
      setState(() {
        _errorMessage = 'Terjadi Kesalahan saat memuat transaksi. Coba Lagi : $e';
        _isLoading = false;
      });
      return[];
    }
  }

  Future<void> _loadAnalysisData({int? year, int? month}) async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _transactions = [];
      _totalIncome = 0.0;
      _totalOutcome = 0.0;
      _monthlySummary = {};
    });

    try {
      List<Transaksi> fetchedTransactions;
      if (year != null) { // If no year is selected, load all transactions
          final DateTime startDate;
          final DateTime endDate;

          if (month != null) {
            startDate = DateTime(year, month, 1);
            endDate = (month < 12)
                ? DateTime(year, month + 1, 1)
                : DateTime(year + 1, 1, 1);
          } else {
            startDate = DateTime(year, 1, 1);
            endDate = DateTime(year + 1, 1, 1);
          }

          fetchedTransactions = await _fetchFromAPI(startDate, endDate);
      } else { // Load transactions for the selected year
        final now = DateTime.now();
        final startDate = DateTime(now.year - 1, now.month, now.day);
        final endDate = now;
        fetchedTransactions = await _fetchFromAPI(startDate, endDate);
      }

      // Filter by month if a month is selected
      if (month != null) {
        fetchedTransactions = fetchedTransactions.where((t) => t.createdAt.month == month).toList();
      }

      _transactions = fetchedTransactions;
      _processTransactionsForAnalysis(_transactions);
      setState(() {});
    } catch (e) {
      setState(() {
        _errorMessage = 'Gagal memuat data analisis: $e';
      });
      print('Error loading analysis data: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _processTransactionsForAnalysis(List<Transaksi> transactions) {
    double tempIncome = 0.0;
    double tempOutcome = 0.0;
    Map<int, Map<String, double>> tempMonthlySummary = {};

    for (var transaction in transactions) {
      if (transaction.jenisTransaksi == JenisTransaksi.pemasukan) {
        tempIncome += transaction.nominal;
      } else {
        tempOutcome += transaction.nominal;
      }

      final month = transaction.createdAt.month;
      if (!tempMonthlySummary.containsKey(month)) {
        tempMonthlySummary[month] = {'income': 0.0, 'outcome': 0.0};
      }
      if (transaction.jenisTransaksi == JenisTransaksi.pemasukan) {
        tempMonthlySummary[month]!['income'] = (tempMonthlySummary[month]!['income'] ?? 0.0) + transaction.nominal;
      } else {
        tempMonthlySummary[month]!['outcome'] = (tempMonthlySummary[month]!['outcome'] ?? 0.0) + transaction.nominal;
      }
    }

    _totalIncome = tempIncome;
    _totalOutcome = tempOutcome;
    _monthlySummary = tempMonthlySummary;
  }

  // Helper to get month name
  String _getMonthName(int month) {
    return DateFormat.MMM('id').format(DateTime(0, month));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                onPressed: () => _loadAnalysisData(year: _selectedYear, month: _selectedMonth),
                child: const Text('Coba Lagi'),
              ),
            ],
          ),
        ),
      )
          : SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Expanded(
                  child: DropdownButtonFormField<int?>(
                    decoration: const InputDecoration(
                        labelText: 'Tahun',
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 0)
                    ),
                    value: _selectedYear,
                    items: [
                      const DropdownMenuItem(value: null, child: Text('Semua Tahun')),
                      ..._availableYears.map((year) =>
                          DropdownMenuItem(value: year, child: Text(year.toString()))),
                    ],
                    onChanged: (int? newValue) {
                      setState(() {
                        _selectedYear = newValue;
                        _selectedMonth = null; // Reset month when year changes
                      });
                      _loadAnalysisData(year: _selectedYear, month: _selectedMonth);
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: DropdownButtonFormField<int?>(
                    decoration: const InputDecoration(
                        labelText: 'Bulan',
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 0)
                    ),
                    value: _selectedMonth,
                    items: [
                      const DropdownMenuItem(value: null, child: Text('Semua Bulan')),
                      for (int i = 1; i <= 12; i++)
                        DropdownMenuItem(value: i, child: Text(_getMonthName(i))),
                    ],
                    onChanged: (int? newValue) {
                      setState(() {
                        _selectedMonth = newValue;
                      });
                      _loadAnalysisData(year: _selectedYear, month: _selectedMonth);
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Card(
              elevation: 2,
              margin: const EdgeInsets.symmetric(vertical: 8),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Ringkasan Keuangan', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Total Pemasukan:', style: TextStyle(fontSize: 16)),
                        Text(
                          NumberFormat.currency(locale: 'id', symbol: 'Rp ').format(_totalIncome),
                          style: const TextStyle(fontSize: 16, color: Colors.green, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    const SizedBox(height: 5),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Total Pengeluaran:', style: TextStyle(fontSize: 16)),
                        Text(
                          NumberFormat.currency(locale: 'id', symbol: 'Rp ').format(_totalOutcome),
                          style: const TextStyle(fontSize: 16, color: Colors.red, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    const Divider(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Saldo Bersih:', style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
                        Text(
                          NumberFormat.currency(locale: 'id', symbol: 'Rp ').format(_totalIncome - _totalOutcome),
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                            color: (_totalIncome - _totalOutcome) >= 0 ? Colors.green[700] : Colors.red[700],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // --- Monthly Trend Chart (Bar Chart) ---
            const Text('Tren Bulanan', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            // Uncomment this section after adding fl_chart to pubspec.yaml
            SizedBox(
              height: 250,
              child: _monthlySummary.isEmpty
                  ? const Center(child: Text('Tidak ada data bulanan untuk ditampilkan.'))
                  : BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY: (_totalIncome > _totalOutcome ? _totalIncome : _totalOutcome) * 1.2, // Dynamic max Y
                  barGroups: _monthlySummary.entries.map((entry) {
                    final month = entry.key;
                    final income = entry.value['income'] ?? 0;
                    final outcome = entry.value['outcome'] ?? 0;
                    return BarChartGroupData(
                      x: month,
                      barRods: [
                        BarChartRodData(toY: income, color: Colors.green, width: 8),
                        BarChartRodData(toY: outcome, color: Colors.red, width: 8),
                      ],
                      showingTooltipIndicators: [0, 1], // Show tooltips for income and outcome bars
                    );
                  }).toList(),
                  titlesData: FlTitlesData(
                    show: true,
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) => Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Text(_getMonthName(value.toInt()), style: const TextStyle(fontSize: 10)),
                        ),
                        reservedSize: 30,
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) => Text(
                          NumberFormat.compact(locale: 'id').format(value), // Compact format (e.g., 100K)
                          style: const TextStyle(fontSize: 10),
                        ),
                        reservedSize: 40,
                      ),
                    ),
                    topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  ),
                  borderData: FlBorderData(
                    show: true,
                    border: Border.all(color: Colors.grey.withOpacity(0.5), width: 1),
                  ),
                  gridData: const FlGridData(show: true, drawVerticalLine: false),
                  barTouchData: BarTouchData(
                    touchTooltipData: BarTouchTooltipData(
                      getTooltipItem: (group, groupIndex, rod, rodIndex) {
                        String text = NumberFormat.currency(locale: 'id', symbol: 'Rp ').format(rod.toY);
                        return BarTooltipItem(
                          text,
                          TextStyle(
                            color: rod.color,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // --- Income vs Outcome Pie Chart ---
            const Text('Persentase Pemasukan vs Pengeluaran', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            // Uncomment this section after adding fl_chart to pubspec.yaml
            SizedBox(
              height: 250,
              child: (_totalIncome == 0 && _totalOutcome == 0)
                  ? const Center(child: Text('Tidak ada data untuk Pie Chart.'))
                  : PieChart(
                PieChartData(
                  sections: [
                    if (_totalIncome > 0)
                      PieChartSectionData(
                        value: _totalIncome,
                        color: Colors.green,
                        title: '${(_totalIncome / (_totalIncome + _totalOutcome) * 100).toStringAsFixed(1)}%',
                        radius: 80,
                        titleStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
                        badgeWidget: const Icon(Icons.arrow_upward, color: Colors.white, size: 24),
                        badgePositionPercentageOffset: 1.1,
                      ),
                    if (_totalOutcome > 0)
                      PieChartSectionData(
                        value: _totalOutcome,
                        color: Colors.red,
                        title: '${(_totalOutcome / (_totalIncome + _totalOutcome) * 100).toStringAsFixed(1)}%',
                        radius: 80,
                        titleStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
                        badgeWidget: const Icon(Icons.arrow_downward, color: Colors.white, size: 24),
                        badgePositionPercentageOffset: 1.1,
                      ),
                  ],
                  sectionsSpace: 2,
                  centerSpaceRadius: 40,
                  pieTouchData: PieTouchData(touchCallback: (FlTouchEvent event, pieTouchResponse) {
                    setState(() {
                      if (!event.isInterestedForInteractions || pieTouchResponse == null || pieTouchResponse.touchedSection == null) {
                        return;
                      }
                      // You can add logic here to show more details when a section is touched
                    });
                  }),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // --- Optional: Transaction List for selected period (for detail) ---
            const Text('Daftar Transaksi Detail (untuk periode terpilih)', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            _transactions.isEmpty
                ? const Text('Tidak ada transaksi untuk periode ini.')
                : ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _transactions.length,
              itemBuilder: (context, index) {
                final transaction = _transactions[index];
                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 4),
                  child: ListTile(
                    title: Text(transaction.deskripsi),
                    subtitle: Text(DateFormat('dd MMM yyyy').format(transaction.createdAt)),
                    trailing: Text(
                      NumberFormat.currency(locale: 'id', symbol: 'Rp ').format(transaction.nominal),
                      style: TextStyle(
                        color: transaction.jenisTransaksi == JenisTransaksi.pemasukan ? Colors.green : Colors.red,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}