import 'package:patrimonio_mobile/models/PatrimonioInventariado_model.dart';
import 'package:patrimonio_mobile/services/database_helper.dart';

class PatrimonioinventariadoService {
  final DatabaseHelper databaseHelper = DatabaseHelper.instance;

  Future<int> inserirPatrimonio(PatrimonioInventariado ativo) async {
    if (ativo.idInventario == 0 || ativo.idSetor == 0) {
      throw Exception("Setor ou Inventário não informados");
    }
    return await databaseHelper.insertPatrimonio(ativo.toMap());
  }

  Future<List<PatrimonioInventariado>> listarPatrimonio(int idSetor, int idInventario) async {
    final List<Map<String, dynamic>> result =
        await databaseHelper.getPatrimoniosPorSetor(idSetor, idInventario);

    return result.map((item) => PatrimonioInventariado.fromMap(item)).toList();
  }

  Future<int> excluirPatrimonio(int id) async {
    return await databaseHelper.deletePatrimonio(id);
  }
}