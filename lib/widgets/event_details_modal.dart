import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../controller/subscription_controller.dart';
import '../screens/search_screen.dart';
import 'event_create_modal.dart';

class EventDetailsModal extends StatelessWidget {
  final Event event;
  final String userId;

  const EventDetailsModal({
    super.key,
    required this.event,
    required this.userId,
  });

  bool get isOrganizer => event.organizerId == userId;

  void _deleteEvent(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Confirmar Exclusão'),
        content: const Text('Você tem certeza que deseja excluir este evento?'),
        actions: [
          TextButton(child: const Text('Cancelar'), onPressed: () => Navigator.of(ctx).pop()),
          TextButton(
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Excluir'),
            onPressed: () async {
              Navigator.of(ctx).pop(); // Fecha o diálogo
              final uri = Uri.parse("https://pi2025-1eventpro-production.up.railway.app/api/event/${event.id}");
              final response = await http.delete(uri, headers: {'Content-Type': 'application/json'}, body: jsonEncode({'userId': userId}));
              if (response.statusCode == 200 && context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(backgroundColor: Colors.green, content: Text('Evento excluído!')));
                Navigator.of(context).pop(true);
              } else if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(backgroundColor: Colors.grey.shade700, content: const Text('Falha ao excluir evento.')));
              }
            },
          ),
        ],
      ),
    );
  }

  void _editEvent(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => EventCreateModal(userId: userId, eventToEdit: event),
    ).then((result) {
      if (result == true) Navigator.of(context).pop(true);
    });
  }

  @override
  Widget build(BuildContext context) {
    final subscriptionController = context.watch<SubscriptionController>();
    final isUserSubscribed = subscriptionController.isSubscribed(event.id);

    return DraggableScrollableSheet(
      initialChildSize: 0.9,
      minChildSize: 0.5,
      maxChildSize: 0.9,
      expand: false,
      builder: (_, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
          ),
          child: Column(
            children: [
              _buildHeaderImage(context),
              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(event.name, style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      if (isUserSubscribed)
                        const Chip(
                          avatar: Icon(Icons.check_circle, color: Colors.white, size: 18),
                          label: Text('Inscrito'),
                          backgroundColor: Colors.green,
                          labelStyle: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                      const SizedBox(height: 16),
                      _buildInfoRow(context, Icons.calendar_today, 'Data e Hora', _formatSchedule(event.schedules)),
                      _buildInfoRow(context, Icons.location_on, 'Localização', event.location['address'] ?? 'Não informado'),
                      const Divider(height: 32),
                      Text('Sobre o Evento', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      Text(event.description, style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey.shade700)),
                      const SizedBox(height: 32),
                      _buildActionButtons(context, isUserSubscribed),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildActionButtons(BuildContext context, bool isUserSubscribed) {
    final subscriptionController = context.read<SubscriptionController>();
    final isLoading = context.watch<SubscriptionController>().isActionInProgress;

    if (isOrganizer) {
      return Row(children: [
        Expanded(child: OutlinedButton.icon(icon: const Icon(Icons.delete_outline), label: const Text('Excluir'), onPressed: () => _deleteEvent(context), style: OutlinedButton.styleFrom(foregroundColor: Colors.red, side: const BorderSide(color: Colors.red), padding: const EdgeInsets.symmetric(vertical: 12)))),
        const SizedBox(width: 16),
        Expanded(child: ElevatedButton.icon(icon: const Icon(Icons.edit), label: const Text('Editar'), onPressed: () => _editEvent(context), style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 12)))),
      ]);
    }

    if (isUserSubscribed) {
      return SizedBox(
        width: double.infinity,
        child: OutlinedButton.icon(
          icon: const Icon(Icons.cancel_outlined),
          label: const Text('Cancelar Inscrição', style: TextStyle(fontSize: 16)),
          onPressed: isLoading ? null : () async {
            // Lógica de Cancelamento Atualizada
            final errorMessage = await subscriptionController.cancelSubscription(event.id, userId);
            if (context.mounted) {
              if (errorMessage == null) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(backgroundColor: Colors.green, content: Text('Inscrição cancelada.')));
              } else {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(backgroundColor: Colors.grey.shade700, content: Text(errorMessage)));
              }
            }
          },
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 14),
            foregroundColor: Colors.red,
            side: const BorderSide(color: Colors.red),
          ),
        ),
      );
    } else {
      return SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: isLoading ? null : () async {
            // Lógica de Inscrição Atualizada
            final errorMessage = await subscriptionController.subscribeToEvent(event, userId);
            if (context.mounted) {
              if (errorMessage == null) { // null significa sucesso
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(backgroundColor: Colors.green, content: Text('Inscrição realizada com sucesso!')));
              } else { // Se não for null, é uma mensagem de erro
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(backgroundColor: Colors.grey.shade700, content: Text(errorMessage)));
              }
            }
          },
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 14),
            backgroundColor: const Color(0xFF004AAD),
            foregroundColor: Colors.white,
          ),
          child: isLoading 
            ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3))
            : const Text('Inscrever-se', style: TextStyle(fontSize: 16)),
        ),
      );
    }
  }

  // --- Widgets Auxiliares (sem alteração) ---
  Widget _buildHeaderImage(BuildContext context) => Stack(children: [ ClipRRect(borderRadius: const BorderRadius.vertical(top: Radius.circular(16)), child: Image.network(event.imageUrl, height: 220, width: double.infinity, fit: BoxFit.cover, errorBuilder: (c, e, s) => Container(height: 220, color: Colors.grey, child: const Icon(Icons.error)))), Positioned(top: 10, right: 10, child: CircleAvatar(backgroundColor: Colors.black.withOpacity(0.5), child: IconButton(icon: const Icon(Icons.close, color: Colors.white), onPressed: () => Navigator.of(context).pop()))) ]);
  Widget _buildInfoRow(BuildContext context, IconData icon, String title, String content) => Padding(padding: const EdgeInsets.only(bottom: 16.0), child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [ Icon(icon, color: Theme.of(context).primaryColor, size: 20), const SizedBox(width: 16), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [ Text(title, style: const TextStyle(fontWeight: FontWeight.bold)), const SizedBox(height: 4), Text(content, style: TextStyle(color: Colors.grey.shade700))])) ]));
  String _formatSchedule(Map<String, dynamic> schedule) { try { final start = DateTime.parse(schedule['start']); final end = DateTime.parse(schedule['end']); return '${DateFormat.yMMMMd('pt_BR').format(start)}, das ${DateFormat.Hm('pt_BR').format(start)} às ${DateFormat.Hm('pt_BR').format(end)}'; } catch (e) { return 'Data não informada'; } }
}