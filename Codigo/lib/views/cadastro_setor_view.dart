import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:patrimonio_mobile/models/instituicao_model.dart';
import 'package:patrimonio_mobile/models/setor_model.dart';
import 'package:patrimonio_mobile/services/instituicao_service.dart';
import 'package:patrimonio_mobile/services/setor_service.dart';
import 'package:patrimonio_mobile/widgets/custom_navbar.dart';

class CadastrarSetorPage extends StatefulWidget {
  const CadastrarSetorPage({super.key});

  @override
  State<CadastrarSetorPage> createState() => _CadastrarSetorPageState();
}

class _CadastrarSetorPageState extends State<CadastrarSetorPage> {
  final scaffoldKey = GlobalKey<ScaffoldState>();
  final _setorService = SetorService();
  final _instituicaoService = InstituicaoService();

  final _nomeSetorController = TextEditingController();
  int? _instituicaoSelecionadaId;

  List<Instituicao> _instituicoes = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadInstituicoes();
  }

  @override
  void dispose() {
    _nomeSetorController.dispose();
    super.dispose();
  }

  Future<void> _loadInstituicoes() async {
    setState(() => _loading = true);

    final instituicoes = await _instituicaoService.queryAllInstituicoes();

    setState(() {
      _instituicoes = instituicoes;

      if (_instituicoes.isNotEmpty) {
        _instituicaoSelecionadaId ??= _instituicoes.first.id;
      }

      _loading = false;
    });
  }

  Future<void> _salvarSetor() async {
    if (_instituicaoSelecionadaId == null ||
        _nomeSetorController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Preencha os campos obrigatórios')),
      );
      return;
    }

    final novoSetor = Setor(
      nome: _nomeSetorController.text.trim(),
      idInstituicao: _instituicaoSelecionadaId!,
    );

    await _setorService.insertSetor(novoSetor);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Setor cadastrado com sucesso')),
      );

      Navigator.pop(context);
    }
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
                    icon: const Icon(Icons.arrow_back,
                        color: Color(0xFF57636C)),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    'Cadastrar Setor',
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
                            'Instituição',
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
                            'Nome do Setor',
                            style: GoogleFonts.inter(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF57636C),
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: _nomeSetorController,
                            decoration:
                                _inputDecoration('Ex: Laborátorio de educação'),
                          ),
                          const SizedBox(height: 30),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: _salvarSetor,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF0055FF),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                padding:
                                    const EdgeInsets.symmetric(vertical: 16),
                              ),
                              child: const Text(
                                'Salvar Setor',
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

