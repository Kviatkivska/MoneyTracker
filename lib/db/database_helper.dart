import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import 'package:flutter_application_1/money_transaction.dart';

class DatabaseHelper {
  DatabaseHelper._();

  static final DatabaseHelper instance = DatabaseHelper._();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) {
      return _database!;
    }

    _database = await _initDatabase();

    return _database!;
  }

  Future<Database> _initDatabase() async {
    final databasePath = await getDatabasesPath();

    final path = join(
      databasePath,
      'money_flow.db',
    );

    return openDatabase(
      path,
      version: 1,
      onCreate: _createDatabase,
    );
  }

  Future<void> _createDatabase(
    Database db,
    int version,
  ) async {
    await db.execute('''
      CREATE TABLE transactions (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        type TEXT NOT NULL,
        amount REAL NOT NULL,
        category TEXT NOT NULL,
        date TEXT NOT NULL,
        note TEXT NOT NULL
      )
    ''');
  }

  Future<int> insertTransaction(
    MoneyTransaction transaction,
  ) async {
    final db = await database;

    return db.insert(
      'transactions',
      transaction.toMap(),
    );
  }

  Future<List<MoneyTransaction>> getTransactions() async {
    final db = await database;

    final maps = await db.query(
      'transactions',
      orderBy: 'date DESC',
    );

    return maps
        .map(
          (map) => MoneyTransaction.fromMap(map),
        )
        .toList();
  }

  Future<int> deleteTransaction(int id) async {
    final db = await database;

    return db.delete(
      'transactions',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}