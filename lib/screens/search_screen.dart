import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

// Widgets e Controladores
import '../controller/login_controller.dart';
import '../widgets/event_create_button.dart';
import '../widgets/evento_card.dart';
import '../widgets/filter_chip_widget.dart';
import '../widgets/event_details_modal.dart';

// Modelo de Dados
class Event {
  final String id;
  final String organizerId;
  final String name;
  final String description;
  final List<String> categories;
  final DateTime date;
  final Map<String, dynamic> location;
  final Map<String, dynamic> capacity;
  final Map<String, dynamic> schedules;
  final double inscriptionPrice;
  final String imageUrl;

  Event({ required this.id, required this.organizerId, required this.name, required this.description, required this.categories, required this.date, required this.location, required this.capacity, required this.schedules, required this.inscriptionPrice, required this.imageUrl });

  factory Event.fromJson(Map<String, dynamic> json) {
    return Event(
      id: json['id'] ?? json['_id'] ?? UniqueKey().toString(),
      organizerId: json['organizerId'] ?? json['userId'] ?? '',
      name: json['name'] ?? 'Evento sem nome',
      description: json['description'] ?? 'Nenhuma descrição fornecida.',
      categories: List<String>.from(json['categories'] ?? (json['category'] != null ? [json['category']] : [])),
      date: DateTime.parse(json['date']),
      location: json['location'] ?? {},
      capacity: json['capacity'] ?? {},
      schedules: json['schedules'] ?? {},
      inscriptionPrice: (json['inscriptionPrice'] ?? (json['inscription']?[0]?['price'] ?? 0.0)).toDouble(),
      imageUrl: json['imageUrl'] ?? 'https://placehold.co/600x400/004AAD/FFFFFF/png?text=Evento',
    );
  }
}

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});
  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  List<Event> allEvents = [];
  List<Event> filteredEvents = [];
  bool _isLoading = true;
  String? _error;
  String selectedFilter = 'Todos';
  TextEditingController searchController = TextEditingController();
  List<String> _availableFilters = ['Todos'];

  @override
  void initState() {
    super.initState();
    fetchEvents();
    searchController.addListener(applyFilterAndSearch);
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  Future<void> fetchEvents() async {
    final uri = Uri.parse('https://pi2025-1eventpro-production.up.railway.app/api/event');
    if (!mounted) return;
    setState(() { _isLoading = true; _error = null; });
    try {
      final response = await http.get(uri).timeout(const Duration(seconds: 15));
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(utf8.decode(response.bodyBytes));
        if (mounted) {
          allEvents = data.map((e) => Event.fromJson(e)).toList();
          final allCategories = allEvents.expand((event) => event.categories).toSet().toList();
          allCategories.sort();
          
          setState(() {
            _availableFilters = ['Todos', ...allCategories];
            applyFilterAndSearch();
            _isLoading = false;
          });
        }
      } else {
        throw Exception('Falha ao carregar eventos: ${response.statusCode}');
      }
    } catch (e) {
      if (mounted) setState(() {
        _error = 'Não foi possível carregar os eventos. Tente novamente.';
        _isLoading = false;
      });
    }
  }

  void applyFilterAndSearch() {
    setState(() {
      final searchText = searchController.text.toLowerCase();
      filteredEvents = allEvents.where((event) {
        final matchesFilter = selectedFilter == 'Todos' || event.categories.any((cat) => cat.toLowerCase() == selectedFilter.toLowerCase());
        final matchesSearch = event.name.toLowerCase().contains(searchText);
        return matchesFilter && matchesSearch;
      }).toList();
    });
  }

  void _onFilterSelected(String label) {
    setState(() { selectedFilter = label; applyFilterAndSearch(); });
  }

  @override
  Widget build(BuildContext context) {
    final userId = Provider.of<LoginController>(context, listen: false).userId;
    return Scaffold(
      backgroundColor: Colors.white,
      floatingActionButton: EventCreateButton(userId: userId, onEventCreated: fetchEvents),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: fetchEvents,
          child: CustomScrollView(slivers: [
            SliverToBoxAdapter(child: Padding(padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              _buildSearchBar(),
              const SizedBox(height: 16),
              _buildFilterChips(),
              const SizedBox(height: 24),
              const Text('Eventos Encontrados', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: Colors.black87)),
            ]))),
            _buildEventList(),
          ]),
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return TextField(controller: searchController, decoration: InputDecoration(hintText: 'Pesquisar eventos...', prefixIcon: const Icon(Icons.search, color: Colors.grey), border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none), filled: true, fillColor: Colors.grey[100]));
  }

  Widget _buildFilterChips() {
    return SizedBox(height: 40, child: ListView.separated(
      scrollDirection: Axis.horizontal,
      itemCount: _availableFilters.length,
      separatorBuilder: (_, __) => const SizedBox(width: 8),
      itemBuilder: (context, index) {
        final label = _availableFilters[index];
        return FilterChipWidget(label: label, selected: selectedFilter == label, onSelected: (bool selected) => _onFilterSelected(selected ? label : 'Todos'));
      },
    ));
  }

  Widget _buildEventList() {
    if (_isLoading) return const SliverFillRemaining(child: Center(child: CircularProgressIndicator()));
    if (_error != null) return SliverFillRemaining(child: Center(child: Text(_error!)));
    if (filteredEvents.isEmpty) return const SliverFillRemaining(child: Center(child: Text('Nenhum evento encontrado para os filtros selecionados')));

    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      sliver: SliverGrid(
        gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(maxCrossAxisExtent: 250.0, mainAxisSpacing: 16.0, crossAxisSpacing: 16.0, childAspectRatio: 0.85),
        delegate: SliverChildBuilderDelegate((BuildContext context, int index) {
          final event = filteredEvents[index];
          final userId = Provider.of<LoginController>(context, listen: false).userId;
          return GestureDetector(
            onTap: () {
              showModalBottomSheet(context: context, isScrollControlled: true, backgroundColor: Colors.transparent, builder: (context) => Container(decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(16))), child: EventDetailsModal(event: event, userId: userId ?? '')))
              .then((value) { if (value == true) fetchEvents(); });
            },
            child: EventoCard(title: event.name, date: _formatEventCardDate(event.schedules), imageUrl: event.imageUrl),
          );
        }, childCount: filteredEvents.length),
      ),
    );
  }

  String _formatEventCardDate(Map<String, dynamic> schedule) {
    if (schedule['start'] == null || schedule['end'] == null) return 'Data não informada';
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