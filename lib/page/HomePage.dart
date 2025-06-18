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
    _transactionListPage = TransactionListPage(key: transactionListPageKey);
    initializeDateFormatting('id', null);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: PreferredSize(preferredSize: Size.fromHeight(56),
            child: MyAppBar(title: title[_currentPageIndex])),
        body: pages[_currentPageIndex],
        bottomNavigationBar: Padding(
            padding: EdgeInsets.all(20),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: NavigationBarTheme(
                data: NavigationBarThemeData(
                    backgroundColor: Color(0xffdfe2fe),
                    indicatorColor: Color(0xffffffff),
                    labelTextStyle: MaterialStateProperty.resolveWith<
                        TextStyle>(
                            (Set<MaterialState> states) {
                          return TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF7971EA)
                          );
                        }
                    )
                ),
                child: NavigationBar(
                  labelBehavior: NavigationDestinationLabelBehavior
                      .onlyShowSelected,
                  selectedIndex: _currentPageIndex,
                  onDestinationSelected: (int index) {
                    setState(() {
                      _currentPageIndex = index;
                    });
                  },
                  destinations: const<Widget>[
                    NavigationDestination(
                        icon: Icon(Icons.home, color: Color(0xFF7971EA)),
                        label: 'Home'),
                    NavigationDestination(
                        icon: Icon(Icons.chat, color: Color(0xFF7971EA)),
                        label: 'Chatbot'),
                    NavigationDestination(
                        icon: Icon(
                            Icons.bar_chart_outlined, color: Color(0xFF7971EA)),
                        label: 'Analytics')
                  ],
                ),
              ),
            )
        )
    );
  }
}