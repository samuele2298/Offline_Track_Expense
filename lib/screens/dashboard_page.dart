import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_finance_app/screens/transaction_page.dart';
import 'package:flutter_finance_app/theme/themes.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:gap/gap.dart';
import 'package:provider/provider.dart';
import '../model/summary_enums.dart';
import '../model/transaction.dart';
import '../provider/general_provider.dart';
import 'home_page.dart';

class DashboardPage extends StatefulWidget {
  @override
  State<DashboardPage> createState() => _DashboardPageState();
}
class _DashboardPageState extends State<DashboardPage> {
  int periodIndex = 1;
  TransactionSummary summary = TransactionSummary.none();
  List<Transaction> ultimeTransazioni = [];
  List<FlSpot> spots = [];

  int _selectedPeriod = 1;

  @override
  void dispose() {
    Provider.of<GeneralProvider>(context, listen: false).removeListener(() {
      changeSummaryByPeriod(periodIndex);
    });
    super.dispose();
  }


  @override
  void initState()  {
    super.initState();

    final provider = Provider.of<GeneralProvider>(context, listen: false);

    provider.addListener(() {
      changeSummaryByPeriod(periodIndex);

      setState(() {
        if(!provider.transactionXAccount.isEmpty)
          ultimeTransazioni  = [
            provider.transactionXAccount.last,
          ];
      });

      Map<DateTime, double> map = generateBalanceMap(
          provider.transactionXAccount,
          provider.actualAccount.balance,
          periodIndex
      );


      spots = generateFlSpots(
          map,
          periodIndex
      );

      //print(map.toString());

    });

    setState(() {
      changeSummaryByPeriod(periodIndex);

      if(!provider.transactionXAccount.isEmpty)
        ultimeTransazioni  = [
          provider.transactionXAccount.last,
        ];

      spots = generateFlSpots(
          generateBalanceMap(
              provider.transactionXAccount,
              provider.actualAccount.balance,
              periodIndex
          ),
          periodIndex
      );

      //print(spots.toString());
    });
 }

  void changePeriod(int newPeriod) {
    final provider = Provider.of<GeneralProvider>(context, listen: false);
    setState(() {
      periodIndex = newPeriod;
      changeSummaryByPeriod(newPeriod);

      spots = generateFlSpots(
          generateBalanceMap(
              provider.transactionXAccount,
              provider.actualAccount.balance,
              newPeriod
          ),
          periodIndex
      );
    });
  }
  void changeSummaryByPeriod(int periodIndex) {
    double totalExpense =0;
    double totalIncome =0;
    double balance =0;
    List<Transaction> transactionList = [];

    final today = DateTime.now();
    DateTime startDate;

    // Calcola la data di inizio del periodo in base all'indice fornito
    switch (periodIndex) {
      case 0: // Giornaliero
        startDate = today.subtract(Duration(days: 1));
        break;
      case 1: // Settimanale
        startDate = today.subtract(Duration(days: 7));
        break;
      case 2: // Mensile
        startDate = today.subtract(Duration(days: 30));
        break;
      case 3: // Annuale
        startDate = today.subtract(Duration(days: 365));
        break;
      default:
        throw ArgumentError('Indice del periodo non valido.');
    }


    List<Transaction> allTransactions =  Provider.of<GeneralProvider>(context,listen: false).getTransactionXAccount;
    // Calcola le somme delle spese, delle entrate e il bilancio per il periodo specificato
    for (var transaction in allTransactions) {
      if (transaction.date.isAfter(startDate) && transaction.date.isBefore(today)) {
        if (transaction.transactionType == TransactionType.expense) {
          totalExpense += transaction.amount;
        } else if (transaction.transactionType == TransactionType.income) {
          totalIncome += transaction.amount;
        }
        transactionList.add(transaction);
      }
    }

    // Calcola il bilancio come differenza tra entrate e spese
    balance = totalIncome-totalExpense;


    setState(() {
      summary = TransactionSummary(
        totalExpense: totalExpense,
        totalIncome: totalIncome,
        balance: balance,
        transactionList: transactionList
      );
    });
  }
  Map<DateTime, double> generateBalanceMap(List<Transaction> transactions, double currentBalance, int periodIndex) {
    // Sort transactions by date in reverse order
    transactions.sort((a, b) => b.date.compareTo(a.date));

    // Initialize balance map with current balance
    Map<DateTime, double> balanceMap = {DateTime.now(): currentBalance};

    // Calculate the number of days based on the period index
    int numDays;
    if (periodIndex == 1) { // Weekly view
      numDays = 7;
    } else if (periodIndex == 2) { // Monthly view
      numDays = 31;
    } else if (periodIndex == 3) { // Annual view
      numDays = 365;
    } else {
      numDays = DateTime.now().difference(transactions.first.date).inDays;
    }

    // Calculate balance for each day in reverse
    for (var i = 0; i <= numDays; i++) {
      DateTime date = DateTime.now().subtract(Duration(days: i));

      // Find transactions for the current date
      var transactionsForDate = transactions.where((t) => (
          t.date.year == date.year &&
          t.date.month == date.month &&
          t.date.day == date.day
        )
      );

      // Add the transaction amounts to the current balance
      for (var transaction in transactionsForDate) {
        currentBalance += transaction.amount;
      }

      // Add the current balance to the balance map
      balanceMap[date] = currentBalance;
    }

    return balanceMap;
  }
  List<FlSpot> generateFlSpots(Map<DateTime, double> balanceMap, int periodIndex) {
    List<FlSpot> spots = [];

    // Filter balance map based on index period
    DateTime now = DateTime.now();
    Map<DateTime, double> filteredMap = Map.from(balanceMap);
    if (periodIndex == 1) { // Weekly view
      filteredMap.removeWhere((date, _) => date.isBefore(now.subtract(Duration(days: 7))));
    } else if (periodIndex == 2) { // Monthly view
      filteredMap.removeWhere((date, _) => date.isBefore(now.subtract(Duration(days: 30))));
    } else if (periodIndex == 3) { // Annual view
      filteredMap.removeWhere((date, _) => date.isBefore(now.subtract(Duration(days: 365))));
    }

    // Get the start date (date of the first entry in the filtered map)
    DateTime startDate = filteredMap.keys.reduce((a, b) => a.isBefore(b) ? a : b);

    // Generate FL spots
    for (var entry in filteredMap.entries) {
      // Calculate the number of days since the start date
      double x = entry.key.difference(startDate).inDays.toDouble();
      // Check if the balance is greater than 0 before taking the logarithm
      double y = entry.value > 0 ? entry.value : 0;
      spots.add(FlSpot(x, y));
    }

    return spots;
  }
  double highestBalanceInYear(List<Transaction> transactions, double currentBalance) {
    // Generate the balance map for the annual view
    Map<DateTime, double> balanceMap = generateBalanceMap(transactions, currentBalance, 3);

    // Find the highest balance in the map
    double highestBalance = balanceMap.values.reduce((curr, next) => curr > next ? curr : next);

    return highestBalance;
  }
  DateTime getStartDate(int periodIndex) {
    DateTime now = DateTime.now();

    if (periodIndex == 1) { // Weekly view
      return now.subtract(Duration(days: 7));
    } else if (periodIndex == 2) { // Monthly view
      return now.subtract(Duration(days: 30));
    } else if (periodIndex == 3) { // Annual view
      return now.subtract(Duration(days: 365));
    } else {
      return now;
    }
  }

  @override
  Widget build(BuildContext context) {
    Size _size = MediaQuery.of(context).size;
    ThemeData _theme = Theme.of(context);

    return Consumer<GeneralProvider>(
        builder: (_, gp, __) {
          return  Padding(
            padding: EdgeInsets.all(10),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  //const Gap(70),

                  //Chart Container
                  Container(
                    margin: EdgeInsets.symmetric(horizontal: 12),
                    padding: EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      color: _theme.primaryColor,
                    ),
                    child: Column(
                      children: [
                        Gap(20),

                        //Balance
                        Column(
                          children: [
                            Text(
                              '${gp.actualAccount.balance} \€',
                              style: TextStyle(
                                fontSize: _size.height*0.06,
                                fontWeight: FontWeight.bold,
                                color: _theme.shadowColor
                              ),
                            ),
                            Gap(3),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  '${summary.balance} €',
                                  style: TextStyle(
                                    fontSize:_size.height*0.025,
                                    fontWeight: FontWeight.bold,
                                    color:  _theme.shadowColor,
                                  ),
                                ),
                                Gap(5),
                                Container(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    getPeriodLabel(periodIndex),
                                    style: TextStyle(
                                      fontSize: _size.height*0.022,
                                      fontWeight: FontWeight.bold,
                                      color:  _theme.shadowColor,

                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),

                        //Chart
                        Container(
                            height: _size.height*0.3,
                            width: double.infinity,
                            padding: const EdgeInsets.all(10),
                            child: lineChart()
                        ),
                        Gap(15),

                        //Bottoni Periodo
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: <Widget>[
                            ChoiceChip(
                              label: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text('1W',  style: TextStyle(
                                    color: _theme.shadowColor,
                                    fontSize: _size.height*0.02
                                )),
                              ),
                              selected: _selectedPeriod == 1,
                              selectedColor: _theme.primaryColor.withOpacity(0.4),
                              backgroundColor: _theme.primaryColor.withOpacity(0.7),
                              onSelected: (bool selected) {
                                setState(() {
                                  _selectedPeriod = 1;
                                  changePeriod(_selectedPeriod);
                                });
                              },
                            ),
                            ChoiceChip(
                              label: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text('1M',
                                    style: TextStyle(
                                      color: _theme.shadowColor,
                                      fontSize: _size.height*0.02
                                    )
                                ),
                              ),
                              selected: _selectedPeriod == 2,
                              selectedColor: _theme.primaryColor.withOpacity(0.4),
                              backgroundColor: _theme.primaryColor.withOpacity(0.7),
                              onSelected: (bool selected) {
                                setState(() {
                                  _selectedPeriod = 2;
                                  changePeriod(_selectedPeriod);
                                });
                              },
                            ),
                            ChoiceChip(
                              label: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text('1Y', style: TextStyle(
                                    color: _theme.shadowColor,
                                    fontSize: _size.height*0.02
                                )),
                              ),
                              selected: _selectedPeriod == 3,
                              selectedColor: _theme.primaryColor.withOpacity(0.4),
                              backgroundColor: _theme.primaryColor.withOpacity(0.7),
                              onSelected: (bool selected) {
                                setState(() {
                                  _selectedPeriod = 3;
                                  changePeriod(_selectedPeriod);
                                });
                              },
                            ),
                          ],
                        ),
                      ],
                    ),

                  ),
                  const Gap(15),

                  //Spese e Entrate
                  Container(
                    margin: EdgeInsets.symmetric(horizontal: 12),
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: _theme.primaryColor,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.2),
                          spreadRadius: 2,
                          blurRadius: 50,
                          offset: Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [

                          Row(
                            children: [
                              Icon(
                                Icons.arrow_downward_rounded,
                                color:  _theme.shadowColor,
                                size: _size.height*0.04,
                              ),
                              SizedBox(width: 10),
                              Column(
                                children: [
                                  Text(
                                    'Spese',
                                    style: TextStyle(
                                      fontSize:  _size.height*0.022,
                                      color: _theme.shadowColor,

                                    ),
                                  ),
                                  Text(
                                    ' ${summary.totalExpense} €',
                                    style: TextStyle(
                                      fontSize: _size.height*0.03,
                                      fontWeight: FontWeight.bold,
                                      color: _theme.shadowColor,
                                    ),
                                  ),
                                ],
                              ),

                            ],
                          ),
                          Row(
                            children: [
                              Icon(
                                Icons.arrow_upward_rounded,
                                color:  _theme.shadowColor,

                                size: _size.height*0.04,
                              ),
                              SizedBox(width: 10),
                              Column(
                                children: [
                                  Text(
                                    'Entrate',
                                    style: TextStyle(
                                      fontSize:  _size.height*0.022,
                                      color: _theme.shadowColor,

                                    ),
                                  ),
                                  Text(
                                    ' ${summary.totalIncome} €',
                                    style: TextStyle(
                                      fontSize: _size.height*0.03,
                                      fontWeight: FontWeight.bold,
                                      color: _theme.shadowColor,
                                    ),
                                  ),
                                ],
                              ),

                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const Gap(12),


                  //Ultime Trans + Tasto
                  Container(
                    padding: EdgeInsets.all(12),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Ultime transazioni',
                          style: TextStyle(
                            fontSize: _size.height*0.025,
                            color: _theme.shadowColor,
                            fontWeight: FontWeight.bold
                          ),
                        ),
                        InkWell(
                          onTap: (){
                                Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => HomePage(index: 1)),
                              );
                          },

                          child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(20),
                                color: _theme.shadowColor
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(10.0),
                                child: Text('Vedi tutte',
                                  style: TextStyle(
                                    fontSize: _size.height*0.02,
                                    color: _theme.primaryColor,
                                    fontWeight: FontWeight.bold
                                ),),
                              )
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Gap(12),

                  //Transazioni
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12.0),
                    child: Column(
                        children: [
                          ...ultimeTransazioni.map((ex) {
                            return InkWell(
                              onTap: (){
                                Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => TransactionPage(ex),
                                ),
                              );
                              },

                              child: Container(
                                margin: EdgeInsets.only(bottom: 8,),
                                decoration: BoxDecoration(
                                  color: ex.transactionType== TransactionType.expense?
                                    _theme.primaryColor:
                                    _theme.primaryColor.withOpacity(0.7),
                                  borderRadius: BorderRadius.circular(20),

                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(12,),
                                  child: Row(
                                    children: [
                                      CircleAvatar(
                                        backgroundColor: _theme.shadowColor,
                                        child: ex.transactionType == TransactionType.income ?
                                          Icon(
                                            Icons.arrow_upward_rounded,
                                            color: _theme.primaryColor,

                                          ) :
                                          Icon(
                                            Icons.arrow_downward_rounded,
                                            color: _theme.primaryColor,
                                          ),
                                      ),
                                      Gap(20),
                                      Expanded(
                                        child: Container(
                                          width: (_size.width - 90) * 0.7,
                                          child: Column(
                                            mainAxisAlignment: MainAxisAlignment
                                                .center,
                                            crossAxisAlignment: CrossAxisAlignment
                                                .start,
                                            children: [
                                              Text(
                                                ex.description.toString(),
                                                style: TextStyle(
                                                  fontSize: _size.height*0.02,
                                                  fontWeight: FontWeight.bold,
                                                  color: _theme.shadowColor,
                                                ),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                              Gap(5),
                                              Text(
                                                DateFormat('d/M').format(ex.date),
                                                style: TextStyle(
                                                  fontSize: _size.height*0.015,
                                                  color: _theme.shadowColor,
                                                  fontStyle: FontStyle.italic,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                      Text(
                                        '${ex.amount.toString()} €',
                                        style: TextStyle(
                                          fontSize: _size.height*0.02,
                                          fontWeight: FontWeight.bold,
                                          color: _theme.shadowColor,
                                        ),
                                      ),
                                      Gap( 15),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ]
                    ),
                  ),
                  const Gap(25),
                ],
              ),
            ),
          );
      }
    );
  }

  Widget lineChart() {
    final provider = Provider.of<GeneralProvider>(context, listen: false);
    Size _size = MediaQuery.of(context).size;
    ThemeData _theme = Theme.of(context);

    return LineChart(
      LineChartData(
        minX: 0,
        maxX: periodIndex == 1 ? 7 : periodIndex == 2? 31: 365,
        minY: 0,
        maxY: periodIndex == 1 ?
          highestBalanceInYear(provider.transactionXAccount, provider.actualAccount.balance):
          highestBalanceInYear(provider.transactionXAccount, provider.actualAccount.balance)*1.5,

        titlesData: FlTitlesData(
          bottomTitles: SideTitles(showTitles: false),
          leftTitles: SideTitles(showTitles: false),
        ),

        gridData: FlGridData(
          show: false,
          getDrawingHorizontalLine: (value) {
            return FlLine(
              color: Colors.white,
              strokeWidth: 2,
            );
          },
          drawVerticalLine: false,
          getDrawingVerticalLine: (value) {
            return FlLine(
              color: const Color(0xff37434d),
              strokeWidth: 2,
            );
          },
        ),

        borderData: FlBorderData(
          show: false,
          border: Border.all(
              color: Colors.black,
              width: 1),
        ),

        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            curveSmoothness: 0.1, // This line makes the curve softer
            colors: [
              _theme.primaryColor,
              _theme.shadowColor,

            ],
            barWidth: 10,
            dotData: FlDotData(
              show: false,
            ),
            belowBarData: BarAreaData(
              show: true,
              colors: [
                _theme.primaryColor,
                _theme.scaffoldBackgroundColor,


              ]
                  .map((color) => color.withOpacity(0.5))
                  .toList(),
            ),
          ),
        ],

        lineTouchData: LineTouchData(
          touchTooltipData: LineTouchTooltipData(
            tooltipBgColor: _theme.shadowColor,
            getTooltipItems: (List<LineBarSpot> touchedBarSpots) {
              return touchedBarSpots.map((barSpot) {
                final flSpot = barSpot;
                DateTime date = getStartDate(periodIndex).add(Duration(days: flSpot.x.toInt()));

                return LineTooltipItem(
                  'Importo: \n${flSpot.y.toStringAsFixed(2)} €\n Data: \n ${DateFormat('dd/MM/yyyy').format(date)}\n',
                   TextStyle(
                     fontSize: _size.height*0.025,
                     color: _theme.primaryColor,
                     fontWeight: FontWeight.bold
                   ),
                );
              }).toList();
            },
          ),
        ),
      ),
    );
  }

}

String getPeriodLabel(int index) {
  switch (index) {
    case 1:
      return 'Settimana';
    case 2:
      return 'Mese';
    case 3:
      return 'Anno';
    default:
      return '';
  }
}