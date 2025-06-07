// lib/screens/events_screen.dart
import 'package:eventpro_app/controller/event_controller.dart';
import 'package:eventpro_app/controller/login_controller.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';

class EventsScreen extends StatefulWidget {
  const EventsScreen({super.key});

  @override
  State<EventsScreen> createState() => _EventsScreenState();
}

class _EventsScreenState extends State<EventsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final user = Provider.of<LoginController>(context, listen: false).currentUser;
      if (user?.id != null) {
        Provider.of<EventsController>(context, listen: false).fetchAllData(user!.id!);
      }
    });
  }
  
  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Meus Eventos"),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          indicatorColor: Colors.white,
          tabs: const [
            Tab(icon: Icon(Icons.star), text: "Eventos Criados"),
            Tab(icon: Icon(Icons.confirmation_number), text: "Minhas Inscrições"),
          ],
        ),
      ),
      body: Consumer<EventsController>(
        builder: (context, controller, child) {
          if (controller.isLoading && controller.createdEvents.isEmpty && controller.userInscriptions.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }
          if (controller.error != null) {
            return Center(child: Text("Erro: ${controller.error}"));
          }
          return TabBarView(
            controller: _tabController,
            children: [
              _buildCreatedEventsList(context),
              _buildMyInscriptionsList(context),
            ],
          );
        },
      ),
    );
  }

  Widget _buildCreatedEventsList(BuildContext context) {
    final controller = Provider.of<EventsController>(context);
    final creatorId = Provider.of<LoginController>(context, listen: false).currentUser?.id;

    if (controller.createdEvents.isEmpty) {
      return const Center(child: Text("Você ainda não criou nenhum evento."));
    }
    
    return ListView.builder(
      itemCount: controller.createdEvents.length,
      itemBuilder: (context, index) {
        final event = controller.createdEvents[index];
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          child: ExpansionTile(
            title: Text(event.name, style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text('Data: ${event.date.day}/${event.date.month}/${event.date.year}'),
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton.icon(
                      icon: const Icon(Icons.login),
                      label: const Text("Check-in"),
                      onPressed: () => _scanAndValidate('checkin', creatorId!, controller),
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                    ),
                    ElevatedButton.icon(
                      icon: const Icon(Icons.logout),
                      label: const Text("Check-out"),
                      onPressed: () => _scanAndValidate('checkout', creatorId!, controller),
                       style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
                    ),
                  ],
                ),
              )
            ],
          ),
        );
      },
    );
  }

  Future<void> _scanAndValidate(String type, String creatorId, EventsController controller) async {
    // Navigate to scanner and get result
    final inscriptionId = await context.push<String>('/qr_scanner');
    if (inscriptionId == null || inscriptionId.isEmpty) return;

    final result = type == 'checkin'
      ? await controller.validateCheckIn(inscriptionId, creatorId)
      : await controller.validateCheckOut(inscriptionId, creatorId);

    if (mounted) {
       ScaffoldMessenger.of(context).showSnackBar(
         SnackBar(
           content: Text(result['message']),
           backgroundColor: result['success'] ? Colors.green : Colors.red,
         ),
       );
    }
  }

  Widget _buildMyInscriptionsList(BuildContext context) {
    final controller = Provider.of<EventsController>(context);

    if (controller.userInscriptions.isEmpty) {
      return const Center(child: Text("Você não está inscrito em nenhum evento."));
    }

    return ListView.builder(
      itemCount: controller.userInscriptions.length,
      itemBuilder: (context, index) {
        final inscription = controller.userInscriptions[index];
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          child: ExpansionTile(
            title: Text(inscription.event.name, style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text('Status: ${inscription.status}'),
            children: [
               Padding(
                padding: const EdgeInsets.all(16.0),
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.qr_code_2),
                  label: const Text("Gerar QR Code de Entrada"),
                  onPressed: () => _showQrCodeDialog(context, inscription.id),
                ),
              )
            ],
          ),
        );
      },
    );
  }

  void _showQrCodeDialog(BuildContext context, String inscriptionId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Seu Ingresso"),
        content: SizedBox(
          width: 250,
          height: 250,
          child: QrImageView(
            data: inscriptionId,
            version: QrVersions.auto,
            size: 200.0,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text("Fechar"),
          )
        ],
      ),
    );
  }
}