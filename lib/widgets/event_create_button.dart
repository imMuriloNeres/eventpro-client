import 'package:flutter/material.dart';
import 'event_create_modal.dart';

class EventCreateButton extends StatelessWidget {
  final VoidCallback? onEventCreated;

  const EventCreateButton({super.key, this.onEventCreated});

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      backgroundColor: const Color(0xFF004AAD),
      onPressed: () async {
        final created = await showModalBottomSheet<bool>(
          context: context,
          isScrollControlled: true,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
          ),
          builder: (context) => const EventCreateModal(),
        );
        if (created == true && onEventCreated != null) {
          onEventCreated!();
        }
      },
      child: const Icon(Icons.add),
    );
  }
}
