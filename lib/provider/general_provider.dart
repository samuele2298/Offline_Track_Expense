import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import '../model/account.dart';
import '../model/summary_enums.dart';
import '../model/transaction.dart';
import '../storage_provider/account_helper.dart';
import '../storage_provider/transaction_helper.dart';
import 'package:share_plus/share_plus.dart';
import 'package:archive/archive.dart';
import 'package:archive/archive_io.dart';

class GeneralProvider extends ChangeNotifier {

  List<Transaction> transactionList = [];
  List<Account>  accountList =[];

  Account actualAccount = Account.none;
  List<Transaction> transactionXAccount= [];


  //GETTER AND SETTER
  static Future<List<Transaction>> get getDBTransactionList {
    return TransactionHelper.instance.get();
  }
  static Future<List<Account>> get getDBAccountList {
    return AccountHelper.instance.get();
  }

  List<Transaction> get getTransactionList {
    return transactionList;
  }
  void setTransactionList(List<Transaction> transactions) async {
    transactionList = transactions;
    notifyListeners();
  }

  List<Account> get getAccountList {
    return accountList;
  }
  void setAccountList(List<Account> accounts) async {
    accountList = accounts;
    notifyListeners();
  }

  Account get getActualAccount => actualAccount;
  void setActualAccount(Account account) {
    actualAccount = account;
    notifyListeners();
  }

  List<Transaction> get getTransactionXAccount => transactionXAccount;
  void setTransactionXAccount(List<Transaction> transactions) {
    transactionXAccount = transactions;
    notifyListeners();
  }


  void init() async{
    // clearAccounts();
    // clearTransactions();
    //
    // initializeTransactions();
    // initializeAccounts();

    notifyListeners();
  }

  //Dato un account ti da la lista delle transazioni
  List<Transaction> transactionsForAccount(List<Transaction>transazioni, Account account){
    List<Transaction> result=[];
    for(Transaction t in transazioni){
      if(t.account == account.name)
        result.add(t);
    }
    return result;
  }


  //DB
  void modifyTransaction(Transaction transaction ) async {
    if(transaction.id==null)
      await TransactionHelper.instance.update(transaction);
    notifyListeners();
  }


  //Esporto JSON
  Future<void> exportDatabase() async {
    // Get the instance of your database
    final TransactionHelper dbT = await TransactionHelper.instance;
    final AccountHelper dbA = await AccountHelper.instance;

    // Read all rows of each table
    List<Transaction> transactions = await dbT.get();
    List<Account> accounts = await dbA.get();

    // Convert each transaction and account into a map using the toJson method
    List<Map<String, dynamic>> transactionsMap = transactions.map((transaction) => transaction.toMap()).toList();
    List<Map<String, dynamic>> accountsMap = accounts.map((account) => account.toMap()).toList();

    // Convert the list of maps into a JSON string
    String transactionsJsonString = jsonEncode(transactionsMap);
    String accountsJsonString = jsonEncode(accountsMap);

    // Get the path of the documents directory
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = documentsDirectory.path;

    // Write the JSON string into a file in the documents directory
    File transactionsFile = File('$path/transactions.json');
    File accountsFile = File('$path/accounts.json');
    await transactionsFile.writeAsString(transactionsJsonString);
    await accountsFile.writeAsString(accountsJsonString);

    // Create an Archive object
    Archive archive = Archive();

    // Add the files to the Archive object
    List<int> transactionsBytes = transactionsFile.readAsBytesSync();
    List<int> accountsBytes = accountsFile.readAsBytesSync();
    archive.addFile(ArchiveFile('transactions.json', transactionsBytes.length, transactionsBytes));
    archive.addFile(ArchiveFile('accounts.json', accountsBytes.length, accountsBytes));

    // Encode the Archive object into a zip file
    List<int>? zipBytes = ZipEncoder().encode(archive);
    if (zipBytes != null) {
      File zipFile = File('$path/database.zip');
      await zipFile.writeAsBytes(zipBytes);
    } else {
      print('Failed to create zip file');
    }

    // Share the zip file
    await Share.shareFiles(['$path/database.zip'], text: 'Ecco il tuo zip di bakcup, conservalo!');
  }

  //////////////////////////////////////////////////////////////////////////////

  //Mock
  //Accounts
  void initializeAccounts() async{
    Account a = Account(
        id: 0,
        name: 'N26',
        balance: 3294.8
    );
    Account b = Account(
        id: 1,
        name: 'Cassa',
        balance: 246.8
    );
    Account c = Account(
        id: 2,
        name: 'Banca',
        balance: 1545.8
    );

    AccountHelper.instance.add(a);
    AccountHelper.instance.add(b);
    AccountHelper.instance.add(c);
    notifyListeners();
    //print(a.toString());
    //print('Ho inizializzato gli accounts');

  }
  void clearAccounts() async {
    await AccountHelper.instance.clearDatabase();
    notifyListeners();
    //print('Ho elimanato gli accounta');
  }

  //Transaction
  void initializeTransactions() async{
    Transaction a = Transaction(
      account: 'Cassa',
      transactionType: TransactionType.expense,
      date: DateTime(2023, 11, 14),
      category: 'Bolletta',
      person: 'Mamma',
      amount: 25.99,
      description: 'Transaction 1',
    );
    Transaction b = Transaction(
      account: 'Cassa',
      transactionType: TransactionType.income,
      date: DateTime(2023, 11, 12),
      category: 'entertainment',
      person: 'Giulia',
      amount: 75.99,
      description: 'Transaction 2',
    );
    Transaction c = Transaction(
      account: 'Banca',
      transactionType: TransactionType.expense,
      date: DateTime(2023, 11, 11),
      category: 'Svago',
      person: 'Stefano',
      amount: 124.99,
      description: 'Transaction 3',
    );
    Transaction d = Transaction(
      account: 'N26',
      transactionType: TransactionType.income,
      date: DateTime(2023, 11, 126),
      category: 'Stipendio',
      person: 'Mamma',
      amount: 25.99,
      description: 'Transaction 4',
    );
    Transaction e = Transaction(
      account: 'Banca',
      transactionType: TransactionType.expense,
      date: DateTime(2023, 11, 12),
      category: 'entertainment',
      person: 'Giulia',
      amount: 45.99,
      description: 'Risparmio',
    );

    TransactionHelper.instance.add(a);
    TransactionHelper.instance.add(b);
    TransactionHelper.instance.add(c);
    TransactionHelper.instance.add(d);
    TransactionHelper.instance.add(e);


    //print('Ho inizializzato le transazioni');

  }
  void clearTransactions() async {
    await TransactionHelper.instance.clear();
    //print('Ho elimanato le transazioni');
  }




}


