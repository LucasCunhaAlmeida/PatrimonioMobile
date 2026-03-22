import 'package:sqflite/sqflite.dart';
import 'package:patrimonio_mobile/models/PatrimonioInventariado_model.dart';
import 'package:patrimonio_mobile/services/database_helper.dart';

class PatrimonioinventariadoService {
  final DatabaseHelper _databaseHelper = DatabaseHelper.instance;

  Future<int> inserirPatrimonio(PatrimonioInventariado ativo) async {
    if (ativo.idInventario == 0 || ativo.idSetor == 0) {
      throw Exception("Setor ou Inventário não informados");
    }
    
    Database db = await _databaseHelper.database;
    
    return await db.insert('PatrimonioInventariado', ativo.toMap());
  }

  Future<List<PatrimonioInventariado>> listarPatrimonio(int idSetor, int idInventario) async {
    Database db = await _databaseHelper.database;
    
    final List<Map<String, dynamic>> result = await db.query(
      'PatrimonioInventariado',
      where: 'idSetor = ? AND idInventario = ?',
      whereArgs: [idSetor, idInventario],
    );

    return result.map((item) => PatrimonioInventariado.fromMap(item)).toList();
  }

  Future<int> atualizarPatrimonio(PatrimonioInventariado ativo) async {
    Database db = await _databaseHelper.database;
    
    Map<String, dynamic> row = ativo.toMap();
    int? id = row['id']; 
    
    if (id == null) {
      throw Exception("Atualização falhou, ID não identificado");
    }

    return await db.update(
      'PatrimonioInventariado',
      row,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> excluirPatrimonio(int id) async {
    Database db = await _databaseHelper.database;
    
    return await db.delete(
      'PatrimonioInventariado',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}