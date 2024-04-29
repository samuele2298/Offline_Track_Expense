
import 'package:flutter_finance_app/model/summary_enums.dart';

class Transaction {
  final int? id;
  final String account;
  final String description;
  final double amount;
  final TransactionType transactionType;
  final DateTime date;
  final String category;
  final String person;

  Transaction({
    this.id,
    required this.account,
    required this.transactionType,
    required this.date,
    required this.category,
    required this.person,
    required this.amount,
    required this.description,
  });

  factory Transaction.fromMap(Map<String, dynamic> json) => Transaction(
    id: json['id'],
    account: json['account'],
    transactionType: json['transactionType'] == 'expense'
        ? TransactionType.expense
        : TransactionType.income,
    date: DateTime.parse(json['date']),
    category: json['category'],
    description:  json['description'],
    person: json['person'],
    amount: json['amount'].toDouble(),
  );

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'account': account,
      'transactionType': transactionType == TransactionType.expense
          ? 'expense'
          : 'income',
      'date': date.toIso8601String(),
      'category': category,
      'person': person,
      'amount': amount,
      'description': description,
    };
  }


  @override
  String toString() {
    return '\nMyTransaction{id: $id, account: $account, description: $description, amount: $amount, transactionType: $transactionType, date: $date, category: $category, person: $person}';
  }
}

