import 'package:flutter/material.dart';
import 'event_create_modal.dart';

class EventCreateButton extends StatelessWidget {
  final VoidCallback? onEventCreated;
  final String? userId; 

  const EventCreateButton({
    super.key,
    this.onEventCreated,
    required this.userId, 
  });

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      backgroundColor: const Color(0xFF004AAD), 
      foregroundColor: Colors.white,          
      onPressed: () async {
        if (userId == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              backgroundColor: Colors.red,
              content: Text('Erro: ID do usuário não encontrado. Faça login novamente.'),
            ),
          );
          return;
        }

        final created = await showModalBottomSheet<bool>(
          context: context,
          isScrollControlled: true,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
          ),
          builder: (context) => EventCreateModal(userId: userId!), // Pass the ID
        );

        if (created == true && onEventCreated != null) {
          onEventCreated!();
        }
      },
      child: const Icon(Icons.add),
    );
  }
}