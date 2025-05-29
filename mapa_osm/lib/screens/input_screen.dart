import 'package:flutter/material.dart';
import '../models/coordinate.dart';

class InputScreen extends StatefulWidget {
  const InputScreen({super.key});

  @override
  State<InputScreen> createState() => _InputScreenState();
}

class _InputScreenState extends State<InputScreen> {
  final List<Coordinate> pontos = [];

  final TextEditingController latController = TextEditingController();
  final TextEditingController lonController = TextEditingController();

  void adicionarPonto() {
    final double? lat = double.tryParse(latController.text);
    final double? lon = double.tryParse(lonController.text);

    if (lat != null && lon != null) {
      setState(() {
        pontos.add(Coordinate(latitude: lat, longitude: lon));
      });
      latController.clear();
      lonController.clear();
    }
  }

  void irParaMapa() {
    Navigator.pushNamed(context, '/loading', arguments: pontos);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Inserir Pontos')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: latController,
              decoration: const InputDecoration(labelText: 'Latitude'),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: lonController,
              decoration: const InputDecoration(labelText: 'Longitude'),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: adicionarPonto,
              child: const Text('Adicionar Ponto'),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: pontos.length,
                itemBuilder: (context, index) {
                  final ponto = pontos[index];
                  return ListTile(
                    title: Text(
                        'Lat: ${ponto.latitude}, Lon: ${ponto.longitude}'),
                  );
                },
              ),
            ),
            ElevatedButton(
              onPressed: pontos.isNotEmpty ? irParaMapa : null,
              child: const Text('Visualizar no Mapa'),
            ),
          ],
        ),
      ),
    );
  }
}
