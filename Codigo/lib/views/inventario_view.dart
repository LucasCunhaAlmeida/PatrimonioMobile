import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '/widgets/custom_navbar.dart'; 

class InventarioView extends StatefulWidget {
  const InventarioView({super.key});

  @override
  State<InventarioView> createState() => _InventarioViewState();
}

class _InventarioViewState extends State<InventarioView> {
  String? setorSelecionado;
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
                      padding: const EdgeInsetsDirectional.fromSTEB(20, 40, 20, 20), 
                      child: Row(
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          IconButton( 
                            icon: const Icon(Icons.arrow_back, size: 40, color: Color(0xFF57636C)),
                            onPressed: () => Navigator.pop(context),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Inventário anual 2026',
                                  style: GoogleFonts.interTight(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                    color: const Color(0xFF57636C),
                                  ),
                                ),
                                Row(
                                  children: [
                                    Text('Início: 01/01/2026', style: GoogleFonts.inter(fontSize: 12)), 
                                    const Text(' | ', style: TextStyle(fontSize: 12)),
                                    Text('Fim: 01/12/2026', style: GoogleFonts.inter(fontSize: 12)), 
                                  ],
                                ),
                              ],
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
                              'Setor',
                              style: GoogleFonts.interTight(fontSize: 18, fontWeight: FontWeight.w600),
                            ),
                            const SizedBox(height: 10),
                          
                            DropdownButtonFormField<String>(
                              initialValue: setorSelecionado,
                              decoration: InputDecoration(
                                filled: true,
                                fillColor: Colors.white,
                                contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: const BorderSide(color: Color(0x9A57636C)),
                                ),
                              ),
                              hint: const Text('Lab 3'),
                              items: ['Option 1', 'Option 2', 'Option 3']
                                  .map((val) => DropdownMenuItem(value: val, child: Text(val)))
                                  .toList(),
                              onChanged: (val) => setState(() => setorSelecionado = val),
                            ),

                            const SizedBox(height: 20),
                            Text(
                              'Patrimônios do setor',
                              style: GoogleFonts.interTight(fontSize: 18, fontWeight: FontWeight.w600),
                            ),
                            
                            Expanded(
                              child: ListView(
                                padding: const EdgeInsets.only(top: 10), 
                                children: [
                                  _buildPatrimonioItem(numero: '1', codigo: '987622'), 
                                  const SizedBox(height: 10),
                                ],
                              ),
                            ),

                            Padding(
                              padding: const EdgeInsets.only(top: 10),
                              child: ElevatedButton.icon(
                                onPressed: () => print('Abrir Câmera'),
                                icon: const Icon(Icons.camera_alt, color: Colors.white),
                                label: const Text('Adicionar patrimônio', style: TextStyle(color: Colors.white, fontSize: 18)),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF0055FF), 
                                  minimumSize: const Size(double.infinity, 50),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
            const NavBarWidget(), 
          ],
        ),
      ),
    );
  }

  Widget _buildPatrimonioItem({required String numero, required String codigo}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(blurRadius: 3, color: Colors.black.withOpacity(0.1), offset: const Offset(0, 2))
        ],
      ),
      child: Row(
        children: [
          Text(numero, style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w500)),
          const SizedBox(width: 30), 
          Expanded(
            child: Text(codigo, style: GoogleFonts.inter(fontSize: 18)),
          ),
          IconButton(
            icon: const Icon(Icons.cancel_outlined, color: Colors.red, size: 24),
            onPressed: () => print('Remover item'),
          ),
        ],
      ),
    );
  }
}
