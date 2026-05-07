import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart' show debugPrint, kIsWeb;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../firebase_options.dart';
import '../models/task.dart';
import '../models/note.dart';

class DatabaseHelper {
  static const String _tasksStorageKey = 'local_tasks';
  static const String _notesStorageKey = 'local_notes';
  static final DatabaseHelper _databaseHelper = DatabaseHelper._();

  DatabaseHelper._();

  factory DatabaseHelper() {
    return _databaseHelper;
  }

  FirebaseFirestore? _firestore;
  SharedPreferences? _preferences;
  bool _isInitialized = false;
  bool _firebaseAvailable = false;

  Future<void> initDB() async {
    if (_isInitialized) {
      return;
    }

    _preferences ??= await SharedPreferences.getInstance();

    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    _firestore = FirebaseFirestore.instance;
    await _tryEnableFirebaseAccess();
    _isInitialized = true;
  }

  Future<void> _tryEnableFirebaseAccess() async {
    try {
      final auth = FirebaseAuth.instance;
      if (auth.currentUser == null) {
        await auth.signInAnonymously();
      }
      _firebaseAvailable = true;
    } on FirebaseAuthException catch (error) {
      if (!_isExpectedOptionalAuthError(error.code)) {
        debugPrint(
          'Firebase anonymous auth unavailable: ${error.code} ${error.message}',
        );
      }
      _firebaseAvailable = false;
    } catch (error) {
      debugPrint('Firebase auth initialization failed: $error');
      _firebaseAvailable = false;
    }
  }

  bool _isExpectedOptionalAuthError(String code) {
    return code == 'configuration-not-found' || code == 'operation-not-allowed';
  }

  Future<SharedPreferences> _getPreferences() async {
    if (!_isInitialized) {
      await initDB();
    }

    _preferences ??= await SharedPreferences.getInstance();
    return _preferences!;
  }

  Future<List<Task>> _getLocalTasks() async {
    final preferences = await _getPreferences();
    final rawTasks = preferences.getStringList(_tasksStorageKey) ?? [];
    return rawTasks
        .map(
          (taskJson) =>
              Task.fromMap(jsonDecode(taskJson) as Map<String, dynamic>),
        )
        .toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  Future<void> _saveLocalTasks(List<Task> tasks) async {
    final preferences = await _getPreferences();
    final rawTasks = tasks.map((task) => jsonEncode(task.toMap())).toList();
    await preferences.setStringList(_tasksStorageKey, rawTasks);
  }

  Future<List<Note>> _getLocalNotes() async {
    final preferences = await _getPreferences();
    final rawNotes = preferences.getStringList(_notesStorageKey) ?? [];
    return rawNotes
        .map(
          (noteJson) =>
              Note.fromMap(jsonDecode(noteJson) as Map<String, dynamic>),
        )
        .toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  Future<void> _saveLocalNotes(List<Note> notes) async {
    final preferences = await _getPreferences();
    final rawNotes = notes.map((note) => jsonEncode(note.toMap())).toList();
    await preferences.setStringList(_notesStorageKey, rawNotes);
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
    return firestore.collection('tasks');
  }

  CollectionReference<Map<String, dynamic>> _noteCollection(
    FirebaseFirestore firestore,
  ) {
    return firestore.collection('notes');
  }

  Future<void> _syncTaskToFirebase(Task task) async {
    if (!_firebaseAvailable) return;
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
    if (!_firebaseAvailable) return;
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
    if (!_firebaseAvailable) return;
    try {
      final firestore = await _getFirestore();
      await _taskCollection(firestore).doc(id.toString()).delete();
    } catch (error) {
      debugPrint('Failed to delete task from Firebase: $error');
    }
  }

  Future<void> _deleteNoteFromFirebase(int id) async {
    if (!_firebaseAvailable) return;
    try {
      final firestore = await _getFirestore();
      await _noteCollection(firestore).doc(id.toString()).delete();
    } catch (error) {
      debugPrint('Failed to delete note from Firebase: $error');
    }
  }

  Future<void> _deleteAllTasksFromFirebase() async {
    if (!_firebaseAvailable) return;
    try {
      final firestore = await _getFirestore();
      final snapshot = await _taskCollection(firestore).get();
      final batch = firestore.batch();

      for (final doc in snapshot.docs) {
        batch.delete(doc.reference);
      }

      await batch.commit();
    } catch (error) {
      debugPrint('Failed to delete all tasks from Firebase: $error');
    }
  }

  Future<void> _deleteAllNotesFromFirebase() async {
    if (!_firebaseAvailable) return;
    try {
      final firestore = await _getFirestore();
      final snapshot = await _noteCollection(firestore).get();
      final batch = firestore.batch();

      for (final doc in snapshot.docs) {
        batch.delete(doc.reference);
      }

      await batch.commit();
    } catch (error) {
      debugPrint('Failed to delete all notes from Firebase: $error');
    }
  }

  Future<int> insertTask(Task task) async {
    if (kIsWeb) {
      final tasks = await _getLocalTasks();
      final int id = task.id ?? _generateId();
      final newTask = task.copyWith(id: id);
      tasks.removeWhere((existingTask) => existingTask.id == id);
      tasks.add(newTask);
      await _saveLocalTasks(tasks);
      // Async sync to Firebase without await
      _syncTaskToFirebase(newTask);
      return id;
    }

    try {
      final firestore = await _getFirestore();
      final int id = task.id ?? _generateId();
      final taskMap = task.copyWith(id: id).toMap();

      await _taskCollection(firestore).doc(id.toString()).set(taskMap);
      return id;
    } catch (error) {
      debugPrint('Failed to insert task: $error');
      return 0;
    }
  }

  Future<List<Task>> retrieveTasks() async {
    if (kIsWeb) {
      return _getLocalTasks();
    }

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
    if (kIsWeb) {
      if (task.id == null) {
        return 0;
      }

      final tasks = await _getLocalTasks();
      final index = tasks.indexWhere(
        (existingTask) => existingTask.id == task.id,
      );
      if (index == -1) {
        return 0;
      }

      tasks[index] = task;
      await _saveLocalTasks(tasks);
      // Async sync to Firebase without await
      _syncTaskToFirebase(task);
      return 1;
    }

    try {
      final firestore = await _getFirestore();

      if (task.id == null) {
        return 0;
      }

      await _taskCollection(
        firestore,
      ).doc(task.id.toString()).update(task.toMap());
      return 1;
    } catch (error) {
      debugPrint('Failed to update task: $error');
      return 0;
    }
  }

  Future<int> deleteTask(int id) async {
    if (kIsWeb) {
      final tasks = await _getLocalTasks();
      tasks.removeWhere((task) => task.id == id);
      await _saveLocalTasks(tasks);
      // Async delete from Firebase without await
      _deleteTaskFromFirebase(id);
      return 1;
    }

    try {
      final firestore = await _getFirestore();

      await _taskCollection(firestore).doc(id.toString()).delete();
      return 1;
    } catch (error) {
      debugPrint('Failed to delete task: $error');
      return 0;
    }
  }

  Future<int> deleteAllTasks() async {
    if (kIsWeb) {
      final tasks = await _getLocalTasks();
      await _saveLocalTasks([]);
      // Async delete all from Firebase without await
      _deleteAllTasksFromFirebase();
      return tasks.length;
    }

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
    if (kIsWeb) {
      final notes = await _getLocalNotes();
      final int id = note.id ?? _generateId();
      final newNote = note.copyWith(id: id);
      notes.removeWhere((existingNote) => existingNote.id == id);
      notes.add(newNote);
      await _saveLocalNotes(notes);
      // Async sync to Firebase without await
      _syncNoteToFirebase(newNote);
      return id;
    }

    try {
      final firestore = await _getFirestore();
      final int id = note.id ?? _generateId();
      final noteMap = note.copyWith(id: id).toMap();

      await _noteCollection(firestore).doc(id.toString()).set(noteMap);
      return id;
    } catch (error) {
      debugPrint('Failed to insert note: $error');
      return 0;
    }
  }

  Future<List<Note>> retrieveNotes() async {
    if (kIsWeb) {
      return _getLocalNotes();
    }

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
    if (kIsWeb) {
      if (note.id == null) {
        return 0;
      }

      final notes = await _getLocalNotes();
      final index = notes.indexWhere(
        (existingNote) => existingNote.id == note.id,
      );
      if (index == -1) {
        return 0;
      }

      notes[index] = note;
      await _saveLocalNotes(notes);
      // Async sync to Firebase without await
      _syncNoteToFirebase(note);
      return 1;
    }

    try {
      final firestore = await _getFirestore();

      if (note.id == null) {
        return 0;
      }

      await _noteCollection(
        firestore,
      ).doc(note.id.toString()).update(note.toMap());
      return 1;
    } catch (error) {
      debugPrint('Failed to update note: $error');
      return 0;
    }
  }

  Future<int> deleteNote(int id) async {
    if (kIsWeb) {
      final notes = await _getLocalNotes();
      notes.removeWhere((note) => note.id == id);
      await _saveLocalNotes(notes);
      // Async delete from Firebase without await
      _deleteNoteFromFirebase(id);
      return 1;
    }

    try {
      final firestore = await _getFirestore();

      await _noteCollection(firestore).doc(id.toString()).delete();
      return 1;
    } catch (error) {
      debugPrint('Failed to delete note: $error');
      return 0;
    }
  }

  Future<int> deleteAllNotes() async {
    if (kIsWeb) {
      final notes = await _getLocalNotes();
      await _saveLocalNotes([]);
      // Async delete all from Firebase without await
      _deleteAllNotesFromFirebase();
      return notes.length;
    }

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
