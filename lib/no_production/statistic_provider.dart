import 'package:flutter/material.dart';
import 'package:flutter_finance_app/no_production/person.dart';
import 'package:flutter_finance_app/no_production/person_helper.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../model/account.dart';
import '../model/summary_enums.dart';
import 'category.dart';
import '../model/transaction.dart';
import '../storage_provider/account_helper.dart';
import 'category_helper.dart';
import '../storage_provider/transaction_helper.dart';


//title: Text('My favorite fruit is ' + Provider.of<Favorites>(context).fruit),
// onPressed: () {Provider.of<Favorites>(context, listen: false).changeFruit(fruit);},

class StatisticProvider extends ChangeNotifier {

  //Dark mode
  bool isDark = false;
  void updateDarkMode() async {
    isDark = await getDarkModeValue();
    this.isDark=isDark;
    notifyListeners();
  }
  Future<bool> getDarkModeValue() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    return prefs.getBool('darkMode') ?? false;

  }

  //Month
  Month actual_month = Month.Giugno;
  Future<void> saveMonth(int value) async {
    final prefs = await SharedPreferences.getInstance();
    final key = 'month';
    //print('salvo: $value');
    // Save the integer value to shared preferences
    await prefs.setInt(key, value);
    notifyListeners();
  }
  Future<void> updateMonth() async {
    final prefs = await SharedPreferences.getInstance();
    final key = 'month';
    //print('vedo: ${prefs.getInt(key) ?? 0}');

    // Retrieve the integer value from shared preferences
    actual_month=  parseIntMonth(prefs.getInt(key) ?? 0);
    //print('vedo dopo: $actual_month');
    notifyListeners();
  }
  Month parseIntMonth(int value) {
    for (Month month in Month.values) {
      if (month.index == value) {
        return month;
      }
    }
    throw ArgumentError('Invalid month value: $value');

  }


  //Selected_Account
  Account selectedAccount = Account.none;
  String actualAccount = '';
  List<Account> accountSelection = [];
  List<Account> accountList = [];
  List<Category> categoryList= [];

  void updateActualAccount() async {
    String? accountValue = await getActualAccount();
    //print(accountValue);
    actualAccount = accountValue != null ?
    accountValue :

    throw Exception('Account selezionato è nullo');
    notifyListeners();

  }
  Future<String?> getActualAccount() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('selectedAccount');
  }

  Future<void> saveSelectedAccounts() async {
    final prefs = await SharedPreferences.getInstance();
    final key = 'intListKey';
    List<int> list=[];

    for (Account a in accountSelection){
      list.add(a.id!);
    }

    // Convert the list of integers to a string representation
    final stringList = list.map((e) => e.toString()).toList();

    // Save the string list to shared preferences
    await prefs.setStringList(key, stringList);
    notifyListeners();
  }
  Future<void> getSelectedAccounts() async {
    final prefs = await SharedPreferences.getInstance();
    final key = 'intListKey';

    // Retrieve the string list from shared preferences
    final stringList = prefs.getStringList(key);

    // Parse the string list back to a list of integers
    final intList = stringList?.map((e) => int.parse(e))?.toList() ?? [];

    for (int a in intList){
      for (Account ac in accountList){
        if (ac.id==a) accountSelection.add(ac);
      }
    }
    notifyListeners();
  }



  String fruit = 'unknown';
  void changeFruit(String newFruit) {
    fruit = newFruit;
    notifyListeners();
  }

  //People
  void initializePeople() async {
    Person a = Person(
        id: 0,
        name: 'Mamma',
        balance: 25.99
    );
    Person b = Person(
        id: 1,
        name: 'Giulia',
        balance: -146.99
    );
    Person c = Person(
        id: 2,
        name: 'Stefano',
        balance: -34.5
    );


    PersonHelper.instance.add(a);
    PersonHelper.instance.add(b);
    PersonHelper.instance.add(c);

    //print('Ho inizializzato le persone');

  }
  void refreshPeople() async {
    List<Person> p = await PersonHelper.instance.get();
    notifyListeners();
    print('Ho refreshato le persone');
  }
  void clearPeople() async {
    await PersonHelper.instance.clearDatabase();
    //print('Ho elimanato le persone');
  }

  //Categories
  void initializeCategory() async{
    Category a = Category(
      id: 0,
      name: 'Bolletta',
    );
    Category b = Category(
      id: 1,
      name: 'Svago',
    );
    Category c = Category(
      id: 2,
      name: 'Mutuo',
    );
    Category d = Category(
      id: 3,
      name: 'Risparmio',
    );
    Category e= Category(
      id: 4,
      name: 'Stipendio',
    );



    CategoryHelper.instance.add(a);
    CategoryHelper.instance.add(b);
    CategoryHelper.instance.add(c);
    CategoryHelper.instance.add(d);
    CategoryHelper.instance.add(e);

    //print('Ho inizializzato le categorie');

  }
  void refreshCategory() async {
    List<Category> a = await CategoryHelper.instance.get();
    notifyListeners();
    print('Ho refreshato le categorie');
  }
  void clearCategory() async {
    await CategoryHelper.instance.clearDatabase();
    //print('Ho elimanato le categorie');
  }

  List<Transaction> transactionList = [];
  void refreshTransactionList() async {
    List<Transaction> t = await TransactionHelper.instance.get();
    this.transactionList = t;
    //print('Ho refreshato il db');
  }

}


