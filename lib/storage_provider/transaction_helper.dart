import 'dart:io';
import 'package:sqflite/sqflite.dart' hide Transaction;
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart' ;
import '../model/account.dart';
import '../model/transaction.dart';

class TransactionHelper {
  TransactionHelper._privateConstructor();
  static final TransactionHelper instance = TransactionHelper._privateConstructor();

  static Database? _database;
  Future<Database> get database async => _database ??= await _initDatabase();

  Future<Database> _initDatabase() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, 'transactions.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE transactions(
          id INTEGER PRIMARY KEY,
          account TEXT,
          transactionType TEXT,
          date TEXT,
          category TEXT,
          person TEXT,
          amount REAL,
          description TEXT
      )
      ''');
  }

  Future<int> add(Transaction transaction) async {
    Database dbClient = await database;
    print('Transazione: ${transaction.description} aggiunta');
    return await dbClient.insert('transactions', transaction.toMap());
  }

  Future<List<Transaction>> get() async {
    Database dbClient = await database;
    List<Map<String, dynamic>> maps = await dbClient.query('transactions');
    return List.generate(
      maps.length,
          (index) => Transaction.fromMap(maps[index]),
    );
  }

  Future<int> update(Transaction transaction) async {
    Database dbClient = await database;
    return await dbClient.update(
      'transactions',
      transaction.toMap(),
      where: 'id = ?',
      whereArgs: [transaction.id],
    );
  }

  Future<int> delete(int id) async {
    Database dbClient = await database;
    return await dbClient.delete(
      'transactions',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> clear() async {
    Database dbClient = await TransactionHelper.instance.database;
    await dbClient.delete('transactions');
  }


}

