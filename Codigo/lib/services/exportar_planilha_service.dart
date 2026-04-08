import 'package:excel/excel.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'dart:io';
import 'database_helper.dart';

class ExportarPlanilhaService {
  Future<String> gerarRelatorioPorInventario(int idInventario, String nomeArquivo) async {
    final List<Map<String, dynamic>> dadosBanco =
        await DatabaseHelper.instance.getRelatorioExcelPorId(idInventario);

    var excel = Excel.createExcel();
    String defaultSheet = excel.getDefaultSheet()!;
    excel.rename(defaultSheet, 'Relatório de Patrimônio');
    Sheet sheetObject = excel['Relatório de Patrimônio'];

    List<String> cabecalho = [
      'Instituição',
      'Setor',
      'Inventário',
      'Data Início',
      'Data Fim',
      'Patrimônio'
    ];

    for (var i = 0; i < cabecalho.length; i++) {
      var cell = sheetObject
          .cell(CellIndex.indexByColumnRow(columnIndex: i, rowIndex: 0));
      cell.value = TextCellValue(cabecalho[i]);
    }

    int linhaAtual = 1;

    for (var row in dadosBanco) {
      String instAtual = row['instituicao']?.toString() ?? "";
      String setorAtual = row['setor']?.toString() ?? "";
      String invAtual = row['inventario']?.toString() ?? "";
      String dataInicio = row['dataInicio']?.toString() ?? "";
      String dataFim = row['dataFim']?.toString() ?? "";
      String patAtual = row['patrimonio']?.toString() ?? "";

      sheetObject
          .cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: linhaAtual))
          .value = TextCellValue(instAtual);

      sheetObject
          .cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: linhaAtual))
          .value = TextCellValue(setorAtual);

      sheetObject
          .cell(CellIndex.indexByColumnRow(columnIndex: 2, rowIndex: linhaAtual))
          .value = TextCellValue(invAtual);

      sheetObject
          .cell(CellIndex.indexByColumnRow(columnIndex: 3, rowIndex: linhaAtual))
          .value = TextCellValue(dataInicio);

      sheetObject
          .cell(CellIndex.indexByColumnRow(columnIndex: 4, rowIndex: linhaAtual))
          .value = TextCellValue(dataFim);

      sheetObject
          .cell(CellIndex.indexByColumnRow(columnIndex: 5, rowIndex: linhaAtual))
          .value = TextCellValue(patAtual);

      linhaAtual++;
    }

    List<int>? fileBytes = excel.save();
    final directory = await getApplicationDocumentsDirectory();
    final fullPath = p.join(directory.path, "$nomeArquivo.xlsx");
    await File(fullPath).writeAsBytes(fileBytes!);

    return fullPath;
  }

  Future<String> gerarRelatorioGeral(String nomeArquivo) async{
    // TODO

    var excel = Excel.createExcel();
    String defaultSheet = excel.getDefaultSheet()!;
    excel.rename(defaultSheet, 'Relatório de Patrimônio');
    Sheet sheetObject = excel['Relatório de Patrimônio'];

     List<int>? fileBytes = excel.save();
    final directory = await getApplicationDocumentsDirectory();
    final fullPath = p.join(directory.path, "$nomeArquivo.xlsx");
    await File(fullPath).writeAsBytes(fileBytes!);

    return fullPath;
  }
}