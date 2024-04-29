import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_finance_app/model/summary_enums.dart';
import 'package:flutter_finance_app/model/transaction.dart';
import 'package:flutter_finance_app/provider/general_provider.dart';
import 'package:flutter_toggle_tab/flutter_toggle_tab.dart';
import 'package:gap/gap.dart';
import 'package:provider/provider.dart';
import '../model/account.dart';
import '../storage_provider/transaction_helper.dart';
import 'home_page.dart';
import 'package:intl/intl.dart';

class TransactionPage extends StatefulWidget {

  TransactionPage(this.transaction);
  final Transaction transaction;

  @override
  State<TransactionPage> createState() => _TransactionPageState();
}
class _TransactionPageState extends State<TransactionPage> {
  bool _isEditing = false;
  bool _isExpense = false;

  //Form
  TextEditingController amountController = TextEditingController();
  TextEditingController personController = TextEditingController();
  TextEditingController categoryController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();
  TextEditingController accountController = TextEditingController();

  final _formKeyAmount = GlobalKey<FormState>();
  final _formKeyDescription = GlobalKey<FormState>();
  final _formKeyPerson= GlobalKey<FormState>();
  final _formKeyCategory = GlobalKey<FormState>();

  DateTime selectedDate = DateTime.now();
  Account newAccount = Account.none;

  @override
  Widget build(BuildContext context) {
    ThemeData _theme = Theme.of(context);
    Size _size = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
      elevation: 1.0,
      backgroundColor: _theme.primaryColor,
      leading: _isEditing?
        Gap(0):
        IconButton(
          icon: Icon(Icons.arrow_back_outlined, color: _theme.shadowColor), // This adds a back arrow.
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    HomePage(index: 1,),
              ),
            );
          }
        ),
      centerTitle: true,
      title: _isEditing?
        Title(
          color: _theme.shadowColor,
          child: Text('Modifica',style: TextStyle(color:_theme.shadowColor,fontWeight: FontWeight.bold),)
        ):
        Text('')
    ),
      body: _isEditing? _edit(): _view(),
      floatingActionButton: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            InkWell(
              onTap: () {
                _isEditing?
                  setState(() {
                    _isEditing = !_isEditing;
                  }):
                  delete();
              },
              child: Container(
                decoration: BoxDecoration(
                    color: _theme.primaryColor,
                    borderRadius: BorderRadius.circular(20)
                ),
                child: Padding(
                  padding: EdgeInsets.all(20),
                  child: !_isEditing ?
                    Row(
                      children: [
                        Icon(
                          Icons.delete,
                          color: _theme.shadowColor,
                          size: _size.height*0.03,
                        ),
                        Gap(15),
                        Text(
                          'Elimina',
                          style: TextStyle(
                            fontSize:  _size.height*0.025,
                            color: _theme.shadowColor,
                            fontWeight: FontWeight.bold
                          ),
                        ),
                      ],
                    ):
                    Row(
                      children: [
                        Icon(
                          Icons.arrow_back,
                          color: _theme.shadowColor,
                          size: _size.height*0.03,
                        ),
                        Gap(10),
                        Text(
                          'Indietro',
                          style: TextStyle(
                            fontSize:  _size.height*0.025,
                            color: _theme.shadowColor,
                            fontWeight: FontWeight.bold

                          ),
                        ),
                      ],
                    ),
                )
              ),
            ),
            Gap(0),
            InkWell(
              onTap: () {
                _isEditing?
                  launchForm() :
                  setState(() {
                    _isEditing = !_isEditing;
                  });
              },
              child: Container(
                  decoration: BoxDecoration(
                    color: _theme.primaryColor,
                    borderRadius: BorderRadius.circular(20)
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(20),
                    child: !_isEditing ?
                      Row(
                        children: [
                          Icon(
                            Icons.edit,
                            color: _theme.shadowColor,
                            size: _size.height*0.03,
                          ),
                          Gap(10),
                          Text(
                            'Modifica',
                            style: TextStyle(
                              fontSize:  _size.height*0.025,
                              color: _theme.shadowColor,
                              fontWeight: FontWeight.bold
                            ),
                          ),
                        ],
                      ):
                      Row(
                        children: [
                          Icon(
                            Icons.done,
                            color: _theme.shadowColor,
                            size: _size.height*0.03,
                          ),
                          Gap(10),
                          Text(
                            'Conferma',
                            style: TextStyle(
                              fontSize:  _size.height*0.025,
                              color: _theme.shadowColor,
                                fontWeight: FontWeight.bold

                            ),
                          ),
                        ],
                      ),
                  )
              ),
            ),
          ],
        ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  Widget _view() {
    Size _size = MediaQuery.of(context).size;
    ThemeData _theme = Theme.of(context);

    accountController.text= widget.transaction.account;
    descriptionController.text= widget.transaction.description;
    personController.text= widget.transaction.person;
    categoryController.text= widget.transaction.category;
    amountController.text= widget.transaction.amount.toStringAsFixed(0);
    selectedDate= widget.transaction.date;

    List<Account> listaAccount = Provider.of<GeneralProvider>(context, listen: false).accountList;
    newAccount= listaAccount.firstWhere((element) => element.name ==widget.transaction.account);

    Color primaryOp = _theme.primaryColor.withOpacity(0.8);

    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            //Descrizione e Data
            Container(
              width: _size.width*0.9,
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                  color: _theme.primaryColor,
                  borderRadius: BorderRadius.circular(20)
              ),
              child: Column(
                children: [
                  Text(
                    widget.transaction.description,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontSize: _size.height*0.06,
                        color: _theme.shadowColor,
                        fontWeight: FontWeight.bold
                    ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Gap(5),
                  Text(
                    DateFormat('dd-MM-yyyy').format(widget.transaction.date),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontSize: _size.height*0.04,
                        color: _theme.shadowColor,
                        fontStyle: FontStyle.italic
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),

                ],
              ),
            ),
            Gap(_size.height*0.05),

            //Account e importo
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Container(
                  width: _size.width*0.4,
                  padding: EdgeInsets.all(15),
                  decoration: BoxDecoration(
                      color: primaryOp,
                      borderRadius: BorderRadius.circular(20)
                  ),
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: _size.height*0.04,
                        backgroundColor: _theme.shadowColor,
                        child: Icon(
                          Icons.account_balance,
                          color: primaryOp,
                          size: _size.height*0.05,
                        ),
                      ),
                      Gap(20),
                      Column(
                        children: [
                          Text(
                            'Account: ',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: _size.height*0.02,
                              color: _theme.shadowColor,
                            ),
                          ),
                          Text(
                            widget.transaction.account,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                fontSize: _size.height*0.035,
                                color: _theme.shadowColor,
                                fontWeight: FontWeight.bold
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Container(
                  width: _size.width*0.4,
                  padding: EdgeInsets.all(15),
                  decoration: BoxDecoration(
                      color: primaryOp,
                      borderRadius: BorderRadius.circular(20)
                  ),
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: _size.height*0.04,
                        backgroundColor: _theme.shadowColor,
                        child: Icon(
                          Icons.balance,
                          color: primaryOp,
                          size: _size.height*0.05,
                        ),
                      ),
                      Gap(20),
                      Column(
                        children: [
                          Text(
                            'Importo:',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: _size.height*0.02,
                              color: _theme.shadowColor,
                            ),
                          ),

                          Text(
                            widget.transaction.transactionType == TransactionType.income?
                              '+${widget.transaction.amount.toStringAsFixed(0)} €':
                              '-${widget.transaction.amount.toStringAsFixed(0)} €',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                fontSize: _size.height*0.035,
                                color: _theme.shadowColor,
                                fontWeight: FontWeight.bold
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            Gap(40),

            //Chi e Cosa
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Container(
                  width: _size.width*0.4,
                  padding: EdgeInsets.all(15),
                  decoration: BoxDecoration(
                      color: primaryOp,
                      borderRadius: BorderRadius.circular(20)
                  ),
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: _size.height*0.04,
                        backgroundColor: _theme.shadowColor,
                        child: Icon(
                          Icons.person_2,
                          color: primaryOp,
                          size: _size.height*0.05,
                        ),
                      ),
                      Gap(20),
                      Column(
                        children: [
                          Text(
                            'Chi:',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: _size.height*0.02,
                              color: _theme.shadowColor,
                            ),
                          ),

                          Text(
                            widget.transaction.person,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                fontSize: _size.height*0.035,
                                color: _theme.shadowColor,
                                fontWeight: FontWeight.bold
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Container(
                  width: _size.width*0.4,
                  padding: EdgeInsets.all(15),
                  decoration: BoxDecoration(
                      color:primaryOp,
                      borderRadius: BorderRadius.circular(20)
                  ),
                  child: Column(
                    children: [
                      CircleAvatar(
                        backgroundColor: _theme.shadowColor,
                        radius: _size.height*0.04,

                        child: Icon(
                          Icons.category,
                          color: primaryOp,
                          size: _size.height*0.05,
                        ),
                      ),
                      Gap(20),
                      Column(
                        children: [
                          Text(
                            'Cosa:',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: _size.height*0.02,
                              color: _theme.shadowColor,
                            ),
                          ),

                          Text(
                            widget.transaction.category,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                fontSize: _size.height*0.035,
                                color: _theme.shadowColor,
                                fontWeight: FontWeight.bold
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),

            Gap(100),

          ],
        ),
      ),
    );
  }
  Widget _edit() {
    Size _size = MediaQuery.of(context).size;
    ThemeData _theme = Theme.of(context);

    Color primaryOp = _theme.primaryColor.withOpacity(0.8);

    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            //Descrizione e Data
            Container(
              width: _size.width*0.9,
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                  color: _theme.primaryColor,
                  borderRadius: BorderRadius.circular(20)
              ),
              child: Column(
                children: [
                  Form(
                    key: _formKeyDescription,
                    child: TextFormField(
                      controller: descriptionController,
                      decoration: InputDecoration(
                        hintText: widget.transaction.description,
                        hintStyle: TextStyle(color: Colors.white.withOpacity(0.4)),
                        border: UnderlineInputBorder(
                          borderSide: BorderSide(color: _theme.shadowColor),
                        ),
                        disabledBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: _theme.shadowColor),
                        ),
                        focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: _theme.shadowColor),
                        ),
                        enabledBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: _theme.shadowColor),
                        ),
                        errorBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: _theme.shadowColor),
                        ),
                        focusedErrorBorder:UnderlineInputBorder(
                          borderSide: BorderSide(color: _theme.shadowColor),
                        ),
                        errorText: descriptionController.text.trim().isEmpty ? 'Il campo non può essere vuoto' : null,
                        errorStyle: TextStyle(color: Colors.white),
                      ),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontSize: _size.height*0.06,
                          color: _theme.shadowColor,
                          fontWeight: FontWeight.bold
                      ),
                      validator: (value) {
                        if (descriptionController.text.isEmpty || descriptionController.text == ' ') {
                          return 'Inserisci una descrizione valida!';
                        }else if (descriptionController.text  == widget.transaction.description) {
                          return 'Nessuna modifica!';
                        }
                        return null;
                      },
                    ),

                  ),

                  Gap(15),
                  InkWell(
                    onTap: () {
                      popUpSelectDate();
                    },
                    child: Text(
                      DateFormat('dd-MM-yyyy').format(selectedDate),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontSize: _size.height*0.04,
                          color: _theme.shadowColor,
                          fontStyle: FontStyle.italic
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),

                ],
              ),
            ),
            Gap(_size.height*0.03),

            //Switch type
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
                    selectedIndex: _isExpense ? 0 : 1,
                    selectedTextStyle: TextStyle(
                        color:_theme.shadowColor,
                        fontSize: _size.height*0.03,
                        fontWeight: FontWeight.bold),
                    unSelectedTextStyle: TextStyle(
                        color: _theme.shadowColor,
                        fontSize: _size.height*0.03,
                        fontWeight: FontWeight.bold),
                    selectedBackgroundColors: [
                      _isExpense?
                        primaryOp:
                        Colors.green,
                    ],
                    unSelectedBackgroundColors: [_theme.scaffoldBackgroundColor],
                    labels: ['Spesa', 'Entrata' ],
                    icons: [Icons.attach_money, Icons.money_off],
                    selectedLabelIndex: (index) {
                      setState(() {
                        _isExpense = index == 0;
                      });
                    },
                    marginSelected: EdgeInsets.symmetric(horizontal: 5,vertical:15),
                  ),
                ),
              ),
            ),
            Gap(_size.height*0.03),

            //Account e importo
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                InkWell(
                  onTap: (){
                    popUpSelectAccount();
                  },
                  child: Container(
                    width: _size.width*0.4,
                    padding: EdgeInsets.all(15),
                    decoration: BoxDecoration(
                        color: primaryOp,
                        borderRadius: BorderRadius.circular(20)
                    ),
                    child: Column(
                      children: [
                        CircleAvatar(
                          radius: _size.height*0.04,
                          backgroundColor: _theme.shadowColor,
                          child: Icon(
                            Icons.account_balance,
                            color: primaryOp,
                            size: _size.height*0.05,
                          ),
                        ),
                        Gap(20),
                        Column(
                          children: [
                            Text(
                              'Account: ',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: _size.height*0.02,
                                color: _theme.shadowColor,
                              ),
                            ),
                            Text(
                              newAccount.name,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  fontSize: _size.height*0.035,
                                  color: _theme.shadowColor,
                                  fontWeight: FontWeight.bold
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                Container(
                  width: _size.width*0.4,
                  padding: EdgeInsets.all(15),
                  decoration: BoxDecoration(
                      color: primaryOp,
                      borderRadius: BorderRadius.circular(20)
                  ),
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: _size.height*0.04,
                        backgroundColor: _theme.shadowColor,
                        child: Icon(
                          Icons.balance,
                          color: primaryOp,
                          size: _size.height*0.05,
                        ),
                      ),
                      Gap(20),
                      Form(
                        key: _formKeyAmount,
                        child: TextFormField(
                          controller: amountController,
                          decoration: InputDecoration(
                            hintText: widget.transaction.amount.toStringAsFixed(0),
                            hintStyle: TextStyle(color: Colors.white.withOpacity(0.4)),
                            labelText: 'Importo:',
                            labelStyle: TextStyle(color: Colors.white),
                            border:  UnderlineInputBorder(
                              borderSide: BorderSide(color: _theme.shadowColor),
                            ),
                            disabledBorder: UnderlineInputBorder(
                              borderSide: BorderSide(color: _theme.shadowColor),
                            ),
                            focusedBorder:  UnderlineInputBorder(
                              borderSide: BorderSide(color: _theme.shadowColor),
                            ),
                            enabledBorder:  UnderlineInputBorder(
                              borderSide: BorderSide(color: _theme.shadowColor),
                            ),
                            errorBorder:  UnderlineInputBorder(
                              borderSide: BorderSide(color: _theme.shadowColor),
                            ),
                            focusedErrorBorder: UnderlineInputBorder(
                              borderSide: BorderSide(color: _theme.shadowColor),
                            ),
                            errorText: amountController.text.trim().isEmpty ? 'Il campo non può essere vuoto' : null,
                            errorStyle: TextStyle(color: Colors.white),
                          ),
                          style: TextStyle(color: _theme.shadowColor,fontSize: _size.height*0.04),
                          validator: (value) {
                            String pattern = r'^\d+$';
                            RegExp regex = RegExp(pattern);
                            if (amountController.text.isEmpty || amountController.text == ' ') {
                              return 'Inserisci importo valido!';
                            } else if (!regex.hasMatch(value!))
                              return 'Numero non valido';
                            else if (value == widget.transaction.amount.toStringAsFixed(0)) {
                              return 'Nessuna modifica!';
                            }
                            return null;

                          },
                        ),

                      ),
                    ],
                  ),
                ),
              ],
            ),
            Gap(40),

            //Chi e Cosa
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Container(
                  width: _size.width*0.4,
                  padding: EdgeInsets.all(15),
                  decoration: BoxDecoration(
                      color: primaryOp,
                      borderRadius: BorderRadius.circular(20)
                  ),
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: _size.height*0.04,
                        backgroundColor: _theme.shadowColor,
                        child: Icon(
                          Icons.person_2,
                          color: primaryOp,
                          size: _size.height*0.05,
                        ),
                      ),
                      Gap(20),
                      Column(
                        children: [
                          Text(
                            'Chi:',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: _size.height*0.02,
                              color: _theme.shadowColor,
                            ),
                          ),

                          Form(
                            key: _formKeyPerson,
                            child: TextFormField(
                              controller: personController,
                              decoration: InputDecoration(
                                hintText: widget.transaction.person,
                                hintStyle: TextStyle(color: Colors.white.withOpacity(0.4)),
                                border: UnderlineInputBorder(
                                  borderSide: BorderSide(color: _theme.shadowColor),
                                ),
                                disabledBorder: UnderlineInputBorder(
                                  borderSide: BorderSide(color: _theme.shadowColor),
                                ),
                                focusedBorder: UnderlineInputBorder(
                                  borderSide: BorderSide(color: _theme.shadowColor),
                                ),
                                enabledBorder: UnderlineInputBorder(
                                  borderSide: BorderSide(color: _theme.shadowColor),
                                ),
                                errorBorder: UnderlineInputBorder(
                                  borderSide: BorderSide(color: _theme.shadowColor),
                                ),
                                focusedErrorBorder:UnderlineInputBorder(
                                  borderSide: BorderSide(color: _theme.shadowColor),
                                ),
                                errorText: personController.text.trim().isEmpty ? 'Il campo non può essere vuoto' : null,
                                errorStyle: TextStyle(color: Colors.white),
                              ),
                              style: TextStyle(
                                  fontSize: _size.height*0.035,
                                  color: _theme.shadowColor,
                                  fontWeight: FontWeight.bold
                              ),
                              validator: (value) {
                                if (personController.text.isEmpty || personController.text == ' ') {
                                  return 'Inserisci una persona valida!';
                                }else if (personController.text  == widget.transaction.person) {
                                  return 'Nessuna modifica!';
                                }
                                return null;
                              },
                            ),

                          ),

                        ],
                      ),
                    ],
                  ),
                ),
                Container(
                  width: _size.width*0.4,
                  padding: EdgeInsets.all(15),
                  decoration: BoxDecoration(
                      color:primaryOp,
                      borderRadius: BorderRadius.circular(20)
                  ),
                  child: Column(
                    children: [
                      CircleAvatar(
                        backgroundColor: _theme.shadowColor,
                        radius: _size.height*0.04,

                        child: Icon(
                          Icons.category,
                          color: primaryOp,
                          size: _size.height*0.05,
                        ),
                      ),
                      Gap(20),
                      Column(
                        children: [
                          Text(
                            'Cosa:',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: _size.height*0.02,
                              color: _theme.shadowColor,
                            ),
                          ),

                          Form(
                            key: _formKeyCategory,
                            child: TextFormField(
                              controller: categoryController,
                              decoration: InputDecoration(
                                hintText: widget.transaction.category,
                                hintStyle: TextStyle(color: Colors.white.withOpacity(0.4)),
                                border: UnderlineInputBorder(
                                  borderSide: BorderSide(color: _theme.shadowColor),
                                ),
                                disabledBorder: UnderlineInputBorder(
                                  borderSide: BorderSide(color: _theme.shadowColor),
                                ),
                                focusedBorder: UnderlineInputBorder(
                                  borderSide: BorderSide(color: _theme.shadowColor),
                                ),
                                enabledBorder: UnderlineInputBorder(
                                  borderSide: BorderSide(color: _theme.shadowColor),
                                ),
                                errorBorder: UnderlineInputBorder(
                                  borderSide: BorderSide(color: _theme.shadowColor),
                                ),
                                focusedErrorBorder:UnderlineInputBorder(
                                  borderSide: BorderSide(color: _theme.shadowColor),
                                ),
                                errorText: categoryController.text.trim().isEmpty ? 'Il campo non può essere vuoto' : null,
                                errorStyle: TextStyle(color: Colors.white),
                              ),
                              style: TextStyle(
                                  fontSize: _size.height*0.035,
                                  color: _theme.shadowColor,
                                  fontWeight: FontWeight.bold
                              ),
                              validator: (value) {
                                if (categoryController.text.isEmpty || categoryController.text == ' ') {
                                  return 'Inserisci una categoria valida!';
                                }else if (categoryController.text  == widget.transaction.category) {
                                  return 'Nessuna modifica!';
                                }
                                return null;
                              },
                            ),

                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),

            Gap(100),

          ],
        ),
      ),
    );
  }


  void popUpSelectDate() {

    Size _size = MediaQuery.of(context).size;
    ThemeData _theme = Theme.of(context);

    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return WillPopScope(
          onWillPop: () async  {
            categoryController.text=widget.transaction.category;
            return true;
          },
          child: AlertDialog(
            shadowColor:  Colors.transparent,
            backgroundColor: _theme.primaryColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            title: Text(
              'Modifica la data',
              style: TextStyle(
                color:_theme.shadowColor,
                fontSize: _size.height*0.03,
              ),
            ),
            content: Container(
              width: _size.width*0.9,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: _theme.shadowColor
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
            actions: <Widget>[
              TextButton(
                child: Text('Salva', style: TextStyle(color: _theme.shadowColor),),
                onPressed: () {
                  Navigator.of(context).pop();

                },
              ),
            ],
          ),
        );
      },
    );
  }
  void popUpSelectAccount() {

    List<Account> listaAccount = Provider.of<GeneralProvider>(context, listen: false).accountList;
    //listaAccount.removeWhere((element) => element.name==widget.transaction.account);

    Size _size = MediaQuery.of(context).size;
    ThemeData _theme = Theme.of(context);

    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return WillPopScope(
          onWillPop: () async  {
            categoryController.text=widget.transaction.category;
            return true;
          },
          child: AlertDialog(
            shadowColor:  Colors.transparent,
            backgroundColor: _theme.primaryColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            title: Text(
              'Modifica l\'account',
              style: TextStyle(
                color:_theme.shadowColor,
                fontSize: _size.height*0.03,
              ),
            ),
            content: SingleChildScrollView(
              child: Container(
                width: _size.width*0.9,
                height: _size.height*0.2,
                child: Padding(
                  padding: EdgeInsets.all(10),
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: listaAccount.length,
                    itemBuilder: (context, index) {
                      return Container(
                        margin: EdgeInsets.only(bottom: 10),
                        decoration: BoxDecoration(
                          color: _theme.shadowColor,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: ListTile(
                          leading: Icon(
                            Icons.account_balance,
                            color: _theme.primaryColor,
                          ),
                          title: Text('${listaAccount[index].name}',
                            style: TextStyle(
                              color: _theme.primaryColor,
                              fontSize: _size.height*0.025
                            ),
                          ),
                          onTap: () {
                            handleAccountChanged(listaAccount[index]);
                            Navigator.of(context).pop();
                          },
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),

          ),
        );
      },
    );
  }

  void handleAccountChanged(Account account) {
    setState(() {
      newAccount = account;
    });
  }
  void handleDateChanged(DateTime? date) {
    setState(() {
      selectedDate = date!;
    });
  }


  void delete() async{
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Sicuro di volerla cancellare?'),
          actions: <Widget>[
            TextButton(
              child: Text('Annulla'),
              onPressed: () {
                Navigator.of(context).pop(); // Dismiss the dialog when the 'No' button is pressed
              },
            ),
            TextButton(
              child: Text('Avanti'),
              onPressed: () {
                TransactionHelper.instance.delete(widget.transaction.id!);
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: Text('Transazione eliminata correttamente'),
                      content: Icon(Icons.check_circle, color: Colors.green, size: 48.0),

                    );
                  },
                );

                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        HomePage(index: 1),
                  ),
                );
              },
            ),
          ],
        );
      },
    );
  }

  /////////

  void launchForm() async{

    ThemeData _theme = Theme.of(context);
    Size _size = MediaQuery.of(context).size;

    bool descBool = _formKeyDescription.currentState!.validate();
    bool cateBool = _formKeyPerson.currentState!.validate();
    bool persBool = _formKeyCategory.currentState!.validate();
    bool amountBool = _formKeyAmount.currentState!.validate();
    bool dateBool = selectedDate!= widget.transaction.date;
    bool accountBool = newAccount.name != widget.transaction.account;
    bool typeBool =
        (widget.transaction.transactionType == TransactionType.expense && !_isExpense)||
        (widget.transaction.transactionType == TransactionType.income && _isExpense);


    if(descBool || cateBool || persBool  || amountBool || dateBool || accountBool || typeBool){
      double amount = double.parse(amountController.text);

      Transaction newTransaction = Transaction(
          id: widget.transaction.id,
          account: newAccount.name,
          transactionType: _isExpense?TransactionType.expense: TransactionType.income,
          date: selectedDate,
          category: categoryController.text,
          person: personController.text,
          amount: amount ,
          description: descriptionController.text);

      TransactionHelper.instance.update(newTransaction);

      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            backgroundColor: _theme.primaryColor,
            shadowColor: Colors.transparent,
            title: Text('Transazione modificata correttamente'),
            content: Icon(Icons.check_circle, color: Colors.green, size: 48.0),

          );
        },
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) =>
              TransactionPage(newTransaction,),
        ),
      );

    }



  }


}


