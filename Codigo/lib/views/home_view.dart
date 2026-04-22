import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:patrimonio_mobile/models/instituicao_model.dart';
import 'package:patrimonio_mobile/models/inventario_model.dart';
import 'package:patrimonio_mobile/services/instituicao_service.dart';
import 'package:patrimonio_mobile/services/inventario_service.dart';
import 'package:patrimonio_mobile/services/importar_planilha_service.dart';
import 'package:patrimonio_mobile/services/exportar_planilha_service.dart';
import 'package:patrimonio_mobile/views/detalhes_inventario_view.dart';
import 'package:file_picker/file_picker.dart';
import 'package:share_plus/share_plus.dart';
import '/widgets/custom_navbar.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  final _instituicaoService = InstituicaoService();
  final _inventarioService = InventarioService();
  final _importarService = ImportarPlanilhaService();

  List<Instituicao> _instituicoes = [];
  List<Inventario> _inventarios = [];

  int? _instituicaoSelecionadaId;

  bool _loadingInstituicoes = true;
  bool _loadingInventarios = false;
  bool _processandoImportacao = false;
  bool _processandoExportacao = false;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _carregarInstituicoes();
  }

  Future<void> _carregarInstituicoes() async {
    setState(() => _loadingInstituicoes = true);

    final lista = await _instituicaoService.queryAllInstituicoes();

    if (!mounted) return;

    setState(() {
      _instituicoes = lista;
      _loadingInstituicoes = false;
    });

    if (lista.length == 1) {
      await _onInstituicaoChanged(lista.first.id);
    }
  }

  Future<void> _onInstituicaoChanged(int? idInstituicao) async {
    setState(() {
      _instituicaoSelecionadaId = idInstituicao;
      _inventarios = [];
      _loadingInventarios = idInstituicao != null;
    });

    if (idInstituicao == null) return;

    final lista =
        await _inventarioService.queryInventariosByInstituicao(idInstituicao);

    if (!mounted) return;

    setState(() {
      _inventarios = lista;
      _loadingInventarios = false;
    });
  }

  Future<void> _importarInventario(Inventario inventario) async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['xlsx'],
      );

      if (result != null && result.files.single.path != null) {
        setState(() => _processandoImportacao = true);

        await _importarService.importarPlanilha(
          result.files.single.path!,
        );

        await _onInstituicaoChanged(_instituicaoSelecionadaId);

        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Importação concluída em ${inventario.nome}',
            ),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao importar: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _processandoImportacao = false);
      }
    }
  }

  Future<void> _exportarInventario(Inventario inventario) async {
    setState(() => _processandoExportacao = true);

    try {
      final service = ExportarPlanilhaService();

      String nomeSanitizado = inventario.nome.replaceAll(' ', '_');
      String nomeArquivo = "Relatorio_$nomeSanitizado";

      final caminho = await service.gerarRelatorioPorInventario(
        inventario.id!,
        nomeArquivo,
      );

      final box = context.findRenderObject() as RenderBox?;
      final posicao =
          box != null ? box.localToGlobal(Offset.zero) & box.size : null;

      await Share.shareXFiles(
        [XFile(caminho)],
        text: 'Segue a planilha do inventário: ${inventario.nome}',
        sharePositionOrigin: posicao,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Planilha "$nomeArquivo" exportada com sucesso!',
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao exportar: $e'),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _processandoExportacao = false);
      }
    }
  }

  String _formatarData(String? data) {
    if (data == null || data.isEmpty) return 'N/A';

    final partes = data.split('-');

    if (partes.length == 3) {
      return '${partes[2]}/${partes[1]}/${partes[0]}';
    }

    return data;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      backgroundColor: const Color(0xFFF1F4F8),
      body: SafeArea(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              height: 130,
              color: const Color(0xFFEFF0F6),
              padding: const EdgeInsets.fromLTRB(20, 30, 20, 0),
              child: Column(
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Instituição',
                      style: GoogleFonts.interTight(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[600],
                      ),
                    ),
                  ),
                  DropdownButtonFormField<int>(
                    value: _instituicaoSelecionadaId,
                    hint: const Text('Selecione a Instituição'),
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding:
                          const EdgeInsets.symmetric(horizontal: 12),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    items: _instituicoes
                        .map(
                          (inst) => DropdownMenuItem<int>(
                            value: inst.id,
                            child: Text(inst.nome),
                          ),
                        )
                        .toList(),
                    onChanged:
                        _loadingInstituicoes ? null : _onInstituicaoChanged,
                  ),
                ],
              ),
            ),
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(30),
                  ),
                ),
                child: Column(
                  children: [
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Inventários',
                        style: GoogleFonts.interTight(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Expanded(
                      child: _buildConteudo(),
                    ),
                  ],
                ),
              ),
            ),
            const NavBarWidget(selectedIndex: 0),
          ],
        ),
      ),
    );
  }

  Widget _buildConteudo() {
    if (_loadingInstituicoes || _loadingInventarios) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_instituicaoSelecionadaId == null) {
      return const Center(
        child: Text('Selecione uma instituição'),
      );
    }

    if (_inventarios.isEmpty) {
      return const Center(
        child: Text('Nenhum inventário encontrado'),
      );
    }

    return ListView.builder(
      itemCount: _inventarios.length,
      itemBuilder: (_, index) {
        final inventario = _inventarios[index];

        return Padding(
          padding: const EdgeInsets.only(bottom: 14),
          child: _buildCardInventario(inventario),
        );
      },
    );
  }

  Widget _buildCardInventario(Inventario inventario) {
    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => DetalhesInventarioView(
              inventario: inventario,
            ),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: const Color(0xFFF1F4F8)),
          boxShadow: [
            BoxShadow(
              blurRadius: 5,
              color: Colors.black.withOpacity(0.05),
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            const Icon(
              Icons.edit_calendar_rounded,
              size: 34,
              color: Color(0xFF0055FF),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    inventario.nome,
                    style: GoogleFonts.interTight(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'Início: ${_formatarData(inventario.dataInicio)} | '
                    'Fim: ${_formatarData(inventario.dataFim)}',
                    style: const TextStyle(
                      fontSize: 11,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              onPressed: _processandoExportacao
                  ? null
                  : () => _exportarInventario(inventario),
              icon: _processandoExportacao
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(
                      Icons.upload_file,
                      color: Color(0xFF0055FF),
                    ),
            ),
            IconButton(
              onPressed: _processandoImportacao
                  ? null
                  : () => _importarInventario(inventario),
              icon: _processandoImportacao
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(
                      Icons.download,
                      color: Color(0xFF0055FF),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}