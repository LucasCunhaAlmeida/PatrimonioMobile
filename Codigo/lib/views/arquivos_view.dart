import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:share_plus/share_plus.dart';
import '../widgets/custom_navbar.dart';
import 'package:patrimonio_mobile/services/exportar_planilha_service.dart';
import 'package:file_picker/file_picker.dart';
import 'package:patrimonio_mobile/services/importar_planilha_service.dart';

class ArquivosView extends StatefulWidget {
  const ArquivosView({super.key});

  @override
  State<ArquivosView> createState() => _ArquivosViewState();
}

class _ArquivosViewState extends State<ArquivosView> {
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  bool _processando = false;

  Future<void> _exportarPlanilha() async {
    setState(() => _processando = true);
    try {
      final service = ExportarPlanilhaService();
      final caminho = await service.gerarRelatorioGeral('patrimonio_exportado');

      final box = context.findRenderObject() as RenderBox?;
      final posicao =
          box != null ? box.localToGlobal(Offset.zero) & box.size : null;

      await Share.shareXFiles(
        [XFile(caminho)],
        text: 'Segue a planilha de patrimônios',
        sharePositionOrigin: posicao,
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Planilha exportada com sucesso!')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao exportar: $e')),
      );
    } finally {
      if (mounted) setState(() => _processando = false);
    }
  }

  Future<void> _importarPlanilha() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['xlsx', 'xls'],
      );

      if (result != null && result.files.single.path != null) {
        String caminhoArquivo = result.files.single.path!;

        setState(() {
          _processando = true; 
        });

        final importacaoService = ImportarPlanilhaService();
        await importacaoService.consumirRelatorio(caminhoArquivo);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Planilha importada e salva no banco com sucesso!'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        debugPrint('Importação cancelada pelo usuário.');
      }
    } catch (e) {
      debugPrint('Erro na importação: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao importar: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _processando = false;
        });
      }
    }
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
          children: [
            Expanded(
              child: Container(
                color: Colors.white,
                child: Padding(
                  padding: const EdgeInsetsDirectional.fromSTEB(20, 60, 20, 0),
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(bottom: 20),
                        child: Row(
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
                        icon: Icons.download,
                        onPressed: _importarPlanilha,
                      ),
                      const SizedBox(height: 10),
                      _buildFileButton(
                        label: 'Exportar patrimônio',
                        icon: Icons.upload_sharp,
                        onPressed: _exportarPlanilha,
                      ),
                    ],
                  ),
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
      onPressed: _processando ? null : onPressed,
      icon: _processando
          ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                  strokeWidth: 2, color: Color(0xFF57636C)),
            )
          : Icon(icon, size: 20, color: const Color(0xFF57636C)),
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
