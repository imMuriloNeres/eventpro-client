import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../widgets/event_create_button.dart';
import '../widgets/evento_card.dart';
import '../widgets/filter_chip_widget.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  late Future<List<Event>> futureEvents;
  List<Event> allEvents = [];
  List<Event> filteredEvents = [];

  String selectedFilter = 'Todos';
  String searchText = '';

  @override
  void initState() {
    super.initState();
    futureEvents = fetchEvents();
  }

  Future<List<Event>> fetchEvents() async {
    final response = await http.get(Uri.parse('http://localhost:3000/api/events'));
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      final events = data.map((e) => Event.fromJson(e)).toList();
      allEvents = events;
      filteredEvents = List.from(allEvents);
      return events;
    } else {
      throw Exception('Falha ao carregar eventos');
    }
  }

  void applyFilter() {
    setState(() {
      filteredEvents = allEvents.where((event) {
        final matchesFilter = selectedFilter == 'Todos' ||
            event.category.toLowerCase() == selectedFilter.toLowerCase();
        final matchesSearch = event.name.toLowerCase().contains(searchText.toLowerCase());
        return matchesFilter && matchesSearch;
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      floatingActionButton: EventCreateButton(
        onEventCreated: () {
          setState(() {
            futureEvents = fetchEvents();
          });
        },
    ),

      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Barra de pesquisa com ícone de notificação
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              decoration: InputDecoration(
                                hintText: 'Pesquisar eventos...',
                                prefixIcon: const Icon(Icons.search),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                filled: true,
                                fillColor: Colors.grey[100],
                              ),
                              onChanged: (value) {
                                searchText = value;
                                applyFilter();
                              },
                            ),
                          ),
                          const SizedBox(width: 12),
                          IconButton(
                            icon: const Icon(Icons.notifications_none),
                            onPressed: () {},
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      // Filtros
                      SizedBox(
                        height: 40,
                        child: ListView(
                          scrollDirection: Axis.horizontal,
                          children: [
                            _buildFilterChip('Todos'),
                            _buildFilterChip('Tecnologia'),
                            _buildFilterChip('Música'),
                            _buildFilterChip('Negócios'),
                            _buildFilterChip('Games'),
                            _buildFilterChip('Esportes'),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Meus eventos
                      const Text(
                        'Meus eventos',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        height: 200,
                        child: FutureBuilder<List<Event>>(
                          future: futureEvents,
                          builder: (context, snapshot) {
                            if (snapshot.connectionState == ConnectionState.waiting) {
                              return const Center(child: CircularProgressIndicator());
                            } else if (snapshot.hasError) {
                              return Center(child: Text('Erro: ${snapshot.error}'));
                            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                              return const Center(child: Text('Nenhum evento encontrado'));
                            } else {
                              // Para "Meus eventos", aqui vamos mostrar só os que o usuário participou
                              // Como não temos isso, vamos usar os 5 primeiros para exemplo
                              final meusEventos = snapshot.data!.take(5).toList();

                              return ListView.separated(
                                scrollDirection: Axis.horizontal,
                                itemCount: meusEventos.length,
                                separatorBuilder: (_, __) => const SizedBox(width: 12),
                                itemBuilder: (context, index) {
                                  final event = meusEventos[index];
                                  return EventoCard(
                                    title: event.name,
                                    date: formatDate(event.date),
                                  );
                                },
                              );
                            }
                          },
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Eventos recomendados - com filtro e busca aplicados
                      const Text(
                        'Eventos recomendados',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        height: 200,
                        child: filteredEvents.isEmpty
                            ? const Center(child: Text('Nenhum evento encontrado'))
                            : ListView.separated(
                                scrollDirection: Axis.horizontal,
                                itemCount: filteredEvents.length,
                                separatorBuilder: (_, __) => const SizedBox(width: 12),
                                itemBuilder: (context, index) {
                                  final event = filteredEvents[index];
                                  return EventoCard(
                                    title: event.name,
                                    date: formatDate(event.date),
                                  );
                                },
                              ),
                      ),
                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }


  Widget _buildFilterChip(String label) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChipWidget(
        label: label,
        selected: selectedFilter == label,
        onSelected: (bool selected) {
          setState(() {
            selectedFilter = selected ? label : 'Todos';
            applyFilter();
          });
        },
      ),
    );
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
  final String category;

  Event({
    required this.name,
    required this.date,
    required this.category,
  });

  factory Event.fromJson(Map<String, dynamic> json) {
    return Event(
      name: json['name'],
      date: DateTime.parse(json['date']),
      category: json['category'] ?? 'Todos',
    );
  }
}
