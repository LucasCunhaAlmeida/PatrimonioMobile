import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:patrimonio_mobile/models/instituicao_model.dart';
import 'package:patrimonio_mobile/models/inventario_model.dart';
import 'package:patrimonio_mobile/services/instituicao_service.dart';
import 'package:patrimonio_mobile/services/inventario_service.dart';
import 'package:patrimonio_mobile/views/cadastro_inventario_view.dart';
import 'package:patrimonio_mobile/widgets/custom_navbar.dart';

class InventarioView extends StatefulWidget {
  const InventarioView({super.key});

  @override
  State<InventarioView> createState() => _InventarioViewState();
}

class _InventarioViewState extends State<InventarioView> {
  final _inventarioService = InventarioService();
  final _instituicaoService = InstituicaoService();

  List<Inventario> _inventarios = [];
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
    final inventarios = await _inventarioService.queryAllInventarios();

    if (!mounted)
      return; // Verifica se o widget ainda está na árvore antes de chamar setState(usuário sair da tela antes de carregar os dados)
    setState(() {
      _instituicoes = instituicoes;
      _inventarios = inventarios;

      if (_instituicoes.isNotEmpty && _instituicaoSelecionadaId == null) {
        _instituicaoSelecionadaId = _instituicoes.first.id;
      }

      _loading = false;
    });
  }

  List<Inventario> get _filteredInventarios {
    if (_instituicaoSelecionadaId == null) return _inventarios;

    return _inventarios
        .where((i) => i.idInstituicao == _instituicaoSelecionadaId)
        .toList();
  }

  Future<void> _deleteInventario(int id) async {
    await _inventarioService.deleteInventario(id);
    await _loadData();
  }

  Future<void> _showDeleteDialog(Inventario inventario) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Excluir inventário'),
        content: Text(
          'Tem certeza que deseja excluir o inventário "${inventario.nome}"?',
        ),
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
      await _deleteInventario(inventario.id!);
    }
  }

  Future<void> _showEditDialog(Inventario inventario) async {
    final nomeController = TextEditingController(text: inventario.nome);
    final dataInicioController =
        TextEditingController(text: inventario.dataInicio);
    final dataFimController = TextEditingController(text: inventario.dataFim);
    int? selectedInstituicao = inventario.idInstituicao;

    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Editar inventário'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nomeController,
                decoration:
                    const InputDecoration(labelText: 'Nome do inventário'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: dataInicioController,
                readOnly: true,
                decoration: const InputDecoration(
                  labelText: 'Data inicio',
                  suffixIcon: Icon(Icons.calendar_today),
                ),
                onTap: () async {
                  final DateTime? picked = await showDatePicker(
                    context: context,
                    locale: const Locale('pt', 'BR'),
                    initialDate: DateTime.now(),
                    firstDate: DateTime(2025),
                    lastDate: DateTime(2030),
                  );
                  if (picked != null) {
                    dataInicioController.text =
                        DateFormat('yyyy-MM-dd').format(picked);
                  }
                },
              ),
              const SizedBox(height: 12),
              TextField(
                controller: dataFimController,
                readOnly: true,
                decoration: const InputDecoration(
                  labelText: 'Data fim',
                  suffixIcon: Icon(Icons.calendar_today),
                ),
                onTap: () async {
                  final DateTime? picked = await showDatePicker(
                    context: context,
                    locale: const Locale('pt', 'BR'),
                    initialDate: DateTime.now(),
                    firstDate: DateTime(2025),
                    lastDate: DateTime(2030),
                  );
                  if (picked != null) {
                    dataFimController.text =
                        DateFormat('yyyy-MM-dd').format(picked);
                  }
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<int>(
                initialValue: _instituicoes.any(
                  (inst) => inst.id == selectedInstituicao,
                )
                    ? selectedInstituicao
                    : null,
                decoration: const InputDecoration(labelText: 'Instituição'),
                items: _instituicoes
                    .map(
                      (inst) => DropdownMenuItem(
                        value: inst.id,
                        child: Text(inst.nome),
                      ),
                    )
                    .toList(),
                onChanged: (value) => selectedInstituicao = value,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (nomeController.text.trim().isEmpty ||
                  dataInicioController.text.trim().isEmpty ||
                  dataFimController.text.trim().isEmpty ||
                  selectedInstituicao == null) {
                return;
              }

              await _inventarioService.updateInventario(
                Inventario(
                  id: inventario.id,
                  nome: nomeController.text.trim(),
                  dataInicio: dataInicioController.text.trim(),
                  dataFim: dataFimController.text.trim(),
                  idInstituicao: selectedInstituicao!,
                ),
              );

              if (!context.mounted) return;
              Navigator.pop(context);
              await _loadData();
            },
            child: const Text('Salvar'),
          ),
        ],
      ),
    );
  }

  Widget _buildInventarioItem(Inventario inventario) {
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  inventario.nome,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Inicio: ${inventario.dataInicio} | Fim: ${inventario.dataFim}',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.black54,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.edit, color: Color(0xFF0055FF)),
            onPressed: () => _showEditDialog(inventario),
          ),
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.red),
            onPressed: () => _showDeleteDialog(inventario),
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
          'Inventários',
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
                  'Instituicao',
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
                      .map(
                        (inst) => DropdownMenuItem(
                          value: inst.id,
                          child: Text(inst.nome),
                        ),
                      )
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
                : _filteredInventarios.isEmpty
                    ? const Center(
                        child: Text(
                          'Nenhum inventário cadastrado para esta instituição.',
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _filteredInventarios.length,
                        itemBuilder: (context, index) {
                          final inventario = _filteredInventarios[index];
                          return _buildInventarioItem(inventario);
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
              builder: (context) => const CadastrarInventarioPage(),
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
