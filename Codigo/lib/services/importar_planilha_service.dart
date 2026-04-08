import 'package:excel/excel.dart';
import 'dart:io';
import 'database_helper.dart';
import 'package:patrimonio_mobile/services/patrimonioInventariado_service.dart';
import 'package:patrimonio_mobile/models/patrimonioInventariado_model.dart';

class ImportarPlanilhaService {
  final dbHelper = DatabaseHelper.instance;

  Future<int> importarParaContexto(String caminhoArquivo, int idInventario, int idSetor) async {
    var bytes = File(caminhoArquivo).readAsBytesSync();
    var excel = Excel.decodeBytes(bytes);
    int importados = 0;

    for (var table in excel.tables.keys) {
      var sheet = excel.tables[table];
      if (sheet == null) continue;

      for (int i = 1; i < sheet.maxRows; i++) {
        var row = sheet.rows[i];
        if (row.isEmpty) continue;

        final patrimonioNumero = row.last?.value?.toString().trim();

        if (patrimonioNumero != null && patrimonioNumero.isNotEmpty) {
          bool existe = await _patrimonioExisteNoInventario(patrimonioNumero, idInventario);
          
          if (!existe) {
            await _salvarNoBanco(patrimonioNumero, idInventario, idSetor);
            importados++;
          }
        }
      }
    }
    return importados;
  }

  Future<void> _salvarNoBanco(String numero, int idInv, int idSetor) async {
    final patrimonioService = PatrimonioInventariadoService();
    await patrimonioService.inserirPatrimonio(PatrimonioInventariado(
      numero: numero,
      idSetor: idSetor,
      idInventario: idInv,
    ));
  }

  Future<bool> _patrimonioExisteNoInventario(String numero, int idInv) async {
    final db = await dbHelper.database;
    final res = await db.query(
      'PatrimonioInventariado',
      where: 'numero = ? AND idInventario = ?',
      whereArgs: [numero, idInv],
    );
    return res.isNotEmpty;
  }
}