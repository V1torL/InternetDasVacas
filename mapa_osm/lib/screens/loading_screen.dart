import 'package:flutter/material.dart';
import '../models/coordinate.dart';

class LoadingScreen extends StatefulWidget {
  const LoadingScreen({super.key});

  @override
  State<LoadingScreen> createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<LoadingScreen> {
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    carregarDados();
  }

  Future<void> carregarDados() async {
    final pontos =
        ModalRoute.of(context)?.settings.arguments as List<Coordinate>?;

    if (pontos == null || pontos.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Nenhum ponto recebido.')),
      );
      Navigator.pop(context);
      return;
    }

    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;
    Navigator.pushReplacementNamed(context, '/map', arguments: pontos);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            CircularProgressIndicator(),
            SizedBox(height: 20),
            Text('Carregando...'),
          ],
        ),
      ),
    );
  }
}
