import 'dart:io';
import 'package:flutter_finance_app/no_production/person.dart';
import 'package:sqflite/sqflite.dart' hide Transaction;
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart' ;


class PersonHelper {
  PersonHelper._privateConstructor();
  static final PersonHelper instance = PersonHelper._privateConstructor();

  static Database? _database;
  Future<Database> get database async => _database ??= await _initDatabase();

  Future<Database> _initDatabase() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, 'people.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE people(
          id INTEGER PRIMARY KEY,
          name TEXT,
          balance INTEGER
      )
      ''');
  }

  Future<int> add(Person p) async {
    Database dbClient = await database;
    return await dbClient.insert('people', p.toMap());
  }

  Future<List<Person>> get() async {
    Database dbClient = await database;
    List<Map<String, dynamic>> maps = await dbClient.query('people');
    return List.generate(
      maps.length,
          (index) => Person.fromMap(maps[index]),
    );
  }

  Future<int> update(Person p) async {
    Database dbClient = await database;
    return await dbClient.update(
      'people',
      p.toMap(),
      where: 'id = ?',
      whereArgs: [p.id],
    );
  }

  Future<int> delete(int id) async {
    Database dbClient = await database;
    return await dbClient.delete(
      'people',
      where: 'id = ?',
      whereArgs: [id],
    );
  }


  Future<void> clearDatabase() async {
    Database dbClient = await PersonHelper.instance.database;
    await dbClient.delete('people');
  }
}

