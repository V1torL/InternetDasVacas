import 'package:flutter/material.dart';

class LoadingScreen extends StatefulWidget {
  final Widget nextScreen;
  final String? message;
  
  const LoadingScreen({
    super.key,
    required this.nextScreen,
    this.message,
  });

  @override
  State<LoadingScreen> createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<LoadingScreen> {
  @override
    void initState() {
      super.initState();
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => widget.nextScreen),
          );
        }
      });
    }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 20),
            Text(widget.message ?? 'Carregando...'),
          ],
        ),
      ),
    );
  }
}