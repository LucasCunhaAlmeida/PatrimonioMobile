import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
<<<<<<< HEAD
import 'package:patrimonio_mobile/models/instituicao_model.dart';
import 'package:patrimonio_mobile/services/instituicao_service.dart';
import 'package:patrimonio_mobile/views/cadastro_instituicao_view.dart';
import 'package:patrimonio_mobile/views/deletar_instituicao_view.dart';
=======

import '../models/instituicao_model.dart';
import '../services/instituicao_service.dart';
import '../views/cadastro_instituicao_view.dart';
import '../widgets/custom_navbar.dart';
>>>>>>> 169dadfc364fcccc5d2aef6e4bdd2d12d0e77a55

class InstituicaoView extends StatefulWidget {
  const InstituicaoView({super.key});

  @override
  State<InstituicaoView> createState() => _InstituicaoViewState();
}

class _InstituicaoViewState extends State<InstituicaoView> {
<<<<<<< HEAD
  final _instituicaoService = InstituicaoService();

  List<Instituicao> _instituicoes = [];
  bool _loading = true;
=======
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  final InstituicaoService _instituicaoService = InstituicaoService();

  List<Instituicao> _instituicoes = [];
  bool _carregando = true;
>>>>>>> 169dadfc364fcccc5d2aef6e4bdd2d12d0e77a55

  @override
  void initState() {
    super.initState();
<<<<<<< HEAD
    _loadInstituicoes();
=======
    _carregarInstituicoes();
>>>>>>> 169dadfc364fcccc5d2aef6e4bdd2d12d0e77a55
  }

  @override
  void dispose() {
    super.dispose();
  }

<<<<<<< HEAD
  Future<void> _loadInstituicoes() async {
    setState(() => _loading = true);

    final instituicoes = await _instituicaoService.queryAllInstituicoes();

    setState(() {
      _instituicoes = instituicoes;
      _loading = false;
    });
  }

  Future<void> _abrirCadastroInstituicao() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const CadastroInstituicaoView(),
      ),
    );

    await _loadInstituicoes();
  }

  Future<void> _abrirExclusaoInstituicao(Instituicao instituicao) async {
    final excluiu = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) => DeletarInstituicaoView(
          instituicao: instituicao,
        ),
      ),
    );

    if (excluiu == true) {
      await _loadInstituicoes();
    }
  }

  Widget _buildInstituicaoItem(Instituicao instituicao) {
    return InkWell(
      onTap: () => _abrirExclusaoInstituicao(instituicao),
      borderRadius: BorderRadius.circular(14),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 6,
              offset: const Offset(0, 2),
            )
          ],
        ),
        child: Row(
          children: [
            Text(
              '${instituicao.id}',
              style: const TextStyle(
                fontSize: 16,
                color: Colors.black54,
              ),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Text(
                instituicao.nome,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios,
              size: 18,
              color: Color(0xFF57636C),
            ),
          ],
        ),
      ),
    );
=======
  Future<void> _carregarInstituicoes() async {
    setState(() => _carregando = true);

    try {
      final instituicoes = await _instituicaoService.queryAllInstituicoes();
      if (!mounted) return;

      setState(() {
        _instituicoes = instituicoes;
        _carregando = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _carregando = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao carregar instituições: $e')),
      );
    }
  }

  Future<void> _removerInstituicao(int id) async {
    try {
      await _instituicaoService.deleteInstituicao(id);
      await _carregarInstituicoes();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao remover instituição: $e')),
      );
    }
>>>>>>> 169dadfc364fcccc5d2aef6e4bdd2d12d0e77a55
  }

  @override
  Widget build(BuildContext context) {
<<<<<<< HEAD
    return Scaffold(
      backgroundColor: const Color(0xFFF1F4F8),
      appBar: AppBar(
        backgroundColor: const Color(0xFFEFF0F6),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF57636C)),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Instituições',
          style: GoogleFonts.inter(
            fontWeight: FontWeight.w600,
            color: const Color(0xFF57636C),
          ),
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _instituicoes.isEmpty
              ? const Center(
                  child: Text('Nenhuma instituição cadastrada.'),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _instituicoes.length,
                  itemBuilder: (context, index) {
                    final instituicao = _instituicoes[index];
                    return _buildInstituicaoItem(instituicao);
                  },
                ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _abrirCadastroInstituicao,
        backgroundColor: const Color(0xFF0055FF),
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text(
          'Adicionar',
          style: TextStyle(color: Colors.white),
=======
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: Scaffold(
        key: scaffoldKey,
        backgroundColor: const Color(0xFFF1F4F8),
        body: Column(
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: Column(
                children: [
                  Container(
                    width: double.infinity,
                    height: 130,
                    decoration: const BoxDecoration(
                      color: Color(0xFFEFF0F6),
                    ),
                    child: Padding(
                      padding:
                          const EdgeInsetsDirectional.fromSTEB(20, 40, 20, 20),
                      child: Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.arrow_back,
                                size: 40, color: Color(0xFF57636C)),
                            onPressed: () => Navigator.pop(context),
                          ),
                          const SizedBox(width: 10),
                          Text(
                            'Instituições',
                            style: GoogleFonts.inter(
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF57636C),
                            ),
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
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Lista de instituições',
                              style: GoogleFonts.interTight(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFF57636C),
                              ),
                            ),
                            const SizedBox(height: 10),
                            Expanded(
                              child: _carregando
                                  ? const Center(
                                      child: CircularProgressIndicator())
                                  : _instituicoes.isEmpty
                                      ? Center(
                                          child: Text(
                                            'Nenhuma instituição cadastrada.',
                                            style: GoogleFonts.inter(
                                              fontSize: 15,
                                              color: const Color(0xFF57636C),
                                            ),
                                          ),
                                        )
                                      : ListView.separated(
                                          itemCount: _instituicoes.length,
                                          separatorBuilder: (_, __) =>
                                              const SizedBox(height: 10),
                                          itemBuilder: (context, index) {
                                            final instituicao =
                                                _instituicoes[index];
                                            return _buildInstituicaoItem(
                                              instituicao: instituicao,
                                              posicao: index + 1,
                                            );
                                          },
                                        ),
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton.icon(
                              onPressed: () async {
                                await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        const CadastroInstituicaoView(),
                                  ),
                                );
                                await _carregarInstituicoes();
                              },
                              icon: const Icon(Icons.add, color: Colors.white),
                              label: Text(
                                'Cadastrar instituição',
                                style: GoogleFonts.interTight(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF0055FF),
                                minimumSize: const Size(double.infinity, 50),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12)),
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
            const NavBarWidget(),
          ],
>>>>>>> 169dadfc364fcccc5d2aef6e4bdd2d12d0e77a55
        ),
      ),
    );
  }
<<<<<<< HEAD
=======

  Widget _buildInstituicaoItem(
      {required Instituicao instituicao, required int posicao}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
              blurRadius: 3,
              color: Colors.black.withOpacity(0.1),
              offset: const Offset(0, 2)),
        ],
      ),
      child: Row(
        children: [
          Text(
            posicao.toString(),
            style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Text(
              instituicao.nome,
              style: GoogleFonts.inter(fontSize: 16),
            ),
          ),
          IconButton(
            icon:
                const Icon(Icons.cancel_outlined, color: Colors.red, size: 24),
            onPressed: instituicao.id == null
                ? null
                : () => _removerInstituicao(instituicao.id!),
          ),
        ],
      ),
    );
  }
>>>>>>> 169dadfc364fcccc5d2aef6e4bdd2d12d0e77a55
}
