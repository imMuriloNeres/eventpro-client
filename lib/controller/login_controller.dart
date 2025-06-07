import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/user_model.dart';

class LoginController extends ChangeNotifier {
  bool isLoading = false;
  String? error;
  User? currentUser;

  String? get userId => currentUser?.id;

  Future<bool> login(String email, String password) async {
    isLoading = true;
    error = null;
    notifyListeners();

    try {
      final response = await http.post(
        Uri.parse('https://pi2025-1eventpro-production.up.railway.app/api/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'email': email, 'password': password}),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseBody = json.decode(response.body);
        
        // Check if the 'user' key exists and is not null
        if (responseBody.containsKey('user') && responseBody['user'] != null) {
          currentUser = User.fromJson(responseBody['user']);
          notifyListeners();
          return true;
        } else {
          error = 'Resposta de login inválida do servidor.';
          return false;
        }
      } else {
        // Handle specific error messages from the API
        final Map<String, dynamic> responseBody = json.decode(response.body);
        error = responseBody['message'] as String? ?? 'Credenciais inválidas ou erro desconhecido.';
        return false;
      }
    } catch (e) {
      error = 'Erro de conexão. Verifique sua rede e tente novamente.';
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
  void logout() {
    currentUser = null;
    error = null;
    notifyListeners();
  }
}
