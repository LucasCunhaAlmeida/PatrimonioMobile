import 'package:sqflite/sqflite.dart';
import 'package:patrimonio_mobile/models/setor_model.dart';
import 'database_helper.dart';

class SetorService {
  final _dbHelper = DatabaseHelper.instance;

  Future<int> insertSetor(Setor setor) async {
    Database db = await _dbHelper.database;
    return await db.insert('Setor', setor.toMap());
  }

  Future<List<Setor>> queryAllSetores() async {
    Database db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query('Setor');

    return List.generate(maps.length, (i) {
      return Setor.fromMap(maps[i]);
    });
  }

  Future<int> deleteSetor(int id) async {
    Database db = await _dbHelper.database;
    return await db.delete('Setor', where: 'id = ?', whereArgs: [id]);
  }

  Future<int> updateSetor(Setor setor) async {
    Database db = await _dbHelper.database;
    return await db.update('Setor', setor.toMap(), where: 'id = ?', whereArgs: [setor.id]);
  }
}
