import 'package:flutter_finance_app/model/transaction.dart';

class TransactionSummary {
  final double totalExpense;
  final double totalIncome;
  final double balance;
  final List<Transaction>? transactionList;

  TransactionSummary({
    required this.totalExpense,
    required this.totalIncome,
    required this.balance,
    this.transactionList,
  });

  factory TransactionSummary.none() {
    return TransactionSummary(
      totalExpense: 0.0,
      totalIncome: 0.0,
      balance: 0.0,
      transactionList: []
    );
  }

  bool isEmpty() {
    return totalExpense == 0.0 && totalIncome == 0.0 && balance == 0.0 && (transactionList == null || transactionList!.isEmpty);
  }

  @override
  String toString() {
    return 'TransactionSummary{totalExpense: $totalExpense, totalIncome: $totalIncome, balance: $balance, transactionList: $transactionList}';
  }
}

enum TransactionType {
  expense,
  income,
}

enum Month {
  Gennaio,
  Febbraio,
  Marzo,
  Aprile,
  Maggio,
  Giugno,
  Luglio,
  Agosto,
  Settembre,
  Ottobre,
  Novembre,
  Dicembre
}