import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_finance_app/model/transaction.dart';
import 'package:flutter_finance_app/provider/general_provider.dart';
import 'package:flutter_finance_app/screens/transaction_page.dart';
import 'package:flutter_finance_app/theme/themes.dart';
import 'package:gap/gap.dart';
import 'package:provider/provider.dart';

import '../model/summary_enums.dart';

class TransactionsPage extends StatefulWidget {
  const TransactionsPage({super.key});

  @override
  State<TransactionsPage> createState() => _TransactionsPageState();
}
class _TransactionsPageState extends State<TransactionsPage> {

  List<Transaction> actualTransactionList = [];

  @override
  void initState(){
    super.initState();

    final provider = Provider.of<GeneralProvider>(context, listen: false);

    provider.addListener(() {

      setState(() {
        resetList();
      });

    });

    setState(() {
      resetList();
    });
  }

  @override
  void dispose() {
    // Now you can safely refer to `myInheritedWidget` here.
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Code that depends on InheritedWidgets
    resetList();
  }

  void resetList()  {
    setState(() {
      actualTransactionList = Provider.of<GeneralProvider>(context,listen: false).getTransactionXAccount;
    });
  }

  int type = 0;
  void filterByType() {
    if (type == 0) {
      setState(() {
        resetList();
        type++;
      });
    }else if (type==1){
      setState(() {
        resetList();
        actualTransactionList=actualTransactionList.where((transaction) =>
          transaction.transactionType == TransactionType.expense)
            .toList();
        type++;
      });
    } else if (type == 2) {
      setState(() {
        resetList();
        actualTransactionList=actualTransactionList.where((transaction) =>
          transaction.transactionType == TransactionType.income)
            .toList();
        type=0;
      });
    }

  }

  bool isDateAscending = true;
  void orderByDate() {
    setState(() {
      resetList();

      // Sort the list by date
      actualTransactionList.sort((a, b) {
        if (isDateAscending) {
          return a.date.compareTo(b.date);
        } else {
          return b.date.compareTo(a.date);
        }
      });

      // Toggle the sort order for the next time the function is called
      isDateAscending = !isDateAscending;
    });
  }

  bool isPriceAscending = true;
  void orderByPrice() {
    setState(() {
      resetList();

      // Sort the list by date
      actualTransactionList.sort((a, b) {
        if (isPriceAscending) {
          return a.amount.compareTo(b.amount);
        } else {
          return b.amount.compareTo(a.amount);
        }
      });

      // Toggle the sort order for the next time the function is called
      isPriceAscending = !isPriceAscending;
    });
  }


  @override
  Widget build(BuildContext context) {
    ThemeData _theme = Theme.of(context);
    Size _size = MediaQuery.of(context).size;

    return Consumer<GeneralProvider>(
        builder: (_, gp, __) {
          return Column(
            children: [
              //Titolo e Download
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10.0),
                child: Container(
                  padding: EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    color: _theme.primaryColor,
                    borderRadius: BorderRadius.circular(20)
                  ),
                  child: Column(
                    children: [
                      Padding(
                        padding: EdgeInsets.all( _size.width*0.03),
                        child: Row(
                            children: [
                              Text(
                                "Transazioni",
                                style: TextStyle(
                                  fontSize: _size.height*0.05,
                                  fontWeight: FontWeight.bold,
                                  color: _theme.shadowColor
                                ),
                              ),
                              Spacer(),
                              InkWell(
                                onTap: (){
                                  Provider.of<GeneralProvider>(context,listen:false).exportDatabase();
                                },
                                child: CircleAvatar(
                                  backgroundColor: _theme.shadowColor,
                                  child: Icon(
                                    Icons.download,
                                    color: _theme.primaryColor,
                                  ),
                                ),
                              )
                            ],
                          ),
                      ),
                      Gap( _size.height*0.001),

                      Divider(color: _theme.shadowColor,),
                      Gap( _size.height*0.01),

                      //Filtri
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          InkWell(
                            onTap: () {
                              setState(() {
                                filterByType();
                              });
                            },
                            child: Row(
                              children: [
                                Icon(Icons.filter_alt,color:  _theme.shadowColor, ),
                                Gap( 10),
                                Text(
                                  "Tipo",
                                  style: TextStyle(
                                    color:  _theme.shadowColor,
                                    fontSize: _size.height*0.025,
                                    fontWeight: FontWeight.bold
                                  ),
                                ),
                              ],
                            ),
                          ),
                          InkWell(
                            onTap: () {
                              setState(() {
                                orderByPrice();
                              });
                            },
                            child: Row(
                              children: [
                                Icon(Icons.monetization_on,color:  _theme.shadowColor, ),
                                Gap( 10),
                                Text(
                                  "Prezzo",
                                  style: TextStyle(
                                      color:  _theme.shadowColor,
                                      fontSize: _size.height*0.025,
                                      fontWeight: FontWeight.bold
                                  ),
                                ),
                              ],
                            ),
                          ),
                          InkWell(
                            onTap: () {
                              setState(() {
                                orderByDate();
                              });
                            },
                            child: Row(
                              children: [
                                Icon(Icons.filter_list,color:  _theme.shadowColor, ),
                                Gap( 10),
                                Text(
                                  "Data",
                                  style: TextStyle(
                                      color:  _theme.shadowColor,
                                      fontSize: _size.height*0.025,
                                      fontWeight: FontWeight.bold
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      Gap( _size.height*0.01),

                    ],
                  ),
                ),
              ),

              //Transazioni
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(15.0),
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: actualTransactionList.length,
                    itemBuilder: (context, index) {
                      Transaction transaction =actualTransactionList[index];
                      return Container(
                        margin: EdgeInsets.only(
                          bottom: 10,
                        ),
                        decoration: BoxDecoration(

                          color:transaction.transactionType==TransactionType.expense?
                            _theme.primaryColor:
                            _theme.primaryColor.withOpacity(0.6),
                          borderRadius:BorderRadius.circular(20),
                        ),

                        child: ListTile(
                          contentPadding: EdgeInsets.all(12),
                          leading: CircleAvatar(
                            radius: 25,
                            backgroundColor:  _theme.shadowColor,
                            child: Icon(
                              transaction.transactionType== TransactionType.income?
                              Icons.arrow_upward_rounded :
                              Icons.arrow_downward_rounded,
                              color: transaction.transactionType==TransactionType.expense?
                                _theme.primaryColor:
                                _theme.primaryColor.withOpacity(0.6),
                            ),
                          ),
                          title: Text(
                            transaction.description,
                            style: TextStyle(
                              fontSize: _size.height*0.025,
                              fontWeight: FontWeight.bold,
                              color: _theme.shadowColor
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          subtitle: Text(
                            '${transaction.date.day}-${transaction.date.month}-${transaction.date.year}',
                            style: TextStyle(
                                fontSize: _size.height*0.017,
                                fontStyle:FontStyle.italic,
                                color: _theme.shadowColor
                            ),
                          ),
                          trailing: Padding(
                            padding: const EdgeInsets.only(right: 10.0),
                            child: Text(
                              "${transaction.amount.toStringAsFixed(2)} €",
                              style: TextStyle(
                                fontSize: _size.height*0.025,
                                color: _theme.shadowColor,
                                fontWeight: FontWeight.bold
                              ),
                            ),
                          ),

                          onTap: (){
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (context) => TransactionPage(actualTransactionList[index]),
                              ),
                            );
                          },
                        )

                      );
                    },
                  ),
                ),
              ),
            ],
          );
        }
      );
    }

}
