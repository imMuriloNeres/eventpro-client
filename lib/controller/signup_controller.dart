import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class SignupController extends ChangeNotifier {
  String? firstName;
  String? lastName;
  DateTime? dateOfBirth;
  String? email;
  String? cpf;
  String? phone;
  String? password;
  bool isLoading = false;
  String? error;

  Future<bool> registerUser() async {
    isLoading = true;
    notifyListeners();

    try {
      final response = await http.post(
        Uri.parse(
          'https://pi2025-1eventpro-production.up.railway.app/api/user',
        ),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          "name": firstName,
          "lastname": lastName,
          "dateOfBirth": dateOfBirth?.toIso8601String(),
          "email": email,
          "cpf": cpf,
          "phone": phone,
          "password": password,
        }),
      );

      if (response.statusCode == 201) {
        return true;
      } else {
        error = 'Erro ao cadastrar: ${response.statusCode}';
        return false;
      }
    } catch (e) {
      error = 'Erro de conexão: $e';
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  void clear() {
    firstName = null;
    lastName = null;
    dateOfBirth = null;
    email = null;
    cpf = null;
    phone = null;
    password = null;
    error = null;
    isLoading = false;
    notifyListeners();
  }
}
