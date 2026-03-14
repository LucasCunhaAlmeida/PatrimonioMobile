import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../widgets/custom_navbar.dart'; 

class ArquivosView extends StatefulWidget {
  const ArquivosView({super.key});

  @override
  State<ArquivosView> createState() => _ArquivosViewState();
}

class _ArquivosViewState extends State<ArquivosView> {
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
              child: Container(
                decoration: const BoxDecoration(),
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    Expanded(
                      child: Container(
                        width: double.infinity,
                        decoration: const BoxDecoration(
                          color: Colors.white,
                        ),
                        child: Padding(
                          padding: const EdgeInsetsDirectional.fromSTEB(20, 60, 20, 0),
                          child: Column(
                            mainAxisSize: MainAxisSize.max,
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(bottom: 20),
                                child: Row(
                                  mainAxisSize: MainAxisSize.max,
                                  children: [
                                    Text(
                                      'Instituição: ',
                                      style: GoogleFonts.inter(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w600,
                                        color: const Color(0xFF57636C),
                                      ),
                                    ),
                                    Text(
                                      'DSI',
                                      style: GoogleFonts.inter(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w600,
                                        color: const Color(0xFF57636C),
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              _buildFileButton(
                                label: 'Importar patrimônio',
                                icon: Icons.upload_sharp,
                                onPressed: () => print('Importar pressionado'),
                              ),

                              const SizedBox(height: 10),

                              _buildFileButton(
                                label: 'Exportar patrimônio',
                                icon: Icons.download,
                                onPressed: () => print('Exportar pressionado'),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const NavBarWidget(selectedIndex: 2),
          ],
        ),
      ),
    );
  }

  Widget _buildFileButton({
    required String label,
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 20, color: const Color(0xFF57636C)),
      label: Text(
        label,
        style: GoogleFonts.interTight(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: const Color(0xFF57636C),
        ),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFFEFF0F6),
        minimumSize: const Size(double.infinity, 45),
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: Color(0xFF57636C), width: 1),
        ),
      ),
    );
  }
}