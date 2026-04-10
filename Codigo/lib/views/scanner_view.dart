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

  bool _ehDuplicado(Object erro) =>
      erro is DuplicatePatrimonioException ||
      erro.toString().toLowerCase().contains('já cadastrado') ||
      erro.toString().toLowerCase().contains('ja cadastrado') ||
      erro.toString().toLowerCase().contains('já existe') ||
      erro.toString().toLowerCase().contains('ja existe') ||
      erro.toString().toLowerCase().contains('duplicate');

  Future<void> _mostrarPopup({
    required String titulo,
    required String codigo,
    required Color cor,
    required IconData icone,
  }) async {
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Ícone com fundo colorido
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: cor.withOpacity(0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(icone, color: cor, size: 42),
              ),
              const SizedBox(height: 14),
              Text(
                titulo,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: cor,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              // Caixa com o código
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
                  onPressed: () => Navigator.pop(context),
                  child: const Text(
                    "OK",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _mostrarFalhaLeitura(String codigo) async {
    if (_isProcessing) return;

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
      scannerController.start();
    }
  }

  Future<void> _salvarNoBanco(String codigo, {bool fromScanner = false}) async {
    // Guard contra múltiplos disparos
    if (_isProcessing) return;

    final codigoLimpo = codigo.trim();

    if (!_codigoValido(codigoLimpo)) {
      if (fromScanner) {
        await _mostrarFalhaLeitura(codigoLimpo.isEmpty ? "(vazio)" : codigoLimpo);
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

      final novoAtivo = PatrimonioInventariado(
        numero: codigoLimpo,
        idInventario: widget.idInventario,
        idSetor: widget.idSetor,
      );

      await _service.inserirPatrimonio(novoAtivo);

      await _mostrarPopup(
        titulo: "Patrimônio salvo",
        codigo: codigoLimpo,
        cor: Colors.green,
        icone: Icons.check_circle_rounded,
      );
    } on DuplicatePatrimonioException {
      await _mostrarPopup(
        titulo: "Patrimônio já cadastrado",
        codigo: codigoLimpo,
        cor: Colors.amber,
        icone: Icons.warning_amber_rounded,
      );
    } catch (e) {
      if (_ehDuplicado(e)) {
        //tratar caso de duplicidade fora do padrão
        await _mostrarPopup(
          titulo: "Patrimônio já cadastrado",
          codigo: codigoLimpo,
          cor: Colors.amber,
          icone: Icons.warning_amber_rounded,
        );
      } else {
        await _mostrarPopup(
          titulo: "Erro ao salvar",
          codigo: codigoLimpo,
          cor: Colors.red,
          icone: Icons.error_rounded,
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isProcessing = false);
      }
      await Future.delayed(_scannerRestartDelay);
      scannerController.start();
    }
  }

  void _abrirTeclado() {
    _manualController.clear();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text("Digitar Código"),
        content: TextField(
          controller: _manualController,
          keyboardType: TextInputType.number,
          maxLength: 10,
          decoration: const InputDecoration(
            hintText: "0000000000",
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancelar"),
          ),
          ElevatedButton(
            onPressed: () {
              final txt = _manualController.text.trim();
              if (txt.isEmpty) return;
              Navigator.pop(context);
              _salvarNoBanco(txt);
            },
            child: const Text("Salvar"),
          ),
        ],
      ),
    );
  }

  //Mira com cantos
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
          // Câmera
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

          // Mira
          Center(child: _buildMira()),

          // Instrução
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

//Canto da mira
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
