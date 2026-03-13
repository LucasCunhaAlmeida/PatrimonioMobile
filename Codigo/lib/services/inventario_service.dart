import 'package:patrimonio_mobile/models/inventario_model.dart';
import 'package:sqflite/sqflite.dart';

import 'database_helper.dart';

class InventarioService {
  final _dbHelper = DatabaseHelper.instance;

  Future<int> insertInventario(Inventario inventario) async {
    final Database db = await _dbHelper.database;
    return db.insert('Inventario', inventario.toMap());
  }

  Future<List<Inventario>> queryAllInventarios() async {
    final Database db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'Inventario',
      orderBy: 'dataInicio DESC',
    );

    return maps.map(Inventario.fromMap).toList();
  }

  Future<List<Inventario>> queryInventariosByInstituicao(
      int idInstituicao) async {
    final Database db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'Inventario',
      where: 'idInstituicao = ?',
      whereArgs: [idInstituicao],
      orderBy: 'dataInicio DESC',
    );

    return maps.map(Inventario.fromMap).toList();
  }

  Future<int> updateInventario(Inventario inventario) async {
    final Database db = await _dbHelper.database;
    return db.update(
      'Inventario',
      inventario.toMap(),
      where: 'id = ?',
      whereArgs: [inventario.id],
    );
  }

  Future<int> deleteInventario(int id) async {
    final Database db = await _dbHelper.database;
    return db.delete(
      'Inventario',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
