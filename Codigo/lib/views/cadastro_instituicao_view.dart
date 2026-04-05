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
  final scaffoldKey = GlobalKey<ScaffoldState>();
  final _instituicaoService = InstituicaoService();

  final _nomeInstituicaoController = TextEditingController();

  @override
  void dispose() {
    _nomeInstituicaoController.dispose();
    super.dispose();
  }

  Future<void> _salvarInstituicao() async {
    if (_nomeInstituicaoController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Preencha o nome da instituição')),
      );
      return;
    }

    final novaInstituicao = Instituicao(
      nome: _nomeInstituicaoController.text.trim(),
    );

    await _instituicaoService.insertInstituicao(novaInstituicao);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Instituição cadastrada com sucesso')),
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
                    'Cadastrar Instituição',
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
                child: ListView(
                  children: [
                    Text(
                      'Nome da Instituição',
                      style: GoogleFonts.inter(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF57636C),
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _nomeInstituicaoController,
                      decoration:
                          _inputDecoration('Ex: Departamento de Português'),
                    ),
                    const SizedBox(height: 30),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _salvarInstituicao,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF0055FF),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          padding:
                              const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: const Text(
                          'Salvar Instituição',
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
