import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:patrimonio_mobile/models/instituicao_model.dart';
import 'package:patrimonio_mobile/models/inventario_model.dart';
import 'package:patrimonio_mobile/services/instituicao_service.dart';
import 'package:patrimonio_mobile/services/inventario_service.dart';
import 'package:patrimonio_mobile/views/detalhes_inventario_view.dart';
import 'package:patrimonio_mobile/services/importar_planilha_service.dart'; 
import 'package:file_picker/file_picker.dart';
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

  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _carregarInstituicoes();
  }

  Future<void> _carregarInstituicoes() async {
    setState(() => _loadingInstituicoes = true);
    final lista = await _instituicaoService.queryAllInstituicoes();
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

    final inventarios = await _inventarioService.queryInventariosByInstituicao(idInstituicao);
    if (!mounted) return;
    setState(() {
      _inventarios = inventarios;
      _loadingInventarios = false;
    });
  }

  Future<void> _importarInventario() async {
    
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['xlsx'],
      );

      if (result != null && result.files.single.path != null) {
        setState(() => _processandoImportacao = true);

        int total = await _importarService.importarPlanilha(result.files.single.path!);

        await _carregarInstituicoes();
      
        if (_instituicaoSelecionadaId != null) {
          await _onInstituicaoChanged(_instituicaoSelecionadaId);
        }

        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('$total registros processados com sucesso!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Erro ao importar: Verifique o formato da planilha.'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) setState(() => _processandoImportacao = false);
    }
  }

  String _formatarData(String? data) {
    if (data == null || data.isEmpty) return 'N/A';
    final partes = data.split('-');
    if (partes.length == 3) return '${partes[2]}/${partes[1]}/${partes[0]}';
    return data;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        key: scaffoldKey,
        backgroundColor: const Color(0xFFF1F4F8),
        body: SafeArea(
          child: Column(
            children: [
              Container(
                width: double.infinity,
                height: 130,
                color: const Color(0xFFEFF0F6),
                padding: const EdgeInsetsDirectional.fromSTEB(20, 30, 20, 0),
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
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Color(0x9A57636C)),
                        ),
                      ),
                      hint: const Text('Selecione a Instituição'),
                      items: _instituicoes
                          .map((inst) => DropdownMenuItem<int>(
                                value: inst.id,
                                child: Text(inst.nome),
                              ))
                          .toList(),
                      onChanged: _loadingInstituicoes ? null : _onInstituicaoChanged,
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Container(
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 20),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Inventários',
                                style: GoogleFonts.interTight(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.grey[700],
                                ),
                              ),
                              ElevatedButton.icon(
                                onPressed: _processandoImportacao ? null : _importarInventario,
                                icon: _processandoImportacao
                                    ? const SizedBox(
                                        width: 15,
                                        height: 15,
                                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                                      )
                                    : const Icon(Icons.download, size: 18, color: Colors.white),
                                label: Text(
                                  _processandoImportacao ? 'Aguarde...' : 'Importar Planilha',
                                  style: GoogleFonts.inter(fontSize: 13, color: Colors.white, fontWeight: FontWeight.w600),
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF0055FF),
                                  minimumSize: const Size(100, 38),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                  elevation: 0,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Expanded(child: _buildListaConteudo()),
                      ],
                    ),
                  ),
                ),
              ),
              const NavBarWidget(selectedIndex: 0),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildListaConteudo() {
    if (_loadingInstituicoes || _loadingInventarios) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_instituicaoSelecionadaId == null) {
      return Center(
        child: Text('Selecione uma instituição', style: GoogleFonts.inter(fontSize: 15, color: Colors.grey[600])),
      );
    }
    if (_inventarios.isEmpty) {
      return Center(
        child: Text('Nenhum inventário encontrado.', style: GoogleFonts.inter(fontSize: 15, color: Colors.grey[600])),
      );
    }
    return ListView.builder(
      padding: EdgeInsets.zero,
      itemCount: _inventarios.length,
      itemBuilder: (context, index) {
        final inv = _inventarios[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 15),
          child: _buildInventarioCard(
            inventario: inv,
            titulo: inv.nome,
            inicio: _formatarData(inv.dataInicio),
            fim: _formatarData(inv.dataFim),
          ),
        );
      },
    );
  }

  Widget _buildInventarioCard({required Inventario inventario, required String titulo, required String inicio, required String fim}) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => DetalhesInventarioView(inventario: inventario)),
        );
      },
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(blurRadius: 5, color: Colors.black.withOpacity(0.05), offset: const Offset(0, 2)),
          ],
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFFF1F4F8)),
        ),
        child: Row(
          children: [
            const Icon(Icons.edit_calendar_rounded, color: Color(0xFF0055FF), size: 35),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(titulo, style: GoogleFonts.interTight(fontSize: 16, fontWeight: FontWeight.bold)),
                  Text('Início: $inicio | Fim: $fim', style: const TextStyle(fontSize: 11, color: Colors.grey)),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios, color: Colors.grey, size: 16),
          ],
        ),
      ),
    );
  }
}