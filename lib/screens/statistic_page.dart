import 'dart:math';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_finance_app/provider/general_provider.dart';
import 'package:flutter_finance_app/screens/transaction_page.dart';
import 'package:flutter_finance_app/theme/themes.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:gap/gap.dart';
import '../model/person_category.dart';
import '../model/transaction.dart';
import '../model/summary_enums.dart';

class StatisticPage extends StatefulWidget {
  @override
  _StatisticPageState createState() => _StatisticPageState();
}
class _StatisticPageState extends State<StatisticPage> {

  TransactionSummary summary = TransactionSummary.none();

  List<CategoryProspect> categories = [];
  List<CategoryProspect> expenseCategories = [];
  List<CategoryProspect> incomeCategories = [];

  String month = '';
  int year = DateTime.now().year;

  Set<int> monthsWithTransactions = {};
  Set<int> yearsWithTransactions = {};

  bool isExpense = true;

  @override
  void initState() {
    super.initState();

    final provider = Provider.of<GeneralProvider>(context, listen: false);

    provider.addListener(() {
      if (!mounted) {
        return;
      }

      // Reload the lists with the new data
      setState(() {

        updateMonths();
        updateYears();

        //year = yearsWithTransactions.reduce(max);
        //month = monthsWithTransactions.reduce(max);

        //print(categories[0].name);
        //print(summary.balance.toString());
        //print(summary.totalExpense.toString());
        //print(summary.totalIncome.toString());

      });
    });

    setState(() {
      SchedulerBinding.instance.addPostFrameCallback((_) {

        month = getMonth(DateTime.now().month);
        categories.clear();
        updateSummary();

        updateMonths();
        updateYears();

        //year = yearsWithTransactions.reduce(max);
        //month = monthsWithTransactions.reduce(max);
      });
    });

  }

  void updateSummary() {
    double totalExpense = 0;
    double totalIncome = 0;
    double balance = 0;
    List<Transaction> transactionList = [];

    DateTime startDate = DateTime(year, toMonth(month), 1);
    DateTime endDate = DateTime(year, toMonth(month)+1, 0);

    List<Transaction> transactions = Provider.of<GeneralProvider>(context, listen: false).getTransactionXAccount;

    // Calcola le somme delle spese, delle entrate e il bilancio per il periodo specificato
    for (var transaction in transactions) {
      if (transaction.date.isAfter(startDate) &&
          transaction.date.isBefore(endDate)) {
        if (transaction.transactionType == TransactionType.expense) {
          totalExpense += transaction.amount;
        } else if (transaction.transactionType == TransactionType.income) {
          totalIncome += transaction.amount;
        }
        transactionList.add(transaction);
      }
    }

    balance = (totalIncome - totalExpense);

    //Load Categories
    var categoryMap = <String, CategoryProspect>{};
    if (transactionList == null) throw Exception(
        'Summary non inizializzato');

    for (var transaction in transactionList) {
      var category = transaction.category;

      if (!categoryMap.containsKey(category)) {
        // If the person is not in the map, add them with a new PersonProspect
        categoryMap[category] = CategoryProspect(
          name: category,
          balance: 0.0, // Initialize balance to 0
          transactionList: [], // Initialize an empty transaction list
        );
      }

      categoryMap[category]?.transactionList.add(transaction);
      transaction.transactionType == TransactionType.expense?
        categoryMap[category]?.balance -= transaction.amount:
        categoryMap[category]?.balance += transaction.amount;

    }

    setState(() {
      summary = TransactionSummary(
          totalExpense: totalExpense,
          totalIncome: totalIncome,
          balance: balance,
          transactionList: transactionList
      );

      categories = categoryMap.values.toList();

      expenseCategories.clear();
      incomeCategories.clear();

      for(CategoryProspect cp in categories){
        if(cp.balance<0.0)
          expenseCategories.add(cp);
        if(cp.balance>=0.0)
          incomeCategories.add(cp);
      }

      //if((expenseCategories.isEmpty && isExpense) || (incomeCategories.isEmpty && !isExpense)) lancioPopUpChartVuoto();

    });
  }
  void updateMonths() {
    monthsWithTransactions.clear();
    for (var transaction in Provider
        .of<GeneralProvider>(context, listen: false)
        .getTransactionXAccount) {
      if (transaction.date.year == year) {
        setState(() {
          monthsWithTransactions.add(transaction.date.month);

          //print(monthsWithTransactions.toString());
          //print(yearsWithTransactions.toString());
        });
      }
    }
  }
  void updateYears() {
    yearsWithTransactions.clear();
    for (var transaction in Provider
        .of<GeneralProvider>(context, listen: false)
        .getTransactionXAccount) {
      setState(() {
        yearsWithTransactions.add(transaction.date.year);

      });
    }
  }

  void lancioPopUpChartVuoto(){
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Attenzione'),
          content: Text('Non ci sono dati disponibili.'),
          actions: <Widget>[
            TextButton(
              child: Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  String getMonth(int i){
    switch(i) {
      case 1 : return 'Gennaio';
      case 2 : return 'Febbraio';
      case 3 : return 'Marzo';
      case 4 : return 'Aprile';
      case 5 : return 'Maggio';
      case 6 : return 'Giugno';
      case 7 : return 'Luglio';
      case 8 : return 'Agosto';
      case 9 : return 'Settembre';
      case 10 : return 'Ottobre';
      case 11 : return 'Novembre';
      case 12 : return 'Dicembre';
      default : return 'Error';
    }
  }
  int toMonth(String s){
    switch(s) {
      case 'Gennaio' : return 1;
      case 'Febbraio' : return 2;
      case 'Marzo' : return 3;
      case 'Aprile' : return 4;
      case 'Maggio' : return 5;
      case 'Giugno' : return 6;
      case 'Luglio' : return 7;
      case 'Agosto' : return 8;
      case 'Settembre' : return 9;
      case 'Ottobre' : return 10;
      case 'Novembre' : return 11;
      case 'Dicembre' : return 12;
      default : return -1;
    }
  }


  @override
  Widget build(BuildContext context){
    Size _size = MediaQuery.of(context).size;
    ThemeData _theme = Theme.of(context);

    return Column(
        children: [

          //Titolo Balance e Spesa/Entrate
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15.0),
            child: Container(
              padding: const EdgeInsets.all( 15.0),
              decoration: BoxDecoration(
                color: _theme.primaryColor,
                borderRadius: BorderRadius.circular(20)
              ),
              child: Column(
                children: [

                  //Titolo
                  Padding(
                    padding: EdgeInsets.all(15),
                    child: Row(
                      children: [
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            "Statistiche",
                            style: TextStyle(
                                fontSize: _size.height*0.05,
                                fontWeight: FontWeight.bold,
                                color: _theme.shadowColor
                            ),
                          ),
                        ),
                        Spacer(),
                        InkWell(
                          onTap: (){
                            launchPopUpChart(context);
                          },
                          child: CircleAvatar(
                            backgroundColor: _theme.shadowColor,
                            child: Icon(
                              Icons.bar_chart,
                              color: _theme.primaryColor,
                            ),
                          ),
                        )
                      ],
                    ),
                  ),

                  Gap(5),
                  Divider(color: _theme.shadowColor,thickness: 1.5,),

                  //Balance
                  Padding(
                    padding: const EdgeInsets.all(15.0),
                    child: Row(
                      children: [
                        Text(
                          'Netto:',
                          style: TextStyle(
                              fontSize:_size.height*0.04,
                              color: _theme.shadowColor,
                              fontWeight: FontWeight.bold
                          ),
                        ),
                        Spacer(),
                        Text(
                          summary.balance>=0?
                            '+${summary.balance.abs().toStringAsFixed(0)} €':
                            '-${summary.balance.abs().toStringAsFixed(0)} €',
                          style: TextStyle(
                            fontSize:_size.height*0.06,
                            color: _theme.shadowColor,
                            fontWeight: FontWeight.bold
                          ),
                        ),
                      ],
                    ),
                  ),
                  Gap(10),

                  //Spese e Entrate
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ChoiceChip(
                        label: Padding(
                          padding: const EdgeInsets.all(5.0),
                          child: Row(
                            children: [
                              Icon(
                                Icons.arrow_downward,
                                size: _size.height*0.04,
                                color: _theme.primaryColor,
                              ),
                              SizedBox(width: 8.0),
                              Column(
                                children: [
                                  Text(
                                    'Spese',
                                    style: TextStyle(
                                      fontSize: _size.height*0.02,
                                      color: _theme.primaryColor,
                                    ),
                                  ),
                                  Text(
                                    '${summary.totalExpense.toStringAsFixed(0)} €',
                                    style: TextStyle(
                                        fontSize: _size.height*0.025,
                                        color: _theme.primaryColor,
                                        fontWeight: FontWeight.bold
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        selected: !isExpense,
                        onSelected: (bool selected) {
                          setState(() {
                            isExpense = true;
                          });
                        },
                        selectedColor: _theme.primaryColor.withOpacity(0.3),
                        backgroundColor: _theme.shadowColor,
                      ),
                      Gap(20),
                      ChoiceChip(
                        label: Padding(
                          padding: const EdgeInsets.all(6.0),
                          child: Row(
                            children: [
                              Icon(
                                Icons.arrow_upward,
                                size: _size.height*0.04,
                                color: _theme.primaryColor,
                              ),
                              SizedBox(width: 8.0),
                              Column(
                                children: [
                                  Text(
                                    'Entrate',
                                    style: TextStyle(
                                        fontSize: _size.height*0.02,
                                        color: _theme.primaryColor,
                                    ),
                                  ),
                                  Text(
                                    '${summary.totalIncome.toStringAsFixed(0)} €',
                                    style: TextStyle(
                                        fontSize: _size.height*0.025,
                                        color: _theme.primaryColor,
                                        fontWeight: FontWeight.bold
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        selected: isExpense,
                        onSelected: (bool selected) {
                          setState(() {
                            isExpense = false;
                          });
                        },
                        selectedColor: _theme.primaryColor.withOpacity(0.3),
                        backgroundColor: _theme.shadowColor,
                      ),
                    ],
                  ),
                  Gap(5),

                ],
              ),
            ),
          ),
          Gap(15),

          //YEAR AND MONTH
          Column(
            children: [
              // Year Selector
              Container(
                height:_size.height*0.08,
                alignment: Alignment.center,
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: yearsWithTransactions.length,
                  itemBuilder: (context, index) {
                    return Container(
                      margin: EdgeInsets.symmetric(horizontal: 10),
                      child: ChoiceChip(
                        shadowColor: Colors.transparent,
                        backgroundColor: _theme.primaryColor.withOpacity(0.8),
                        selectedShadowColor: Colors.transparent,
                        selectedColor: _theme.primaryColor,
                        label: Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: Text(
                              yearsWithTransactions.toList()[index].toString(),
                            style: TextStyle(
                              //fontWeight: FontWeight.bold,
                              color: _theme.shadowColor,
                              fontSize:_size.height*0.025,
                            ),
                          ),
                        ),
                        selected: year == yearsWithTransactions.toList()[index],
                        onSelected: (bool selected) {
                          setState(() {
                            year = yearsWithTransactions.toList()[index];
                            print('Year is now: $year');

                            updateMonths();

                            //Se premo un nuovo anno mi mette il primo mese
                            month= getMonth(monthsWithTransactions.toList()[0]);
                            updateSummary();
                          });
                        },
                      ),
                    );
                  },
                ),
              ),
              // Month Selector
              Container(
                padding: EdgeInsets.symmetric(horizontal: 20),
                height:_size.height*0.08,
                alignment: Alignment.center,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: monthsWithTransactions.length ,
                  itemBuilder: (context, index) {
                    return Container(
                      margin: EdgeInsets.symmetric(horizontal: 10),
                      child: ChoiceChip(
                        shadowColor: Colors.transparent,
                        backgroundColor: _theme.primaryColor.withOpacity(0.8),
                        selectedShadowColor: Colors.transparent,
                        selectedColor: _theme.primaryColor,
                        label: Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: Text(
                            getMonth(monthsWithTransactions.toList()[index]),
                            style: TextStyle(
                              //fontWeight: FontWeight.bold,
                              color: _theme.shadowColor,
                              fontSize:_size.height*0.025,
                            ),
                          ),
                        ),
                        selected: month == getMonth(monthsWithTransactions.toList()[index]),
                        onSelected: (bool selected) {
                          setState(() {
                            month = getMonth(monthsWithTransactions.toList()[index]);

                            updateSummary();
                          });

                          //print('\n');
                          //!categories.isEmpty?
                          // print('Categorie trovate: ${categories[0].name}'):
                          // print('Nessuna Categoria');
                          // print('Summary : ${summary.toString()}');
                          //
                          // print('Categorie  Spesa: ${expenseCategories.length}');
                          // print('Categorie  Income: ${incomeCategories.length}');

                        },
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
          Gap(15),

          isExpense?
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: ListView.builder(

                    itemCount: expenseCategories.length,
                    itemBuilder: (context, index) {
                      CategoryProspect item = expenseCategories[index];
                      return Container(
                        margin: EdgeInsets.only(bottom: 10),
                        decoration: BoxDecoration(
                            color: _theme.shadowColor,
                            borderRadius: BorderRadius.circular(20)

                        ),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: _theme.primaryColor,
                            radius: _size.height*0.03,
                            child: Icon(
                              Icons.category,
                              color: _theme.shadowColor,
                              size: _size.height*0.04,
                            ),
                          ),
                          title: Padding(
                            padding: const EdgeInsets.all(4.0),
                            child: Text(
                              item.name,
                              style: TextStyle(
                                  fontSize: _size.height*0.022,
                                  color: _theme.primaryColor,
                                  fontWeight: FontWeight.bold
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          subtitle: Padding(
                            padding: const EdgeInsets.symmetric(horizontal:4.0),
                            child: Text(
                              'Totale: ${item.balance.toStringAsFixed(0)} €',
                              style: TextStyle(
                                fontSize: _size.height*0.022,
                                color: _theme.primaryColor,
                                //fontWeight: FontWeight.bold
                              ),
                            ),
                          ),
                          trailing: Icon(
                            Icons.arrow_forward,
                            size: _size.height*0.03,
                            color: _theme.primaryColor,
                          ),
                          onTap: () {
                            launchPopUpCategoryProspectSummary(expenseCategories[index]);
                          },
                        ),
                      );
                    },
                  ),
                ),
              ):
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: ListView.builder(

                    itemCount: incomeCategories.length,
                    itemBuilder: (context, index) {
                      CategoryProspect item = incomeCategories[index];
                      return Container(
                        margin: EdgeInsets.only(bottom: 10),
                        decoration: BoxDecoration(
                            color: _theme.shadowColor,
                            borderRadius: BorderRadius.circular(20)

                        ),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: _theme.primaryColor,
                            radius: _size.height*0.03,
                            child: Icon(
                              Icons.category,
                              color: _theme.shadowColor,
                              size: _size.height*0.04,
                            ),
                          ),
                          title: Padding(
                            padding: const EdgeInsets.all(4.0),
                            child: Text(
                              item.name,
                              style: TextStyle(
                                  fontSize: _size.height*0.022,
                                  color: _theme.primaryColor,
                                  fontWeight: FontWeight.bold
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          subtitle: Padding(
                            padding: const EdgeInsets.symmetric(horizontal:4.0),
                            child: Text(
                              'Totale: ${item.balance.toStringAsFixed(0)} €',
                              style: TextStyle(
                                fontSize: _size.height*0.022,
                                color: _theme.primaryColor,
                                //fontWeight: FontWeight.bold
                              ),
                            ),
                          ),
                          trailing: Icon(
                            Icons.arrow_forward,
                            size: _size.height*0.03,
                            color: _theme.primaryColor,
                          ),
                          onTap: () {
                            launchPopUpCategoryProspectSummary(incomeCategories[index]);
                          },
                        ),
                      );
                    },
                  ),
                ),
              ),
          Gap(15),

        ],
    );

  }

  void launchPopUpChart(BuildContext context) {
    Size _size = MediaQuery.of(context).size;
    ThemeData _theme = Theme.of(context);

    if( (isExpense && expenseCategories.isEmpty) || (!isExpense && incomeCategories.isEmpty))
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            backgroundColor: _theme.primaryColor,
            shadowColor: Colors.transparent,

            title: Text(
              'Nessuna Categoria trovata',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: _size.height*0.02,
                  fontWeight: FontWeight.bold
              ),
            ),

          );
        },
      );
    else{
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            backgroundColor: _theme.primaryColor,
            shadowColor: Colors.transparent,

            title: Text(
              isExpense?
              'Spese $month $year':
              'Entrate $month $year',

              style: TextStyle(
                  color: Colors.white,
                  fontSize: _size.height*0.04,
                  fontWeight: FontWeight.bold
              ),
            ),
            content: Container(
              padding: EdgeInsets.all(15),
              height: _size.height*0.6,
              width: _size.width*0.9,
              child: SingleChildScrollView(
                child: isExpense?
                    PieChartWidget(expenseCategories,summary.totalExpense,):
                    PieChartWidget(incomeCategories,summary.totalIncome,),

              ),
            ),
          );
        },
      );
    }


  }
  void launchPopUpCategoryProspectSummary(CategoryProspect categoryProspect){
    Size _size = MediaQuery.of(context).size;
    ThemeData _theme = Theme.of(context);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          elevation: 0,
          shadowColor: Colors.transparent,
          backgroundColor: _theme.primaryColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20), // Questo arrotonda i bordi del dialogo.
          ),
          child: Padding(
            padding: const EdgeInsets.all(15.0),
            child: Column(
              children: [
                Gap(40),
                Text(
                  'Categoria:',
                  style: TextStyle(
                    //fontWeight: FontWeight.bold,
                    color: _theme.shadowColor,
                    fontSize: _size.height*0.03,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10.0),
                  child: Text(
                    categoryProspect.name,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: _theme.shadowColor,
                      fontSize: _size.height*0.05,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Gap(25),
                Text(
                  'Periodo:',
                  style: TextStyle(
                    //fontWeight: FontWeight.bold,
                    color: _theme.shadowColor,
                    fontSize: _size.height*0.03,
                  ),
                ),
                Gap(10),
                Text(
                  '$month $year',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: _theme.shadowColor,
                    fontSize: _size.height*0.04,
                  ),
                ),
                Gap(25),
                Text(
                  'Totale:',
                  style: TextStyle(
                    //fontWeight: FontWeight.bold,
                    color: _theme.shadowColor,
                    fontSize: _size.height*0.03,
                  ),
                ),
                Gap(10),
                Text(
                  categoryProspect.balance.toString()+ ' €',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: _theme.shadowColor,
                    fontSize: _size.height*0.04,
                  ),
                ),


                Gap(15),
                Divider(color: _theme.shadowColor,thickness: 1.5,),
                Gap(15),
                Expanded(
                  child: SingleChildScrollView(
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: categoryProspect.transactionList.length,
                      itemBuilder:  (BuildContext context, int index2) {
                        return ListTile(
                          leading: CircleAvatar(
                            child: Icon(
                              Icons.credit_card_off,
                              size: _size.height*0.03,
                              color: _theme.primaryColor,
                            ),
                            backgroundColor: _theme.shadowColor,
                            radius: _size.height*0.03,
                          ),
                          subtitle: Text(
                            DateFormat('dd-MM-yyyy').format(categoryProspect.transactionList[index2].date),
                            style: TextStyle(
                              fontStyle: FontStyle.italic,
                              color: _theme.shadowColor,
                              fontSize: _size.height*0.02,
                            ),
                          ),
                          title: Text(
                            categoryProspect.transactionList[index2].description,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: _theme.shadowColor,
                              fontSize: _size.height*0.02,
                            ),
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                          ),
                          trailing: Text(
                            categoryProspect.transactionList[index2].amount.toStringAsFixed(2)+ ' €',
                            style: TextStyle(
                              //fontWeight: FontWeight.bold,
                              color: _theme.shadowColor,
                              fontSize: _size.height*0.02,
                            ),
                          ),
                          onTap: (){
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(builder:(BuildContext context) => TransactionPage(categoryProspect.transactionList[index2])),
                            );
                          },
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

}

class PieChartWidget extends StatefulWidget {

  List<CategoryProspect> listCategory;
  double totalSection;
  PieChartWidget(this.listCategory, this.totalSection);

  @override
  _PieChartWidgetState createState() => _PieChartWidgetState();

}
class _PieChartWidgetState extends State<PieChartWidget> {
  int touchedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return pieChart();
  }
  Widget pieChart() {
    return Column(
      children: <Widget>[
        Gap(20),
        AspectRatio(
          aspectRatio: 1.3,
          child: PieChart(
            PieChartData(
              pieTouchData: PieTouchData(
                touchCallback: (pieTouchResponse) {
                  if (pieTouchResponse.touchInput is FlLongPressEnd ||
                      pieTouchResponse.touchInput is FlPanEnd) {

                  } else {
                    setState(() {
                      // Imposta l'indice dell'elemento selezionato
                      touchedIndex = pieTouchResponse.touchedSectionIndex;
                    });
                  }
                },
              ),
              borderData: FlBorderData(
                show: false,
              ),
              sectionsSpace: 0,
              centerSpaceRadius: 40,
              sections: showingSections(),
            ),
          ),
        ),
        Gap(90),
        ...
        buildLegend(),

      ],
    );
  }
// Definisci la tua lista di colori
  final List<Color> colorList = [
    Colors.pinkAccent,
    Colors.lightBlueAccent,
    Colors.purpleAccent,
    Colors.orangeAccent,
    Colors.tealAccent,
    Colors.pink,
    Colors.lightBlue,
    Colors.purple,
    Colors.orange,
    Colors.teal,
  ];

  List<PieChartSectionData> showingSections() {
    return List.generate(widget.listCategory.length, (i) {
      final isTouched = touchedIndex==i;
      final double fontSize = isTouched ? 25 : 18;
      final double radius = isTouched ? 80 : 60;
      final double value = widget.listCategory[i].balance.abs();
      final String title = '${((value/widget.totalSection)*100).toStringAsFixed(0)}%';

      // Usa la lista di colori per assegnare i colori alle sezioni
      final Color color = colorList[i % colorList.length];

      return PieChartSectionData(
        color: color,
        value: value,
        title: title,
        radius: radius,
        titleStyle: TextStyle(
            fontSize: fontSize,
            fontWeight: FontWeight.bold,
            color: Colors.white
        ),
      );
    });
  }

  List<Widget> buildLegend() {
    Size _size = MediaQuery.of(context).size;
    ThemeData _theme = Theme.of(context);

    return List.generate(widget.listCategory.length, (i) {
      // Usa la stessa lista di colori per assegnare i colori alla legenda
      final Color color = colorList[i % colorList.length];

      return ListTile(
        leading: Icon(Icons.circle, color: color,size: _size.height*0.04,),
        title: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            widget.listCategory[i].name,
            style: TextStyle(
              color:  Colors.white,
              fontSize: _size.height*0.025,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Text(
            widget.listCategory[i].balance.toStringAsFixed(2) + ' €',
            style: TextStyle(
                color:  Colors.white,
                fontSize: _size.height*0.03,
                fontWeight: FontWeight.bold
            ),
          ),
        ),
      );
    });
  }

}