import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import 'package:eventpro_app/core/themes/app_colors.dart';
import '../controller/login_controller.dart';
import '../widgets/event_create_button.dart';
import '../widgets/evento_card.dart';
import '../widgets/event_details_modal.dart';
import '../screens/search_screen.dart'; // Importa a classe Event para o DetailsModal

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<dynamic> _recommendedEvents = [];
  List<dynamic> _featuredEvents = [];

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
            _recommendedEvents = allEvents.take(5).toList();
            _featuredEvents = allEvents.skip(5).toList();
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

  // =======================================================
  // CORREÇÃO APLICADA AQUI
  // =======================================================
  Future<void> _refreshEvents() async {
    await _fetchEvents();
  }

  @override
  Widget build(BuildContext context) {
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
            Text('Seja bem-vindo', style: Theme.of(context).textTheme.titleLarge?.copyWith(color: AppColors.textPrimary, fontWeight: FontWeight.bold)),
            Text('Explore os próximos eventos', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary)),
          ],
        ),
      ),
      floatingActionButton: EventCreateButton(userId: userId, onEventCreated: _refreshEvents),
      body: RefreshIndicator(
        onRefresh: _refreshEvents, // Agora a função tem a assinatura correta
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
      return Center(child: Padding(padding: const EdgeInsets.all(16.0), child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Text(_error!, textAlign: TextAlign.center, style: const TextStyle(color: Colors.red, fontSize: 16)),
        const SizedBox(height: 20),
        ElevatedButton(onPressed: _refreshEvents, style: ElevatedButton.styleFrom(backgroundColor: AppColors.bluePrimary), child: const Text('Tentar novamente', style: TextStyle(color: Colors.white))),
      ])));
    }
    return CustomScrollView(
      slivers: [
        _buildHorizontalCarouselSection(title: 'Eventos Recomendados', events: _recommendedEvents),
        ..._buildVerticalGridSection(title: 'Eventos em Destaque', events: _featuredEvents),
      ],
    );
  }

  Widget _buildHorizontalCarouselSection({required String title, required List<dynamic> events}) {
    if (events.isEmpty) return const SliverToBoxAdapter(child: SizedBox.shrink());
    final userId = Provider.of<LoginController>(context, listen: false).userId;
    return SliverToBoxAdapter(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 16.0),
            child: Text(title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
          ),
          SizedBox(height: 240, child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: events.length,
            itemBuilder: (context, index) {
              final eventData = events[index];
              final event = Event.fromJson(eventData as Map<String, dynamic>);
              final cardWidth = MediaQuery.of(context).size.width * 0.7;
              return Container(
                width: cardWidth,
                margin: EdgeInsets.only(right: index == events.length - 1 ? 0 : 16),
                child: GestureDetector(
                  onTap: () => _openDetailsModal(event, userId),
                  child: EventoCard(title: event.name, date: _formatEventCardDate(event.schedules), imageUrl: event.imageUrl),
                ),
              );
            },
          )),
        ],
      ),
    );
  }

  List<Widget> _buildVerticalGridSection({required String title, required List<dynamic> events}) {
    if (events.isEmpty) return [const SliverToBoxAdapter(child: SizedBox.shrink())];
    final userId = Provider.of<LoginController>(context, listen: false).userId;
    return [
      SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16.0, 24.0, 16.0, 16.0),
          child: Text(title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
        ),
      ),
      SliverPadding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        sliver: SliverGrid(
          gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(maxCrossAxisExtent: 250.0, mainAxisSpacing: 16.0, crossAxisSpacing: 16.0, childAspectRatio: 0.85),
          delegate: SliverChildBuilderDelegate((context, index) {
            final eventData = events[index];
            final event = Event.fromJson(eventData as Map<String, dynamic>);
            return GestureDetector(
              onTap: () => _openDetailsModal(event, userId),
              child: EventoCard(title: event.name, date: _formatEventCardDate(event.schedules), imageUrl: event.imageUrl),
            );
          }, childCount: events.length),
        ),
      ),
    ];
  }

  void _openDetailsModal(Event event, String? userId) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
        child: EventDetailsModal(event: event, userId: userId ?? ''),
      ),
    ).then((value) { if (value == true) _refreshEvents(); });
  }

  String _formatEventCardDate(Map<String, dynamic>? schedule) {
    if (schedule == null || schedule['start'] == null || schedule['end'] == null) return 'Data não informada';
    try {
      final start = DateTime.parse(schedule['start']);
      final end = DateTime.parse(schedule['end']);
      final dayFormat = DateFormat('dd \'de\' MMMM', 'pt_BR');
      final timeFormat = DateFormat('HH:mm', 'pt_BR');
      if (start.year == end.year && start.month == end.month && start.day == end.day) {
        return '${dayFormat.format(start)} • ${timeFormat.format(start)} às ${timeFormat.format(end)}h';
      }
      return '${DateFormat('dd/MM HH:mm', 'pt_BR').format(start)} até ${DateFormat('dd/MM HH:mm', 'pt_BR').format(end)}';
    } catch (e) {
      return 'Data inválida';
    }
  }
}