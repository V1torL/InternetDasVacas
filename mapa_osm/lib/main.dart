import 'package:flutter/material.dart';
import 'screens/home_screen.dart';
import 'screens/input_coordinates_screen.dart';
import 'screens/loading_screen.dart';
import 'screens/map_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'App de Mapas',
      theme: ThemeData(primarySwatch: Colors.blue),
      initialRoute: '/loading',
      routes: {
        '/': (context) => const HomeScreen(),
        '/input': (context) => const InputCoordinatesScreen(),
        '/map': (context) => const MapScreen(),
        '/loading': (context) => const LoadingScreen(),
      },
    );
  }
}
