// lib/controller/login_controller.dart
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:eventpro_app/models/user_model.dart'; // Importar o modelo de usuário

class LoginController extends ChangeNotifier {
  bool isLoading = false;
  String? error;
  User? currentUser; // Adicionando a propriedade para o usuário logado

  Future<bool> login(String email, String password) async {
    isLoading = true;
    error = null;
    notifyListeners();

    try {
      final response = await http.post(
        Uri.parse('https://pi2025-1eventpro-production.up.railway.app/api/auth/login'), // Use a URL da API do Railway
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'email': email,
          'password': password,
        }),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseBody = json.decode(response.body);
        currentUser = User.fromJson(responseBody['user']); // Armazena o usuário logado
        return true;
      } else if (response.statusCode == 404 || response.statusCode == 401) {
        final Map<String, dynamic> responseBody = json.decode(response.body);
        error = responseBody['message'] as String? ?? 'Credenciais inválidas'; // Mensagem da API
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