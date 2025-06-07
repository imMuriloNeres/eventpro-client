import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../widgets/inscription_model.dart';
import '../screens/search_screen.dart';

class SubscriptionController extends ChangeNotifier {
  List<Inscription> _inscriptions = [];
  bool _isLoading = false;
  bool _isActionInProgress = false;

  List<Inscription> get inscriptions => _inscriptions;
  bool get isLoading => _isLoading;
  bool get isActionInProgress => _isActionInProgress;

  bool isSubscribed(String eventId) {
    return _inscriptions.any((insc) => insc.event.id == eventId && insc.status == 'confirmed');
  }

  Future<void> fetchSubscriptions(String userId) async {
    _isLoading = true;
    notifyListeners();
    try {
      final uri = Uri.parse('https://pi2025-1eventpro-production.up.railway.app/api/inscription?userId=$userId');
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final data = jsonDecode(utf8.decode(response.bodyBytes)) as List;
        _inscriptions = data.map((item) => Inscription.fromJson(item)).toList();
      } else {
        throw Exception('Falha ao carregar inscrições do usuário.');
      }
    } catch (e) {
      debugPrint("Erro em fetchSubscriptions: $e");
      _inscriptions = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> subscribeToEvent(Event event, String userId) async {
    if (isSubscribed(event.id) || _isActionInProgress) return false;
    _isActionInProgress = true;
    notifyListeners();

    try {
      final uri = Uri.parse('https://pi2025-1eventpro-production.up.railway.app/api/inscription');

      // =======================================================
      // CORREÇÃO APLICADA AQUI: Chave 'event' alterada para 'eventId'
      // =======================================================
      final body = jsonEncode({'eventId': event.id, 'userId': userId});
      
      final headers = {
        'Content-Type': 'application/json; charset=UTF-8',
        // 'Authorization': 'Bearer SEU_TOKEN_AQUI', // Adicione se sua API exigir
      };

      debugPrint("URL da Requisição: $uri");
      debugPrint("Corpo (Body) Enviado: $body");

      final response = await http.post(uri, headers: headers, body: body);

      debugPrint("Status da Resposta: ${response.statusCode}");
      debugPrint("Corpo da Resposta: ${response.body}");

      if (response.statusCode == 201) {
        await fetchSubscriptions(userId); 
        return true;
      }
      return false;
    } catch (e) {
      debugPrint("!! OCORREU UM ERRO NO CATCH: $e");
      return false;
    } finally {
      _isActionInProgress = false;
      notifyListeners();
    }
  }

  Future<bool> cancelSubscription(String eventId, String userId) async {
    if (!isSubscribed(eventId) || _isActionInProgress) return false;
    final inscription = _inscriptions.firstWhere((insc) => insc.event.id == eventId);
    
    _isActionInProgress = true;
    notifyListeners();
    try {
      final uri = Uri.parse('https://pi2025-1eventpro-production.up.railway.app/api/inscription/${inscription.id}/cancel');
      final response = await http.patch(uri, body: jsonEncode({'userId': userId}), headers: {'Content-Type': 'application/json; charset=UTF-8'});

      if (response.statusCode == 200) {
        _inscriptions.removeWhere((insc) => insc.id == inscription.id);
        return true;
      }
      return false;
    } catch (e) {
      debugPrint("Erro em cancelSubscription: $e");
      return false;
    } finally {
      _isActionInProgress = false;
      notifyListeners();
    }
  }
}
