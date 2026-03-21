import 'package:excel/excel.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'dart:io';
import 'database_helper.dart';

class ExportarPlanilhaService {

  Future<String> gerarRelatorioGeral(String nomeArquivo) async {

    final List<Map<String, dynamic>> dadosBanco = await DatabaseHelper.instance.getRelatorioExcel();
    
    var excel = Excel.createExcel();
    String defaultSheet = excel.getDefaultSheet()!;
    excel.rename(defaultSheet, 'Relatório de Patrimônio');
    Sheet sheetObject = excel['Relatório de Patrimônio'];

    // 1. Cabeçalho (Linha 0)
    List<String> cabecalho = ['Instituição', 'Setor', 'Inventário', 'Patrimônio'];
    for (var i = 0; i < cabecalho.length; i++) {
      var cell = sheetObject.cell(CellIndex.indexByColumnRow(columnIndex: i, rowIndex: 0));
      cell.value = TextCellValue(cabecalho[i]);
    }

    int linhaAtual = 1;

    // Variáveis para controlar a repetição de nomes (Efeito Escada)
    String ultimaInst = "";
    String ultimoSetor = "";
    String ultimoInv = "";

    // 2. Loop único pelos dados do banco
    for (var row in dadosBanco) {
      String instAtual = row['instituicao']?.toString() ?? "";
      String setorAtual = row['setor']?.toString() ?? "";
      String invAtual = row['inventario']?.toString() ?? "";
      String patCod = row['patrimonio_cod']?.toString() ?? "";
      String patDesc = row['patrimonio_desc']?.toString() ?? "";

      // Coluna A: Instituição (Só escreve se for diferente da linha de cima)
      if (instAtual != ultimaInst) {
        sheetObject.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: linhaAtual))
            .value = TextCellValue(instAtual);
        ultimaInst = instAtual;
        ultimoSetor = ""; // Reseta o controle do setor quando a instituição muda
        ultimoInv = "";
      }

      // Coluna B: Setor (Só escreve se for diferente)
      if (setorAtual != ultimoSetor) {
        sheetObject.cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: linhaAtual))
            .value = TextCellValue(setorAtual);
        ultimoSetor = setorAtual;
        ultimoInv = ""; // Reseta o controle do inventário quando o setor muda
      }

      // Coluna C: Inventário (Só escreve se for diferente)
      if (invAtual != ultimoInv) {
        sheetObject.cell(CellIndex.indexByColumnRow(columnIndex: 2, rowIndex: linhaAtual))
            .value = TextCellValue(invAtual);
        ultimoInv = invAtual;
      }

      // Coluna D: Patrimônio (Sempre escreve)
      sheetObject.cell(CellIndex.indexByColumnRow(columnIndex: 3, rowIndex: linhaAtual))
          .value = TextCellValue("$patCod - $patDesc");

      linhaAtual++;
    }

    // 3. Salvamento do arquivo
    List<int>? fileBytes = excel.save();
    final directory = await getApplicationDocumentsDirectory();
    final fullPath = p.join(directory.path, "$nomeArquivo.xlsx");
    await File(fullPath).writeAsBytes(fileBytes!);

    return fullPath;
  }
}