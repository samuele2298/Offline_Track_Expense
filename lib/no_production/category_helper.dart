import 'dart:io';
import 'package:flutter/foundation.dart' hide Category;
import 'package:sqflite/sqflite.dart' hide Transaction;
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart' ;

import 'category.dart';

class CategoryHelper {
  CategoryHelper._privateConstructor();
  static final CategoryHelper instance = CategoryHelper._privateConstructor();

  static Database? _database;
  Future<Database> get database async => _database ??= await _initDatabase();

  Future<Database> _initDatabase() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, 'categories.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE categories(
          id INTEGER PRIMARY KEY,
          name TEXT
      )
      ''');
  }

  Future<int> add(Category c) async {
    Database dbClient = await database;
    return await dbClient.insert('categories', c.toMap());
  }

  Future<List<Category>> get() async {
    Database dbClient = await database;
    List<Map<String, dynamic>> maps = await dbClient.query('categories');
    return List.generate(
      maps.length,
          (index) => Category.fromMap(maps[index]),
    );
  }

  Future<int> update(Category c) async {
    Database dbClient = await database;
    return await dbClient.update(
      'categories',
      c.toMap(),
      where: 'id = ?',
      whereArgs: [c.id],
    );
  }

  Future<int> delete(int id) async {
    Database dbClient = await database;
    return await dbClient.delete(
      'categories',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> clearDatabase() async {
    Database dbClient = await CategoryHelper.instance.database;
    await dbClient.delete('categories');
  }
}

