import 'package:flutter/material.dart';
import 'package:godvlan/page/AddTransactionPage.dart';
import 'package:godvlan/page/AnalysisPage.dart';
// import 'package:godvlan/page/RingkasanKeuangan.dart';
import 'package:godvlan/widget/AppBar.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'ChatBotPage.dart';
import 'TransactionListPage.dart';


class HomePage extends StatefulWidget{
  const HomePage({super.key});

  @override
  _HomePage createState() => _HomePage();
  
}

class _HomePage extends State<HomePage>{

  int _currentPageIndex = 0;
  List<String> title = ["Home", "ChatBot", "Analytic"];
  late final TransactionListPage _transactionListPage;
  List<StatefulWidget> pages= [TransactionListPage(), ChatBotPage(), AnalysisPage() ];
  @override
  void initState() {
    super.initState();
    // Inisialisasi TransactionListPage dengan key
    _transactionListPage = TransactionListPage(key: transactionListPageKey);

    // Initialisasi data lokal untuk intl
    initializeDateFormatting('id', null);
  }

  void _navigateToAddTransactionPage() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AddTransactionPage()),
    );

    // Jika AddTransactionPage mengembalikan `true` (berhasil menambahkan)
    if (result == true) {
      print('HomePage: Transaksi baru berhasil ditambahkan, meminta refresh TransactionListPage.');
      // Panggil metode refresh di TransactionListPage melalui key-nya
      transactionListPageKey.currentState?.refreshTransactions();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(preferredSize: Size.fromHeight(56), child: MyAppBar(title: title[_currentPageIndex])),
      body: pages[_currentPageIndex],
      bottomNavigationBar: Padding(
        padding: EdgeInsets.all(20),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: NavigationBarTheme(
              data: NavigationBarThemeData(
                backgroundColor: Color(0xffdfe2fe),
                indicatorColor: Color(0xffffffff),
                labelTextStyle: MaterialStateProperty.resolveWith<TextStyle>(
                    (Set<MaterialState> states){
                      return TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF7971EA)
                      );
                    }
                )
              ),
              child: NavigationBar(
              labelBehavior: NavigationDestinationLabelBehavior.onlyShowSelected,
              selectedIndex: _currentPageIndex,
              onDestinationSelected: (int index)
              {
                setState(() {
                  _currentPageIndex = index;
                });
              },
              destinations: const<Widget>[
                NavigationDestination(
                    icon: Icon(Icons.home, color : Color(0xFF7971EA)),
                    label: 'Home'),
                NavigationDestination(
                    icon: Icon(Icons.chat, color : Color(0xFF7971EA)),
                    label: 'Chatbot'),
                NavigationDestination(
                    icon: Icon(Icons.bar_chart_outlined, color : Color(0xFF7971EA)),
                    label: 'Analytics')
              ],
              ),
          ),
        )
      ),

      floatingActionButton: _currentPageIndex == 0 ? ElevatedButton(
          style: ButtonStyle(
            iconColor: WidgetStateProperty.resolveWith<Color?>(
                    (Set<WidgetState> states){
                      if(states.contains(WidgetState.pressed)){
                        return Color(0xffffffff);
                      }
                      return Color(0xFF7971EA);
                    }
                    ),
            backgroundColor: WidgetStateProperty.resolveWith<Color?>(
                  (Set<WidgetState> states) {
                if (states.contains(WidgetState.pressed)) {
                  return Color(0xFF7971EA);
                }
                return Color(0xffdfe2fe); // Use the component's default.
              },
            ),
          ),
        onPressed: _navigateToAddTransactionPage, // Panggil metode ini
        child: const Icon(Icons.add),
      )
          : null,
    );
  }
  
}