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

  /// Realiza a inscrição em um novo evento.
  /// Retorna null em caso de sucesso, ou uma String com a mensagem de erro em caso de falha.
  Future<String?> subscribeToEvent(Event event, String userId) async {
    // Retorna uma mensagem específica se o usuário já estiver inscrito.
    if (isSubscribed(event.id)) {
      return 'Você já está inscrito neste evento.';
    }
    if (_isActionInProgress) {
      return 'Aguarde, outra operação está em andamento.';
    }
    
    _isActionInProgress = true;
    notifyListeners();

    try {
      final uri = Uri.parse('https://pi2025-1eventpro-production.up.railway.app/api/inscription');
      final body = jsonEncode({'eventId': event.id, 'userId': userId});
      final headers = {'Content-Type': 'application/json; charset=UTF-8'};

      final response = await http.post(uri, headers: headers, body: body);

      if (response.statusCode == 201) {
        await fetchSubscriptions(userId); 
        return null; // Sucesso
      } else {
        // Retorna a mensagem de erro da API ou uma mensagem padrão.
        final errorBody = jsonDecode(response.body);
        return errorBody['message'] ?? 'Ocorreu um erro desconhecido.';
      }
    } catch (e) {
      debugPrint("!! OCORREU UM ERRO NO CATCH ao se inscrever: $e");
      return 'Erro de conexão. Tente novamente.';
    } finally {
      _isActionInProgress = false;
      notifyListeners();
    }
  }

  /// Cancela uma inscrição existente.
  /// Retorna null em caso de sucesso, ou uma String com a mensagem de erro em caso de falha.
  Future<String?> cancelSubscription(String eventId, String userId) async {
    if (!isSubscribed(eventId)) return 'Você não está inscrito neste evento.';
    if (_isActionInProgress) return 'Aguarde, outra operação está em andamento.';
    
    final inscription = _inscriptions.firstWhere((insc) => insc.event.id == eventId);
    
    _isActionInProgress = true;
    notifyListeners();
    try {
      final uri = Uri.parse('https://pi2025-1eventpro-production.up.railway.app/api/inscription/${inscription.id}/cancel');
      final response = await http.patch(uri, body: jsonEncode({'userId': userId}), headers: {'Content-Type': 'application/json; charset=UTF-8'});

      if (response.statusCode == 200) {
        _inscriptions.removeWhere((insc) => insc.id == inscription.id);
        return null; // Sucesso
      } else {
        final errorBody = jsonDecode(response.body);
        return errorBody['message'] ?? 'Ocorreu um erro desconhecido.';
      }
    } catch (e) {
      debugPrint("Erro em cancelSubscription: $e");
      return 'Erro de conexão. Tente novamente.';
    } finally {
      _isActionInProgress = false;
      notifyListeners();
    }
  }
}
