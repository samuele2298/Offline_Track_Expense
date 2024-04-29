import 'package:flutter_finance_app/model/transaction.dart';

class PersonProspect {
  String name;
  double balance;
  List<Transaction> transactionList;

  PersonProspect({
    required this.name,
    this.balance = 0.0,  // Provide a default value
    required this.transactionList,
  });
}

class CategoryProspect {
  String name;
  double balance;
  List<Transaction> transactionList;

  CategoryProspect({
    required this.name,
    this.balance = 0.0,  // Provide a default value
    required this.transactionList,
  });
}


