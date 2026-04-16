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
      version: 3,
      onCreate: _createDB,
      onUpgrade: _onUpgrade,
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
        estadoPatrimonio TEXT NOT NULL,
        estadoConservacao TEXT NOT NULL,
        FOREIGN KEY (idInventario) REFERENCES Inventario (id) ON DELETE CASCADE,
        FOREIGN KEY (idSetor) REFERENCES Setor (id) ON DELETE CASCADE
      )
    ''');
  }

  // Método para lidar com atualizações de versão do banco de dados
  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await _ensureColumnExists(
        db,
        table: 'PatrimonioInventariado',
        column: 'estadoPatrimonio',
        definition: 'TEXT',
      );
      await _ensureColumnExists(
        db,
        table: 'PatrimonioInventariado',
        column: 'estadoConservacao',
        definition: 'TEXT',
      );
    }

    if (oldVersion < 3) {
      await _normalizarEstadosPatrimonio(db);
    }
  }

  // Para bases existentes: apenas preencher legados nulos/vazios com defaults.
  Future<void> _normalizarEstadosPatrimonio(Database db) async {
    await db.execute('''
      UPDATE PatrimonioInventariado
      SET
        estadoPatrimonio = COALESCE(NULLIF(TRIM(estadoPatrimonio), ''), 'Em uso'),
        estadoConservacao = COALESCE(NULLIF(TRIM(estadoConservacao), ''), 'Bom')
    ''');
  }

  //Migração segura para adicionar colunas sem perder dados existentes
  Future<void> _ensureColumnExists(
    Database db, {
    required String table,
    required String column,
    required String definition,
  }) async {
    final columns = await db.rawQuery('PRAGMA table_info($table)');
    final exists = columns.any((c) => c['name'] == column);
    if (!exists) {
      await db.execute(
        'ALTER TABLE $table ADD COLUMN $column $definition',
      );
    }
  }

  Future<List<Map<String, dynamic>>> getRelatorioExcelPorId(
      int idInventario) async {
    final db = await instance.database;

    return await db.rawQuery('''
    SELECT 
      inst.nome AS instituicao,
      s.nome AS setor,
      inv.nome AS inventario,
      inv.dataInicio AS dataInicio,
      inv.dataFim AS dataFim,
      p.numero AS patrimonio
    FROM PatrimonioInventariado p
    INNER JOIN Setor s ON p.idSetor = s.id
    INNER JOIN Inventario inv ON p.idInventario = inv.id
    INNER JOIN Instituicao inst ON inv.idInstituicao = inst.id
    WHERE p.idInventario = ?
  ''', [idInventario]);
  }
}
