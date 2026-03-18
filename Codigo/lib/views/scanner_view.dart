import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:patrimonio_mobile/models/PatrimonioInventariado_model.dart';
import 'package:patrimonio_mobile/services/PatrimonioInventariado_service.dart';

class ScannerView extends StatefulWidget {
  final int idInventario;
  final int idSetor;

  const ScannerView({super.key, required this.idInventario, required this.idSetor});

  @override
  State<ScannerView> createState() => _ScannerViewState();
}

class _ScannerViewState extends State<ScannerView> {
  final PatrimonioinventariadoService _service = PatrimonioinventariadoService();
  final MobileScannerController scannerController = MobileScannerController();
  final AudioPlayer player = AudioPlayer();
  final TextEditingController _manualController = TextEditingController();

  bool _isProcessing = false;
  String _statusMensagem = "Aponte para a etiqueta";
  Color _statusCor = Colors.white;

  Future<void> _salvarNoBanco(String codigo) async {
    if (_isProcessing) return;

    final codigoLimpo = codigo.trim();
    if (!RegExp(r'^\d{6}$').hasMatch(codigoLimpo)) {
      _notificar("Código inválido (6 dígitos)", Colors.orange);
      return;
    }

    setState(() => _isProcessing = true);

    try {
      // Feedback sonoro (Opcional, não trava se falhar)
      try { await player.play(AssetSource('sound/beep.mp3')); } catch (_) {}

      final novoAtivo = PatrimonioInventariado(
        numero: codigoLimpo,
        idInventario: widget.idInventario,
        idSetor: widget.idSetor,
      );

      await _service.inserirPatrimonio(novoAtivo);

      setState(() {
        _statusMensagem = "Salvo: $codigoLimpo";
        _statusCor = Colors.green;
      });

      await Future.delayed(const Duration(milliseconds: 800));
    } catch (e) {
      _notificar("Erro ao salvar no banco", Colors.red);
    } finally {
      if (mounted) setState(() {
        _isProcessing = false;
        _statusCor = Colors.white;
      });
    }
  }

  void _notificar(String msg, Color cor) {
    setState(() {
      _statusMensagem = msg;
      _statusCor = cor;
    });
  }

  void _abrirTeclado() {
    _manualController.clear();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Digitar Código"),
        content: TextField(
          controller: _manualController,
          keyboardType: TextInputType.number,
          maxLength: 6,
          decoration: const InputDecoration(hintText: "000000"),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancelar")),
          ElevatedButton(
            onPressed: () {
              final txt = _manualController.text;
              Navigator.pop(context);
              _salvarNoBanco(txt);
            },
            child: const Text("Salvar"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(title: const Text("Scanner UFS"), backgroundColor: const Color(0xFF0055FF)),
      floatingActionButton: FloatingActionButton(
        onPressed: _abrirTeclado,
        backgroundColor: Colors.orange,
        child: const Icon(Icons.keyboard),
      ),
      body: Stack(
        children: [
          MobileScanner(
            controller: scannerController,
            onDetect: (capture) {
              if (capture.barcodes.isNotEmpty) {
                _salvarNoBanco(capture.barcodes.first.rawValue ?? "");
              }
            },
          ),
          Center(
            child: Container(
              width: 280, height: 160,
              decoration: BoxDecoration(border: Border.all(color: _statusCor, width: 4), borderRadius: BorderRadius.circular(16)),
            ),
          ),
          Positioned(
            top: 40, left: 20, right: 20,
            child: Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(color: _statusCor.withOpacity(0.9), borderRadius: BorderRadius.circular(12)),
              child: Text(_statusMensagem, textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.bold)),
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