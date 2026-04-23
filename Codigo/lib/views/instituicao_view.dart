import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:patrimonio_mobile/models/instituicao_model.dart';
import 'package:patrimonio_mobile/services/instituicao_service.dart';
import 'package:patrimonio_mobile/views/cadastro_instituicao_view.dart';
import 'package:patrimonio_mobile/widgets/custom_navbar.dart';

class InstituicaoView extends StatefulWidget {
  const InstituicaoView({super.key});

  @override
  State<InstituicaoView> createState() => _InstituicaoViewState();
}

class _InstituicaoViewState extends State<InstituicaoView> {
  final InstituicaoService _instituicaoService = InstituicaoService();

  List<Instituicao> _instituicoes = [];
  bool _carregando = true;

  @override
  void initState() {
    super.initState();
    _carregarInstituicoes();
  }

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

  Future<void> _abrirCadastroInstituicao() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const CadastroInstituicaoView(),
      ),
    );

    if (!mounted) return;
    await _carregarInstituicoes();
  }

  Future<void> _deleteInstituicao(int id) async {
    await _instituicaoService.deleteInstituicao(id);
    await _carregarInstituicoes();
  }

  Future<void> _showDeleteDialog(Instituicao instituicao) async {
    final confirmed = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => Dialog(
        insetPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 24),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 560),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    color: Colors.red.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.delete_outline,
                    color: Colors.red,
                    size: 42,
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  'Excluir instituição?',
                  style: GoogleFonts.interTight(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.red,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 14),
                Text(
                  'Tem certeza que deseja excluir a instituição "${instituicao.nome}"?',
                  style: GoogleFonts.inter(fontSize: 15),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.black87,
                          side: BorderSide(color: Colors.grey.shade400),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        onPressed: () => Navigator.of(dialogContext).pop(false),
                        child: const Text(
                          'Cancelar',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        onPressed: () => Navigator.of(dialogContext).pop(true),
                        child: const Text(
                          'Excluir',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );

    if (confirmed == true) {
      await _deleteInstituicao(instituicao.id!);
    }
  }

  Future<void> _showEditDialog(Instituicao instituicao) async {
    final nomeController = TextEditingController(text: instituicao.nome);

    final updated = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => Dialog(
        insetPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 24),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 560),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      color: Colors.blue.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.edit_rounded,
                      color: Colors.blue,
                      size: 42,
                    ),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    'Editar instituição',
                    style: GoogleFonts.interTight(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: nomeController,
                    textAlign: TextAlign.center,
                    decoration: InputDecoration(
                      labelText: 'Nome da instituição',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.black87,
                            side: BorderSide(color: Colors.grey.shade400),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          onPressed: () =>
                              Navigator.of(dialogContext).pop(false),
                          child: const Text(
                            'Cancelar',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          onPressed: () async {
                            if (nomeController.text.trim().isEmpty) {
                              return;
                            }

                            await _instituicaoService.updateInstituicao(
                              instituicao.id!,
                              Instituicao(
                                id: instituicao.id,
                                nome: nomeController.text.trim(),
                              ),
                            );

                            if (!mounted) return;
                            Navigator.of(dialogContext).pop(true);
                          },
                          child: const Text(
                            'Salvar',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );

    if (updated == true) {
      if (!mounted) return;
      await _carregarInstituicoes();
    }
  }

  @override
  Widget build(BuildContext context) {
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
      body: _carregando
          ? const Center(child: CircularProgressIndicator())
          : _instituicoes.isEmpty
              ? const Center(
                  child: Text('Nenhuma instituição cadastrada.'),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _instituicoes.length,
                  itemBuilder: (context, index) {
                    return _buildInstituicaoItem(_instituicoes[index]);
                  },
                ),
      bottomNavigationBar: const NavBarWidget(selectedIndex: 1),
      floatingActionButton: FloatingActionButton(
        onPressed: _abrirCadastroInstituicao,
        backgroundColor: const Color(0xFF0055FF),
        child: const Icon(
          Icons.add,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _buildInstituicaoItem(Instituicao instituicao) {
    return Container(
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
          IconButton(
            icon: const Icon(Icons.edit, color: Color(0xFF0055FF)),
            onPressed: () => _showEditDialog(instituicao),
          ),
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.red),
            onPressed: () => _showDeleteDialog(instituicao),
          ),
        ],
      ),
    );
  }
}
