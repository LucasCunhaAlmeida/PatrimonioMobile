import 'package:flutter/material.dart';
import 'package:patrimonio_mobile/models/instituicao_model.dart';
import 'package:patrimonio_mobile/models/inventario_model.dart';
import 'package:patrimonio_mobile/services/instituicao_service.dart';
import 'package:patrimonio_mobile/services/inventario_service.dart';

class InventarioView extends StatefulWidget {
  const InventarioView({super.key});

  @override
  State<InventarioView> createState() => _InventarioViewState();
}

class _InventarioViewState extends State<InventarioView> {
  final InstituicaoService _instituicaoService = InstituicaoService();
  final InventarioService _inventarioService = InventarioService();

  List<Instituicao> _instituicoes = [];
  List<Inventario> _inventarios = [];
  Instituicao? _instituicaoSelecionada;
  bool _carregando = true;
  int _indiceNavegacao = 0;

  @override
  void initState() {
    super.initState();
    _carregarDadosIniciais();
  }

  Future<void> _carregarDadosIniciais() async {
    setState(() => _carregando = true);

    final instituicoes = await _instituicaoService.queryAllInstituicoes();

    Instituicao? instituicaoSelecionada;
    List<Inventario> inventarios;

    if (instituicoes.isNotEmpty) {
      instituicaoSelecionada = instituicoes.first;
      inventarios = await _inventarioService
          .queryInventariosByInstituicao(instituicaoSelecionada.id!);
    } else {
      inventarios = [];
    }

    if (!mounted) return;

    setState(() {
      _instituicoes = instituicoes;
      _instituicaoSelecionada = instituicaoSelecionada;
      _inventarios = inventarios;
      _carregando = false;
    });
  }

  Future<void> _trocarInstituicao(Instituicao? instituicao) async {
    if (instituicao == null) return;

    setState(() {
      _instituicaoSelecionada = instituicao;
      _carregando = true;
    });

    final inventarios =
        await _inventarioService.queryInventariosByInstituicao(instituicao.id!);

    if (!mounted) return;

    setState(() {
      _inventarios = inventarios;
      _carregando = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFECECEF),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _carregarDadosIniciais,
          child: LayoutBuilder(
            builder: (context, constraints) {
              final horizontal = constraints.maxWidth >= 700 ? 40.0 : 16.0;

              return ListView(
                padding: EdgeInsets.fromLTRB(horizontal, 20, horizontal, 24),
                children: [
                  _buildDestaqueInstituicao(),
                  const SizedBox(height: 20),
                  _buildCardCabecalho(),
                ],
              );
            },
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _indiceNavegacao,
        onTap: _aoSelecionarAba,
        items: const [
          BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined), label: 'Inicio'),
          BottomNavigationBarItem(icon: Icon(Icons.add), label: 'Cadastrar'),
          BottomNavigationBarItem(icon: Icon(Icons.menu), label: 'Mais'),
        ],
      ),
    );
  }

  Widget _buildDestaqueInstituicao() {
    final nome = _instituicaoSelecionada?.nome;

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 250),
      child: Container(
        key: ValueKey(nome),
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF23467E), Color(0xFF4A78C4)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF23467E).withValues(alpha: 0.25),
              blurRadius: 16,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          children: [
            const Icon(Icons.apartment_rounded, color: Colors.white, size: 34),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Instituicao selecionada',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    nome ?? 'Nenhuma instituicao',
                    maxLines: 2,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCardCabecalho() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFFE3E3E5),
        borderRadius: BorderRadius.circular(36),
      ),
      padding: const EdgeInsets.fromLTRB(12, 22, 12, 14),
      child: Column(
        children: [
          const Text(
            'Inventarios',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Color(0xFF596670),
            ),
          ),
          const SizedBox(height: 16),
          _buildDropdownInstituicoes(),
          const SizedBox(height: 12),
          if (_carregando)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 18),
              child: Center(child: CircularProgressIndicator()),
            )
          else if (_inventarios.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 24),
              child: Text(
                'Nenhum inventario encontrado para essa instituicao.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 15, color: Color(0xFF66717A)),
              ),
            )
          else
            ..._inventarios.map(_buildInventarioTile),
        ],
      ),
    );
  }

  Widget _buildDropdownInstituicoes() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFC9CFD5)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<Instituicao>(
          value: _instituicaoSelecionada,
          isExpanded: true,
          icon: const Icon(Icons.keyboard_arrow_down_rounded),
          hint: const Text('Selecione a instituicao'),
          items: _instituicoes
              .map(
                (instituicao) => DropdownMenuItem<Instituicao>(
                  value: instituicao,
                  child: Text(instituicao.nome),
                ),
              )
              .toList(),
          onChanged: _instituicoes.isEmpty ? null : _trocarInstituicao,
        ),
      ),
    );
  }

  Widget _buildInventarioTile(Inventario inventario) {
    return Container(
      margin: const EdgeInsets.only(top: 10),
      child: Card(
        elevation: 4,
        shadowColor: Colors.black45,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(26)),
        child: ListTile(
          onTap: () =>
              _mostrarMensagem('Inventario selecionado: ${inventario.nome}'),
          leading: const Icon(Icons.edit_calendar,
              size: 40, color: Color(0xFF23467E)),
          title: Text(
            inventario.nome,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
          ),
          subtitle: Text(
            'Inicio: ${inventario.dataInicio} | Fim: ${inventario.dataFim}',
            style: const TextStyle(fontSize: 16, color: Color(0xFF333A41)),
          ),
          trailing: const Icon(Icons.arrow_forward_ios, size: 26),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        ),
      ),
    );
  }

  void _aoSelecionarAba(int indice) {
    setState(() {
      _indiceNavegacao = indice;
    });

    if (indice == 1) {
      _mostrarMensagem('Tela de cadastro ainda sera integrada.');
    } else if (indice == 2) {
      _mostrarMensagem('Menu adicional ainda sera integrado.');
    }
  }

  void _mostrarMensagem(String mensagem) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(mensagem)));
  }
}
