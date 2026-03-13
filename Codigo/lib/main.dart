import 'package:flutter/material.dart';
import 'package:patrimonio_mobile/views/instituicao_view.dart';
import 'package:patrimonio_mobile/views/scanner_view.dart';

void main() async {
  // Garante que os widgets do Flutter estejam inicializados antes de abrir o banco
  WidgetsFlutterBinding.ensureInitialized();
  // Garante que os widgets do Flutter estejam inicializados antes de abrir o banco
  WidgetsFlutterBinding.ensureInitialized();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Controle de Patrimônio'),
        backgroundColor: Colors.blue,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.qr_code_scanner, size: 100, color: Colors.blue),
            const SizedBox(height: 30),
            const Text(
              'Pronto para Inventariar?',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              icon: const Icon(Icons.camera_alt),
              label: const Text('ABRIR SCANNER'),
              style: ElevatedButton.styleFrom(
                padding:
                    const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
              ),
              onPressed: () {
                // NAVEGAÇÃO: Chama a View do Scanner passando IDs fictícios para teste
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ScannerView(
                      idInventario: 1, // ID de teste
                      idSetor: 1, // ID de teste
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              icon: const Icon(Icons.foundation),
              label: const Text('ABRIR INSTITUIÇÕES'),
              style: ElevatedButton.styleFrom(
                padding:
                    const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const InstituicaoView(),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
