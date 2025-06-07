import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:eventpro_app/core/themes/app_colors.dart';
import '../widgets/event_create_button.dart';
import '../widgets/evento_card.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<dynamic> _events = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchEvents();
  }

  Future<void> _fetchEvents() async {
    try {
      // Tentativa com endpoint alternativo
      final uri = Uri.parse('https://pi2025-1eventpro-production.up.railway.app/apievents');

      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final decodedResponse = jsonDecode(utf8.decode(response.bodyBytes));
        if (decodedResponse is List) {
          // CORREÇÃO: Verificar se o widget está montado antes de chamar setState
          if (mounted) {
            setState(() {
              _events = decodedResponse;
              _isLoading = false;
              _error = null;
            });
          }
          return;
        }
      }

      // Se falhar, tentar o endpoint original com tratamento especial
      await _tryFallbackEndpoint();
    } catch (e) {
      // CORREÇÃO: Verificar se o widget está montado antes de chamar setState
      if (mounted) {
        setState(() {
          _error = 'Não foi possível carregar os eventos. Tente novamente mais tarde.';
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _tryFallbackEndpoint() async {
    try {
      final uri = Uri.parse('https://pi2025-1eventpro-production.up.railway.app/api/event');
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final decodedResponse = jsonDecode(response.body);
        // CORREÇÃO: Verificar se o widget está montado antes de chamar setState
        if (mounted) {
          setState(() {
            _events = decodedResponse is List ? decodedResponse : [];
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      throw Exception('Serviço indisponível no momento');
    }
  }

  void _refreshEvents() {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    _fetchEvents();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Seja bem-vindo',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.bold,
                  ),
            ),
            Text(
              'Comece a explorar os eventos',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondary,
                  ),
            ),
          ],
        ),
      ),
      floatingActionButton: EventCreateButton(
        onEventCreated: _refreshEvents,
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          color: AppColors.bluePrimary,
        ),
      );
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              _error!,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.red, fontSize: 16),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _refreshEvents,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.bluePrimary,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
              child: const Text(
                'Tentar novamente',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      );
    }

    if (_events.isEmpty) {
      return const Center(
        child: Text(
          'Nenhum evento encontrado',
          style: TextStyle(color: Colors.grey, fontSize: 16),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _fetchEvents,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _events.length,
        itemBuilder: (context, index) {
          final event = _events[index];
          return EventoCard(
            title: event['name']?.toString() ?? 'Evento sem nome',
            date: _formatDate(event['date']?.toString()),
          );
        },
      ),
    );
  }

  String _formatDate(String? dateString) {
    if (dateString == null || dateString.isEmpty) return 'Data não informada';

    try {
      final date = DateTime.parse(dateString);
      return '${date.day} de ${_monthName(date.month)} de ${date.year} - ${date.hour}h';
    } catch (e) {
      return 'Data inválida';
    }
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