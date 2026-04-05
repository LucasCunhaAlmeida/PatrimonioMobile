import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:patrimonio_mobile/models/instituicao_model.dart';
import 'package:patrimonio_mobile/models/inventario_model.dart';
import 'package:patrimonio_mobile/services/instituicao_service.dart';
import 'package:patrimonio_mobile/services/inventario_service.dart';
import 'package:patrimonio_mobile/widgets/custom_navbar.dart';

class CadastrarInventarioPage extends StatefulWidget {
  const CadastrarInventarioPage({super.key});

  @override
  State<CadastrarInventarioPage> createState() =>
      _CadastrarInventarioPageState();
}

class _CadastrarInventarioPageState extends State<CadastrarInventarioPage> {
  final scaffoldKey = GlobalKey<ScaffoldState>();

  final _inventarioService = InventarioService();
  final _instituicaoService = InstituicaoService();
  final _nomeInventarioController = TextEditingController();
  int? _instituicaoSelecionadaId;
  DateTime? _dataInicio;
  DateTime? _dataFim;

  List<Instituicao> _instituicoes = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadInstituicoes();
  }

  @override
  void dispose() {
    _nomeInventarioController.dispose();
    super.dispose();
  }

  Future<void> _loadInstituicoes() async {
    setState(() => _loading = true);

    final instituicoes = await _instituicaoService.queryAllInstituicoes();

    if (!mounted) return;
    setState(() {
      _instituicoes = instituicoes;

      if (_instituicoes.isNotEmpty) {
        _instituicaoSelecionadaId ??= _instituicoes.first.id;
      }

      _loading = false;
    });
  }

  Future<void> _selecionarData(bool isInicio) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      locale: const Locale('pt', 'BR'),
      initialDate: isInicio
          ? (_dataInicio ?? DateTime.now())
          : (_dataFim ?? _dataInicio ?? DateTime.now()),
      firstDate: DateTime(2025),
      lastDate: DateTime(2030),
    );
    if (picked != null) {
      setState(() {
        if (isInicio) {
          _dataInicio = picked;
        } else {
          _dataFim = picked;
        }
      });
    }
  }

  Future<void> _salvarInventario() async {
    if (_instituicaoSelecionadaId == null ||
        _nomeInventarioController.text.trim().isEmpty ||
        _dataInicio == null ||
        _dataFim == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Preencha os campos obrigatórios')),
      );
      return;
    }

    final novoInventario = Inventario(
      nome: _nomeInventarioController.text.trim(),
      dataInicio: DateFormat('yyyy-MM-dd').format(_dataInicio!),
      dataFim: DateFormat('yyyy-MM-dd').format(_dataFim!),
      idInstituicao: _instituicaoSelecionadaId!,
    );

    await _inventarioService.insertInventario(novoInventario);

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Inventário cadastrado com sucesso')),
    );

    Navigator.pop(context);
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFFE0E3E7)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFFE0E3E7)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFF0055FF)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        key: scaffoldKey,
        backgroundColor: const Color(0xFFF1F4F8),
        body: Column(
          children: [
            Container(
              height: 120,
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(20, 50, 20, 20),
              color: const Color(0xFFEFF0F6),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(
                      Icons.arrow_back,
                      color: Color(0xFF57636C),
                    ),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    'Cadastrar Inventario',
                    style: GoogleFonts.inter(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF57636C),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: const BoxDecoration(
                  color: Color(0xFFF1F4F8),
                ),
                child: _loading
                    ? const Center(child: CircularProgressIndicator())
                    : ListView(
                        children: [
                          Text(
                            'Instituicao',
                            style: GoogleFonts.inter(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF57636C),
                            ),
                          ),
                          const SizedBox(height: 8),
                          DropdownButtonFormField<int>(
                            initialValue: _instituicaoSelecionadaId,
                            decoration:
                                _inputDecoration('Selecione a instituição'),
                            items: _instituicoes
                                .map(
                                  (inst) => DropdownMenuItem(
                                    value: inst.id,
                                    child: Text(inst.nome),
                                  ),
                                )
                                .toList(),
                            onChanged: (val) =>
                                setState(() => _instituicaoSelecionadaId = val),
                          ),
                          const SizedBox(height: 20),
                          Text(
                            'Nome do Inventario',
                            style: GoogleFonts.inter(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF57636C),
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: _nomeInventarioController,
                            decoration:
                                _inputDecoration('Ex: Patrimônio anual'),
                          ),
                          const SizedBox(height: 20),
                          Row(
                            children: [
                              Expanded(
                                child: InkWell(
                                  onTap: () => _selecionarData(true),
                                  child: InputDecorator(
                                    decoration:
                                        _inputDecoration('Data de início'),
                                    child: Text(
                                      _dataInicio == null
                                          ? 'Selecione'
                                          : DateFormat('dd/MM/yyyy')
                                              .format(_dataInicio!),
                                      style: GoogleFonts.inter(
                                        color: const Color(0xFF57636C),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: InkWell(
                                  onTap: () => _selecionarData(false),
                                  child: InputDecorator(
                                    decoration: _inputDecoration('Data de fim'),
                                    child: Text(
                                      _dataFim == null
                                          ? 'Selecione'
                                          : DateFormat('dd/MM/yyyy')
                                              .format(_dataFim!),
                                      style: GoogleFonts.inter(
                                        color: const Color(0xFF57636C),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 30),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: _salvarInventario,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF0055FF),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                padding:
                                    const EdgeInsets.symmetric(vertical: 16),
                              ),
                              child: const Text(
                                'Salvar Inventario',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
              ),
            ),
            const NavBarWidget(selectedIndex: 1),
          ],
        ),
      ),
    );
  }
}
