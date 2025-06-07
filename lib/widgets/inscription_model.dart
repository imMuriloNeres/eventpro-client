import 'package:eventpro_app/screens/search_screen.dart'; 

class Inscription {
  final String id;
  final String userId;
  final Event event;
  final String status; 
  final DateTime createdAt;

  Inscription({
    required this.id,
    required this.userId,
    required this.event,
    required this.status,
    required this.createdAt,
  });

  factory Inscription.fromJson(Map<String, dynamic> json) {
    if (json['id'] == null || json['_id'] == null) {
    }
    if (json['user'] == null) {
      throw ArgumentError('O campo "user" (userId) não pode ser nulo no JSON da inscrição.');
    }
    if (json['event'] == null) {
      throw ArgumentError('O objeto "event" não pode ser nulo no JSON da inscrição.');
    }
    if (json['createdAt'] == null) {
      throw ArgumentError('O campo "createdAt" não pode ser nulo no JSON da inscrição.');
    }

    return Inscription(
      id: json['id'] ?? json['_id'], 
      userId: json['user'],
      event: Event.fromJson(json['event']), 
      status: json['status'] ?? 'confirmed',
      createdAt: DateTime.parse(json['createdAt']),
    );
  }
}