import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';
import '../screens/search_screen.dart';
import 'event_create_modal.dart';

class EventDetailsModal extends StatefulWidget {
  final Event event;
  final String userId;

  const EventDetailsModal({
    super.key,
    required this.event,
    required this.userId,
  });

  @override
  State<EventDetailsModal> createState() => _EventDetailsModalState();
}

class _EventDetailsModalState extends State<EventDetailsModal> {
  bool get isOrganizer => widget.event.organizerId == widget.userId;
  bool _isDeleting = false;

  void _subscribeToEvent() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(backgroundColor: Colors.green, content: Text('Inscrição realizada com sucesso!')),
    );
    Navigator.of(context).pop();
  }

  void _editEvent() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => EventCreateModal(
        userId: widget.userId,
        eventToEdit: widget.event,
      ),
    ).then((result) {
      if (result == true) {
        Navigator.of(context).pop(true);
      }
    });
  }

  Future<void> _performDelete() async {
    setState(() => _isDeleting = true);
    try {
      // ===================================================================
      // CORREÇÃO APLICADA AQUI: Aspas duplas para a interpolação funcionar
      // ===================================================================
      final uri = Uri.parse("https://pi2025-1eventpro-production.up.railway.app/api/event/${widget.event.id}");

      // Lembre-se de adicionar headers de autenticação se sua API exigir
      final response = await http.delete(uri);

      if (!mounted) return;
      if (response.statusCode == 200 || response.statusCode == 204) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(backgroundColor: Colors.green, content: Text('Evento excluído com sucesso!')),
        );
        Navigator.of(context).pop(true);
      } else {
        // Agora, o erro do backend será mais claro, se houver um
        final errorBody = jsonDecode(response.body);
        final errorMessage = errorBody['message'] ?? 'Falha ao excluir o evento.';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(backgroundColor: Colors.red, content: Text('$errorMessage (Cód: ${response.statusCode})')),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(backgroundColor: Colors.red, content: Text('Erro de conexão: $e')));
    } finally {
      if (mounted) setState(() => _isDeleting = false);
    }
  }

  void _deleteEvent() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Confirmar Exclusão'),
        content: const Text('Você tem certeza que deseja excluir este evento? Esta ação não pode ser desfeita.'),
        actions: [
          TextButton(child: const Text('Cancelar'), onPressed: () => Navigator.of(ctx).pop()),
          TextButton(
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            onPressed: () {
              Navigator.of(ctx).pop();
              _performDelete();
            },
            child: _isDeleting
                ? const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(strokeWidth: 2))
                : const Text('Excluir'),
          ),
        ],
      ),
    );
  }

  // O resto do arquivo (build, _buildHeaderImage, etc.) permanece o mesmo.
  // ...
  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
        initialChildSize: 0.9,
        minChildSize: 0.5,
        maxChildSize: 0.9,
        expand: false,
        builder: (_, scrollController) {
          return Column(
            children: [
              _buildHeaderImage(),
              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(widget.event.name, style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 24),
                      _buildInfoRow(Icons.calendar_today, 'Data e Hora', _formatSchedule(widget.event.schedules)),
                      _buildInfoRow(Icons.location_on, 'Localização', widget.event.location['address'] ?? 'Não informado'),
                      _buildInfoRow(Icons.category, 'Categorias', widget.event.categories.join(', ')),
                      _buildInfoRow(Icons.people, 'Capacidade', '${widget.event.capacity['max'] ?? 'Ilimitada'} pessoas'),
                      _buildInfoRow(Icons.sell, 'Preço', 'R\$ ${widget.event.inscriptionPrice.toStringAsFixed(2)}'),
                      const Divider(height: 32),
                      Text('Sobre o Evento', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      Text(widget.event.description, style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey.shade700)),
                      const SizedBox(height: 32),
                      _buildActionButtons(),
                    ],
                  ),
                ),
              ),
            ],
          );
        });
  }

  Widget _buildHeaderImage() {
    return Stack(children: [
      ClipRRect(borderRadius: const BorderRadius.vertical(top: Radius.circular(16)), child: Image.network(widget.event.imageUrl, height: 220, width: double.infinity, fit: BoxFit.cover, errorBuilder: (context, error, stackTrace) => Container(height: 220, color: Colors.grey, child: const Icon(Icons.error)))),
      Positioned(top: 10, right: 10, child: CircleAvatar(backgroundColor: Colors.black.withOpacity(0.5), child: IconButton(icon: const Icon(Icons.close, color: Colors.white), onPressed: () => Navigator.of(context).pop()))),
    ]);
  }

  Widget _buildInfoRow(IconData icon, String title, String content) {
    if (content.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Icon(icon, color: Theme.of(context).primaryColor, size: 20),
        const SizedBox(width: 16),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(content, style: TextStyle(color: Colors.grey.shade700)),
        ])),
      ]),
    );
  }

  Widget _buildActionButtons() {
    if (isOrganizer) {
      return Row(children: [
        Expanded(child: OutlinedButton.icon(icon: const Icon(Icons.delete_outline), label: const Text('Excluir'), onPressed: _deleteEvent, style: OutlinedButton.styleFrom(foregroundColor: Colors.red, side: const BorderSide(color: Colors.red), padding: const EdgeInsets.symmetric(vertical: 12)))),
        const SizedBox(width: 16),
        Expanded(child: ElevatedButton.icon(icon: const Icon(Icons.edit), label: const Text('Editar'), onPressed: _editEvent, style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 12)))),
      ]);
    } else {
      return SizedBox(width: double.infinity, child: ElevatedButton(onPressed: _subscribeToEvent, style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 14), backgroundColor: const Color(0xFF004AAD), foregroundColor: Colors.white), child: const Text('Inscrever-se', style: TextStyle(fontSize: 16))));
    }
  }

  String _formatSchedule(Map<String, dynamic> schedule) {
    try {
      final start = DateTime.parse(schedule['start']);
      final end = DateTime.parse(schedule['end']);
      return '${DateFormat.yMMMMd('pt_BR').format(start)}, das ${DateFormat.Hm('pt_BR').format(start)} às ${DateFormat.Hm('pt_BR').format(end)}';
    } catch (e) {
      return 'Data não informada';
    }
  }
}