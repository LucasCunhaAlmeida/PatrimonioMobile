import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('patrimonio.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
      onConfigure: (db) async => await db.execute('PRAGMA foreign_keys = ON'),
    );
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE Instituicao (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        nome TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE Setor (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        nome TEXT NOT NULL,
        idInstituicao INTEGER NOT NULL,
        FOREIGN KEY (idInstituicao) REFERENCES Instituicao (id) ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE TABLE Inventario (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        nome TEXT NOT NULL,
        dataInicio TEXT,
        dataFim TEXT,
        idInstituicao INTEGER NOT NULL,
        FOREIGN KEY (idInstituicao) REFERENCES Instituicao (id) ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE TABLE PatrimonioInventariado (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        numero TEXT NOT NULL,
        idInventario INTEGER NOT NULL,
        idSetor INTEGER NOT NULL,
        FOREIGN KEY (idInventario) REFERENCES Inventario (id) ON DELETE CASCADE,
        FOREIGN KEY (idSetor) REFERENCES Setor (id) ON DELETE CASCADE
      )
    ''');
  }

  Future<int> insertPatrimonio(Map<String, dynamic> row) async {
    Database db = await instance.database;
    return await db.insert('PatrimonioInventariado', row);
  }

  Future<List<Map<String, dynamic>>> getPatrimoniosPorSetor(int idSetor, int idInventario) async {
    Database db = await instance.database;
    return await db.query(
      'PatrimonioInventariado',
      where: 'idSetor = ? AND idInventario = ?',
      whereArgs: [idSetor, idInventario],
    );
  }

  Future<int> deletePatrimonio(int id) async {
    Database db = await instance.database;
    return await db.delete(
      'PatrimonioInventariado',
      where: 'id = ?',
      whereArgs: [id],
    );

  }
}