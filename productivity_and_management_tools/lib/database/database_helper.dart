import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart';
import '../models/task.dart';
import '../models/note.dart';

class DatabaseHelper {
  static final DatabaseHelper _databaseHelper = DatabaseHelper._();

  DatabaseHelper._();

  factory DatabaseHelper() {
    return _databaseHelper;
  }

  Database? db;

  Future<void> initDB() async {
    if (kIsWeb) {
      debugPrint("Database is disabled on Web");
      return;
    }

    final directory = await getApplicationDocumentsDirectory();
    final path = join(directory.path, 'focusflow.db');

    db = await openDatabase(
      path,
      version: 1,
      onCreate: (Database database, int version) async {
        await database.execute('''
          CREATE TABLE tasks (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            title TEXT NOT NULL,
            description TEXT,
            priority TEXT NOT NULL,
            isCompleted INTEGER NOT NULL DEFAULT 0,
            dueDate TEXT,
            createdAt TEXT NOT NULL
          )
        ''');

        await database.execute('''
          CREATE TABLE notes (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            title TEXT NOT NULL,
            body TEXT NOT NULL,
            createdAt TEXT NOT NULL
          )
        ''');
      },
    );
  }

  Future<int> insertTask(Task task) async {
    if (db == null) return 0;
    return await db!.insert('tasks', task.toMap());
  }

  Future<List<Task>> retrieveTasks() async {
    if (db == null) return [];
    final maps = await db!.query('tasks', orderBy: 'createdAt DESC');
    return List.generate(maps.length, (i) => Task.fromMap(maps[i]));
  }

  Future<int> updateTask(Task task) async {
    if (db == null) return 0;
    return await db!.update(
      'tasks',
      task.toMap(),
      where: 'id = ?',
      whereArgs: [task.id],
    );
  }

  Future<int> deleteTask(int id) async {
    if (db == null) return 0;
    return await db!.delete(
      'tasks',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> deleteAllTasks() async {
    if (db == null) return 0;
    return await db!.delete('tasks');
  }

  Future<int> insertNote(Note note) async {
    if (db == null) return 0;
    return await db!.insert('notes', note.toMap());
  }

  Future<List<Note>> retrieveNotes() async {
    if (db == null) return [];
    final maps = await db!.query('notes', orderBy: 'createdAt DESC');
    return List.generate(maps.length, (i) => Note.fromMap(maps[i]));
  }

  Future<int> updateNote(Note note) async {
    if (db == null) return 0;
    return await db!.update(
      'notes',
      note.toMap(),
      where: 'id = ?',
      whereArgs: [note.id],
    );
  }

  Future<int> deleteNote(int id) async {
    if (db == null) return 0;
    return await db!.delete(
      'notes',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> deleteAllNotes() async {
    if (db == null) return 0;
    return await db!.delete('notes');
  }
}