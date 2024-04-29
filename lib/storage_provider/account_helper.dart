import 'dart:io';
import 'package:sqflite/sqflite.dart' hide Transaction;
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart' ;
import '../model/account.dart';

class AccountHelper {
  AccountHelper._privateConstructor();
  static final AccountHelper instance = AccountHelper._privateConstructor();

  static Database? _database;
  Future<Database> get database async => _database ??= await _initDatabase();

  Future<Database> _initDatabase() async {

    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, 'accounts.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE accounts(
          id INTEGER PRIMARY KEY,
          name TEXT,
          balance NUMERIC
      )
      ''');
  }

  Future<int> add(Account a) async {
    Database dbClient = await database;
    return await dbClient.insert('accounts', a.toMap());
  }

  Future<List<Account>> get() async {
    Database dbClient = await database;
    List<Map<String, dynamic>> maps = await dbClient.query('accounts');
    return List.generate(
      maps.length,
          (index) => Account.fromMap(maps[index]),
    );
  }

  Future<int> update(Account a) async {
    Database dbClient = await database;
    return await dbClient.update(
      'accounts',
      a.toMap(),
      where: 'id = ?',
      whereArgs: [a.id],
    );
  }

  Future<int> delete(int id) async {
    Database dbClient = await database;
    return await dbClient.delete(
      'accounts',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
  Future<void> clearDatabase() async {
    Database dbClient = await AccountHelper.instance.database;
    await dbClient.delete('accounts');
  }
}

