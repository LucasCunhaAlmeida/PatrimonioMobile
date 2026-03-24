import 'package:excel/excel.dart';
import 'dart:io';
import 'database_helper.dart';
import 'patrimonioInventariado_service.dart';
import 'package:patrimonio_mobile/models/patrimonioInventariado_model.dart';

class ImportarPlanilhaService {
  final dbHelper = DatabaseHelper.instance;

  Future<void> consumirRelatorio(String caminhoArquivo) async {
    var bytes = File(caminhoArquivo).readAsBytesSync();
    var excel = Excel.decodeBytes(bytes);

    for (var table in excel.tables.keys) {
      var sheet = excel.tables[table];
      if (sheet == null) continue;

      for (int i = 1; i < sheet.maxRows; i++) {
        var row = sheet.rows[i];

        final instituicaoNome = row[0]?.value?.toString();
        final setorNome = row[1]?.value?.toString();
        final inventarioNome = row[2]?.value?.toString();
        
        final dataInicio = row[3]?.value?.toString(); 
        final dataFim = row[4]?.value?.toString();
        
        final patrimonioNumero = row[5]?.value?.toString()?.trim();

        if (patrimonioNumero != null && patrimonioNumero.isNotEmpty) {
          bool existe = await _patrimonioExiste(patrimonioNumero);
          if (existe) continue;

          await _salvarNoBanco(
            patrimonioNumero, 
            instituicaoNome, 
            setorNome, 
            inventarioNome, 
            dataInicio, 
            dataFim
          );
        }
      }
    }
  }

  Future<void> _salvarNoBanco(
      String numero, 
      String? instituicaoNome,
      String? setorNome, 
      String? inventarioNome,
      String? dataInicio,
      String? dataFim) async {
    
    int idInst = await _obterOuCriarInstituicao(instituicaoNome ?? 'Desconhecida');
    int idSetor = await _obterOuCriarSetor(setorNome ?? 'Desconhecido', idInst);
    
    int idInv = await _obterOuCriarInventario(
      inventarioNome ?? 'Desconhecido', 
      idInst, 
      dataInicio, 
      dataFim
    );

    final patrimonioService = PatrimonioInventariadoService();
    await patrimonioService.inserirPatrimonio(PatrimonioInventariado(
        numero: numero, 
        idSetor: idSetor, 
        idInventario: idInv
    ));
  }

  Future<int> _obterOuCriarInstituicao(String nome) async {
    final db = await dbHelper.database;
    var res =
        await db.query('Instituicao', where: 'nome = ?', whereArgs: [nome]);

    if (res.isNotEmpty) return res.first['id'] as int;

    return await db.insert('Instituicao', {'nome': nome});
  }

  Future<int> _obterOuCriarSetor(String nome, int idInstituicao) async {
    final db = await dbHelper.database;
    var res = await db.query('Setor',
        where: 'nome = ? AND idInstituicao = ?',
        whereArgs: [nome, idInstituicao]);

    if (res.isNotEmpty) return res.first['id'] as int;

    return await db
        .insert('Setor', {'nome': nome, 'idInstituicao': idInstituicao});
  }

  Future<int> _obterOuCriarInventario(
      String nome, int idInstituicao, String? dataInicio, String? dataFim) async {
    final db = await dbHelper.database;
    var res = await db.query('Inventario',
        where: 'nome = ? AND idInstituicao = ?',
        whereArgs: [nome, idInstituicao]);

    if (res.isNotEmpty) return res.first['id'] as int;

    return await db.insert('Inventario', {
      'nome': nome,
      'idInstituicao': idInstituicao,
      'dataInicio': dataInicio ?? DateTime.now().toIso8601String().split('T')[0],
      'dataFim': dataFim ?? "",
    });
  }

  Future<bool> _patrimonioExiste(String patrimonioNumero) async {
    final db = await dbHelper.database;

    final List<Map<String, dynamic>> resultado = await db.query(
        'PatrimonioInventariado',
        where: 'numero = ?',
        whereArgs: [patrimonioNumero]);

    return resultado.isNotEmpty;
  }
}
