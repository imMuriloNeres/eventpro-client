class Event {
  final String id;
  final String userId;
  final String name;
  final String description;
  final DateTime date;

  Event({
    required this.id,
    required this.userId,
    required this.name,
    required this.description,
    required this.date,
  });

  factory Event.fromJson(Map<String, dynamic> json) {
    return Event(
      id: json['_id'] as String,
      userId: json['userId'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      date: DateTime.parse(json['date'] as String),
    );
  }
}