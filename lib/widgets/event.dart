import 'package:intl/intl.dart';

class Event {
  final String id;
  final String name;
  final String description;
  final DateTime date;
  final String type;
  final String entryQrCode;
  final Location location;
  final Capacity capacity;
  final Schedule schedules;

  Event({
    required this.id,
    required this.name,
    required this.description,
    required this.date,
    required this.type,
    required this.entryQrCode,
    required this.location,
    required this.capacity,
    required this.schedules,
  });

  factory Event.fromJson(Map<String, dynamic> json) {
    return Event(
      id: json['_id'],
      name: json['name'],
      description: json['description'],
      date: DateTime.parse(json['date']),
      type: json['type'],
      entryQrCode: json['entryQrCode'] ?? '',
      location: Location.fromJson(json['location']),
      capacity: Capacity.fromJson(json['capacity']),
      schedules: Schedule.fromJson(json['schedules']),
    );
  }

  String get formattedDate {
    return DateFormat('dd/MM/yyyy').format(date);
  }

  String get formattedTime {
    return '${DateFormat('HH:mm').format(schedules.start)} - ${DateFormat('HH:mm').format(schedules.end)}';
  }
}

class Location {
  final String address;
  final String city;
  final String state;
  final String country;
  final String additionalInfo;

  Location({
    required this.address,
    required this.city,
    required this.state,
    required this.country,
    required this.additionalInfo,
  });

  factory Location.fromJson(Map<String, dynamic> json) {
    return Location(
      address: json['address'],
      city: json['city'],
      state: json['state'],
      country: json['country'],
      additionalInfo: json['additionalInfo'] ?? '',
    );
  }

  String get fullAddress {
    return '$address, $city - $state, $country';
  }
}

class Capacity {
  final int max;
  final int current;
  final int total;

  Capacity({
    required this.max,
    required this.current,
    required this.total,
  });

  factory Capacity.fromJson(Map<String, dynamic> json) {
    return Capacity(
      max: json['max'],
      current: json['current'],
      total: json['total'],
    );
  }
}

class Schedule {
  final DateTime start;
  final DateTime end;

  Schedule({
    required this.start,
    required this.end,
  });

  factory Schedule.fromJson(Map<String, dynamic> json) {
    return Schedule(
      start: DateTime.parse(json['start']),
      end: DateTime.parse(json['end']),
    );
  }
}