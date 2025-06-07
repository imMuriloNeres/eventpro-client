import 'package:flutter/material.dart';
import 'event_create_modal.dart';

class EventCreateButton extends StatelessWidget {
  final VoidCallback? onEventCreated;
  final String? userId; // To receive the user ID

  const EventCreateButton({
    super.key,
    this.onEventCreated,
    required this.userId, // UserID is now required
  });

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      backgroundColor: const Color(0xFF004AAD),
      onPressed: () async {
        // Prevent opening modal if userId is not available for some reason.
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