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
                  'Excluir inventário?',
                  style: GoogleFonts.interTight(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.red,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 14),
                Text(
                  'Tem certeza que deseja excluir o inventário "${inventario.nome}"?',
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
      await _deleteInventario(inventario.id!);
    }
  }

  Future<void> _showEditDialog(Inventario inventario) async {
    final nomeController = TextEditingController(text: inventario.nome);
    final dataInicioController =
        TextEditingController(text: inventario.dataInicio);
    final dataFimController = TextEditingController(text: inventario.dataFim);
    int? selectedInstituicao = inventario.idInstituicao;

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
                    'Editar inventário',
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
                      labelText: 'Nome do inventário',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: dataInicioController,
                    readOnly: true,
                    decoration: InputDecoration(
                      labelText: 'Data início',
                      suffixIcon: const Icon(Icons.calendar_today),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
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
                    decoration: InputDecoration(
                      labelText: 'Data fim',
                      suffixIcon: const Icon(Icons.calendar_today),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
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
                    decoration: InputDecoration(
                      labelText: 'Instituição',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
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
