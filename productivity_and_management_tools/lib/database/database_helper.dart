import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import '../firebase_options.dart';
import '../models/task.dart';
import '../models/note.dart';

class DatabaseHelper {
  static final DatabaseHelper _databaseHelper = DatabaseHelper._();

  DatabaseHelper._();

  factory DatabaseHelper() {
    return _databaseHelper;
  }

  FirebaseFirestore? _firestore;
  bool _isInitialized = false;
  bool _useFallbackStore = false;

  final List<Map<String, dynamic>> _webTaskStore = [];
  final List<Map<String, dynamic>> _webNoteStore = [];

  Future<void> initDB() async {
    if (_isInitialized) {
      return;
    }

    try {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
      _firestore = FirebaseFirestore.instance;
      _useFallbackStore = false;
    } catch (error) {
      _useFallbackStore = true;
      debugPrint(
        'Firebase initialization failed. Falling back to in-memory storage. '
        'Run "flutterfire configure" and add your platform Firebase config files. '
        'Error: $error',
      );
    } finally {
      _isInitialized = true;
    }
  }

  Future<FirebaseFirestore?> _getFirestore() async {
    if (!_isInitialized) {
      await initDB();
    }

    if (_useFallbackStore) {
      return null;
    }

    final firestore = _firestore;
    if (firestore == null) {
      throw StateError('Firebase failed to initialize.');
    }

    return firestore;
  }

  int _generateId() => DateTime.now().microsecondsSinceEpoch;

  CollectionReference<Map<String, dynamic>> _taskCollection(
    FirebaseFirestore firestore,
  ) {
    return firestore.collection('tasks');
  }

  CollectionReference<Map<String, dynamic>> _noteCollection(
    FirebaseFirestore firestore,
  ) {
    return firestore.collection('notes');
  }

  Future<int> insertTask(Task task) async {
    final firestore = await _getFirestore();
    final int id = task.id ?? _generateId();
    final taskMap = task.copyWith(id: id).toMap();

    if (firestore == null) {
      taskMap['id'] = id;
      _webTaskStore.add(taskMap);
      return id;
    }

    await _taskCollection(firestore).doc(id.toString()).set(taskMap);
    return id;
  }

  Future<List<Task>> retrieveTasks() async {
    final firestore = await _getFirestore();

    if (firestore == null) {
      final maps = List<Map<String, dynamic>>.from(_webTaskStore);
      maps.sort(
        (a, b) =>
            (b['createdAt'] as String).compareTo(a['createdAt'] as String),
      );
      return List.generate(maps.length, (i) => Task.fromMap(maps[i]));
    }

    final snapshot = await _taskCollection(
      firestore,
    ).orderBy('createdAt', descending: true).get();
    return snapshot.docs.map((doc) => Task.fromMap(doc.data())).toList();
  }

  Future<int> updateTask(Task task) async {
    final firestore = await _getFirestore();

    if (firestore == null) {
      final index = _webTaskStore.indexWhere((map) => map['id'] == task.id);
      if (index == -1) {
        return 0;
      }
      _webTaskStore[index] = task.toMap();
      return 1;
    }

    if (task.id == null) {
      return 0;
    }

    await _taskCollection(
      firestore,
    ).doc(task.id.toString()).update(task.toMap());
    return 1;
  }

  Future<int> deleteTask(int id) async {
    final firestore = await _getFirestore();

    if (firestore == null) {
      final int initialLength = _webTaskStore.length;
      _webTaskStore.removeWhere((map) => map['id'] == id);
      return _webTaskStore.length < initialLength ? 1 : 0;
    }

    await _taskCollection(firestore).doc(id.toString()).delete();
    return 1;
  }

  Future<int> deleteAllTasks() async {
    final firestore = await _getFirestore();

    if (firestore == null) {
      final count = _webTaskStore.length;
      _webTaskStore.clear();
      return count;
    }

    final snapshot = await _taskCollection(firestore).get();
    final batch = firestore.batch();

    for (final doc in snapshot.docs) {
      batch.delete(doc.reference);
    }

    await batch.commit();
    return snapshot.docs.length;
  }

  Future<int> insertNote(Note note) async {
    final firestore = await _getFirestore();
    final int id = note.id ?? _generateId();
    final noteMap = note.copyWith(id: id).toMap();

    if (firestore == null) {
      noteMap['id'] = id;
      _webNoteStore.add(noteMap);
      return id;
    }

    await _noteCollection(firestore).doc(id.toString()).set(noteMap);
    return id;
  }

  Future<List<Note>> retrieveNotes() async {
    final firestore = await _getFirestore();

    if (firestore == null) {
      final maps = List<Map<String, dynamic>>.from(_webNoteStore);
      maps.sort(
        (a, b) =>
            (b['createdAt'] as String).compareTo(a['createdAt'] as String),
      );
      return List.generate(maps.length, (i) => Note.fromMap(maps[i]));
    }

    final snapshot = await _noteCollection(
      firestore,
    ).orderBy('createdAt', descending: true).get();
    return snapshot.docs.map((doc) => Note.fromMap(doc.data())).toList();
  }

  Future<int> updateNote(Note note) async {
    final firestore = await _getFirestore();

    if (firestore == null) {
      final index = _webNoteStore.indexWhere((map) => map['id'] == note.id);
      if (index == -1) {
        return 0;
      }
      _webNoteStore[index] = note.toMap();
      return 1;
    }

    if (note.id == null) {
      return 0;
    }

    await _noteCollection(
      firestore,
    ).doc(note.id.toString()).update(note.toMap());
    return 1;
  }

  Future<int> deleteNote(int id) async {
    final firestore = await _getFirestore();

    if (firestore == null) {
      final int initialLength = _webNoteStore.length;
      _webNoteStore.removeWhere((map) => map['id'] == id);
      return _webNoteStore.length < initialLength ? 1 : 0;
    }

    await _noteCollection(firestore).doc(id.toString()).delete();
    return 1;
  }

  Future<int> deleteAllNotes() async {
    final firestore = await _getFirestore();

    if (firestore == null) {
      final count = _webNoteStore.length;
      _webNoteStore.clear();
      return count;
    }

    final snapshot = await _noteCollection(firestore).get();
    final batch = firestore.batch();

    for (final doc in snapshot.docs) {
      batch.delete(doc.reference);
    }

    await batch.commit();
    return snapshot.docs.length;
  }
}
