import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class LoginController extends ChangeNotifier {
  bool isLoading = false;
  String? error;
  String? userId; // Stores the logged-in user's ID

  Future<bool> login(String email, String password) async {
    isLoading = true;
    error = null;
    userId = null; // Reset on new login attempt
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
        final responseData = json.decode(response.body);
        
        // IMPORTANT: Adjust keys ('user', 'id') to match your actual API response.
        if (responseData.containsKey('user') && responseData['user'].containsKey('id')) {
          userId = responseData['user']['id'];
          notifyListeners(); // Notify listeners that userId is available
          return true;
        } else {
          error = 'Resposta de login inválida do servidor.';
          return false;
        }
      } else {
        error = 'Credenciais inválidas';
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
}