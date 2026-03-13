import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('patrimonio.db');
    await _ensureMockData(_database!);
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
      onOpen: (db) async => await _ensureMockData(db),
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

    await _seedMockData(db);
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
  /// Dados de exemplo para desenvolvimento.
  /// Remova ou comente este método quando o CRUD real de Instituição estiver pronto.
  Future<void> _seedMockData(Database db) async {
    // Instituições
    final int idUFS = await db.insert('Instituicao', {'nome': 'UFS'});
    final int idUnicamp = await db.insert('Instituicao', {'nome': 'Unicamp'});

    // Setores (necessários para PatrimonioInventariado)
    final int idTI =
        await db.insert('Setor', {'nome': 'TI', 'idInstituicao': idUFS});
    await db
        .insert('Setor', {'nome': 'Biblioteca', 'idInstituicao': idUnicamp});

    // Inventários vinculados às instituições
    final int idInv1 = await db.insert('Inventario', {
      'nome': 'Inventário Anual 2025',
      'dataInicio': '2025-01-10',
      'dataFim': '2025-01-31',
      'idInstituicao': idUFS,
    });
    await db.insert('Inventario', {
      'nome': 'Inventário Semestral',
      'dataInicio': '2025-06-01',
      'dataFim': '2025-06-15',
      'idInstituicao': idUFS,
    });
    await db.insert('Inventario', {
      'nome': 'Inventário Geral 2025',
      'dataInicio': '2025-03-05',
      'dataFim': '2025-03-20',
      'idInstituicao': idUnicamp,
    });

    // Patrimônio de exemplo
    await db.insert('PatrimonioInventariado', {
      'numero': 'PAT-001',
      'idInventario': idInv1,
      'idSetor': idTI,
    });
  }

  Future<void> _ensureMockData(Database db) async {
    final resultado = await db.rawQuery(
      'SELECT COUNT(*) AS total FROM Instituicao',
    );
    final totalInstituicoes = Sqflite.firstIntValue(resultado) ?? 0;

    if (totalInstituicoes == 0) {
      await _seedMockData(db);
    }
  }
}
