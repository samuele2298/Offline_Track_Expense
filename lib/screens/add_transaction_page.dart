import 'package:flutter/material.dart';
import 'package:flutter_finance_app/model/transaction.dart';
import 'package:flutter_finance_app/provider/general_provider.dart';
import 'package:flutter_finance_app/screens/home_page.dart';
import 'package:flutter_finance_app/screens/transaction_page.dart';
import 'package:provider/provider.dart';
import '../model/account.dart';
import '../model/summary_enums.dart';
import '../storage_provider/transaction_helper.dart';
import 'package:gap/gap.dart';
import 'package:flutter_toggle_tab/flutter_toggle_tab.dart';

class AddTransactionPage extends StatefulWidget {
  const AddTransactionPage({Key? key}) : super(key: key);

  @override
  State<AddTransactionPage> createState() => _AddTransactionPageState();
}
class _AddTransactionPageState extends State<AddTransactionPage> {

  TextEditingController amountController = TextEditingController();
  TextEditingController personController = TextEditingController();
  TextEditingController categoryController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();

  DateTime selectedDate = DateTime.now();
  final _formKeyAmount = GlobalKey<FormState>();
  final _formKeyPerson = GlobalKey<FormState>();
  final _formKeyCategory = GlobalKey<FormState>();
  final _formKeyDescription = GlobalKey<FormState>();

  bool isExpense = false;

  @override
  Widget build(BuildContext context) {
    Size _size = MediaQuery.of(context).size;
    ThemeData _theme = Theme.of(context);

    return Scaffold(
      backgroundColor: _theme.scaffoldBackgroundColor,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: _theme.primaryColor,
        leading: IconButton(
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                  builder: (context) => HomePage(index: 0)),
            );
          },
          icon: Icon(
            Icons.arrow_back,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.all(18),
          child: Container(
            padding: EdgeInsets.all(15),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(30),
            ),
            child: Column(
              children: [
                Gap(5),

                //Descrizione
                Container(
                  padding: EdgeInsets.symmetric(vertical: 15,horizontal:25 ),
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      color: _theme.primaryColor
                  ),
                  child: Form(
                    key: _formKeyDescription,
                    child: TextFormField(
                      autofocus: true,
                      controller: descriptionController,
                      style: TextStyle(
                        fontSize: _size.height*0.035,
                        color: _theme.shadowColor,
                        fontWeight: FontWeight.bold

                      ),
                      decoration: InputDecoration(
                        labelText: 'Inserisci descrizione:',
                        labelStyle: TextStyle(
                          fontSize: _size.height*0.035,
                          color: _theme.shadowColor
                        ),

                        hintText: 'Dare 5€ a Mario',
                        hintStyle: TextStyle(
                            fontSize: _size.height*0.035,
                            color: _theme.shadowColor
                        ),
                        border: InputBorder.none,
                        focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: _theme.shadowColor),
                        ),
                        errorBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: _theme.shadowColor),
                        ),
                        focusedErrorBorder:UnderlineInputBorder(
                          borderSide: BorderSide(color: _theme.shadowColor),
                        ),
                        errorStyle: TextStyle(color: Colors.white),

                      ),
                      validator: (value) {
                        if (descriptionController.text.isEmpty || descriptionController.text == ' ') {
                          return 'Inserisci una descrizione valida!';
                        }
                        return null;
                      },
                    ),
                  ),
                ),
                Gap(20),

                //Entrata?
                Container(
                  width: double.infinity,
                  child: Center(
                    child: FittedBox(
                      child: FlutterToggleTab(
                        isShadowEnable: false,
                        width: _size.width*0.3,
                        iconSize: _size.height*0.03,
                        height: _size.height*0.12,
                        isScroll: true,
                        borderRadius: 20,
                        selectedIndex: isExpense ? 1 : 0,
                        selectedTextStyle: TextStyle(
                            color:_theme.shadowColor,
                            fontSize: _size.height*0.03,
                            fontWeight: FontWeight.bold),
                        unSelectedTextStyle: TextStyle(
                            color: _theme.shadowColor,
                            fontSize: _size.height*0.03,
                            fontWeight: FontWeight.bold),
                        selectedBackgroundColors: [
                          !isExpense?
                          Colors.green:
                          _theme.primaryColor,

                        ],
                        unSelectedBackgroundColors: [_theme.scaffoldBackgroundColor],
                        labels: ['Entrata', 'Spesa'],
                        icons: [Icons.attach_money, Icons.money_off],
                        selectedLabelIndex: (index) {
                          setState(() {
                            isExpense = index != 0;
                          });
                        },
                        marginSelected: EdgeInsets.symmetric(horizontal: 5,vertical:15),
                      ),
                    ),
                  ),
                ),
                Gap(20),

                //Importo
                Container(
                  padding: EdgeInsets.symmetric(vertical: 15,horizontal:25 ),
                  decoration: BoxDecoration(
                    color: _theme.primaryColor,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Form(
                    key: _formKeyAmount,
                    child: TextFormField(
                      controller: amountController,
                      style: TextStyle(
                        fontSize: _size.height*0.04,
                        fontWeight: FontWeight.bold,
                        color: _theme.shadowColor
                      ),
                      keyboardType: TextInputType.numberWithOptions(decimal: true),
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        hintText: "123 €",
                        hintStyle: TextStyle(
                          fontSize: _size.height*0.04,
                          fontWeight: FontWeight.bold,
                          color: _theme.shadowColor
                        ),
                        labelText: "Importo: ",
                        labelStyle: TextStyle(
                            fontSize: _size.height*0.04,
                            fontWeight: FontWeight.bold,
                            color: _theme.shadowColor
                        ),
                        focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: _theme.shadowColor),
                        ),
                        errorBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: _theme.shadowColor),
                        ),
                        focusedErrorBorder:UnderlineInputBorder(
                          borderSide: BorderSide(color: _theme.shadowColor),
                        ),
                        errorStyle: TextStyle(color: Colors.white),
                      ),
                      validator: (value) {
                        String pattern = r'^\d+$';
                        RegExp regex = RegExp(pattern);
                        if (amountController.text.isEmpty || amountController.text == ' ') {
                          return 'Inserisci importo valido!';
                        } else if (!regex.hasMatch(value!))
                          return 'Inserisci un numero valido (100)';
                        return null;
                      },
                    ),
                  ),
                ),
                Gap( 16),

                //Chi e cosa
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly ,
                  children: [
                    Container(
                      width: _size.width*0.4,
                      padding: EdgeInsets.symmetric(vertical: 15,horizontal:25 ),
                      decoration: BoxDecoration(
                        color: _theme.primaryColor,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Form(
                        key: _formKeyPerson,
                        child: TextFormField(
                          controller: personController,
                          style: TextStyle(
                            fontSize: _size.height*0.035,
                              color: _theme.shadowColor
                          ),
                          decoration: InputDecoration(
                            labelStyle: TextStyle(
                              fontSize: _size.height*0.025,
                              color: _theme.shadowColor,
                              fontWeight: FontWeight.bold

                            ),
                            labelText: 'A chi?',
                            hintStyle: TextStyle(
                              fontSize: _size.height*0.035,
                              color: _theme.shadowColor,
                            ),
                            hintText: 'Mario',
                            border: InputBorder.none, // Rimuove la linea inferiore
                            focusedBorder: UnderlineInputBorder(
                              borderSide: BorderSide(color: _theme.shadowColor),
                            ),
                            errorBorder: UnderlineInputBorder(
                              borderSide: BorderSide(color: _theme.shadowColor),
                            ),
                            focusedErrorBorder:UnderlineInputBorder(
                              borderSide: BorderSide(color: _theme.shadowColor),
                            ),
                            errorStyle: TextStyle(color: Colors.white),
                          ),
                          validator: (value) {
                            if (personController.text.isEmpty || personController.text == ' ') {
                              return 'Inserisci un nome valido!';
                            }
                            return null;
                          },
                        ),
                      ),
                    ),
                    Spacer(),
                    Container(
                      width: _size.width*0.4,
                      padding: EdgeInsets.symmetric(vertical: 15,horizontal:25 ),
                      decoration: BoxDecoration(
                        color: _theme.primaryColor,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Form(
                        key: _formKeyCategory,
                        child: TextFormField(
                          controller: categoryController,
                          style: TextStyle(
                              fontSize: _size.height*0.035,
                              color: _theme.shadowColor
                          ),
                          decoration: InputDecoration(
                            labelStyle: TextStyle(
                                fontSize: _size.height*0.025,
                                color: _theme.shadowColor,
                                fontWeight: FontWeight.bold

                            ),
                            labelText: 'Per cosa?',
                            hintStyle: TextStyle(
                              fontSize: _size.height*0.035,
                              color: _theme.shadowColor,
                            ),
                            hintText: 'Svago',
                            border: InputBorder.none, // Rimuove la linea inferiore
                            focusedBorder: UnderlineInputBorder(
                              borderSide: BorderSide(color: _theme.shadowColor),
                            ),
                            errorBorder: UnderlineInputBorder(
                              borderSide: BorderSide(color: _theme.shadowColor),
                            ),
                            focusedErrorBorder:UnderlineInputBorder(
                              borderSide: BorderSide(color: _theme.shadowColor),
                            ),
                            errorStyle: TextStyle(color: Colors.white),
                          ),
                          validator: (value) {
                            if (categoryController.text.isEmpty || categoryController.text == ' ') {
                              return 'Inserisci una categoria valida!';
                            }
                            return null;
                          },
                        ),
                      ),
                    ),
                  ],
                ),
                Gap( 30),


                //Calendario
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    color: Colors.white
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(20),
                    child: Theme(
                      data: ThemeData.light().copyWith(

                        colorScheme: ColorScheme.light(
                          primary: _theme.primaryColor,
                        ),
                      ),
                      child: CalendarDatePicker(
                        initialDate: DateTime.now(),
                        firstDate: DateTime(2000),
                        lastDate: DateTime(2100),
                        onDateChanged: handleDateChanged,
                        // Gestisci la selezione della data
                      ),
                    ),
                  ),
                ),

            ]
          ),
          )
      ),
      ),
      floatingActionButton: InkWell(
          onTap: (){
            launchForm();
          },
          child: Container(

            width: _size.width*0.7,
            height: _size.height*0.08,

            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(25),
                color: _theme.primaryColor

            ),
            child: Center(
              child: Text(
                'Aggiungi',
                style: TextStyle(
                  fontSize: _size.height*0.03,
                  fontWeight: FontWeight.bold,
                  color:_theme.shadowColor
                ),
              ),
            ),
          ),
        ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,


    );
  }

  void launchForm(){
    Size _size = MediaQuery.of(context).size;
    ThemeData _theme = Theme.of(context);


    int? year = selectedDate?.year; // Estrai l'anno (nullable)
    int? month = selectedDate?.month; // Estrai il mese (nullable)
    int? day = selectedDate?.day; // Estrai il giorno (nullable)

    if (year != null && month != null && day != null) {

      bool descBool = _formKeyDescription.currentState!.validate();
      bool amountBool = _formKeyAmount.currentState!.validate();
      bool cateBool = _formKeyCategory.currentState!.validate();
      bool persBool = _formKeyPerson.currentState!.validate();

      if(descBool && amountBool && cateBool && persBool){

        try {
          Transaction t = Transaction(
              account: Provider.of<GeneralProvider>(context,listen: false).actualAccount!.name,
              transactionType: isExpense? TransactionType.expense: TransactionType.income,
              date: DateTime(year!,month!,day!),
              category: categoryController.text,
              person: personController.text,
              amount:double.parse(amountController.text) ,
              description: descriptionController.text);
        if (!iHaveEnoughMoney(t) && isExpense) {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Text('Non hai abbastanza soldi su questo account!'),
              );
            },
          );
        }else if( Provider.of<GeneralProvider>(context,listen: false).transactionXAccount.contains(t)){
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20), // Questo arrotonda i bordi del dialogo.
                ),

                backgroundColor: _theme.primaryColor,
                shadowColor: Colors.transparent,
                title: Text('Transazione già presente!', style: TextStyle(color: Colors.white),),
                content: Icon(
                    Icons.wrong_location, color: Colors.white, size: 48.0),
              );
            },
            barrierDismissible: true, // Questa proprietà permette di chiudere il dialogo toccando all'esterno
          );
        }
        else{

          TransactionHelper.instance.add(t);

          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20), // Questo arrotonda i bordi del dialogo.
                ),

                backgroundColor: _theme.primaryColor,
                shadowColor: Colors.transparent,
                title: Text('Transazione aggiunta correttamente!', style: TextStyle(color: Colors.white),),
                content: Icon(
                    Icons.check_circle, color: Colors.white, size: 48.0),
              );
            },
            barrierDismissible: true, // Questa proprietà permette di chiudere il dialogo toccando all'esterno
          ).then((_) {
            Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => TransactionPage(t)));
          });

          //Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => TransactionPage(t)));
        }

        } on Exception catch (e) {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20), // Questo arrotonda i bordi del dialogo.
                ),

                backgroundColor: _theme.primaryColor,
                shadowColor: Colors.transparent,
                title: Text('Transazione non eseguita correttamente! Per l \'importo', style: TextStyle(color: Colors.white),),
                content: Icon(
                    Icons.report, color: Colors.white, size: 48.0),
              );
            },
            barrierDismissible: true, // Questa proprietà permette di chiudere il dialogo toccando all'esterno
          );
        }
      }



    }else {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            backgroundColor: _theme.primaryColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20), // Questo arrotonda i bordi del dialogo.
            ),
            shadowColor: Colors.transparent,
            title: Text('Seleziona una data valida', style: TextStyle(color: Colors.white),),
            content: Icon(
                Icons.wrong_location, color: Colors.white, size: 48.0),
          );
        },
        barrierDismissible: true, // Questa proprietà permette di chiudere il dialogo toccando all'esterno
      );
    }
  }


  bool iHaveEnoughMoney(Transaction t){
    if(Provider.of<GeneralProvider>(context,listen: false).actualAccount!.balance< t.amount) return false;
    return true;
  }
  void handleDateChanged(DateTime? date) {
    setState(() {
      selectedDate = date!;
    });
  }



}
