import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:patrimonio_mobile/models/instituicao_model.dart';
import 'package:patrimonio_mobile/models/setor_model.dart';
import 'package:patrimonio_mobile/services/instituicao_service.dart';
import 'package:patrimonio_mobile/services/setor_service.dart';
import 'package:patrimonio_mobile/views/cadastro_setor_view.dart';

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
      builder: (context) => AlertDialog(
        title: const Text('Excluir setor'),
        content: Text('Tem certeza que deseja excluir o setor "${setor.nome}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              'Excluir',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await _deleteSetor(setor.id!);
    }
  }

  Future<void> _showEditDialog(Setor setor) async {
    final nomeController = TextEditingController(text: setor.nome);
    int? selectedInstituicao = setor.idInstituicao;

    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Editar setor'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nomeController,
              decoration: const InputDecoration(labelText: 'Nome do setor'),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<int>(
              initialValue: selectedInstituicao,
              decoration: const InputDecoration(labelText: 'Instituição'),
              items: _instituicoes
                  .map((inst) => DropdownMenuItem(
                        value: inst.id,
                        child: Text(inst.nome),
                      ))
                  .toList(),
              onChanged: (value) => selectedInstituicao = value,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
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

              Navigator.pop(context);
              await _loadData();
            },
            child: const Text('Salvar'),
          ),
        ],
      ),
    );
  }

  Widget _buildSetorItem(Setor setor) {
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
          Text(
            '${setor.id}',
            style: const TextStyle(
              fontSize: 16,
              color: Colors.black54,
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Text(
              setor.nome,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.edit, color: Color(0xFF0055FF)),
            onPressed: () => _showEditDialog(setor),
          ),
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.red),
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