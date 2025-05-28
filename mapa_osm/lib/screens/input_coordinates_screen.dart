import 'package:flutter/material.dart';
import '../models/coordinate.dart';

class InputCoordinatesScreen extends StatefulWidget {
  const InputCoordinatesScreen({super.key});

  @override
  State<InputCoordinatesScreen> createState() => _InputCoordinatesScreenState();
}

class _InputCoordinatesScreenState extends State<InputCoordinatesScreen> {
  final List<Coordinate> coordinates = [];
  final TextEditingController latController = TextEditingController();
  final TextEditingController lngController = TextEditingController();

  void adicionarCoordenada() {
    final lat = double.tryParse(latController.text);
    final lng = double.tryParse(lngController.text);

    if (lat != null && lng != null) {
      setState(() {
        coordinates.add(Coordinate(latitude: lat, longitude: lng));
      });
      latController.clear();
      lngController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Inserir Coordenadas')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: latController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Latitude'),
            ),
            TextField(
              controller: lngController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Longitude'),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: adicionarCoordenada,
              child: const Text('Adicionar'),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: coordinates.length,
                itemBuilder: (context, index) {
                  final coord = coordinates[index];
                  return ListTile(
                    title: Text('Lat: ${coord.latitude}, Lng: ${coord.longitude}'),
                  );
                },
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(
                  context,
                  '/map',
                  arguments: coordinates,
                );
              },
              child: const Text('Ir para o Mapa'),
            )
          ],
        ),
      ),
    );
  }
}
