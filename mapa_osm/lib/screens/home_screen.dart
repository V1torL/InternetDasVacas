import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('App de Mapas')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              child: const Text('Inserir Coordenadas'),
              onPressed: () {
                Navigator.pushNamed(context, '/input');
              },
            ),
            ElevatedButton(
              child: const Text('Visualizar no Mapa'),
              onPressed: () {
                Navigator.pushNamed(context, '/map');
              },
            ),
          ],
        ),
      ),
    );
  }
}
