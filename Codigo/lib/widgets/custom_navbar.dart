import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:patrimonio_mobile/views/arquivos_view.dart';
import 'package:patrimonio_mobile/views/cadastro_view.dart';
import 'package:patrimonio_mobile/views/home_view.dart';

class NavBarWidget extends StatelessWidget {
  final int selectedIndex;

  const NavBarWidget({super.key, this.selectedIndex = 0});

  void _navigateTo(BuildContext context, int index) {
    if (index == selectedIndex) {
      return;
    }

    Widget destination;

    switch (index) {
      case 0:
        destination = const HomeView();
        break;
      case 1:
        destination = const CadastroView();
        break;
      case 2:
        destination = const ArquivosView();
        break;
      default:
        destination = const HomeView();
    }

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => destination),
    );
  }

  Widget _buildNavItem(
    BuildContext context, {
    required int index,
    required IconData icon,
    required String label,
    required Color? defaultColor,
    required Color activeColor,
  }) {
    final bool isActive = selectedIndex == index;

    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: () => _navigateTo(context, index),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: isActive ? activeColor : defaultColor,
              size: 40,
            ),
            Text(
              label,
              style: GoogleFonts.inter(
                color: isActive ? activeColor : defaultColor,
                fontSize: 14,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final corFundo = const Color(0xFFEFF0F5);
    final corIconeTexto = Colors.grey[700];
    const corAtiva = Color(0xFF0055FF);
    final corSombra = Colors.black.withOpacity(0.1);

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: corFundo,
        boxShadow: [
          BoxShadow(
            blurRadius: 1,
            color: corSombra,
            offset: const Offset(0, 1),
          )
        ],
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(10, 10, 10, 10), 
          child: Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(
                context,
                index: 0,
                icon: Icons.home_outlined,
                label: 'Início',
                defaultColor: corIconeTexto,
                activeColor: corAtiva,
              ),
              _buildNavItem(
                context,
                index: 1,
                icon: Icons.add_sharp,
                label: 'Cadastrar',
                defaultColor: corIconeTexto,
                activeColor: corAtiva,
              ),
              _buildNavItem(
                context,
                index: 2,
                icon: Icons.menu,
                label: 'Arquivos',
                defaultColor: corIconeTexto,
                activeColor: corAtiva,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
