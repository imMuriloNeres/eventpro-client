import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:eventpro_app/core/themes/app_colors.dart';
import 'package:provider/provider.dart'; // Import provider
import '../controller/login_controller.dart'; // Import your controller
import '../widgets/event_create_button.dart';
import '../widgets/evento_card.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<dynamic> _myEvents = [];
  List<dynamic> _featuredEvents = [];
  List<dynamic> _recommendedEvents = [];
  
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchEvents();
  }

  Future<void> _fetchEvents() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final uri = Uri.parse('https://pi2025-1eventpro-production.up.railway.app/api/event');
      final response = await http.get(
        uri,
        headers: {'Content-Type': 'application/json', 'Accept': 'application/json'},
      ).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final decodedResponse = jsonDecode(utf8.decode(response.bodyBytes));
        if (mounted && decodedResponse is List) {
          setState(() {
            final allEvents = List<dynamic>.from(decodedResponse);
            allEvents.shuffle();

            _myEvents = allEvents.take(5).toList();
            _featuredEvents = allEvents.skip(5).take(5).toList();
            _recommendedEvents = allEvents.skip(10).toList();
            _isLoading = false;
          });
        }
      } else {
        throw Exception('Falha ao carregar os dados da API');
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = 'Não foi possível carregar os eventos. Verifique sua conexão.';
          _isLoading = false;
        });
      }
    }
  }

  void _refreshEvents() {
    _fetchEvents();
  }

  @override
  Widget build(BuildContext context) {
    // Get the user ID from the LoginController provided in your widget tree.
    final userId = Provider.of<LoginController>(context, listen: false).userId;

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
              'Explore os próximos eventos',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondary,
                  ),
            ),
          ],
        ),
      ),
      floatingActionButton: EventCreateButton(
        userId: userId, // Pass the user ID
        onEventCreated: _refreshEvents,
      ),
      body: RefreshIndicator(
        onRefresh: _fetchEvents,
        color: AppColors.bluePrimary,
        child: _buildBody(),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator(color: AppColors.bluePrimary));
    }

    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(_error!, textAlign: TextAlign.center, style: const TextStyle(color: Colors.red, fontSize: 16)),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _refreshEvents,
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.bluePrimary),
                child: const Text('Tentar novamente', style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        ),
      );
    }
    
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildEventSection(title: 'Meus Eventos', events: _myEvents),
          _buildEventSection(title: 'Eventos em Destaque', events: _featuredEvents),
          _buildEventSection(title: 'Eventos Recomendados', events: _recommendedEvents),
        ],
      ),
    );
  }

  Widget _buildEventSection({required String title, required List<dynamic> events}) {
    if (events.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
        ),
        const SizedBox(height: 16),
        Container(
          height: 240,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: events.length,
            itemBuilder: (context, index) {
              final event = events[index];
              final imageUrl = event['imageUrl']?.toString() ?? 'https://picsum.photos/240/120?random=${event['id'] ?? index}';
              final cardWidth = MediaQuery.of(context).size.width * 0.6;

              return Container(
                width: cardWidth,
                margin: EdgeInsets.only(right: index == events.length - 1 ? 0 : 16),
                child: EventoCard(
                  title: event['name']?.toString() ?? 'Evento sem nome',
                  date: _formatDate(event['date']?.toString()),
                  imageUrl: imageUrl,
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  String _formatDate(String? dateString) {
    if (dateString == null || dateString.isEmpty) return 'Data não informada';
    try {
      final date = DateTime.parse(dateString);
      return '${date.day} de ${_monthName(date.month)} - ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}h';
    } catch (e) {
      return 'Data inválida';
    }
  }

  String _monthName(int month) {
    const names = ['janeiro', 'fevereiro', 'março', 'abril', 'maio', 'junho', 'julho', 'agosto', 'setembro', 'outubro', 'novembro', 'dezembro'];
    return names[month - 1];
  }
}