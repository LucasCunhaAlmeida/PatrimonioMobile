import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:patrimonio_mobile/models/instituicao_model.dart';
import 'package:patrimonio_mobile/models/setor_model.dart';
import 'package:patrimonio_mobile/services/instituicao_service.dart';
import 'package:patrimonio_mobile/services/setor_service.dart';
import 'package:patrimonio_mobile/views/cadastro_setor_view.dart';
import 'package:patrimonio_mobile/widgets/custom_navbar.dart';

class SetorView extends StatefulWidget {
  const SetorView({super.key});

  @override
  State<SetorView> createState() => _SetorViewState();
}

class _SetorViewState extends State<SetorView> {
  final _setorService = SetorService();
  final _instituicaoService = InstituicaoService();

  List<Setor> _setores = [];
  List<Instituicao> _instituicoes = [];
  int? _instituicaoSelecionadaId;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _loading = true);

    final instituicoes = await _instituicaoService.queryAllInstituicoes();
    final setores = await _setorService.queryAllSetores();

    if (!mounted) return;
    setState(() {
      _instituicoes = instituicoes;
      _setores = setores;

      if (_instituicoes.isNotEmpty && _instituicaoSelecionadaId == null) {
        _instituicaoSelecionadaId = _instituicoes.first.id;
      }

      _loading = false;
    });
  }

  List<Setor> get _filteredSetores {
    if (_instituicaoSelecionadaId == null) return _setores;

    return _setores
        .where((s) => s.idInstituicao == _instituicaoSelecionadaId)
        .toList();
  }

  Future<void> _deleteSetor(int id) async {
    await _setorService.deleteSetor(id);
    await _loadData();
  }

  Future<void> _showDeleteDialog(Setor setor) async {
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
                  'Excluir setor?',
                  style: GoogleFonts.interTight(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.red,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 14),
                Text(
                  'Tem certeza que deseja excluir o setor "${setor.nome}"?',
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
      await _deleteSetor(setor.id!);
    }
  }

  Future<void> _showEditDialog(Setor setor) async {
    final nomeController = TextEditingController(text: setor.nome);
    int? selectedInstituicao = setor.idInstituicao;

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
                    'Editar setor',
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
                    decoration: InputDecoration(
                      labelText: 'Nome do setor',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<int>(
                    initialValue: selectedInstituicao,
                    decoration: InputDecoration(
                      labelText: 'Instituição',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    items: _instituicoes
                        .map((inst) => DropdownMenuItem(
                              value: inst.id,
                              child: Text(inst.nome),
                            ))
                        .toList(),
                    onChanged: (value) => selectedInstituicao = value,
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
                            if (nomeController.text.trim().isEmpty ||
                                selectedInstituicao == null) {
                              return;
                            }

                            await _setorService.updateSetor(
                              Setor(
                                id: setor.id,
                                nome: nomeController.text.trim(),
                                idInstituicao: selectedInstituicao!,
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
      await _loadData();
    }
  }

  Widget _buildSetorItem(Setor setor) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Row(
        children: [
          const SizedBox(width: 24),
          Expanded(
            child: Text(
              setor.nome,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.edit, color: Color(0xFF0055FF), size: 32),
            onPressed: () => _showEditDialog(setor),
          ),
          const SizedBox(width: 8),
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.red, size: 32),
            onPressed: () => _showDeleteDialog(setor),
          ),
        ],
      ),
    );
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
          'Setores',
          style: GoogleFonts.inter(
            fontWeight: FontWeight.w600,
            color: const Color(0xFF57636C),
          ),
        ),
      ),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            color: Colors.white,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Instituição',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<int>(
                  initialValue: _instituicaoSelecionadaId,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                  ),
                  items: _instituicoes
                      .map((inst) => DropdownMenuItem(
                            value: inst.id,
                            child: Text(inst.nome),
                          ))
                      .toList(),
                  onChanged: (val) {
                    setState(() {
                      _instituicaoSelecionadaId = val;
                    });
                  },
                ),
              ],
            ),
          ),
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : _filteredSetores.isEmpty
                    ? const Center(
                        child: Text(
                          'Nenhum setor cadastrado para esta instituição.',
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _filteredSetores.length,
                        itemBuilder: (context, index) {
                          final setor = _filteredSetores[index];
                          return _buildSetorItem(setor);
                        },
                      ),
          ),
        ],
      ),
      bottomNavigationBar: const NavBarWidget(selectedIndex: 1),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const CadastrarSetorPage(),
            ),
          );
          await _loadData();
        },
        backgroundColor: const Color(0xFF0055FF),
        child: const Icon(
          Icons.add,
          color: Colors.white,
        ),
      ),
    );
  }
}
