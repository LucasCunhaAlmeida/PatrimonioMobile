import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:patrimonio_mobile/models/inventario_model.dart';
import 'package:patrimonio_mobile/models/patrimonioInventariado_model.dart';
import 'package:patrimonio_mobile/models/setor_model.dart';
import 'package:patrimonio_mobile/services/patrimonioInventariado_service.dart';
import 'package:patrimonio_mobile/services/setor_service.dart';
import 'package:patrimonio_mobile/views/scanner_view.dart';
import '/widgets/custom_navbar.dart';

class DetalhesInventarioView extends StatefulWidget {
  final Inventario inventario;
  const DetalhesInventarioView({super.key, required this.inventario});

  @override
  State<DetalhesInventarioView> createState() => _DetalhesInventarioViewState();
}

class _DetalhesInventarioViewState extends State<DetalhesInventarioView> {
  final _setorService = SetorService();
  final _patrimonioService = PatrimonioInventariadoService();

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

    final filtrados = todos
        .where((s) => s.idInstituicao == widget.inventario.idInstituicao)
        .toList();

    setState(() {
      _setores = filtrados;
      _loadingSetores = false;
    });

    if (filtrados.length == 1) {
      await _onSetorChanged(filtrados.first.id);
    }
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
                            const SizedBox(height: 20),
                            Text(
                              'Patrimônios do setor',
                              style: GoogleFonts.interTight(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                              ),
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
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            blurRadius: 3,
            color: Colors.black.withValues(alpha: 0.1),
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment:
            CrossAxisAlignment.center, // alinha verticalmente ao centro
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  p.numero,
                  style: GoogleFonts.inter(
                    fontSize: 22,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Estado: ${p.estadoPatrimonio} | Conservação: ${p.estadoConservacao}',
                  style: GoogleFonts.inter(fontSize: 14, color: Colors.grey),
                ),
              ],
            ),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon:
                    const Icon(Icons.edit, color: Color(0xFF0055FF), size:28),
                onPressed: () => _mostrarDialogoEditar(p),
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline,
                    color: Colors.red, size: 28),
                onPressed: () => _mostrarDialogoDeletar(p),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSeletorOpcoes({
    required String label,
    required List<String> opcoes,
    required ValueNotifier<String?> notifier,
    bool centralizarOpcoes = false,
    bool centralizarLabel = false,
  }) {
    return SizedBox(
      width: double.infinity,
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Align(
          alignment: centralizarLabel ? Alignment.center : Alignment.centerLeft,
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: Colors.black54,
            ),
            textAlign: centralizarLabel ? TextAlign.center : TextAlign.left,
          ),
        ),
        const SizedBox(height: 8),
        ValueListenableBuilder<String?>(
            valueListenable: notifier,
            builder: (context, selecionado, _) {
              final chips = opcoes.map((opcao) {
                final estaSelecionado = selecionado == opcao;
                return GestureDetector(
                  onTap: () => notifier.value = opcao,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: estaSelecionado
                          ? const Color(0xFF0055FF)
                          : Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: estaSelecionado
                            ? const Color(0xFF0055FF)
                            : Colors.grey.shade300,
                      ),
                    ),
                    child: Text(
                      opcao,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: estaSelecionado ? Colors.white : Colors.black54,
                      ),
                    ),
                  ),
                );
              }).toList();

              final chipsComEspacamento = List<Widget>.generate(
                chips.length * 2 - (chips.isEmpty ? 0 : 1),
                (index) {
                  if (index.isEven) {
                    return chips[index ~/ 2];
                  }

                  return SizedBox(width: centralizarOpcoes ? 8 : 10);
                },
              );

              if (centralizarOpcoes) {
                return Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: chipsComEspacamento,
                );
              }

              return SizedBox(
                width: double.infinity,
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.center,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: chipsComEspacamento,
                  ),
                ),
              );
            }),
      ]),
    );
  }

  Future<void> _mostrarDialogoEditar(PatrimonioInventariado p) async {
    final rootContext = context;
    final controller = TextEditingController(text: p.numero);
    final estadoPatrimonioNotifier = ValueNotifier<String?>(p.estadoPatrimonio);
    final estadoConservacaoNotifier =
        ValueNotifier<String?>(p.estadoConservacao);
    bool isLoading = false;

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return StatefulBuilder(builder: (_, setStateDialog) {
          return Dialog(
            insetPadding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 24),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 560),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 72,
                        height: 72,
                        decoration: BoxDecoration(
                          color: Colors.blue.withValues(alpha: 0.15),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.edit_rounded,
                          color: Colors.blue,
                          size: 42,
                        ),
                      ),
                      const SizedBox(height: 14),
                      Text(
                        'Editar Patrimônio',
                        style: GoogleFonts.interTight(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 20),
                      Center(
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 200),
                          child: isLoading
                              ? const SizedBox(
                                  height: 50,
                                  child: Center(
                                    child: CircularProgressIndicator(),
                                  ),
                                )
                              : TextField(
                                  style: const TextStyle(
                                    fontSize: 23.5,
                                    fontWeight: FontWeight.w500,
                                  ),
                                  textAlign: TextAlign.center,
                                  controller: controller,
                                  keyboardType: TextInputType.number,
                                  maxLength: 10,
                                  autofocus: true,
                                  decoration: InputDecoration(
                                    hintText: '0000000000',
                                    counterText: '',
                                    contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 12,
                                    ),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                      borderSide: const BorderSide(
                                        color: Colors.blue,
                                        width: 1.6,
                                      ),
                                    ),
                                  ),
                                ),
                        ),
                      ),
                      const SizedBox(height: 18),
                      _buildSeletorOpcoes(
                        label: 'Estado do patrimônio',
                        opcoes: const ['Em uso', 'Defeituoso', 'Ocioso'],
                        notifier: estadoPatrimonioNotifier,
                        centralizarOpcoes: true,
                        centralizarLabel: true,
                      ),
                      const SizedBox(height: 14),
                      _buildSeletorOpcoes(
                        label: 'Estado de conservação',
                        opcoes: const ['Ótimo', 'Bom', 'Regular', 'Ruim'],
                        notifier: estadoConservacaoNotifier,
                        centralizarLabel: true,
                      ),
                      const SizedBox(height: 20),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              style: OutlinedButton.styleFrom(
                                foregroundColor: Colors.black87,
                                side: BorderSide(color: Colors.grey.shade400),
                                padding:
                                    const EdgeInsets.symmetric(vertical: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              onPressed: isLoading
                                  ? null
                                  : () => Navigator.of(dialogContext).pop(),
                              child: const Text(
                                'Cancelar',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue,
                                foregroundColor: Colors.white,
                                padding:
                                    const EdgeInsets.symmetric(vertical: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              onPressed: isLoading
                                  ? null
                                  : () async {
                                      final numero = controller.text.trim();
                                      final estadoPatrimonio =
                                          estadoPatrimonioNotifier.value;
                                      final estadoConservacao =
                                          estadoConservacaoNotifier.value;

                                      if (numero.isEmpty ||
                                          estadoPatrimonio == null ||
                                          estadoConservacao == null) {
                                        return;
                                      }

                                      setStateDialog(() => isLoading = true);

                                      try {
                                        p.numero = numero;
                                        p.estadoPatrimonio = estadoPatrimonio;
                                        p.estadoConservacao = estadoConservacao;

                                        await _patrimonioService
                                            .atualizarPatrimonio(p);

                                        if (mounted) {
                                          Navigator.of(dialogContext).pop();
                                          _loadPatrimonios(
                                              _setorSelecionadoId!);
                                          ScaffoldMessenger.of(rootContext)
                                              .showSnackBar(
                                            const SnackBar(
                                              content: Text(
                                                  'Atualizado com sucesso!'),
                                            ),
                                          );
                                        }
                                      } catch (e) {
                                        setStateDialog(() => isLoading = false);
                                        if (!mounted) return;
                                        ScaffoldMessenger.of(rootContext)
                                            .showSnackBar(
                                          SnackBar(
                                            content:
                                                Text('Erro ao atualizar: $e'),
                                          ),
                                        );
                                      }
                                    },
                              child: const Text(
                                'Salvar',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        });
      },
    );
  }

  Future<void> _mostrarDialogoDeletar(PatrimonioInventariado p) async {
    final rootContext = context;
    bool isLoading = false;

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return StatefulBuilder(builder: (_, setStateDialog) {
          return Dialog(
            insetPadding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 24),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 560),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 72,
                      height: 72,
                      decoration: BoxDecoration(
                        color: Colors.red.withValues(alpha: 0.15),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.delete_outline,
                        color: Colors.red,
                        size: 42,
                      ),
                    ),
                    const SizedBox(height: 14),
                    Text(
                      'Confirmar exclusão?',
                      style: GoogleFonts.interTight(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.red,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 14),
                    isLoading
                        ? const SizedBox(
                            height: 50,
                            child: Center(child: CircularProgressIndicator()),
                          )
                        : Text(
                            'Deseja excluir o patrimônio ${p.numero}?',
                            style: GoogleFonts.inter(fontSize: 15),
                            textAlign: TextAlign.center,
                          ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.black87,
                              side: BorderSide(color: Colors.grey.shade400),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            onPressed: isLoading
                                ? null
                                : () => Navigator.of(dialogContext).pop(),
                            child: const Text(
                              'Cancelar',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            onPressed: isLoading
                                ? null
                                : () async {
                                    setStateDialog(() => isLoading = true);

                                    try {
                                      await _patrimonioService
                                          .excluirPatrimonio(p.id!);

                                      if (mounted) {
                                        Navigator.of(dialogContext).pop();
                                        _loadPatrimonios(_setorSelecionadoId!);
                                        ScaffoldMessenger.of(rootContext)
                                            .showSnackBar(
                                          const SnackBar(
                                            content:
                                                Text('Excluído com sucesso!'),
                                          ),
                                        );
                                      }
                                    } catch (e) {
                                      setStateDialog(() => isLoading = false);
                                      if (!mounted) return;
                                      ScaffoldMessenger.of(rootContext)
                                          .showSnackBar(
                                        SnackBar(
                                            content:
                                                Text('Erro ao excluir: $e')),
                                      );
                                    }
                                  },
                            child: const Text(
                              'Excluir',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        });
      },
    );
  }
}
