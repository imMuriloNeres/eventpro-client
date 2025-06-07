import 'dart:convert';
import 'package:eventpro_app/models/event_model.dart';
import 'package:eventpro_app/models/inscription_model.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class EventsController extends ChangeNotifier {
  bool _isLoading = false;
  String? _error;
  List<Event> _createdEvents = [];
  List<Inscription> _userInscriptions = [];

  bool get isLoading => _isLoading;
  String? get error => _error;
  List<Event> get createdEvents => _createdEvents;
  List<Inscription> get userInscriptions => _userInscriptions;

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }
  
  void _setError(String? err) {
    _error = err;
    notifyListeners();
  }

  Future<void> fetchAllData(String userId) async {
     _setLoading(true);
     _setError(null);
     await Future.wait([
       fetchMyCreatedEvents(userId),
       fetchMyInscriptions(userId),
     ]);
     _setLoading(false);
  }

  Future<void> fetchMyCreatedEvents(String userId) async {
    try {
      final response = await http.get(
        Uri.parse('https://pi2025-1eventpro-production.up.railway.app/api/event/created-by/$userId'),
      );
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        _createdEvents = data.map((json) => Event.fromJson(json)).toList();
      } else {
         _setError('Failed to load created events.');
      }
    } catch (e) {
       _setError('Error fetching created events: $e');
    }
    notifyListeners();
  }

  Future<void> fetchMyInscriptions(String userId) async {
    try {
      final response = await http.get(
        Uri.parse('https://pi2025-1eventpro-production.up.railway.app/api/inscription/user/$userId'),
      );
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        _userInscriptions = data.map((json) => Inscription.fromJson(json)).toList();
      } else {
        _setError('Failed to load inscriptions.');
      }
    } catch (e) {
      _setError('Error fetching inscriptions: $e');
    }
    notifyListeners();
  }

  Future<Map<String, dynamic>> validateCheckIn(String inscriptionId, String creatorId) async {
    return _validateEntryExit('validate-entry', inscriptionId, creatorId);
  }

  Future<Map<String, dynamic>> validateCheckOut(String inscriptionId, String creatorId) async {
     return _validateEntryExit('validate-exit', inscriptionId, creatorId);
  }

  Future<Map<String, dynamic>> _validateEntryExit(String path, String inscriptionId, String creatorId) async {
     _setLoading(true);
     _setError(null);
     try {
       final response = await http.post(
         Uri.parse('https://pi2025-1eventpro-production.up.railway.app/api/event/$path/$inscriptionId'),
         headers: {'Content-Type': 'application/json'},
         body: json.encode({'eventCreatorId': creatorId}),
       );
       final body = json.decode(response.body);
       if (response.statusCode == 200) {
         return {'success': true, 'message': body['message']};
       } else {
         _setError(body['message'] ?? 'An unknown error occurred');
         return {'success': false, 'message': _error};
       }
     } catch (e) {
       _setError('Connection error: $e');
       return {'success': false, 'message': _error};
     } finally {
       _setLoading(false);
     }
  }
}