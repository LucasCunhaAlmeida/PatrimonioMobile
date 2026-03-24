import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:patrimonio_mobile/models/instituicao_model.dart';
import 'package:patrimonio_mobile/models/inventario_model.dart';
import 'package:patrimonio_mobile/services/instituicao_service.dart';
import 'package:patrimonio_mobile/services/inventario_service.dart';
import 'package:patrimonio_mobile/views/detalhes_inventario_view.dart';
import '/widgets/custom_navbar.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  final _instituicaoService = InstituicaoService();
  final _inventarioService = InventarioService();

  List<Instituicao> _instituicoes = [];
  List<Inventario> _inventarios = [];
  int? _instituicaoSelecionadaId;
  bool _loadingInstituicoes = true;
  bool _loadingInventarios = false;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _loadInstituicoes();
  }

  Future<void> _loadInstituicoes() async {
    setState(() => _loadingInstituicoes = true);

    final instituicoes = await _instituicaoService.queryAllInstituicoes();

    setState(() {
      _instituicoes = instituicoes;
      _loadingInstituicoes = false;
    });
  }

  Future<void> _onInstituicaoChanged(int? idInstituicao) async {
    setState(() {
      _instituicaoSelecionadaId = idInstituicao;
      _inventarios = [];
      _loadingInventarios = idInstituicao != null;
    });

    if (idInstituicao == null) {
      return;
    }

    final inventarios = await _inventarioService.queryInventariosByInstituicao(
      idInstituicao,
    );

    if (!mounted) return;

    setState(() {
      _inventarios = inventarios;
      _loadingInventarios = false;
    });
  }

  String _formatarData(String data) {
    final partes = data.split('-');
    if (partes.length == 3) {
      return '${partes[2]}/${partes[1]}/${partes[0]}';
    }
    return data;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: Scaffold(
        key: scaffoldKey,
        backgroundColor: const Color(0xFFF1F4F8), // Cor de fundo padrão
        body: Column(
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.max,
                children: [
                  // --- CABEÇALHO (INSTITUIÇÃO) ---
                  Container(
                    width: double.infinity,
                    height: 130,
                    decoration: const BoxDecoration(
                      color: Color(0xFFEFF0F6),
                    ),
                    child: Padding(
                      padding:
                          const EdgeInsetsDirectional.fromSTEB(20, 30, 20, 0),
                      child: Column(
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          Align(
                            alignment: const AlignmentDirectional(-1, 0),
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
                            initialValue: _instituicaoSelecionadaId,
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: Colors.white,
                              contentPadding:
                                  const EdgeInsets.symmetric(horizontal: 12),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide:
                                    const BorderSide(color: Color(0x9A57636C)),
                              ),
                            ),
                            hint: const Text('Selecione a Instituição'),
                            items: _instituicoes
                                .map((inst) => DropdownMenuItem<int>(
                                      value: inst.id,
                                      child: Text(inst.nome),
                                    ))
                                .toList(),
                            onChanged: _loadingInstituicoes
                                ? null
                                : (val) => _onInstituicaoChanged(val),
                          ),
                        ],
                      ),
                    ),
                  ),

                  Expanded(
                    child: Container(
                      width: double.infinity,
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
                              child: Text(
                                'Inventários',
                                style: GoogleFonts.interTight(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.grey[700],
                                ),
                              ),
                            ),
                            Expanded(
                              child: _loadingInstituicoes || _loadingInventarios
                                  ? const Center(
                                      child: CircularProgressIndicator(),
                                    )
                                  : _instituicaoSelecionadaId == null
                                      ? Center(
                                          child: Text(
                                            'Selecione a Instituição',
                                            style: GoogleFonts.inter(
                                              fontSize: 15,
                                              color: Colors.grey[600],
                                            ),
                                          ),
                                        )
                                      : _inventarios.isEmpty
                                          ? Center(
                                              child: Text(
                                                'Nenhum inventário encontrado para esta instituição.',
                                                style: GoogleFonts.inter(
                                                  fontSize: 15,
                                                  color: Colors.grey[600],
                                                ),
                                              ),
                                            )
                                          : ListView.builder(
                                              padding: EdgeInsets.zero,
                                              itemCount: _inventarios.length,
                                              itemBuilder: (context, index) {
                                                final inventario =
                                                    _inventarios[index];
                                                return Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                    bottom: 15,
                                                  ),
                                                  child: _buildInventarioCard(
                                                    inventario: inventario,
                                                    titulo: inventario.nome,
                                                    inicio: _formatarData(
                                                      inventario.dataInicio,
                                                    ),
                                                    fim: _formatarData(
                                                      inventario.dataFim,
                                                    ),
                                                  ),
                                                );
                                              },
                                            ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const NavBarWidget(selectedIndex: 0),
          ],
        ),
      ),
    );
  }

  // Widget auxiliar para construir o card de inventário e manter o build principal limpo
  Widget _buildInventarioCard(
      {required Inventario inventario,
      required String titulo,
      required String inicio,
      required String fim}) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
                DetalhesInventarioView(inventario: inventario),
          ),
        );
      },
      borderRadius: BorderRadius.circular(20),
      child: Container(
        width: 100,
        height: 80,
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              blurRadius: 5,
              color: Colors.black.withOpacity(0.1),
              offset: const Offset(0, 2),
            )
          ],
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 10),
              child: Icon(Icons.edit_calendar_rounded,
                  color: Color(0xFF0055FF), size: 40),
            ),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    titulo,
                    style: GoogleFonts.interTight(
                        fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  Row(
                    children: [
                      Text('Início: $inicio',
                          style: const TextStyle(fontSize: 12)),
                      const Text(' | ', style: TextStyle(fontSize: 12)),
                      Text('Fim: $fim', style: const TextStyle(fontSize: 12)),
                    ],
                  ),
                ],
              ),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 10),
              child: Icon(Icons.arrow_forward_ios,
                  color: Colors.grey, size: 20),
            ),
          ],
        ),
      ),
    );
  }
}
