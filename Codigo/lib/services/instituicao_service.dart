import 'package:sqflite/sqflite.dart';
import 'package:patrimonio_mobile/models/instituicao_model.dart';
import 'database_helper.dart';

class InstituicaoService {
  final _dbHelper = DatabaseHelper.instance;

  static const String _table = 'Instituicao';
  static const String _idColumn = 'id';

  Future<int> insertInstituicao(Instituicao instituicao) async {
    Database db = await _dbHelper.database;
    return await db.insert(_table, instituicao.toMap());
  }

  Future<List<Instituicao>> queryAllInstituicoes() async {
    Database db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(_table);

    return List.generate(maps.length, (i) {
      return Instituicao.fromMap(maps[i]);
    });
  }

  Future<Instituicao?> queryInstituicaoById(int id) async {
    Database db = await _dbHelper.database;
    final maps = await db.query(
      _table,
      where: '$_idColumn = ?',
      whereArgs: [id],
      limit: 1,
    );

    if (maps.isEmpty) return null;
    return Instituicao.fromMap(maps.first);
  }

  Future<int> updateInstituicao(int id, Instituicao instituicao) async {
    Database db = await _dbHelper.database;
    final Map<String, dynamic> data = Map<String, dynamic>.from(instituicao.toMap());
    data.remove(_idColumn);
    return await db.update(
      _table,
      data,
      where: '$_idColumn = ?',
      whereArgs: [id],
    );
  }

  Future<int> deleteInstituicao(int id) async {
    Database db = await _dbHelper.database;
    return await db.delete(_table, where: '$_idColumn = ?', whereArgs: [id]);
  }
}
