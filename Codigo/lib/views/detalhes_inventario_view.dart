import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:patrimonio_mobile/models/inventario_model.dart';
import 'package:patrimonio_mobile/models/patrimonioInventariado_model.dart';
import 'package:patrimonio_mobile/models/setor_model.dart';
import 'package:patrimonio_mobile/services/patrimonioInventariado_service.dart';
import 'package:patrimonio_mobile/services/setor_service.dart';
import 'package:patrimonio_mobile/views/scanner_view.dart';
import 'package:patrimonio_mobile/services/exportar_planilha_service.dart';
import '/widgets/custom_navbar.dart';
import 'package:share_plus/share_plus.dart';

class DetalhesInventarioView extends StatefulWidget {
  final Inventario inventario;
  const DetalhesInventarioView({super.key, required this.inventario});

  @override
  State<DetalhesInventarioView> createState() => _DetalhesInventarioViewState();
}

class _DetalhesInventarioViewState extends State<DetalhesInventarioView> {
  final _setorService = SetorService();
  final _patrimonioService = PatrimonioInventariadoService();
  bool _processando = false;

  List<Setor> _setores = [];
  List<PatrimonioInventariado> _patrimonios = [];
  int? _setorSelecionadoId;
  bool _loadingSetores = true;
  bool _loadingPatrimonios = false;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _loadSetores();
  }

  Future<void> _loadSetores() async {
    setState(() => _loadingSetores = true);
    final todos = await _setorService.queryAllSetores();

    if (!mounted) return;

    setState(() {
      _setores = todos
          .where((s) => s.idInstituicao == widget.inventario.idInstituicao)
          .toList();
      _loadingSetores = false;
    });
  }

  Future<void> _onSetorChanged(int? idSetor) async {
    setState(() {
      _setorSelecionadoId = idSetor;
      _patrimonios = [];
      _loadingPatrimonios = idSetor != null;
    });
    if (idSetor == null) return;
    await _loadPatrimonios(idSetor);
  }

  Future<void> _loadPatrimonios(int idSetor) async {
    setState(() => _loadingPatrimonios = true);
    final lista = await _patrimonioService.listarPatrimonio(
        idSetor, widget.inventario.id!);
    if (!mounted) return;
    setState(() {
      _patrimonios = lista;
      _loadingPatrimonios = false;
    });
  }

  Future<void> _exportarPlanilha() async {
    setState(() => _processando = true);
    try {
      final service = ExportarPlanilhaService();

      String nomeSanitizado = widget.inventario.nome.replaceAll(' ', '_');
      String nomeArquivo = "Relatorio_$nomeSanitizado";

      final caminho = await service.gerarRelatorioPorInventario(
          widget.inventario.id!, nomeArquivo);

      final box = context.findRenderObject() as RenderBox?;
      final posicao =
          box != null ? box.localToGlobal(Offset.zero) & box.size : null;

      await Share.shareXFiles(
        [XFile(caminho)],
        text: 'Segue a planilha do inventário: ${widget.inventario.nome}',
        sharePositionOrigin: posicao,
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('Planilha "$nomeArquivo" exportada com sucesso!')),
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

  String _formatarData(String data) {
    final partes = data.split('-');
    if (partes.length == 3) return '${partes[2]}/${partes[1]}/${partes[0]}';
    return data;
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
                mainAxisSize: MainAxisSize.max,
                children: [
                  Container(
                    width: double.infinity,
                    height: 130,
                    decoration: const BoxDecoration(color: Color(0xFFEFF0F6)),
                    child: Padding(
                      padding:
                          const EdgeInsetsDirectional.fromSTEB(20, 40, 20, 20),
                      child: Row(
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.arrow_back,
                                size: 40, color: Color(0xFF57636C)),
                            onPressed: () => Navigator.pop(context),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  widget.inventario.nome,
                                  style: GoogleFonts.interTight(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                    color: const Color(0xFF57636C),
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                Row(
                                  children: [
                                    Text(
                                      'Início: ${_formatarData(widget.inventario.dataInicio)}',
                                      style: GoogleFonts.inter(fontSize: 12),
                                    ),
                                    const Text(' | ',
                                        style: TextStyle(fontSize: 12)),
                                    Text(
                                      'Fim: ${_formatarData(widget.inventario.dataFim)}',
                                      style: GoogleFonts.inter(fontSize: 12),
                                    ),
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
                              style: GoogleFonts.interTight(
                                  fontSize: 18, fontWeight: FontWeight.w600),
                            ),
                            const SizedBox(height: 10),
                            _loadingSetores
                                ? const Center(
                                    child: CircularProgressIndicator())
                                : DropdownButtonFormField<int>(
                                    value: _setorSelecionadoId,
                                    decoration: InputDecoration(
                                      filled: true,
                                      fillColor: Colors.white,
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                              horizontal: 12),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: const BorderSide(
                                            color: Color(0x9A57636C)),
                                      ),
                                    ),
                                    hint: const Text('Selecione o Setor'),
                                    items: _setores
                                        .map((s) => DropdownMenuItem(
                                              value: s.id,
                                              child: Text(s.nome),
                                            ))
                                        .toList(),
                                    onChanged: _onSetorChanged,
                                  ),
                            const SizedBox(height: 16),
                            ElevatedButton.icon(
                              onPressed: (_processando ||
                                      _setorSelecionadoId == null)
                                  ? null
                                  : _exportarPlanilha,
                              icon: _processando
                                  ? const SizedBox(
                                      width: 22,
                                      height: 22,
                                      child: CircularProgressIndicator(
                                        color: Colors.white,
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : const Icon(Icons.upload_file,
                                      size: 22, color: Colors.white),
                              label: Text(
                                "Exportar Inventário",
                                style: GoogleFonts.inter(
                                    fontSize: 18, color: Colors.white),
                                overflow: TextOverflow.ellipsis,
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF0055FF),
                                minimumSize: const Size(double.infinity, 50),
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                disabledBackgroundColor: Colors.grey,
                              ),
                            ),
                            const SizedBox(height: 20),
                            Text(
                              'Patrimônios do setor',
                              style: GoogleFonts.interTight(
                                  fontSize: 18, fontWeight: FontWeight.w600),
                            ),
                            const SizedBox(height: 10),
                            Expanded(child: _buildPatrimonioList()),
                            Padding(
                              padding: const EdgeInsets.only(top: 10),
                              child: ElevatedButton.icon(
                                onPressed: _setorSelecionadoId == null
                                    ? null
                                    : () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => ScannerView(
                                              idInventario:
                                                  widget.inventario.id!,
                                              idSetor: _setorSelecionadoId!,
                                            ),
                                          ),
                                        ).then((_) {
                                          if (!mounted) return;
                                          if (_setorSelecionadoId != null) {
                                            _loadPatrimonios(
                                                _setorSelecionadoId!);
                                          }
                                        });
                                      },
                                icon: const Icon(Icons.camera_alt,
                                    size: 22, color: Colors.white),
                                label: Text('Adicionar patrimônio',
                                    style: GoogleFonts.inter(
                                        color: Colors.white, fontSize: 18)),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF0055FF),
                                  minimumSize: const Size(double.infinity, 50),
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12)),
                                  disabledBackgroundColor: Colors.grey,
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
            const NavBarWidget(selectedIndex: 0),
          ],
        ),
      ),
    );
  }

  Widget _buildPatrimonioList() {
    if (_setorSelecionadoId == null) {
      return Center(
        child: Text(
          'Selecione um setor para ver os patrimônios',
          style: GoogleFonts.inter(color: const Color(0xFF57636C)),
          textAlign: TextAlign.center,
        ),
      );
    }
    if (_loadingPatrimonios) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_patrimonios.isEmpty) {
      return Center(
        child: Text(
          'Nenhum patrimônio cadastrado neste setor',
          style: GoogleFonts.inter(color: const Color(0xFF57636C)),
          textAlign: TextAlign.center,
        ),
      );
    }
    return ListView.separated(
      padding: EdgeInsets.zero,
      itemCount: _patrimonios.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (_, i) => _buildPatrimonioItem(_patrimonios[i]),
    );
  }

  Widget _buildPatrimonioItem(PatrimonioInventariado p) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            blurRadius: 3,
            color: Colors.black.withOpacity(0.1),
            offset: const Offset(0, 2),
          )
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              p.numero,
              style:
                  GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w500),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.edit, color: Color(0xFF0055FF), size: 24),
            onPressed: () => _mostrarDialogoEditar(p),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline, color: Colors.red, size: 24),
            onPressed: () => _mostrarDialogoDeletar(p),
          ),
        ],
      ),
    );
  }

  Future<void> _mostrarDialogoEditar(PatrimonioInventariado p) async {
    final controller = TextEditingController(text: p.numero);
    bool isLoading = false;

    await showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(builder: (context, setStateDialog) {
          return AlertDialog(
            title: Text('Editar Patrimônio',
                style: GoogleFonts.interTight(fontWeight: FontWeight.w600)),
            content: isLoading
                ? const SizedBox(
                    height: 50,
                    child: Center(child: CircularProgressIndicator()))
                : TextField(
                    controller: controller,
                    keyboardType: TextInputType.number,
                    maxLength: 10,
                    decoration: const InputDecoration(
                      labelText: 'Número do Patrimônio',
                      border: OutlineInputBorder(),
                    ),
                  ),
            actions: [
              TextButton(
                onPressed: isLoading ? null : () => Navigator.pop(context),
                child: const Text('Cancelar',
                    style: TextStyle(color: Colors.grey)),
              ),
              TextButton(
                onPressed: isLoading
                    ? null
                    : () async {
                        if (controller.text.trim().isEmpty) return;

                        setStateDialog(() => isLoading = true);

                        try {
                          p.numero = controller.text.trim();
                          await _patrimonioService.atualizarPatrimonio(p);

                          if (mounted) {
                            Navigator.pop(context);
                            _loadPatrimonios(_setorSelecionadoId!);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text('Atualizado com sucesso!')),
                            );
                          }
                        } catch (e) {
                          setStateDialog(() => isLoading = false);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Erro ao atualizar: $e')),
                          );
                        }
                      },
                child: const Text('Salvar',
                    style: TextStyle(color: Color(0xFF0055FF))),
              ),
            ],
          );
        });
      },
    );
  }

  Future<void> _mostrarDialogoDeletar(PatrimonioInventariado p) async {
    bool isLoading = false;

    await showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(builder: (context, setStateDialog) {
          return AlertDialog(
            title: Text('Excluir Patrimônio',
                style: GoogleFonts.interTight(fontWeight: FontWeight.w600)),
            content: isLoading
                ? const SizedBox(
                    height: 50,
                    child: Center(child: CircularProgressIndicator()))
                : Text(
                    'Tem certeza que deseja excluir o patrimônio "${p.numero}"? Essa ação não pode ser desfeita.'),
            actions: [
              TextButton(
                onPressed: isLoading ? null : () => Navigator.pop(context),
                child: const Text('Cancelar',
                    style: TextStyle(color: Colors.grey)),
              ),
              TextButton(
                onPressed: isLoading
                    ? null
                    : () async {
                        setStateDialog(() => isLoading = true);
                        try {
                          await _patrimonioService.excluirPatrimonio(p.id!);

                          if (mounted) {
                            Navigator.pop(context);
                            _loadPatrimonios(_setorSelecionadoId!);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text('Excluído com sucesso!')),
                            );
                          }
                        } catch (e) {
                          setStateDialog(() => isLoading = false);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Erro ao excluir: $e')),
                          );
                        }
                      },
                style: TextButton.styleFrom(foregroundColor: Colors.red),
                child: const Text('Excluir'),
              ),
            ],
          );
        });
      },
    );
  }
}