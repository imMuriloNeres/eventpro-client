// lib/models/user_model.dart
class User {
  final String? id;
  final String name;
  final String lastname;
  final String email;
  final DateTime? dateOfBirth;
  final String? cpf;
  final String? phone;

  User({
    this.id,
    required this.name,
    required this.lastname,
    required this.email,
    this.dateOfBirth,
    this.cpf,
    this.phone,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      // Handles both 'id' from login response and '_id' from user endpoint response
      id: json['_id'] as String? ?? json['id'] as String?,
      name: json['name'] as String,
      lastname: json['lastname'] as String,
      email: json['email'] as String,
      dateOfBirth: json['dateOfBirth'] != null
          ? DateTime.parse(json['dateOfBirth'])
          : null,
      cpf: json['cpf'] as String?,
      phone: json['phone'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'lastname': lastname,
      'email': email,
      'dateOfBirth': dateOfBirth?.toIso8601String(),
      'cpf': cpf,
      'phone': phone,
    };
  }
}