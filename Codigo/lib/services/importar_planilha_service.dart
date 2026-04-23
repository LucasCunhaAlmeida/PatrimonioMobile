import 'dart:io';
import 'package:excel/excel.dart';
import 'database_helper.dart';
import 'package:patrimonio_mobile/models/patrimonioInventariado_model.dart';
import 'package:patrimonio_mobile/services/patrimonioInventariado_service.dart';

class ImportarPlanilhaService {
  final dbHelper = DatabaseHelper.instance;
  final _patrimonioService = PatrimonioInventariadoService();

  Future<int> importarPlanilha(String caminhoArquivo) async {
    var bytes = File(caminhoArquivo).readAsBytesSync();
    var excel = Excel.decodeBytes(bytes);
    int totalProcessados = 0;

    for (var table in excel.tables.keys) {
      var sheet = excel.tables[table];
      if (sheet == null) continue;

      for (int i = 1; i < sheet.maxRows; i++) {
        var row = sheet.rows[i];
        // Verifica se a linha está vazia ou se a primeira célula essencial é nula
        if (row.isEmpty || row.length < 6) continue;

        try {
          final nomeInstituicao = row[0]?.value?.toString().trim();
          final nomeSetor = row[1]?.value?.toString().trim();
          final nomeInventario = row[2]?.value?.toString().trim();
          final dataInicio = row[3]?.value?.toString().trim();
          final dataFim = row[4]?.value?.toString().trim();

          final numeroPatrimonioRaw = row[5]?.value?.toString().trim();

          String? numeroPatrimonio;
          if (numeroPatrimonioRaw != null) {
            if (numeroPatrimonioRaw.endsWith('.0')) {
              numeroPatrimonio = numeroPatrimonioRaw.substring(
                  0, numeroPatrimonioRaw.length - 2);
            } else {
              numeroPatrimonio = numeroPatrimonioRaw;
            }
          }

          if (nomeInstituicao == null ||
              numeroPatrimonio == null ||
              numeroPatrimonio.isEmpty) {
            continue;
          }

          int idInst = await _obterOuCriarInstituicao(nomeInstituicao);

          int idSetor =
              await _obterOuCriarSetor(nomeSetor ?? "Setor Geral", idInst);

          int idInv = await _obterOuCriarInventario(
              nomeInventario ?? "Novo Inventário", idInst, dataInicio, dataFim);

          await _upsertPatrimonio(numeroPatrimonio, idInv, idSetor);

          totalProcessados++;
        } catch (e) {
          print("Erro ao processar linha $i: $e");
        }
      }
    }
    return totalProcessados;
  }

  Future<int> _obterOuCriarInstituicao(String nome) async {
    final db = await dbHelper.database;
    var res =
        await db.query('Instituicao', where: 'nome = ?', whereArgs: [nome]);

    if (res.isNotEmpty) {
      return res.first['id'] as int;
    } else {
      return await db.insert('Instituicao', {'nome': nome});
    }
  }

  Future<int> _obterOuCriarSetor(String nome, int idInst) async {
    final db = await dbHelper.database;
    var res = await db.query('Setor',
        where: 'nome = ? AND idInstituicao = ?', whereArgs: [nome, idInst]);

    if (res.isNotEmpty) {
      return res.first['id'] as int;
    } else {
      return await db.insert('Setor', {'nome': nome, 'idInstituicao': idInst});
    }
  }

  Future<int> _obterOuCriarInventario(
      String nome, int idInst, String? inicio, String? fim) async {
    final db = await dbHelper.database;
    var res = await db.query('Inventario',
        where: 'nome = ? AND idInstituicao = ?', whereArgs: [nome, idInst]);

    if (res.isNotEmpty) {
      return res.first['id'] as int;
    } else {
      return await db.insert('Inventario', {
        'nome': nome,
        'dataInicio': inicio,
        'dataFim': fim,
        'idInstituicao': idInst
      });
    }
  }

  Future<void> _upsertPatrimonio(String numero, int idInv, int idSetor) async {
    final db = await dbHelper.database;

    var res = await db.query('PatrimonioInventariado',
        where: 'numero = ? AND idInventario = ?', whereArgs: [numero, idInv]);

    if (res.isEmpty) {
      await _patrimonioService.inserirPatrimonio(PatrimonioInventariado(
        numero: numero,
        idInventario: idInv,
        idSetor: idSetor,
        estadoPatrimonio: 'Em uso',
        estadoConservacao: 'Bom',
      ));
    } else {
      var pExistente = PatrimonioInventariado.fromMap(res.first);
      pExistente.idSetor = idSetor;

      await _patrimonioService.atualizarPatrimonio(pExistente);
    }
  }
}
