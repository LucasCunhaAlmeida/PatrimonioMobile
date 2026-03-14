import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../widgets/custom_navbar.dart';

class EditarInventarioPage extends StatefulWidget {
  const EditarInventarioPage({super.key});

  @override
  State<EditarInventarioPage> createState() => _EditarInventarioPageState();
}

class _EditarInventarioPageState extends State<EditarInventarioPage> {
  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Scaffold(
            key: scaffoldKey,
            backgroundColor: const Color(0xFFF1F4F8),
            body: Column(children: [
              Container(
                  height: 130,
                  color: const Color(0xFFEFF0F6),
                  padding: const EdgeInsets.only(top: 40, left: 20, right: 20),
                  child: Row(children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back,
                          size: 30, color: Color(0xFF57636C)),
                      onPressed: () => Navigator.pop(context),
                    ),
                    Text(
                      'Editar Inventário',
                      style: GoogleFonts.interTight(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF57636C),
                      ),
                    )
                  ]))
            ])));
  }
}
