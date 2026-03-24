import 'package:flutter/material.dart';
import 'home_view.dart'; // Import correto da sua Home
import '../services/database_helper.dart'; // Import do seu helper de banco

class SplashView extends StatefulWidget {
  const SplashView({super.key});

  @override
  State<SplashView> createState() => _SplashViewState();
}

class _SplashViewState extends State<SplashView> {
  @override
  void initState() {
    super.initState();
    _inicializarApp();
  }

  Future<void> _inicializarApp() async {

    final tempoMinimo = Future.delayed(const Duration(milliseconds: 800));

    final carregarBanco = DatabaseHelper.instance.database;

    await Future.wait([tempoMinimo, carregarBanco]);

    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const HomeView()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Color(0xFFF1F4F8),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inventory_2, size: 80, color: Colors.blue),
            SizedBox(height: 20),
            Text(
              "Patrimônio Mobile",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.blueGrey),
            ),
            SizedBox(height: 10),
            SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.blue),
            ),
          ],
        ),
      ),
    );
  }
}