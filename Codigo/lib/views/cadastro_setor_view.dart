import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '/widgets/custom_navbar.dart';

class CadastroSetorView extends StatefulWidget {
  const CadastroSetorView({super.key});

  @override
  State<CadastroSetorView> createState() => _CadastroSetorViewState();
}

class _CadastroSetorViewState extends State<CadastroSetorView> {
  late TextEditingController _setorController;
  late FocusNode _setorFocusNode;
  String? instituicaoSelecionada;
  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _setorController =
        TextEditingController(text: 'Digite o nome do novo setor');
    _setorFocusNode = FocusNode();
  }

  @override
  void dispose() {
    _setorController.dispose();
    _setorFocusNode.dispose();
    super.dispose();
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
                            icon: const Icon(Icons.arrow_back,
                                size: 40, color: Color(0xFF57636C)),
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
                              'Instituição',
                              style: GoogleFonts.interTight(
                                fontSize: 20,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFF57636C),
                              ),
                            ),
                            DropdownButtonFormField<String>(
                              value: instituicaoSelecionada,
                              decoration: InputDecoration(
                                filled: true,
                                fillColor: Colors.white,
                                contentPadding:
                                    const EdgeInsets.symmetric(horizontal: 12),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: const BorderSide(
                                      color: Color(0x9A57636C)),
                                ),
                              ),
                              hint:
                                  const Text('Departamento de sistemas de...'),
                              items: ['Opção 1', 'Opção 2', 'Opção 3']
                                  .map((val) => DropdownMenuItem(
                                      value: val, child: Text(val)))
                                  .toList(),
                              onChanged: (val) =>
                                  setState(() => instituicaoSelecionada = val),
                            ),
                            const SizedBox(height: 20),
                            Text(
                              'Setores',
                              style: GoogleFonts.interTight(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFF57636C),
                              ),
                            ),
                            Expanded(
                              child: ListView(
                                padding: const EdgeInsets.only(top: 10),
                                children: [
                                  _buildSetorItem('1', 'Laboratório 1'),
                                  const SizedBox(height: 10),
                                ],
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 20),
                              child: TextFormField(
                                controller: _setorController,
                                focusNode: _setorFocusNode,
                                decoration: InputDecoration(
                                  filled: true,
                                  fillColor: const Color(0xFFEFF0F6),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(16),
                                    borderSide: BorderSide.none,
                                  ),
                                ),
                                style: GoogleFonts.inter(fontSize: 18),
                              ),
                            ),
                            ElevatedButton(
                              onPressed: () => print('Adicionar setor'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF0055FF),
                                minimumSize: const Size(double.infinity, 50),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12)),
                              ),
                              child: Text(
                                'Adicionar setor',
                                style: GoogleFonts.interTight(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                            ),
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

  Widget _buildSetorItem(String id, String nome) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
              blurRadius: 3,
              color: Colors.black.withOpacity(0.1),
              offset: const Offset(0, 2))
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Text(id,
                  style: GoogleFonts.inter(
                      fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(width: 15),
              Text(nome, style: GoogleFonts.inter(fontSize: 18)),
            ],
          ),
          IconButton(
            icon:
                const Icon(Icons.cancel_outlined, color: Colors.red, size: 24),
            onPressed: () => print('Remover setor'),
          ),
        ],
      ),
    );
  }
}
