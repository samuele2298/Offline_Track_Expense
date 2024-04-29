import 'package:flutter/material.dart';
import 'package:flutter_finance_app/model/summary_enums.dart';
import 'package:flutter_finance_app/model/transaction.dart';
import 'package:flutter_finance_app/provider/general_provider.dart';
import 'package:flutter_finance_app/screens/transaction_page.dart';
import 'package:flutter_finance_app/theme/themes.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:gap/gap.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_toggle_tab/flutter_toggle_tab.dart';
import '../model/person_category.dart';

class DebitPage extends StatefulWidget {

  @override
  State<DebitPage> createState() => _DebitPageState();
}
class _DebitPageState extends State<DebitPage> {

  bool isDebt = false;

  List<PersonProspect> allPerson = [];
  List<PersonProspect> debtPerson = [];
  List<PersonProspect> creditPerson = [];

  @override
  void initState()  {
    super.initState();

    final provider = Provider.of<GeneralProvider>(context, listen: false);

    provider.addListener(() {

      if (!mounted) {
        return;
      }

      // Reload the lists with the new data
      setState(() {
        // Clear the lists
        //allPerson.clear();
        //debtPerson.clear();
        //creditPerson.clear();

        loadPersonProspects(provider);
      });
    });

    setState(() {
      SchedulerBinding.instance.addPostFrameCallback((_) {
        // Clear the lists
        allPerson.clear();
        debtPerson.clear();
        creditPerson.clear();

        loadPersonProspects(provider);
      });
    });
    // Load the PersonProspect objects for the initial selected account

  }

  void loadPersonProspects( GeneralProvider provider) {
    var personMap = <String, PersonProspect>{};

    for (var transaction in provider.getTransactionXAccount) {
      var personName = transaction.person;

      if (!personMap.containsKey(personName)) {
        // If the person is not in the map, add them with a new PersonProspect
        personMap[personName] = PersonProspect(
          name: personName,
          balance: 0.0, // Initialize balance to 0
          transactionList: [], // Initialize an empty transaction list
        );
      }

      personMap[personName]?.transactionList.add(transaction);
      if(transaction.transactionType == TransactionType.expense)
        personMap[personName]?.balance += transaction.amount;
      else personMap[personName]?.balance -= transaction.amount;
    }

    // Convert the map values (PersonProspect objects) to a list
    allPerson = personMap.values.toList();

    for (PersonProspect person in allPerson) {
      if (person.balance < 0.0) {
        if (!debtPerson.any((p) => p.name == person.name)) {
          debtPerson.add(person);
        }
      } else {
        if (!creditPerson.any((p) => p.name == person.name)) {
          creditPerson.add(person);
        }
      }
    }

    //print('persone trovate .. ${allPerson.length} ') ;
    //print('creditPerson trovate .. ${creditPerson.length} ') ;
    //print('debtPerson trovate .. ${debtPerson.length} ') ;
  }


  @override
  Widget build(BuildContext context) {
    Size _size = MediaQuery.of(context).size;
    ThemeData _theme = Theme.of(context);

    Color primaryOp =  _theme.primaryColor.withOpacity(0.7);

    return Column(
      children: [

        //Recap
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
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "Amici",
                      style: TextStyle(
                          fontSize: _size.height*0.05,
                          fontWeight: FontWeight.bold,
                          color: _theme.shadowColor
                      ),
                    ),
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
                        'Netto: ',
                        style: TextStyle(
                            fontSize:_size.height*0.04,
                            color: _theme.shadowColor,
                            fontWeight: FontWeight.bold
                        ),
                      ),
                      Spacer(),
                      Text(
                        (totBalance(creditPerson).abs()-totBalance(debtPerson).abs())>=0?
                        '+ ${(totBalance(debtPerson).abs()-totBalance(creditPerson)).abs().toStringAsFixed(0)} €':
                        '- ${(totBalance(debtPerson).abs()-totBalance(creditPerson)).abs().toStringAsFixed(0)} €',
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
                                  'Debiti',
                                  style: TextStyle(
                                    fontSize: _size.height*0.02,
                                    color: _theme.primaryColor,
                                  ),
                                ),
                                Text(
                                  '${totBalance(debtPerson).toStringAsFixed(0)} €',
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
                      selected: isDebt,
                      onSelected: (bool selected) {
                        setState(() {
                          isDebt = false;
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
                                  'Crediti',
                                  style: TextStyle(
                                    fontSize: _size.height*0.02,
                                    color: _theme.primaryColor,
                                  ),
                                ),
                                Text(
                                  '${totBalance(creditPerson).toStringAsFixed(0)} €',
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
                      selected: !isDebt,
                      onSelected: (bool selected) {
                        setState(() {
                          isDebt = true;
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
        Gap(20),

        //Debiti/Crediti
        Expanded(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Column(
                children: !isDebt ?
                List<Widget>.generate(
                  debtPerson.length,
                      (int index) {
                    return Container(
                      margin: EdgeInsets.only(bottom: 10),
                      padding: EdgeInsets.all(12),
                      decoration: BoxDecoration(
                          color: _theme.primaryColor,
                          borderRadius: BorderRadius.circular(20)
                      ),
                      child: ListTile(
                        onTap: () {
                          launchPopUpPersonProspectSummary(debtPerson[index]);
                        },
                        contentPadding: EdgeInsets.all(5),
                        leading: CircleAvatar(
                          child: Text(
                            '${debtPerson[index].name[0].toUpperCase()}',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: _size.height*0.03,
                              color:  _theme.primaryColor,
                            ),
                          ),
                          backgroundColor: _theme.shadowColor,
                          radius: _size.height*0.04,
                        ),
                        title:  Text('${debtPerson[index].name}',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: _size.height*0.03,
                            color:  _theme.shadowColor,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        trailing: Text(
                          '${debtPerson[index].balance} €',
                          style: TextStyle(
                            //fontWeight: FontWeight.bold,
                            fontSize: _size.height*0.03,
                            color:  _theme.shadowColor,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    );
                  },
                ):
                List<Widget>.generate(
                  creditPerson.length,
                      (int index) {
                    return Container(
                      margin: EdgeInsets.only(bottom: 10),
                      padding: EdgeInsets.all(12),
                      decoration: BoxDecoration(
                          color: primaryOp,
                          borderRadius: BorderRadius.circular(20)
                      ),
                      child: ListTile(
                        onTap: () {
                          launchPopUpPersonProspectSummary(creditPerson[index]);
                        },
                        contentPadding: EdgeInsets.all(5),
                        leading: CircleAvatar(
                          child: Text(
                            '${creditPerson[index].name[0].toUpperCase()}',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: _size.height*0.03,
                              color:  primaryOp,
                            ),
                          ),
                          backgroundColor: _theme.shadowColor,
                          radius: _size.height*0.04,
                        ),
                        title:  Text('${creditPerson[index].name}',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: _size.height*0.03,
                            color:  _theme.shadowColor,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        trailing: Text(
                          '${creditPerson[index].balance} €',
                          style: TextStyle(
                            //fontWeight: FontWeight.bold,
                            fontSize: _size.height*0.03,
                            color:  _theme.shadowColor,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        ),

      ],
    );
  }

  void launchPopUpPersonProspectSummary(PersonProspect personProspect){
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
                  'Persona:',
                  style: TextStyle(
                    //fontWeight: FontWeight.bold,
                    color: _theme.shadowColor,
                    fontSize: _size.height*0.03,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10.0),
                  child: Text(
                    personProspect.name,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: _theme.shadowColor,
                      fontSize: _size.height*0.06,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Gap(25),
                Text(
                  personProspect.balance>=0?
                    'Credito:':
                    'Debito:',
                  style: TextStyle(
                    //fontWeight: FontWeight.bold,
                    color: _theme.shadowColor,
                    fontSize: _size.height*0.03,
                  ),
                ),
                Gap(10),
                Text(
                  personProspect.balance.abs().toString()+ ' €',
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
                      itemCount: personProspect.transactionList.length,
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
                            DateFormat('dd-MM-yyyy').format(personProspect.transactionList[index2].date),
                            style: TextStyle(
                              fontStyle: FontStyle.italic,
                              color: _theme.shadowColor,
                              fontSize: _size.height*0.02,
                            ),
                          ),
                          title: Text(
                            personProspect.transactionList[index2].description,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: _theme.shadowColor,
                              fontSize: _size.height*0.02,
                            ),
                          ),
                          trailing: Text(
                            personProspect.transactionList[index2].amount.toStringAsFixed(2)+ ' €',
                            style: TextStyle(
                              //fontWeight: FontWeight.bold,
                              color: _theme.shadowColor,
                              fontSize: _size.height*0.02,
                            ),
                          ),
                          onTap: (){
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(builder:(BuildContext context) => TransactionPage(personProspect.transactionList[index2])),
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

  double totBalance(List<PersonProspect> list){
    double r=0.0;
    for(PersonProspect pp  in list){
      r = r+pp.balance;
    }
    return r;
  }
}


