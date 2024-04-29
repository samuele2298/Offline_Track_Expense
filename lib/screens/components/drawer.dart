import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_finance_app/provider/general_provider.dart';
import 'package:provider/provider.dart';
import 'package:gap/gap.dart';
import '../../model/account.dart';
import '../../storage_provider/account_helper.dart';
import '../home_page.dart';

class StaticDrawer extends StatefulWidget {

  @override
  State<StaticDrawer> createState() => _StaticDrawerState();
}
class _StaticDrawerState extends State<StaticDrawer> {

  String selected = '';

  final _formKeyValidator = GlobalKey<FormState>();


  @override
  Widget build(BuildContext context) {
    Size _size = MediaQuery.of(context).size;
    ThemeData _theme = Theme.of(context);

    final provider = Provider.of<GeneralProvider>(context, listen: false);
    return Consumer<GeneralProvider>(
        builder: (_, gp, __) {
          return Drawer(
            backgroundColor: _theme.scaffoldBackgroundColor,
            child: ListView(
              padding: EdgeInsets.zero,
              children: <Widget>[
                UserAccountsDrawerHeader(
                  decoration: BoxDecoration(
                      color: _theme.primaryColor,
                  ),
                  accountName: Text('Giulia',
                    style: TextStyle(
                        fontSize: 20,
                        color: _theme.shadowColor
                    ),),
                  accountEmail: Text('Da Como',
                    style: TextStyle(
                        fontSize: 15,
                        color: _theme.shadowColor
                    ),),
                  currentAccountPicture: ClipRRect(
                    child: Container(
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(1000),
                          color: _theme.shadowColor
                      ),
                      child: Center(
                          child: Text('G',
                            style: TextStyle(
                                fontSize: 30,
                                color: _theme.primaryColor
                            ),
                          )
                      ),
                    ),
                  ),
                ),

                Padding(
                  padding: EdgeInsets.all(_size.height*0.02),
                  child: Column(
                    children: [
                      ListView.builder(
                        shrinkWrap: true,
                        itemCount: gp.getAccountList.length,
                        itemBuilder: (context, index) {
                          return Container(
                            margin: EdgeInsets.only(bottom: 20),
                            child: Dismissible(
                              key: Key(gp.getAccountList[index].name),
                              direction: DismissDirection.horizontal,
                              confirmDismiss: (direction) async {
                                if (direction == DismissDirection.endToStart) {
                                  //Elimina
                                  return await showDialog(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return AlertDialog(
                                        shadowColor:  Colors.transparent,
                                        backgroundColor: _theme.primaryColor,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(20),
                                        ),
                                        title: Text('Sicuro di volerla cancellare?', style: TextStyle(color: Colors.white),),
                                        actions: <Widget>[
                                          TextButton(
                                            child: Text('Annulla', style: TextStyle(color: Colors.white),),
                                            onPressed: () {
                                              Navigator.of(context).pop(false); // Dismiss the dialog and cancel the dismissal.
                                            },
                                          ),
                                          // Add a "Conferma" button that returns true.
                                          TextButton(
                                            child: Text('Avanti', style: TextStyle(color: Colors.white),),
                                            onPressed: () {

                                              AccountHelper.instance.delete(gp.getAccountList[index].id!);

                                              setState(() {
                                                gp.getAccountList.removeAt(index);
                                              });

                                              Navigator.pop(context);

                                              showDialog(
                                                context: context,
                                                builder: (BuildContext context) {
                                                  return AlertDialog(
                                                    shadowColor:  Colors.transparent,
                                                    backgroundColor: _theme.primaryColor,
                                                    shape: RoundedRectangleBorder(
                                                      borderRadius: BorderRadius.circular(20),
                                                    ),
                                                    title: Text('Account eliminato correttamente', style: TextStyle(color: Colors.white),),
                                                    content: Icon(Icons.check_circle, color: Colors.white, size: 48.0),

                                                  );
                                                },
                                              );



                                            },
                                          ),
                                        ],
                                      );
                                    },
                                  );
                                } else if (direction == DismissDirection.startToEnd) {
                                  //Modifica
                                  final nameController2 = TextEditingController();
                                  final balanceController2 = TextEditingController();

                                  nameController2.text = gp.getAccountList[index].name;
                                  balanceController2.text = gp.getAccountList[index].balance.toString();

                                  return await showDialog(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return AlertDialog(
                                        shadowColor: Colors.transparent,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(20), // Questo arrotonda i bordi del dialogo.
                                        ),

                                        backgroundColor: _theme.primaryColor,
                                        title: Center(child: Text('Aggiungi conto', style: TextStyle(color: _theme.shadowColor))),
                                        content: Container(
                                          height: _size.height * 0.25,
                                          child: Center(
                                            child: Form(
                                              key: _formKeyValidator,
                                              child: Column(
                                                children: <Widget>[
                                                  Gap(20),
                                                  TextFormField(
                                                    controller: nameController2,
                                                    decoration: InputDecoration(
                                                      hintText: "Nome",
                                                      hintStyle: TextStyle(color: _theme.shadowColor),

                                                      enabledBorder: UnderlineInputBorder(
                                                        borderSide: BorderSide(color: _theme.shadowColor),
                                                      ),
                                                      focusedBorder: UnderlineInputBorder(
                                                        borderSide: BorderSide(color: _theme.shadowColor),
                                                      ),
                                                      errorStyle: TextStyle(color: _theme.shadowColor),
                                                      errorBorder: UnderlineInputBorder(
                                                        borderSide: BorderSide(color: _theme.shadowColor),
                                                      ),

                                                    ),
                                                    style: TextStyle(color: _theme.shadowColor,),

                                                    validator: (value) {
                                                      if (nameController2.text.isEmpty || nameController2.text == ' ') {
                                                        return 'Inserisci un nome';
                                                      }
                                                      return null;
                                                    },
                                                  ),
                                                  Gap(15),
                                                  TextFormField(
                                                    controller: balanceController2,
                                                    decoration: InputDecoration(
                                                      hintText: "Saldo",
                                                      hintStyle: TextStyle(color: _theme.shadowColor),
                                                      enabledBorder: UnderlineInputBorder(
                                                        borderSide: BorderSide(color: _theme.shadowColor),
                                                      ),
                                                      focusedBorder: UnderlineInputBorder(
                                                        borderSide: BorderSide(color: _theme.shadowColor),
                                                      ),
                                                      errorStyle: TextStyle(color: _theme.shadowColor),
                                                      errorBorder: UnderlineInputBorder(
                                                        borderSide: BorderSide(color: _theme.shadowColor),
                                                      ),


                                                    ),

                                                    style: TextStyle(color: _theme.shadowColor),
                                                    validator: (value) {
                                                      if (balanceController2.text.isEmpty) {
                                                        return 'Inserisci un bilancio';
                                                      }
                                                      try {
                                                        double.parse(balanceController2.text);
                                                      } catch (e) {
                                                        return 'Inserisci un bilancio valido';
                                                      }
                                                      return null;
                                                    },


                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                        actions: <Widget>[
                                          TextButton(
                                            child: Text('Salva', style: TextStyle(color: _theme.shadowColor,fontSize: _size.height*0.02)),
                                            onPressed: () {

                                              if (_formKeyValidator.currentState!.validate()) {
                                                Account a = Account(
                                                  name: nameController2.text,
                                                  balance: double.parse(balanceController2.text),
                                                );
                                                AccountHelper.instance.update(a);
                                              }

                                              setState(() {
                                                //gp.getAccountList[index].name = nameController2.text;
                                                //gp.getAccountList[index].balance =balanceController2.text;
                                              });

                                              Navigator.pop(context);

                                              showDialog(
                                                context: context,
                                                builder: (BuildContext context) {
                                                  return AlertDialog(
                                                    shadowColor:  Colors.transparent,
                                                    backgroundColor: _theme.primaryColor,
                                                    shape: RoundedRectangleBorder(
                                                      borderRadius: BorderRadius.circular(20),
                                                    ),
                                                    title: Text('Account modificato correttamente', style: TextStyle(color: Colors.white),),
                                                    content: Icon(Icons.check_circle, color: Colors.white, size: 48.0),

                                                  );
                                                },
                                              );



                                              Navigator.pop(context);

                                            },
                                          ),
                                        ],

                                      );
                                    },
                                  );
                                }
                              },

                              background: Container(
                                alignment: Alignment.centerRight,
                                decoration: BoxDecoration(
                                    color: Colors.red,
                                    borderRadius: BorderRadius.circular(10)
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Icon(Icons.delete, color: Colors.white),
                                ),
                              ),
                              child: ListTile(
                                onTap: () {
                                  setState(() {
                                    gp.setActualAccount(gp.getAccountList[index]);
                                    gp.setTransactionXAccount(gp.transactionList.where((transaction) => transaction.account == gp.actualAccount.name).toList());
                                  });
                                },
                                leading: Icon(
                                  Icons.account_balance,
                                  color: gp.getAccountList[index].name == provider.actualAccount!.name ?
                                    _theme.shadowColor :
                                    _theme.primaryColor,
                                ),
                                title: Text('${gp.getAccountList[index].name}',
                                  style: TextStyle(
                                    color: gp.getAccountList[index].name == provider.actualAccount!.name ?
                                    _theme.shadowColor :
                                    _theme.primaryColor,
                                  ),
                                ),
                                trailing: Text('${gp.getAccountList[index].balance} €',
                                  style: TextStyle(
                                    color: gp.getAccountList[index].name == provider.actualAccount!.name ?
                                    _theme.shadowColor :
                                    _theme.primaryColor,
                                  ),
                                ),

                                tileColor: gp.getAccountList[index].name == provider.actualAccount!.name ?
                                  _theme.primaryColor :
                                  _theme.shadowColor,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),

                              ),
                            ),
                          );
                        },
                      ),
                      Gap(_size.height*0.02),
                      InkWell(
                        onTap: () {
                          final nameController = TextEditingController();
                          final balanceController = TextEditingController();

                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                shadowColor: Colors.transparent,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20), // Questo arrotonda i bordi del dialogo.
                                ),

                                backgroundColor: _theme.primaryColor,
                                title: Center(child: Text('Aggiungi conto', style: TextStyle(color: _theme.shadowColor))),
                                content: Container(
                                  height: _size.height * 0.25,
                                  child: Center(
                                    child: Form(
                                      key: _formKeyValidator,
                                      child: Column(
                                        children: <Widget>[
                                          Gap(20),
                                          TextFormField(
                                            controller: nameController,
                                            decoration: InputDecoration(
                                              hintText: "Nome",
                                              hintStyle: TextStyle(color: _theme.shadowColor),

                                              enabledBorder: UnderlineInputBorder(
                                                borderSide: BorderSide(color: _theme.shadowColor),
                                              ),
                                              focusedBorder: UnderlineInputBorder(
                                                borderSide: BorderSide(color: _theme.shadowColor),
                                              ),
                                              errorStyle: TextStyle(color: _theme.shadowColor),
                                              errorBorder: UnderlineInputBorder(
                                                borderSide: BorderSide(color: _theme.shadowColor),
                                              ),

                                            ),
                                            style: TextStyle(color: _theme.shadowColor,),

                                            validator: (value) {
                                              if (nameController.text.isEmpty || nameController.text == ' ') {
                                                return 'Inserisci un nome';
                                              }
                                              return null;
                                            },
                                          ),
                                          Gap(15),
                                          TextFormField(
                                            controller: balanceController,
                                            decoration: InputDecoration(
                                              hintText: "Saldo",
                                              hintStyle: TextStyle(color: _theme.shadowColor),
                                              enabledBorder: UnderlineInputBorder(
                                                borderSide: BorderSide(color: _theme.shadowColor),
                                              ),
                                              focusedBorder: UnderlineInputBorder(
                                                borderSide: BorderSide(color: _theme.shadowColor),
                                              ),
                                              errorStyle: TextStyle(color: _theme.shadowColor),
                                              errorBorder: UnderlineInputBorder(
                                                borderSide: BorderSide(color: _theme.shadowColor),
                                              ),


                                            ),

                                            style: TextStyle(color: _theme.shadowColor),
                                            validator: (value) {
                                              if (balanceController.text.isEmpty) {
                                                return 'Inserisci un bilancio';
                                              }
                                              try {
                                                double.parse(balanceController.text);
                                              } catch (e) {
                                                return 'Inserisci un bilancio valido';
                                              }
                                              return null;
                                            },


                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                                actions: <Widget>[
                                  TextButton(
                                    child: Text('Salva', style: TextStyle(color: _theme.shadowColor,fontSize: _size.height*0.02)),
                                    onPressed: () {

                                      if (_formKeyValidator.currentState!.validate()) {
                                        Account a = Account(
                                          name: nameController.text,
                                          balance: double.parse(balanceController.text),
                                        );
                                        AccountHelper.instance.add(a);
                                      }

                                      Navigator.pop(context);

                                    },
                                  ),
                                ],

                              );
                            },
                          );

                        },
                        child: ClipRRect(
                          child: CircleAvatar(
                            backgroundColor: _theme.primaryColor,
                              child:Icon(Icons.add,color: _theme.shadowColor,)
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

              ],
            ),
          );
        }
      );
  }



}

