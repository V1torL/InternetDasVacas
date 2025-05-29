import 'package:flutter/material.dart';
import 'screens/home_screen.dart';
import 'screens/input_screen.dart';
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
      title: 'Mapa com Flutter',
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      routes: {
        '/': (context) => const HomeScreen(),
        '/input': (context) => const InputScreen(),
        '/loading': (context) => const LoadingScreen(),
        '/map': (context) => const MapScreen(),
      },
    );
  }
}
