import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:patrimonio_mobile/views/cadastro_inventario_view.dart';
import 'package:patrimonio_mobile/views/setor_view.dart';
import '/widgets/custom_navbar.dart';

class CadastroView extends StatefulWidget {
  const CadastroView({super.key});

  @override
  State<CadastroView> createState() => _CadastroViewState();
}

class _CadastroViewState extends State<CadastroView> {
  final scaffoldKey = GlobalKey<ScaffoldState>();

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
                mainAxisSize: MainAxisSize.max,
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
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          Text(
                            'Escolha o que deseja cadastrar',
                            textAlign: TextAlign.start,
                            style: GoogleFonts.interTight(
                              fontSize: 18,
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
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: SingleChildScrollView(
                          child: Column(
                            mainAxisSize: MainAxisSize.max,
                            children: [
                              const SizedBox(height: 20),
                              _buildOptionCard(
                                icon: Icons.foundation,
                                title: 'Instituição',
                                onTap: () => print('Cadastrar Instituição'),
                              ),
                              const SizedBox(height: 20),
                              _buildOptionCard(
                                icon: Icons.store,
                                title: 'Setor',
                                onTap: () {
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              const SetorView(),
                                        ));
                                  },    
                              ),
                              const SizedBox(height: 20),
                              _buildOptionCard(
                                  icon: Icons.inventory_sharp,
                                  title: 'Inventário',
                                  onTap: () {
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              const CadastrarInventarioPage(),
                                        ));
                                  }),
                              const SizedBox(height: 20),
                            ],
                          ),
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

  // Widget auxiliar para os cards de seleção
  Widget _buildOptionCard(
      {required IconData icon,
      required String title,
      required VoidCallback onTap}) {
    return Container(
      width: double.infinity,
      height: 70,
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            blurRadius: 5,
            color: Colors.black.withOpacity(0.1),
            offset: const Offset(0, 2),
          )
        ],
        borderRadius: BorderRadius.circular(20),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Row(
            mainAxisSize: MainAxisSize.max,
            children: [
              Icon(
                icon,
                color: const Color(0xFF0055FF),
                size: 40,
              ),
              const SizedBox(width: 15),
              Expanded(
                child: Text(
                  title,
                  style: GoogleFonts.interTight(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF57636C),
                  ),
                ),
              ),
              const Icon(
                Icons.arrow_forward_ios,
                color: Color(0xFF57636C),
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
