import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:patrimonio_mobile/models/patrimonioInventariado_model.dart';
import 'package:patrimonio_mobile/services/patrimonioInventariado_service.dart';

class ScannerView extends StatefulWidget {
  final int idInventario;
  final int idSetor;

  const ScannerView(
      {super.key, required this.idInventario, required this.idSetor});

  @override
  State<ScannerView> createState() => _ScannerViewState();
}

class _ScannerViewState extends State<ScannerView> {
  final PatrimonioInventariadoService _service =
      PatrimonioInventariadoService();
  final MobileScannerController scannerController = MobileScannerController();
  final AudioPlayer player = AudioPlayer();
  final TextEditingController _manualController = TextEditingController();
  static const Duration _scannerRestartDelay = Duration(milliseconds: 400);

  bool _isProcessing = false;

  bool _codigoValido(String codigo) =>
      RegExp(r'^\d{1,10}$').hasMatch(codigo.trim());

  Future<void> _mostrarPopup({
    required String titulo,
    required String codigo,
    required Color cor,
    required IconData icone,
    String? subtitulo,
    double tamanhoTitulo = 20,
    Future<void> Function(String estadoPatrimonio, String estadoConservacao)?
        onSalvarEstados,
    String textoBotaoCancelar = 'Voltar',
    String textoBotaoSalvar = 'Salvar',
    String? estadoInicialPatrimonio,
    String? estadoInicialConservacao,
  }) async {
    final rootContext = context;
    final exibeSeletoresEstado = onSalvarEstados != null;

    final estadoPatrimonioNotifier =
        ValueNotifier<String?>(estadoInicialPatrimonio);
    final estadoConservacaoNotifier =
        ValueNotifier<String?>(estadoInicialConservacao);

    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (subtitulo != null) ...[
                Text(
                  subtitulo,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    color: Colors.black87,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
              ],
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: cor.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(icone, color: cor, size: 42),
              ),
              const SizedBox(height: 14),
              Text(
                titulo,
                style: TextStyle(
                  fontSize: tamanhoTitulo,
                  fontWeight: FontWeight.bold,
                  color: cor,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: Text(
                  codigo,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              if (exibeSeletoresEstado) ...[
                _buildSeletorOpcoes(
                  label: "Estado do patrimônio",
                  opcoes: const ["Em uso", "Defeituoso", "Ocioso"],
                  notifier: estadoPatrimonioNotifier,
                  centralizarOpcoes: true,
                  centralizarLabel: true,
                ),
                const SizedBox(height: 14),
                _buildSeletorOpcoes(
                  label: "Estado de conservação",
                  opcoes: const ["Ótimo", "Bom", "Regular", "Ruim"],
                  notifier: estadoConservacaoNotifier,
                  centralizarLabel: true,
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ValueListenableBuilder2(
                    first: estadoPatrimonioNotifier,
                    second: estadoConservacaoNotifier,
                    builder: (_, estadoPatrimonio, estadoConservacao, child) {
                      final podeSalvar =
                          estadoPatrimonio != null && estadoConservacao != null;

                      return Row(
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
                              onPressed: () =>
                                  Navigator.of(dialogContext).pop(),
                              child: Text(
                                textoBotaoCancelar,
                                style: const TextStyle(
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
                                  backgroundColor:
                                      podeSalvar ? cor : Colors.grey.shade400,
                                  foregroundColor: Colors.white,
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 12),
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10))),
                              onPressed: podeSalvar
                                  ? () async {
                                      try {
                                        await onSalvarEstados(
                                          estadoPatrimonio,
                                          estadoConservacao,
                                        );
                                        if (mounted) {
                                          Navigator.of(dialogContext).pop();
                                        }
                                      } catch (e) {
                                        if (mounted) {
                                          ScaffoldMessenger.of(rootContext)
                                              .showSnackBar(
                                            SnackBar(
                                              content:
                                                  Text('Erro ao salvar: $e'),
                                              backgroundColor: Colors.red,
                                            ),
                                          );
                                        }
                                      }
                                    }
                                  : null,
                              child: Text(
                                podeSalvar ? textoBotaoSalvar : "Salvar",
                                style: const TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ] else ...[
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: cor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onPressed: () => Navigator.of(dialogContext).pop(),
                    child: const Text(
                      "OK",
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
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

  Future<void> _mostrarFalhaLeitura(String codigo) async {
    if (!mounted || _isProcessing) return;

    setState(() => _isProcessing = true);
    scannerController.stop();

    try {
      await _mostrarPopup(
        titulo: "Falha na leitura",
        codigo: codigo,
        cor: Colors.red,
        icone: Icons.error_rounded,
      );
    } finally {
      if (mounted) {
        setState(() => _isProcessing = false);
      }
      await Future.delayed(_scannerRestartDelay);
      if (!mounted) return;
      scannerController.start();
    }
  }

  Future<void> _salvarNoBanco(String codigo, {bool fromScanner = false}) async {
    if (!mounted || _isProcessing) return;

    final codigoLimpo = codigo.trim();

    if (!_codigoValido(codigoLimpo)) {
      if (fromScanner) {
        await _mostrarFalhaLeitura(
            codigoLimpo.isEmpty ? "(vazio)" : codigoLimpo);
      } else {
        await _mostrarPopup(
          titulo: "Código inválido",
          codigo: codigoLimpo.isEmpty ? "(vazio)" : codigoLimpo,
          cor: Colors.red,
          icone: Icons.warning_rounded,
        );
      }
      return;
    }

    setState(() => _isProcessing = true);
    scannerController.stop();

    try {
      try {
        await player.play(AssetSource('sound/beep.mp3'));
      } catch (_) {}

      final patrimonioExistente = await _service.buscarPatrimonio(
        codigoLimpo,
        widget.idInventario,
      );

      if (patrimonioExistente == null) {
        await _mostrarPopup(
          titulo: "Novo Patrimônio",
          tamanhoTitulo: 18,
          codigo: codigoLimpo,
          cor: Colors.green,
          icone: Icons.qr_code_scanner_rounded,
          subtitulo: "Confirmar Patrimônio?",
          textoBotaoCancelar: 'Não',
          textoBotaoSalvar: 'Salvar',
          onSalvarEstados: (estadoPatrimonio, estadoConservacao) async {
            await _service.inserirPatrimonio(
              PatrimonioInventariado(
                numero: codigoLimpo,
                idInventario: widget.idInventario,
                idSetor: widget.idSetor,
                estadoPatrimonio: estadoPatrimonio,
                estadoConservacao: estadoConservacao,
              ),
            );
          },
        );
      } else {
        await _mostrarPopup(
          titulo: "Patrimônio já cadastrado",
          codigo: codigoLimpo,
          cor: Colors.amber,
          icone: Icons.warning_amber_rounded,
          textoBotaoCancelar: 'Voltar',
          textoBotaoSalvar: 'Salvar',
          estadoInicialPatrimonio: patrimonioExistente.estadoPatrimonio,
          estadoInicialConservacao: patrimonioExistente.estadoConservacao,
          onSalvarEstados: (estadoPatrimonio, estadoConservacao) async {
            await _service.atualizarPatrimonio(
              PatrimonioInventariado(
                id: patrimonioExistente.id,
                numero: codigoLimpo,
                idInventario: widget.idInventario,
                idSetor: widget.idSetor,
                estadoPatrimonio: estadoPatrimonio,
                estadoConservacao: estadoConservacao,
              ),
            );
          },
        );
      }
    } catch (e) {
      await _mostrarPopup(
        titulo: "Erro ao salvar",
        codigo: codigoLimpo,
        cor: Colors.red,
        icone: Icons.error_rounded,
      );
    } finally {
      if (mounted) {
        setState(() => _isProcessing = false);
      }
      await Future.delayed(_scannerRestartDelay);
      if (!mounted) return;
      scannerController.start();
    }
  }

  void _abrirTeclado() {
    _manualController.clear();
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(24),
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
                  Icons.keyboard_alt_rounded,
                  color: Colors.blue,
                  size: 42,
                ),
              ),
              const SizedBox(height: 14),
              const Text(
                "Digitar código",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 220),
                  child: TextField(
                    controller: _manualController,
                    keyboardType: TextInputType.number,
                    maxLength: 10,
                    autofocus: true,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 23.5,
                      fontWeight: FontWeight.w500,
                    ),
                    decoration: InputDecoration(
                      hintText: "0000000000",
                      counterText: "",
                      isDense: true,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 10,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide:
                            const BorderSide(color: Colors.blue, width: 1.6),
                      ),
                    ),
                  ),
                ),
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
                      onPressed: () => Navigator.of(dialogContext).pop(),
                      child: const Text(
                        "Cancelar",
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
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      onPressed: () {
                        final txt = _manualController.text.trim();
                        if (txt.isEmpty) return;
                        Navigator.of(dialogContext).pop();
                        _salvarNoBanco(txt);
                      },
                      child: const Text(
                        "Salvar",
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
  }

  Widget _buildMira() {
    const double width = 280;
    const double height = 160;
    const double cornerSize = 28;
    const double strokeWidth = 4;
    const Color color = Colors.white;

    return SizedBox(
      width: width,
      height: height,
      child: Stack(
        children: [
          Positioned(
            top: 0,
            left: 0,
            child: _Corner(
                color: color,
                strokeWidth: strokeWidth,
                size: cornerSize,
                top: true,
                left: true),
          ),
          Positioned(
            top: 0,
            right: 0,
            child: _Corner(
                color: color,
                strokeWidth: strokeWidth,
                size: cornerSize,
                top: true,
                left: false),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            child: _Corner(
                color: color,
                strokeWidth: strokeWidth,
                size: cornerSize,
                top: false,
                left: true),
          ),
          Positioned(
            bottom: 0,
            right: 0,
            child: _Corner(
                color: color,
                strokeWidth: strokeWidth,
                size: cornerSize,
                top: false,
                left: false),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text("Scanner UFS"),
        backgroundColor: const Color(0xFF0055FF),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _abrirTeclado,
        backgroundColor: Colors.orange,
        child: const Icon(Icons.keyboard),
      ),
      body: Stack(
        children: [
          MobileScanner(
            controller: scannerController,
            onDetect: (capture) async {
              if (_isProcessing) return;

              if (capture.barcodes.isEmpty) {
                await _mostrarFalhaLeitura("(nenhum código identificado)");
                return;
              }

              final rawValue = capture.barcodes.first.rawValue;
              if (rawValue == null || rawValue.trim().isEmpty) {
                await _mostrarFalhaLeitura("(sem valor)");
                return;
              }

              await _salvarNoBanco(rawValue, fromScanner: true);
            },
          ),
          Center(child: _buildMira()),
          const Align(
            alignment: Alignment(0, 0.45),
            child: Text(
              "Aponte para o código de barras",
              style: TextStyle(
                color: Colors.white70,
                fontSize: 14,
                letterSpacing: 0.5,
              ),
            ),
          ),
          if (_isProcessing)
            Container(
              color: Colors.black54,
              child: const Center(
                child: CircularProgressIndicator(color: Colors.white),
              ),
            ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    scannerController.dispose();
    _manualController.dispose();
    player.dispose();
    super.dispose();
  }
}

class ValueListenableBuilder2<A, B> extends StatelessWidget {
  final ValueNotifier<A> first;
  final ValueNotifier<B> second;
  final Widget Function(BuildContext, A, B, Widget?) builder;

  const ValueListenableBuilder2({
    super.key,
    required this.first,
    required this.second,
    required this.builder,
  });

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<A>(
      valueListenable: first,
      builder: (context, a, _) {
        return ValueListenableBuilder<B>(
          valueListenable: second,
          builder: (context, b, child) => builder(context, a, b, child),
        );
      },
    );
  }
}

class _Corner extends StatelessWidget {
  final Color color;
  final double strokeWidth;
  final double size;
  final bool top;
  final bool left;

  const _Corner({
    required this.color,
    required this.strokeWidth,
    required this.size,
    required this.top,
    required this.left,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _CornerPainter(
          color: color,
          strokeWidth: strokeWidth,
          top: top,
          left: left,
        ),
      ),
    );
  }
}

class _CornerPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  final bool top;
  final bool left;

  _CornerPainter({
    required this.color,
    required this.strokeWidth,
    required this.top,
    required this.left,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.square;

    final path = Path();

    if (top && left) {
      path.moveTo(0, size.height);
      path.lineTo(0, 0);
      path.lineTo(size.width, 0);
    } else if (top && !left) {
      path.moveTo(0, 0);
      path.lineTo(size.width, 0);
      path.lineTo(size.width, size.height);
    } else if (!top && left) {
      path.moveTo(0, 0);
      path.lineTo(0, size.height);
      path.lineTo(size.width, size.height);
    } else {
      path.moveTo(0, size.height);
      path.lineTo(size.width, size.height);
      path.lineTo(size.width, 0);
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_CornerPainter oldDelegate) => false;
}
