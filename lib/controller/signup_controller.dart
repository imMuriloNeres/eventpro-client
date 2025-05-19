import 'package:flutter/material.dart';

class SignupController extends ChangeNotifier {
  String? firstName;
  String? lastName;
  String? password;
  DateTime? dateOfBirth;
  String? cpf;
  String? phone;
  String? email;

  void update({
    String? firstName,
    String? lastName,
    String? password,
    DateTime? dateOfBirth,
    String? cpf,
    String? phone,
    String? email,
  }) {
    this.firstName = firstName ?? this.firstName;
    this.lastName = lastName ?? this.lastName;
    this.password = password ?? this.password;
    this.dateOfBirth = dateOfBirth ?? this.dateOfBirth;
    this.cpf = cpf ?? this.cpf;
    this.phone = phone ?? this.phone;
    this.email = email ?? this.email;
    notifyListeners();
  }

  void setName(String value) {
    firstName = value;
    notifyListeners();
  }

  void setLastName(String value) {
    lastName = value;
    notifyListeners();
  }

  void setPassword(String value) {
    password = value;
    notifyListeners();
  }

  void setDateOfBirth(DateTime value) {
    dateOfBirth = value;
    notifyListeners();
  }

  void setCpf(String value) {
    cpf = value;
    notifyListeners();
  }

  void setPhone(String value) {
    phone = value;
    notifyListeners();
  }

  void setEmail(String value) {
    email = value;
    notifyListeners();
  }


  Map<String, dynamic> toJson() {
    return {
      "name": firstName,
      "lastname": lastName,
      "password": password,
      "dateOfBirth": dateOfBirth?.toIso8601String(),
      "cpf": cpf,
      "phone": phone,
      "email": email,
    };
  }
}
