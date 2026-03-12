import 'package:sqflite/sqflite.dart';
import 'package:patrimonio_mobile/models/instituicao_model.dart';
import 'database_helper.dart';

class InstituicaoService {
  final _dbHelper = DatabaseHelper.instance;

  Future<int> insertInstituicao(Instituicao instituicao) async {
    Database db = await _dbHelper.database;
    return await db.insert('Instituicao', instituicao.toMap());
  }

  Future<List<Instituicao>> queryAllInstituicoes() async {
    Database db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query('Instituicao');

    return List.generate(maps.length, (i) {
      return Instituicao.fromMap(maps[i]);
    });
  }
}
