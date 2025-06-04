import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'hooks/auth_provider.dart';
import 'screens/home_screen.dart';
import 'screens/input_screen.dart';
import 'screens/loading_screen.dart';
import 'screens/map_screen.dart';
import 'screens/login_screen.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, auth, child) {
        return MaterialApp(
          title: 'Mapa com Flutter',
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            primarySwatch: Colors.blue,
          ),
          home: auth.isAuthenticated ? const HomeScreen() : const LoginScreen(),
          routes: {
            '/login': (context) => const LoginScreen(),
            '/home': (context) => const HomeScreen(),
            '/input': (context) => const InputScreen(),
            '/loading': (context) => const LoadingScreen(),
            '/map': (context) => const MapScreen(),
          },
        );
      },
    );
  }
}
