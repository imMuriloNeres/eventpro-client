import 'package:eventpro_app/screens/search_screen.dart'; // Importa a classe Event

class Inscription {
  final String id;
  final String userId;
  final Event event;
  final String status; // ex: "confirmed", "cancelled"
  final DateTime createdAt;

  Inscription({
    required this.id,
    required this.userId,
    required this.event,
    required this.status,
    required this.createdAt,
  });

  /// Construtor de fábrica para criar uma instância de Inscription a partir de um mapa JSON.
  /// Isso é usado para decodificar a resposta da sua API.
  factory Inscription.fromJson(Map<String, dynamic> json) {
    // Verifica se os campos essenciais não são nulos para evitar erros
    if (json['id'] == null || json['_id'] == null) {
      // '_id' é comumente usado por MongoDB/Mongoose
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
      id: json['id'] ?? json['_id'], // Compatível com 'id' ou '_id'
      userId: json['user'],
      // Assume que o objeto completo do evento vem aninhado dentro da inscrição
      event: Event.fromJson(json['event']), 
      status: json['status'] ?? 'confirmed',
      createdAt: DateTime.parse(json['createdAt']),
    );
  }
}