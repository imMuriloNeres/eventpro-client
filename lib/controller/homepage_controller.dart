import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class HomePageController extends ChangeNotifier {
  List<Event> _events = [];
  bool _isLoading = false;
  String? _error;

  List<Event> get events => _events;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchEvents() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await http.get(
        Uri.parse('https://pi2025-1eventpro-production.up.railway.app/api/event'),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        _events = data.map((e) => Event.fromJson(e)).toList();
      } else {
        _error = 'Falha ao carregar eventos';
      }
    } catch (e) {
      _error = 'Erro de conexão: ${e.toString()}';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  String formatDate(DateTime date) {
    return '${date.day} de ${_monthName(date.month)} de ${date.year} - ${date.hour}h';
  }

  String _monthName(int month) {
    const names = [
      'janeiro',
      'fevereiro',
      'março',
      'abril',
      'maio',
      'junho',
      'julho',
      'agosto',
      'setembro',
      'outubro',
      'novembro',
      'dezembro'
    ];
    return names[month - 1];
  }
}

class Event {
  final String name;
  final DateTime date;

  Event({required this.name, required this.date});

  factory Event.fromJson(Map<String, dynamic> json) {
    return Event(
      name: json['name'],
      date: DateTime.parse(json['date']),
    );
  }
}