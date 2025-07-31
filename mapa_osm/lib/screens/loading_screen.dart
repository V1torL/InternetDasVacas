import 'package:flutter/material.dart';
import '../models/vehicle_marker.dart';

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
    final markers =
        ModalRoute.of(context)?.settings.arguments as List<VehicleMarker>?;

    if (markers == null || markers.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Nenhum marcador recebido.')),
      );
      Navigator.pop(context);
      return;
    }

    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;
    Navigator.pushReplacementNamed(context, '/map', arguments: markers);
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
            Text('Carregando ...'),
          ],
        ),
      ),
    );
  }
}