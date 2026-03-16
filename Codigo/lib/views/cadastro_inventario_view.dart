import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../widgets/custom_navbar.dart'; 

class CadastrarInventarioPage extends StatefulWidget {
  const CadastrarInventarioPage({super.key});

  @override
  State<CadastrarInventarioPage> createState() => _CadastrarInventarioPageState();
}

class _CadastrarInventarioPageState extends State<CadastrarInventarioPage> {
  final scaffoldKey = GlobalKey<ScaffoldState>();
  
  final _nomeInventarioController = TextEditingController();
  String? _instituicaoSelecionada;
  DateTime? _dataInicio;
  DateTime? _dataFim;

  final List<String> _instituicoes = ['Instituição A', 'Instituição B', 'Instituição C'];

  @override
  void dispose() {
    _nomeInventarioController.dispose();
    super.dispose();
  }

  Future<void> _selecionarData(BuildContext context, bool isInicio) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2025),
      lastDate: DateTime(2030),
    );
    if (picked != null) {
      setState(() {
        if (isInicio) _dataInicio = picked;
        else _dataFim = picked;
      });
    }
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
              height: 130,
              color: const Color(0xFFEFF0F6),
              padding: const EdgeInsets.only(top: 40, left: 20, right: 20),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, size: 30, color: Color(0xFF57636C)),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const SizedBox(width: 10),
                  Text('Cadastrar Inventário', style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.w600)),
                ],
              ),
            ),

            Expanded(
              child: Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(topLeft: Radius.circular(30), topRight: Radius.circular(30)),
                ),
                padding: const EdgeInsets.all(20),
                child: ListView(
                  children: [
                    const Text('Instituição', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    DropdownButtonFormField<String>(
                      initialValue: _instituicaoSelecionada,
                      decoration: const InputDecoration(hintText: 'Selecione a instituição'),
                      items: _instituicoes.map((inst) => DropdownMenuItem(value: inst, child: Text(inst))).toList(),
                      onChanged: (val) => setState(() => _instituicaoSelecionada = val),
                      validator: (value) => value == null ? 'Por favor, selecione uma instituição' : null,
                    ),

                    const SizedBox(height: 20),
                    const Text('Nome do Inventário', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    TextFormField(
                      controller: _nomeInventarioController,
                      decoration: const InputDecoration(hintText: 'Ex: Inventário Anual 2026'),
                    ),

                    const SizedBox(height: 20),

                    Row(
                      children: [
                        Expanded(
                          child: InkWell(
                            onTap: () => _selecionarData(context, true),
                            child: InputDecorator(
                              decoration: const InputDecoration(labelText: 'Data Início'),
                              child: Text(_dataInicio == null ? 'Selecione' : DateFormat('dd/MM/yyyy').format(_dataInicio!)),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: InkWell(
                            onTap: () => _selecionarData(context, false),
                            child: InputDecorator(
                              decoration: const InputDecoration(labelText: 'Data Fim'),
                              child: Text(_dataFim == null ? 'Selecione' : DateFormat('dd/MM/yyyy').format(_dataFim!)),
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 30),

                    ElevatedButton(
                      onPressed: () {
                        if (_instituicaoSelecionada != null && _nomeInventarioController.text.isNotEmpty) {
                          print('Salvo: ${_nomeInventarioController.text} para ${_instituicaoSelecionada}');
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Preencha os campos obrigatórios')));
                        }
                      },
                      style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0055FF)),
                      child: const Text('Salvar Inventário', style: TextStyle(color: Colors.white)),
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