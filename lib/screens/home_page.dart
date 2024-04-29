import 'package:animated_bottom_navigation_bar/animated_bottom_navigation_bar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_finance_app/screens/add_transaction_page.dart';
import 'package:flutter_finance_app/screens/components/appbar.dart';
import 'package:flutter_finance_app/screens/components/drawer.dart';
import 'package:flutter_finance_app/screens/statistic_page.dart';
import 'package:flutter_finance_app/screens/transactions_page.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';
import 'package:flutter_finance_app/provider/general_provider.dart';
import '../model/account.dart';
import 'dashboard_page.dart';
import 'debit_page.dart';

final GP = GeneralProvider();

class HomePage extends StatefulWidget {
  final int index;

  HomePage({required this.index});

  @override
  State<HomePage> createState() => _HomePageState();
}
class _HomePageState extends State<HomePage> {

  int pageIndex = 0;
  List<Widget> pages = [
    DashboardPage(),
    TransactionsPage(),
    DebitPage(),
    StatisticPage(),
  ];

//Funzioni
  setTabs(index) {
    setState(() {
      pageIndex = index;
    });
  }

  @override
  void initState() {
    super.initState();
    setTabs(widget.index);
    GP.init();
  }

  //Widget
  Widget getBody() {
     return IndexedStack(
      index: pageIndex,
      children: pages,
    );
  }

  Widget getFooter(BuildContext context) {
    ThemeData _theme = Theme.of(context);
    Size _size = MediaQuery.of(context).size;

    List<IconData> iconItems = [
      CupertinoIcons.home,
      CupertinoIcons.creditcard,
      CupertinoIcons.money_dollar,
      CupertinoIcons.chart_bar,
    ];
    return PhysicalModel(
      color: _theme.primaryColor,
      elevation: 10,
      //shadowColor: _theme.primaryColor,
      borderRadius: BorderRadius.circular(40),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
        ),
        child: AnimatedBottomNavigationBar(
          //backgroundColor:  _theme.primaryColorLight ,
          backgroundColor: _theme.primaryColor,
          icons: iconItems,
          splashColor:  _theme.primaryColor,
          inactiveColor: _theme.shadowColor.withOpacity(0.7) ,
          activeColor: _theme.shadowColor,
          gapLocation: GapLocation.center,
          activeIndex: pageIndex,
          notchSmoothness: NotchSmoothness.softEdge,
          leftCornerRadius: 15,
          iconSize: _size.height*0.03,
          rightCornerRadius: 10,
          elevation: 0,
          blurEffect: true,
          onTap: (index) {
            setTabs(index);
          },
        ),
      ),
    );
  }

  //Build
  @override
  Widget build(BuildContext context) {
    ThemeData _theme = Theme.of(context);
    final provider =Provider.of<GeneralProvider>(context, listen: false);
    Size _size = MediaQuery.of(context).size;

    return FutureBuilder<List<dynamic>>(
      future: Future.wait([
        GeneralProvider.getDBAccountList,
        GeneralProvider.getDBTransactionList,
      ]),
      builder: (BuildContext context, AsyncSnapshot<List<dynamic>> snapshot) {
        if (snapshot.hasData) {

          WidgetsBinding.instance!.addPostFrameCallback((_) {
            provider.setAccountList(snapshot.data?[0]);
            provider.setTransactionList(snapshot.data?[1]);

            if (provider.actualAccount == Account.none && !provider.accountList.isEmpty )
              provider.setActualAccount(provider.accountList.first);
            provider.setTransactionXAccount(provider.transactionList.where((transaction) => transaction.account == provider.actualAccount.name).toList());

          });

          return Scaffold(
            //extendBodyBehindAppBar: true,
            //backgroundColor: _theme.primaryColor,
            appBar: StaticAppBar(),
            drawer: StaticDrawer(),
            body: getBody(),
            bottomNavigationBar: getFooter(context),
            floatingActionButton: FloatingActionButton(
              backgroundColor: _theme.shadowColor,
              onPressed: () {

                if (Provider.of<GeneralProvider>(context,listen: false).actualAccount==Account.none) popUpSelezionaAccount();
                else Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                      builder: (context) => AddTransactionPage()),
                );
              },
              child: Icon(Icons.add, size: _size.width*0.07, color: _theme.primaryColor,),
              elevation: 1.0,
            ),
            floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,

          );
        } else if (snapshot.hasError) {
          return Text('Errore: ${snapshot.error}');
        } else {
          return CircularProgressIndicator();
        }
      },
    );
  }

  void popUpSelezionaAccount() {

    Size _size = MediaQuery.of(context).size;
    ThemeData _theme = Theme.of(context);

    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return AlertDialog(
          shadowColor:  Colors.transparent,
          backgroundColor: _theme.primaryColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Text(
            'Seleziona un account prima di inserire una transazione',
            style: TextStyle(
              color:_theme.shadowColor,
              fontSize: _size.height*0.03,
            ),
          ),
        );
      },
    );
  }

}

