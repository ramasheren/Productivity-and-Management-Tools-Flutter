import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart' show debugPrint;
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

  Future<void> initDB() async {
    if (_isInitialized) {
      return;
    }

    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    _firestore = FirebaseFirestore.instance;
    _isInitialized = true;
  }

  Future<FirebaseFirestore> _getFirestore() async {
    if (!_isInitialized) {
      await initDB();
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
    return firestore.collection('task');
  }

  CollectionReference<Map<String, dynamic>> _noteCollection(
    FirebaseFirestore firestore,
  ) {
    return firestore.collection('note');
  }

  Future<void> _syncTaskToFirebase(Task task) async {
    try {
      final firestore = await _getFirestore();
      await _taskCollection(
        firestore,
      ).doc(task.id.toString()).set(task.toMap());
    } catch (error) {
      debugPrint('Failed to sync task to Firebase: $error');
    }
  }

  Future<void> _syncNoteToFirebase(Note note) async {
    try {
      final firestore = await _getFirestore();
      await _noteCollection(
        firestore,
      ).doc(note.id.toString()).set(note.toMap());
    } catch (error) {
      debugPrint('Failed to sync note to Firebase: $error');
    }
  }

  Future<void> _deleteTaskFromFirebase(int id) async {
    try {
      final firestore = await _getFirestore();
      await _taskCollection(firestore).doc(id.toString()).delete();
    } catch (error) {
      debugPrint('Failed to delete task from Firebase: $error');
    }
  }

  Future<void> _deleteNoteFromFirebase(int id) async {
    try {
      final firestore = await _getFirestore();
      await _noteCollection(firestore).doc(id.toString()).delete();
    } catch (error) {
      debugPrint('Failed to delete note from Firebase: $error');
    }
  }

  Future<int> insertTask(Task task) async {
    final int id = task.id ?? _generateId();
    final newTask = task.copyWith(id: id);
    try {
      await _syncTaskToFirebase(newTask);
      return id;
    } catch (error) {
      debugPrint('Failed to insert task: $error');
      return 0;
    }
  }

  Future<List<Task>> retrieveTasks() async {
    try {
      final firestore = await _getFirestore();

      final snapshot = await _taskCollection(
        firestore,
      ).orderBy('createdAt', descending: true).get();
      return snapshot.docs.map((doc) => Task.fromMap(doc.data())).toList();
    } catch (error) {
      debugPrint('Failed to retrieve tasks: $error');
      return [];
    }
  }

  Future<int> updateTask(Task task) async {
    try {
      if (task.id == null) {
        return 0;
      }

      await _syncTaskToFirebase(task);
      return 1;
    } catch (error) {
      debugPrint('Failed to update task: $error');
      return 0;
    }
  }

  Future<int> deleteTask(int id) async {
    try {
      await _deleteTaskFromFirebase(id);
      return 1;
    } catch (error) {
      debugPrint('Failed to delete task: $error');
      return 0;
    }
  }

  Future<int> deleteAllTasks() async {
    try {
      final firestore = await _getFirestore();
      final snapshot = await _taskCollection(firestore).get();
      final batch = firestore.batch();

      for (final doc in snapshot.docs) {
        batch.delete(doc.reference);
      }

      await batch.commit();
      return snapshot.docs.length;
    } catch (error) {
      debugPrint('Failed to delete all tasks: $error');
      return 0;
    }
  }

  Future<int> insertNote(Note note) async {
    final int id = note.id ?? _generateId();
    final newNote = note.copyWith(id: id);
    try {
      await _syncNoteToFirebase(newNote);
      return id;
    } catch (error) {
      debugPrint('Failed to insert note: $error');
      return 0;
    }
  }

  Future<List<Note>> retrieveNotes() async {
    try {
      final firestore = await _getFirestore();

      final snapshot = await _noteCollection(
        firestore,
      ).orderBy('createdAt', descending: true).get();
      return snapshot.docs.map((doc) => Note.fromMap(doc.data())).toList();
    } catch (error) {
      debugPrint('Failed to retrieve notes: $error');
      return [];
    }
  }

  Future<int> updateNote(Note note) async {
    try {
      if (note.id == null) {
        return 0;
      }

      await _syncNoteToFirebase(note);
      return 1;
    } catch (error) {
      debugPrint('Failed to update note: $error');
      return 0;
    }
  }

  Future<int> deleteNote(int id) async {
    try {
      await _deleteNoteFromFirebase(id);
      return 1;
    } catch (error) {
      debugPrint('Failed to delete note: $error');
      return 0;
    }
  }

  Future<int> deleteAllNotes() async {
    try {
      final firestore = await _getFirestore();
      final snapshot = await _noteCollection(firestore).get();
      final batch = firestore.batch();

      for (final doc in snapshot.docs) {
        batch.delete(doc.reference);
      }

      await batch.commit();
      return snapshot.docs.length;
    } catch (error) {
      debugPrint('Failed to delete all notes: $error');
      return 0;
    }
  }
}
