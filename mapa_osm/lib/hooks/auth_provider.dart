import 'package:flutter/material.dart';

class AuthProvider with ChangeNotifier {
  bool _isAuthenticated = false;

  bool get isAuthenticated => _isAuthenticated;

  Future<void> login(String email, String password) async {
    if (email == "admin@example.com" && password == "123456") {
      _isAuthenticated = true;
      notifyListeners();
    } else {
      throw Exception('Email ou senha inválidos');
    }
  }

  void logout() {
    _isAuthenticated = false;
    notifyListeners();
  }
}
