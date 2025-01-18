import 'dart:io';

import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

class DbHelper {
  static final String table_name = "todo_data";
  static final String id = "id";
  static final String title = "title";
  static final String desc = "desc";
  static final String status = "status";

  DbHelper._();

  static final DbHelper getInstance = DbHelper._();

  Database? myDB;

  Future<Database> getDb() async {
    myDB ??= await openDb();
    return myDB!;
  }

  Future<Database> openDb() async {
    // Get the application directory
    Directory appDir = await getApplicationDocumentsDirectory();

    // Construct the database path
    String dbPath = join(appDir.path, "todo.db");

    // Open and create the database if it doesn't exist
    return await openDatabase(
      dbPath,
      version: 1,
      onCreate: (db, version) async {
        // Create table
        await db.execute('''
        CREATE TABLE $table_name (
          $id INTEGER PRIMARY KEY AUTOINCREMENT,
          $title TEXT,
          $desc TEXT,
          $status INTEGER
        )
      ''');
      },
    );
  }

  /// all queries

  /// insert database.
  Future<bool> addTodo({
    required String mtitle,
    required String mdesc,
    required int mstatus,
  }) async {
    // Get the database instance.
    var db = await getDb();

    // Insert a new  record
    int rowEffected = await db.insert(
      table_name,
      {
        title: mtitle,
        desc: mdesc,
        status: mstatus,
      },
    );
    return rowEffected > 0;
  }

  ///read
  Future<List<Map<String, dynamic>>> getAlltodo() async {
    var db = await getDb();
    List<Map<String, dynamic>> mData = await db.query(table_name);
    return mData;
  }

  ///update
  /// Update a todo item.
  Future<bool> updateTodo({
    required int id,
    required String mtitle,
    required String mdesc,
    required int mstatus,
  }) async {
    var db = await getDb();

    // Update the record with the given id
    int rowsUpdated = await db.update(
      table_name,
      {
        title: mtitle,
        desc: mdesc,
        status: mstatus,
      },
      where: 'id = ?', // Use the 'id' as a filter
      whereArgs: [id], // Pass the id dynamically
    );

    return rowsUpdated > 0;
  }

  ///delete
  /// Delete a todo item.
  Future<bool> deleteTodo({
    required int id,
  }) async {
    var db = await getDb();

    // Delete the record with the given id
    int rowsDeleted = await db.delete(
      table_name,
      where: 'id = ?', // Use the 'id' as a filter
      whereArgs: [id], // Pass the id dynamically
    );

    return rowsDeleted > 0;
  }

  /// Get completed tasks.
  Future<List<Map<String, dynamic>>> getCompletedTasks() async {
    var db = await getDb();
    List<Map<String, dynamic>> completedTasks = await db.query(
      table_name,
      where: 'status = ?',
      whereArgs: [1], // 1 represents completed tasks
    );
    return completedTasks;
  }

  /// Get incomplete tasks.
  Future<List<Map<String, dynamic>>> getIncompleteTasks() async {
    var db = await getDb();
    List<Map<String, dynamic>> incompleteTasks = await db.query(
      table_name,
      where: 'status = ?',
      whereArgs: [0], // 0 represents incomplete tasks
    );
    return incompleteTasks;
  }
}
