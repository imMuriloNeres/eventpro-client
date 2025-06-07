// lib/models/inscription_model.dart
import 'package:eventpro_app/models/event_model.dart';
import 'package:eventpro_app/models/user_model.dart';

class Inscription {
  final String id;
  final User user;
  final Event event;
  final String status;
  final String participationStatus;

  Inscription({
    required this.id,
    required this.user, 
    required this.event,
    required this.status,
    required this.participationStatus,
  });

  factory Inscription.fromJson(Map<String, dynamic> json) {
    return Inscription(
      id: json['_id'] as String,
      user: User.fromJson(json['userId'] as Map<String, dynamic>),
      event: Event.fromJson(json['eventId'] as Map<String, dynamic>),
      status: json['status'] as String,
      participationStatus: json['participation_status'] as String,
    );
  }
}