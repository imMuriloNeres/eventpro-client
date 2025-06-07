import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

import 'package:eventpro_app/core/themes/app_colors.dart';
import '../controller/login_controller.dart';
import '../widgets/event_create_button.dart';
import '../widgets/evento_card.dart';
import '../widgets/filter_chip_widget.dart';

// Best Practice: This class should be in its own file, e.g., 'lib/models/event_model.dart'
class Event {
  final String name;
  final DateTime date;
  final String category;
  final String imageUrl;

  Event({
    required this.name,
    required this.date,
    required this.category,
    required this.imageUrl,
  });

  factory Event.fromJson(Map<String, dynamic> json) {
    return Event(
      name: json['name'] ?? 'Evento sem nome',
      date: DateTime.parse(json['date']),
      category: json['category'] ?? 'Geral',
      imageUrl: json['imageUrl'] ?? 'https://picsum.photos/240/120?random=${json['id'] ?? UniqueKey().toString()}',
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

  @override
  void initState() {
    super.initState();
    fetchEvents();
    searchController.addListener(() {
      applyFilterAndSearch();
    });
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  Future<void> fetchEvents() async {
    final uri = Uri.parse('https://pi2025-1eventpro-production.up.railway.app/api/event');
    
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final response = await http.get(uri).timeout(const Duration(seconds: 15));
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(utf8.decode(response.bodyBytes));
        if (mounted) {
          setState(() {
            allEvents = data.map((e) => Event.fromJson(e)).toList();
            applyFilterAndSearch();
            _isLoading = false;
          });
        }
      } else {
        throw Exception('Falha ao carregar eventos: ${response.statusCode}');
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = 'Não foi possível carregar os eventos. Tente novamente.';
          _isLoading = false;
        });
      }
    }
  }

  void applyFilterAndSearch() {
    setState(() {
      final searchText = searchController.text.toLowerCase();
      filteredEvents = allEvents.where((event) {
        final matchesFilter = selectedFilter == 'Todos' ||
            (event.category.toLowerCase() == selectedFilter.toLowerCase());
        
        final matchesSearch = event.name.toLowerCase().contains(searchText);

        return matchesFilter && matchesSearch;
      }).toList();
    });
  }

  void _onFilterSelected(String label) {
    setState(() {
      selectedFilter = label;
      applyFilterAndSearch();
    });
  }

  @override
  Widget build(BuildContext context) {
    // Get the userId from the provider
    final userId = Provider.of<LoginController>(context, listen: false).userId;

    return Scaffold(
      backgroundColor: Colors.white,
      floatingActionButton: EventCreateButton(
        userId: userId, // Pass the userId
        onEventCreated: fetchEvents,
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: fetchEvents,
          child: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSearchBar(),
                      const SizedBox(height: 16),
                      _buildFilterChips(),
                      const SizedBox(height: 24),
                      const Text(
                        'Eventos Recomendados',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              _buildEventList(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return TextField(
      controller: searchController,
      decoration: InputDecoration(
        hintText: 'Pesquisar eventos...',
        prefixIcon: const Icon(Icons.search, color: Colors.grey),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        filled: true,
        fillColor: Colors.grey[100],
      ),
    );
  }

  Widget _buildFilterChips() {
    final filters = ['Todos', 'Tecnologia', 'Música', 'Negócios', 'Games', 'Esportes'];
    return SizedBox(
      height: 40,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: filters.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final label = filters[index];
          return FilterChipWidget(
            label: label,
            selected: selectedFilter == label,
            onSelected: (bool selected) {
              _onFilterSelected(selected ? label : 'Todos');
            },
          );
        },
      ),
    );
  }

  Widget _buildEventList() {
    if (_isLoading) {
      return const SliverFillRemaining(child: Center(child: CircularProgressIndicator()));
    }

    if (_error != null) {
      return SliverFillRemaining(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(_error!, textAlign: TextAlign.center),
          ),
        ),
      );
    }

    if (filteredEvents.isEmpty) {
      return const SliverFillRemaining(child: Center(child: Text('Nenhum evento encontrado')));
    }

    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      sliver: SliverGrid(
        gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
          maxCrossAxisExtent: 250.0,
          mainAxisSpacing: 16.0,
          crossAxisSpacing: 16.0,
          childAspectRatio: 0.8,
        ),
        delegate: SliverChildBuilderDelegate(
          (BuildContext context, int index) {
            final event = filteredEvents[index];
            return EventoCard(
              title: event.name,
              date: formatDate(event.date),
              imageUrl: event.imageUrl,
            );
          },
          childCount: filteredEvents.length,
        ),
      ),
    );
  }

  String formatDate(DateTime date) {
    return '${date.day} de ${_monthName(date.month)} - ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}h';
  }

  String _monthName(int month) {
    const names = [
      'janeiro', 'fevereiro', 'março', 'abril', 'maio', 'junho',
      'julho', 'agosto', 'setembro', 'outubro', 'novembro', 'dezembro'
    ];
    return names[month - 1];
  }
}