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

  final List<Map<String, dynamic>> _webTaskStore = [];
  final List<Map<String, dynamic>> _webNoteStore = [];
  int _webTaskAutoIncrement = 1;
  int _webNoteAutoIncrement = 1;

  Future<void> initDB() async {
    if (db != null || kIsWeb) {
      if (kIsWeb) {
        debugPrint("Database is disabled on Web");
      }
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

  Future<Database> _getDatabase() async {
    if (kIsWeb) {
      throw UnsupportedError('Local database is not available on Web.');
    }

    if (db == null) {
      await initDB();
    }

    final database = db;
    if (database == null) {
      throw StateError('Database failed to initialize.');
    }

    return database;
  }

  Future<int> insertTask(Task task) async {
    if (kIsWeb) {
      final taskMap = task.toMap();
      final int id = _webTaskAutoIncrement++;
      taskMap['id'] = id;
      _webTaskStore.add(taskMap);
      return Future.value(id);
    }

    final database = await _getDatabase();
    return database.insert('tasks', task.toMap());
  }

  Future<List<Task>> retrieveTasks() async {
    if (kIsWeb) {
      final maps = List<Map<String, dynamic>>.from(_webTaskStore);
      maps.sort((a, b) => (b['createdAt'] as String)
          .compareTo(a['createdAt'] as String));
      return List.generate(maps.length, (i) => Task.fromMap(maps[i]));
    }

    final database = await _getDatabase();
    final maps = await database.query('tasks', orderBy: 'createdAt DESC');
    return List.generate(maps.length, (i) => Task.fromMap(maps[i]));
  }

  Future<int> updateTask(Task task) async {
    if (kIsWeb) {
      final index = _webTaskStore.indexWhere((map) => map['id'] == task.id);
      if (index == -1) {
        return Future.value(0);
      }
      _webTaskStore[index] = task.toMap();
      return Future.value(1);
    }

    final database = await _getDatabase();
    return database.update(
      'tasks',
      task.toMap(),
      where: 'id = ?',
      whereArgs: [task.id],
    );
  }

  Future<int> deleteTask(int id) async {
    if (kIsWeb) {
      final int initialLength = _webTaskStore.length;
      _webTaskStore.removeWhere((map) => map['id'] == id);
      return Future.value(_webTaskStore.length < initialLength ? 1 : 0);
    }

    final database = await _getDatabase();
    return database.delete(
      'tasks',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> deleteAllTasks() async {
    if (kIsWeb) {
      final count = _webTaskStore.length;
      _webTaskStore.clear();
      return Future.value(count);
    }

    final database = await _getDatabase();
    return database.delete('tasks');
  }

  Future<int> insertNote(Note note) async {
    if (kIsWeb) {
      final noteMap = note.toMap();
      final int id = _webNoteAutoIncrement++;
      noteMap['id'] = id;
      _webNoteStore.add(noteMap);
      return Future.value(id);
    }

    final database = await _getDatabase();
    return database.insert('notes', note.toMap());
  }

  Future<List<Note>> retrieveNotes() async {
    if (kIsWeb) {
      final maps = List<Map<String, dynamic>>.from(_webNoteStore);
      maps.sort((a, b) => (b['createdAt'] as String)
          .compareTo(a['createdAt'] as String));
      return List.generate(maps.length, (i) => Note.fromMap(maps[i]));
    }

    final database = await _getDatabase();
    final maps = await database.query('notes', orderBy: 'createdAt DESC');
    return List.generate(maps.length, (i) => Note.fromMap(maps[i]));
  }

  Future<int> updateNote(Note note) async {
    if (kIsWeb) {
      final index = _webNoteStore.indexWhere((map) => map['id'] == note.id);
      if (index == -1) {
        return Future.value(0);
      }
      _webNoteStore[index] = note.toMap();
      return Future.value(1);
    }

    final database = await _getDatabase();
    return database.update(
      'notes',
      note.toMap(),
      where: 'id = ?',
      whereArgs: [note.id],
    );
  }

  Future<int> deleteNote(int id) async {
    if (kIsWeb) {
      final int initialLength = _webNoteStore.length;
      _webNoteStore.removeWhere((map) => map['id'] == id);
      return Future.value(_webNoteStore.length < initialLength ? 1 : 0);
    }

    final database = await _getDatabase();
    return database.delete(
      'notes',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> deleteAllNotes() async {
    if (kIsWeb) {
      final count = _webNoteStore.length;
      _webNoteStore.clear();
      return Future.value(count);
    }

    final database = await _getDatabase();
    return database.delete('notes');
  }
}
