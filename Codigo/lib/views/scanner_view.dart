import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:patrimonio_mobile/models/PatrimonioInventariado_model.dart';
import 'package:patrimonio_mobile/services/PatrimonioInventariado_service.dart'; // Importe seu service

class ScannerView extends StatefulWidget {
  final int idInventario;
  final int idSetor;
  const ScannerView({super.key, required this.idInventario, required this.idSetor});

  @override
  State<ScannerView> createState() => _ScannerViewState();
}

class _ScannerViewState extends State<ScannerView> {
  final PatrimonioinventariadoService _service = PatrimonioinventariadoService();

  void _aoDetectarCodigo(BarcodeCapture capture) async {
    final List<Barcode> barcodes = capture.barcodes;

    for (final barcode in barcodes) {
      if (barcode.rawValue != null) {
        final String codigoLido = barcode.rawValue!;

        final novoAtivo = PatrimonioInventariado(
          numero: codigoLido,
          idInventario: widget.idInventario,
          idSetor: widget.idSetor,
        );

        await _service.inserirPatrimonio(novoAtivo);

        debugPrint("Patrimônio $codigoLido salvo no setor ${widget.idSetor}");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Escanear Patrimônio")),
      body: MobileScanner(
        onDetect: _aoDetectarCodigo,
      ),
    );
  }
}