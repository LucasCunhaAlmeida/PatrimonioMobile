import 'dart:io';
import 'package:excel/excel.dart';
import 'database_helper.dart';
import 'package:patrimonio_mobile/models/patrimonioInventariado_model.dart';
import 'package:patrimonio_mobile/services/patrimonioInventariado_service.dart';

class ImportarPlanilhaService {
  final dbHelper = DatabaseHelper.instance;
  final _patrimonioService = PatrimonioInventariadoService();

  Future<int> importarPlanilha(String caminhoArquivo, int idInstituicao, int idInventario) async {
    var bytes = File(caminhoArquivo).readAsBytesSync();
    var excel = Excel.decodeBytes(bytes);
    int totalProcessados = 0;

    for (var table in excel.tables.keys) {
      var sheet = excel.tables[table];
      if (sheet == null) continue;

      for (int i = 1; i < sheet.maxRows; i++) {
        var row = sheet.rows[i];
        if (row.isEmpty || row.length < 6) continue;

        try {
          final nomeSetor = row[1]?.value?.toString().trim();
          final numeroPatrimonioRaw = row[5]?.value?.toString().trim();
          final estadoPatrimonioRaw = row.length > 6 ? row[6]?.value?.toString().trim() : null;
          final estadoConservacaoRaw = row.length > 7 ? row[7]?.value?.toString().trim() : null;

          String estadoPatrimonio = (estadoPatrimonioRaw != null && estadoPatrimonioRaw.isNotEmpty) 
              ? estadoPatrimonioRaw : 'Em uso';
          String estadoConservacao = (estadoConservacaoRaw != null && estadoConservacaoRaw.isNotEmpty) 
              ? estadoConservacaoRaw : 'Bom';

          String? numeroPatrimonio;
          if (numeroPatrimonioRaw != null) {
            numeroPatrimonio = numeroPatrimonioRaw.endsWith('.0') 
                ? numeroPatrimonioRaw.substring(0, numeroPatrimonioRaw.length - 2) 
                : numeroPatrimonioRaw;
          }

          if (numeroPatrimonio == null || numeroPatrimonio.isEmpty) continue;

          int idSetor = await _obterOuCriarSetor(nomeSetor ?? "Setor Geral", idInstituicao);

          await _upsertPatrimonio(
              numeroPatrimonio, idInventario, idSetor, estadoPatrimonio, estadoConservacao);

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
    var res = await db.query('Instituicao', where: 'nome = ?', whereArgs: [nome]);

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

  // Assinatura atualizada para receber os dois novos campos
  Future<void> _upsertPatrimonio(
      String numero, int idInv, int idSetor, String estadoPatrimonio, String estadoConservacao) async {
    final db = await dbHelper.database;

    var res = await db.query('PatrimonioInventariado',
        where: 'numero = ? AND idInventario = ?', whereArgs: [numero, idInv]);

    if (res.isEmpty) {
      await _patrimonioService.inserirPatrimonio(PatrimonioInventariado(
        numero: numero,
        idInventario: idInv,
        idSetor: idSetor,
        estadoPatrimonio: estadoPatrimonio, // Campo novo
        estadoConservacao: estadoConservacao, // Campo novo
      ));
    } else {
      var pExistente = PatrimonioInventariado.fromMap(res.first);
      pExistente.idSetor = idSetor;
      pExistente.estadoPatrimonio = estadoPatrimonio; // Atualiza se existir
      pExistente.estadoConservacao = estadoConservacao; // Atualiza se existir

      await _patrimonioService.atualizarPatrimonio(pExistente);
    }
  }
}