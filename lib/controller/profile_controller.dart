import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:eventpro_app/models/user_model.dart';

class ProfileController extends ChangeNotifier {
  bool _isLoading = false;
  String? _error;
  User? _user;

  bool get isLoading => _isLoading;
  String? get error => _error;
  User? get user => _user;

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String? error) {
    _error = error;
    notifyListeners();
  }

  Future<void> fetchUserDetails(String userId) async {
    _setLoading(true);
    _setError(null);
    try {
      final response = await http.get(
        Uri.parse('https://pi2025-1eventpro-production.up.railway.app/api/user/$userId'),
      );

      if (response.statusCode == 200) {
        _user = User.fromJson(json.decode(response.body));
      } else {
        _setError('Erro ao buscar os detalhes do usuário: ${response.statusCode}');
      }
    } catch (e) {
      _setError('Erro de conexão: $e');
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> updateUserDetails(String userId, Map<String, dynamic> data) async {
    _setLoading(true);
    _setError(null);
    try {
      final response = await http.patch(
        Uri.parse('https://pi2025-1eventpro-production.up.railway.app/api/user/$userId'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(data),
      );

      if (response.statusCode == 200) {
        // Refetch user details to get the latest data
        await fetchUserDetails(userId);
        return true;
      } else {
        final body = json.decode(response.body);
        _setError(body['message'] ?? 'Erro ao atualizar o perfil.');
        return false;
      }
    } catch (e) {
      _setError('Erro de conexão: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> changePassword({
    required String email,
    required String userId,
    required String oldPassword,
    required String newPassword,
  }) async {
    _setLoading(true);
    _setError(null);

    try {
      // Step 1: Verify the old password by trying to log in
      final loginResponse = await http.post(
        Uri.parse('https://pi2025-1eventpro-production.up.railway.app/api/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'email': email, 'password': oldPassword}),
      );

      if (loginResponse.statusCode != 200) {
        _setError('A senha antiga está incorreta.');
        return false;
      }

      // Step 2: If the old password is correct, update to the new one
      final updateResponse = await http.patch(
        Uri.parse('https://pi2025-1eventpro-production.up.railway.app/api/user/$userId'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'password': newPassword}),
      );

      if (updateResponse.statusCode == 200) {
        return true;
      } else {
        final body = json.decode(updateResponse.body);
        _setError(body['message'] ?? 'Erro ao alterar a senha.');
        return false;
      }
    } catch (e) {
      _setError('Erro de conexão: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }
}