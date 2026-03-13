import 'package:flutter/material.dart';
import 'views/inventario_view.dart';

void main() async {
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
      home: const InventarioView(),
    );
  }
}
