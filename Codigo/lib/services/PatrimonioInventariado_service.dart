  import 'package:patrimonio_mobile/models/PatrimonioInventariado_model.dart';
  import 'package:patrimonio_mobile/services/database_helper.dart';

  class PatrimonioinventariadoService {

    final DatabaseHelper databaseHelper = DatabaseHelper.instance;

    Future<int> inserirPatrimonio(PatrimonioInventariado ativos) async
    {
      if(ativos.id == 0 || ativos.idInventario == 0){
         throw Exception("Setor ou Inventario ao informados");
      } 
      return databaseHelper.insertPatrimonio(ativos.toMap());
    }

    Future<List<PatrimonioInventariado>> listarPatrimonio(int idSetor, int idInventario) async
    {
      final List<Map<String, dynamic>> result = 
      await databaseHelper.getPatrimoniosPorSetor(idSetor, idInventario);

      return result.map((item) => PatrimonioInventariado.fromMap(item)).toList();
    }

    Future<int> excluirPatrimonio(int id) async {
      if(id == Null){
        throw Exception("exclusão falhou, id não identificado");
      }
      return await databaseHelper.deletePatrimonio(id);
   }
 }
