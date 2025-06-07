import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:eventpro_app/models/user_model.dart';

class LoginController extends ChangeNotifier {
  bool isLoading = false;
  String? error;
  User? currentUser; 
  String? userId;

  Future<bool> login(String email, String password) async {
    isLoading = true;
    error = null;
    userId = null;
    notifyListeners();

    try {
      final response = await http.post(
        Uri.parse('https://pi2025-1eventpro-production.up.railway.app/api/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'email': email,
          'password': password,
        }),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseBody = json.decode(response.body);
        currentUser = User.fromJson(responseBody['user']);
        return true;
      } else if (response.statusCode == 404 || response.statusCode == 401) {
        final Map<String, dynamic> responseBody = json.decode(response.body);
        error = responseBody['message'] as String? ?? 'Credenciais inválidas';
        return false;
      } else {
        error = 'Erro desconhecido: ${response.statusCode}';
        return false;
      }
    } catch (e) {
      error = 'Erro de conexão: ${e.toString()}';
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  void logout() {
    currentUser = null;
    notifyListeners();
  }
}