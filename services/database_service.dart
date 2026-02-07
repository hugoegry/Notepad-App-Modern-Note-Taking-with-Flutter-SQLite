import 'dart:convert';
import 'dart:io';
import 'package:crypto/crypto.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:path/path.dart';
import '../models/note.dart';
import '../models/folder.dart';

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  factory DatabaseService() => _instance;
  DatabaseService._internal();

  Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    // Initialize sqflite for desktop platforms
    if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
    }

    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'bloc_notes.db');

    return openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE folders (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT NOT NULL,
            password TEXT,
            createdAt TEXT NOT NULL,
            updatedAt TEXT NOT NULL
          )
        ''');
        await db.execute('''
          CREATE TABLE notes (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            title TEXT NOT NULL,
            content TEXT NOT NULL,
            folderId INTEGER,
            password TEXT,
            createdAt TEXT NOT NULL,
            updatedAt TEXT NOT NULL,
            FOREIGN KEY (folderId) REFERENCES folders (id) ON DELETE SET NULL
          )
        ''');
      },
    );
  }

  // --- Hash password ---
  String hashPassword(String password) {
    final bytes = utf8.encode(password);
    return sha256.convert(bytes).toString();
  }

  bool verifyPassword(String input, String hashed) {
    return hashPassword(input) == hashed;
  }

  // --- FOLDERS ---
  Future<List<NoteFolder>> getFolders() async {
    final db = await database;
    final maps = await db.query('folders', orderBy: 'updatedAt DESC');
    return maps.map((m) => NoteFolder.fromMap(m)).toList();
  }

  Future<NoteFolder?> getFolder(int id) async {
    final db = await database;
    final maps = await db.query('folders', where: 'id = ?', whereArgs: [id]);
    if (maps.isEmpty) return null;
    return NoteFolder.fromMap(maps.first);
  }

  Future<int> insertFolder(NoteFolder folder) async {
    final db = await database;
    final map = folder.toMap();
    map.remove('id');
    if (map['password'] != null && (map['password'] as String).isNotEmpty) {
      map['password'] = hashPassword(map['password'] as String);
    }
    return db.insert('folders', map);
  }

  Future<int> updateFolder(NoteFolder folder) async {
    final db = await database;
    final map = folder.toMap();
    return db.update('folders', map, where: 'id = ?', whereArgs: [folder.id]);
  }

  Future<int> updateFolderPassword(int folderId, String? password) async {
    final db = await database;
    return db.update(
      'folders',
      {
        'password': password != null && password.isNotEmpty
            ? hashPassword(password)
            : null,
        'updatedAt': DateTime.now().toIso8601String(),
      },
      where: 'id = ?',
      whereArgs: [folderId],
    );
  }

  Future<int> deleteFolder(int id) async {
    final db = await database;
    // Move notes out of this folder
    await db.update(
      'notes',
      {'folderId': null},
      where: 'folderId = ?',
      whereArgs: [id],
    );
    return db.delete('folders', where: 'id = ?', whereArgs: [id]);
  }

  // --- NOTES ---
  Future<List<Note>> getNotes({int? folderId, bool rootOnly = false}) async {
    final db = await database;
    String? where;
    List<dynamic>? whereArgs;
    if (folderId != null) {
      where = 'folderId = ?';
      whereArgs = [folderId];
    } else if (rootOnly) {
      where = 'folderId IS NULL';
    }
    final maps = await db.query(
      'notes',
      where: where,
      whereArgs: whereArgs,
      orderBy: 'updatedAt DESC',
    );
    return maps.map((m) => Note.fromMap(m)).toList();
  }

  Future<Note?> getNote(int id) async {
    final db = await database;
    final maps = await db.query('notes', where: 'id = ?', whereArgs: [id]);
    if (maps.isEmpty) return null;
    return Note.fromMap(maps.first);
  }

  Future<int> insertNote(Note note) async {
    final db = await database;
    final map = note.toMap();
    map.remove('id');
    if (map['password'] != null && (map['password'] as String).isNotEmpty) {
      map['password'] = hashPassword(map['password'] as String);
    }
    return db.insert('notes', map);
  }

  Future<int> updateNote(Note note) async {
    final db = await database;
    final map = note.toMap();
    map['updatedAt'] = DateTime.now().toIso8601String();
    return db.update('notes', map, where: 'id = ?', whereArgs: [note.id]);
  }

  Future<int> updateNotePassword(int noteId, String? password) async {
    final db = await database;
    return db.update(
      'notes',
      {
        'password': password != null && password.isNotEmpty
            ? hashPassword(password)
            : null,
        'updatedAt': DateTime.now().toIso8601String(),
      },
      where: 'id = ?',
      whereArgs: [noteId],
    );
  }

  Future<int> moveNoteToFolder(int noteId, int? folderId) async {
    final db = await database;
    return db.update(
      'notes',
      {'folderId': folderId, 'updatedAt': DateTime.now().toIso8601String()},
      where: 'id = ?',
      whereArgs: [noteId],
    );
  }

  Future<int> deleteNote(int id) async {
    final db = await database;
    return db.delete('notes', where: 'id = ?', whereArgs: [id]);
  }

  Future<int> getNoteCountInFolder(int folderId) async {
    final db = await database;
    final result = await db.rawQuery(
      'SELECT COUNT(*) as count FROM notes WHERE folderId = ?',
      [folderId],
    );
    return Sqflite.firstIntValue(result) ?? 0;
  }
}
