import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:patrimonio_mobile/models/instituicao_model.dart';
import 'package:patrimonio_mobile/services/instituicao_service.dart';
import 'package:patrimonio_mobile/widgets/custom_navbar.dart';

class CadastroInstituicaoView extends StatefulWidget {
  const CadastroInstituicaoView({super.key});

  @override
  State<CadastroInstituicaoView> createState() =>
      _CadastroInstituicaoViewState();
}

class _CadastroInstituicaoViewState extends State<CadastroInstituicaoView> {
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  final InstituicaoService _instituicaoService = InstituicaoService();
  late final TextEditingController _textController;
  late final FocusNode _textFieldFocusNode;

  List<Instituicao> _instituicoes = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _textController = TextEditingController();
    _textFieldFocusNode = FocusNode();
    _carregarInstituicoes();
  }

  @override
  void dispose() {
    _textController.dispose();
    _textFieldFocusNode.dispose();
    super.dispose();
  }

  Future<void> _carregarInstituicoes() async {
    setState(() => _isLoading = true);

    try {
      final instituicoes = await _instituicaoService.queryAllInstituicoes();
      if (!mounted) return;

      setState(() {
        _instituicoes = instituicoes;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao carregar instituições: $e')),
      );
    }
  }

  Future<void> _adicionarInstituicao() async {
    final nome = _textController.text.trim();

    if (nome.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Digite o nome da instituição.')),
      );
      return;
    }

    try {
      await _instituicaoService.insertInstituicao(Instituicao(nome: nome));
      if (!mounted) return;

      _textController.clear();
      _textFieldFocusNode.unfocus();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Instituição cadastrada com sucesso.')),
      );
      await _carregarInstituicoes();
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao adicionar instituição: $e')),
      );
    }
  }

  Future<void> _removerInstituicao(int id) async {
    try {
      await _instituicaoService.deleteInstituicao(id);
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Instituição excluída com sucesso.')),
      );
      await _carregarInstituicoes();
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao remover instituição: $e')),
      );
    }
  }

  Future<void> _confirmarExclusaoInstituicao({
    required int id,
    required String nome,
  }) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Excluir instituição'),
          content: Text('Deseja realmente excluir a instituição "$nome"?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFE53935),
              ),
              child: const Text(
                'Excluir',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );

    if (confirmar == true) {
      await _removerInstituicao(id);
    }
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
                            icon: const Icon(
                              Icons.arrow_back,
                              size: 40,
                              color: Color(0xFF57636C),
                            ),
                            onPressed: () => Navigator.pop(context),
                          ),
                          const SizedBox(width: 10),
                          Text(
                            'Cadastrar instituição',
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
                              'Nova instituição',
                              style: GoogleFonts.interTight(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFF57636C),
                              ),
                            ),
                            const SizedBox(height: 12),
                            Expanded(
                              child: _isLoading
                                  ? const Center(
                                      child: CircularProgressIndicator(),
                                    )
                                  : _instituicoes.isEmpty
                                      ? Center(
                                          child: Text(
                                            'Nenhuma instituição cadastrada.',
                                            style: GoogleFonts.inter(
                                              fontSize: 16,
                                            ),
                                          ),
                                        )
                                      : ListView.separated(
                                          padding:
                                              const EdgeInsets.only(bottom: 12),
                                          itemCount: _instituicoes.length,
                                          separatorBuilder: (_, __) =>
                                              const SizedBox(height: 10),
                                          itemBuilder: (context, index) {
                                            final instituicao =
                                                _instituicoes[index];
                                            return _buildInstituicaoItem(
                                              posicao: (index + 1).toString(),
                                              nome: instituicao.nome,
                                              onRemover: instituicao.id == null
                                                  ? null
                                                  : () =>
                                                      _confirmarExclusaoInstituicao(
                                                        id: instituicao.id!,
                                                        nome: instituicao.nome,
                                                      ),
                                            );
                                          },
                                        ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              child: TextFormField(
                                controller: _textController,
                                focusNode: _textFieldFocusNode,
                                textInputAction: TextInputAction.done,
                                onFieldSubmitted: (_) =>
                                    _adicionarInstituicao(),
                                decoration: InputDecoration(
                                  filled: true,
                                  fillColor: const Color(0xFFEFF0F6),
                                  hintText: 'Nome da Instituição',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(16),
                                    borderSide: BorderSide.none,
                                  ),
                                ),
                                style: GoogleFonts.inter(fontSize: 18),
                              ),
                            ),
                            ElevatedButton(
                              onPressed: _adicionarInstituicao,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF0055FF),
                                minimumSize: const Size(double.infinity, 50),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: Text(
                                'Adicionar Instituição',
                                style: GoogleFonts.interTight(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const NavBarWidget(selectedIndex: 1),
          ],
        ),
      ),
    );
  }

  Widget _buildInstituicaoItem({
    required String posicao,
    required String nome,
    required VoidCallback? onRemover,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            blurRadius: 3,
            color: Colors.black.withOpacity(0.1),
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Row(
              children: [
                Text(
                  posicao,
                  style: GoogleFonts.inter(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: Text(
                    nome,
                    style: GoogleFonts.inter(fontSize: 16),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(
              Icons.cancel_outlined,
              color: Colors.red,
              size: 24,
            ),
            onPressed: onRemover,
          ),
        ],
      ),
    );
  }
}
